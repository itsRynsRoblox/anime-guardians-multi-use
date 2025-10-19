#Requires AutoHotkey v2.0

StartPortals() {
    if (PortalRoleDropdown.Text != "Guest") {
        OpenInventory("Portals")
        FixClick(485, 270) ; Click the search bar
        Sleep (500)
        SendInput(PortalDropdown.Text) ; Type the selected portal
        Sleep (500)
        TryPortals(false, true)
    } else {
        AddToLog("Attempting to join portal")
        while (!SuccessfullyJoinedPortal()) {
            Walk("e", 800)
        }
        AddToLog("Joined portal, waiting for host to start")
        WaitForMapChange()
        RestartStage()
    }
}

HandlePortalEnd(isVictory := true) {
    if (PortalRoleDropdown.Text != "Guest") {
        if (isVictory) {
            AddToLog(PortalDropdown.Text " Portal completed successfully, starting next portal...")
            ClickReplay()
            Sleep (500)
            FixClick(485, 270) ; Click the search bar
            Sleep (500)
            SendInput(PortalDropdown.Text) ; Type the selected portal
            Sleep (500)
            TryPortals(true, true)
        } else {
            AddToLog(PortalDropdown.Text " Portal failed, retrying...")
            ClickReplay()
            FixClick(485, 270) ; Click the search bar
            Sleep (500)
            SendInput(PortalDropdown.Text) ; Type the selected portal
            Sleep (500)
            TryPortals(true, true)
        }
    } else {
        if (isVictory) {
            AddToLog(PortalDropdown.Text " Portal completed successfully")
        } else {
            AddToLog(PortalDropdown.Text " Portal failed, waiting for host to start next portal")
        }
        WaitForMapChange()
    }
    return RestartStage()
}

IsValidPortal(x, y, inGame := false) {
    Sleep(1000)  ; Allow UI to fully update

    pixelChecks := [{ color: 0x32DD00, x: 100, y: 70, disabledInGame: true }, { color: 0x248FFE, x: 100, y: 100 }]

    for pixel in pixelChecks {
        ; Skip check if this pixel is disabled in-game
        if (inGame && pixel.HasOwnProp("disabledInGame") && pixel.disabledInGame) {
            continue
        }

        checkX := x + pixel.x
        checkY := y + pixel.y

        if GetPixel(pixel.color, checkX, checkY, 4, 4, 20) {
            return true
        }
    }
}

TryPortals(inGame := false, usingPixel := false) {

    ; Get selected portal from dropdown
    selectedPortal := PortalDropDown.Text

    if (usingPixel) {
        ; Map of available portal names to their portal data/patterns
        portalMaps := Map(
            "Marine Ford", MarineFordPortal,
            "Demon District", DemonDistrictPortal
        )

        ; Check if the selected portal exists in the map
        if portalMaps.Has(selectedPortal) {
            portalType := portalMaps[selectedPortal]
            success := SearchAndStartPortal(selectedPortal, portalType, inGame)
            if (success) {
                return true
            } else {
                AddToLog(selectedPortal " portal not found..")
            }
        } else {
            AddToLog("Unknown portal selected: " selectedPortal)
        }
    } else {
        success := SearchAndStartPortal(selectedPortal, portalType, inGame)
        if (success) {
            return true
        } else {
            AddToLog(selectedPortal " portal not found..")
        }
    }
    HandleNoPortal(inGame)
}

HandleNoPortal(inGame := false) {
    AddToLog("No portal detected, shutting down...")
    Sleep(2000)
    return Reload()
}

SearchAndStartPortal(mapName, portalText, inGame := false) {
    AddToLog("Searching for " StrReplace(mapName, "_", " ") " Portals...")
    xOffsets := [200, 280, 360, 440, 520, 600]
    yOffsets := [325, 395]

    searchFunc := FindText

    for portalY in yOffsets {
        for portalX in xOffsets {
            MouseMove(portalX, portalY, 1)
            Sleep 500
            wiggle()
            FixClick(portalX, portalY)
            Sleep 500

            ok := IsValidPortal(portalX, portalY, inGame)

            if (ok) {
                AddToLog("Found " StrReplace(mapName, "_", " ") " Portal, attempting to start...")
                Sleep 500
                ClickUsePortal(portalX, portalY, inGame)
                if (!inGame) {
                    if (PortalRoleDropdown.Text = "Host") {
                        AddToLog("Waiting 15 seconds for others to join")
                        Sleep(15000)
                    }
                    WaitForMapChange()
                    return RestartStage()
                } else {
                    if (!inGame) {
                        FixClick(345, 314) ; Click Yes
                    }
                    WaitForMapChange()
                    return RestartStage()
                }
            } else {
                if (FarmMorePortals.Value) {
                    if (isInLobby() && !isInGame) {
                        SwitchActiveFarm()
                        return StartSelectedMode()
                    } else {
                        FixClick(657, 231) ; Close inventory interface
                        Sleep(1000)
                        FixClick(428, 132) ; Reopen end screen
                        Sleep(1000)
                        SwitchActiveFarm()
                        return ClickReturnToLobby()
                    }
                }
            }
        }
    }
}

ClickUsePortal(x, y, inGame := false, testing := false) {
    pixelChecks := [{ color: 0x32DD00, x: 100, y: 70, disabledInGame: true }, { color: 0x248FFE, x: 100, y: 100 }]

    for pixel in pixelChecks {
        ; Skip check if this pixel is disabled in-game
        if (inGame && pixel.HasOwnProp("disabledInGame") && pixel.disabledInGame) {
            continue
        }

        checkX := x + pixel.x
        checkY := y + pixel.y

        if GetPixel(pixel.color, checkX, checkY, 4, 4, 20) {
            FixClick(checkX, checkY, (testing ? "Right" : "Left"))
            Sleep(1000)
            if (!inGame) {
                FixClick(327, 372) ; Open Portal
            }
            if (testing) {
                Sleep(1500)
            }
            return
        } else if (testing) {
            MouseMove(checkX, checkY)
        }
    }
}

SuccessfullyJoinedPortal() {
    return FindText(&X, &Y, 289, 496, 521, 553, 0.05, 0.05, GuestUICheck)
}

WaitForMapChange() {
    while (isInLobby() || isMenuOpen("End Screen")) {
        Sleep(1000)
    }
}

GetMapForFarming(portalName) {
    farmMap := Map(
        "Demon District", "Demon District",
        "Marine Ford", "Marine Ford"
    )
    return farmMap.Get(portalName, "")  ; returns "" if not found
}

SetMapForPortalFarm(name, isStory := false) {
    if (isStory) {
        ModeDropdown.Text := "Story"
        StoryActDropdown.Text := "Infinite"
        StoryDropdown.Text := String(name)
    } else {
        ModeDropdown.Text := "Portal"
        PortalDropdown.Text := String(name)
        PortalRoleDropdown.Text := "Solo"
    }
}

SwitchActiveFarm() {
    if (ModeDropdown.Text = "Story") {
        selectedPortal := StoryDropdown.Text
        newMap := GetMapForFarming(selectedPortal)
        if (newMap != "") {
            SetMapForPortalFarm(newMap, false)
            AddToLog("Switched to " newMap " Portals")
            if (debugMessages) {
                AddToLog("Mode: " ModeDropdown.Text)
                AddToLog("Portal: " PortalDropdown.Text)
                AddToLog("Join Type: " PortalRoleDropdown.Text)
            }
        } else if (debugMessages) {
            AddToLog("No valid portal mapping found for: " selectedPortal)
        }
    } else {
        newMap := GetMapForFarming(PortalDropdown.Text)
        if (newMap != "no map found") {
            SetMapForPortalFarm(newMap, true)
            AddToLog("Switched to " newMap " for farming portals")
            if (debugMessages) {
                AddToLog("Mode: " ModeDropdown.Text)
                AddToLog("Story Act: " StoryActDropdown.Text)
                AddToLog("Story: " StoryDropdown.Text)
            }
        } else {
            if (debugMessages) {
                AddToLog("No valid story mapping found for " PortalDropdown.Text)
            }
        }
    }
}