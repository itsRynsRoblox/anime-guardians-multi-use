#Requires AutoHotkey v2.0
#Include Image.ahk
global macroStartTime := A_TickCount
global stageStartTime := A_TickCount

LoadKeybindSettings()  ; Load saved keybinds
Hotkey(F1Key, (*) => moveRobloxWindow())
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
Hotkey(F4Key, (*) => TogglePause())

StartMacro(*) {
    if (!ValidateMode()) {
        return
    }
    StartSelectedMode()
}

TogglePause(*) {
    Pause -1
    if (A_IsPaused) {
        AddToLog("Macro Paused")
        Sleep(1000)
    } else {
        AddToLog("Macro Resumed")
        Sleep(1000)
    }
}

PlacingUnits() {
    global successfulCoordinates
    successfulCoordinates := []
    placedCounts := Map()  

    anyEnabled := false
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        if (enabled) {
            anyEnabled := true
            break
        }
    }

    if (!anyEnabled) {
        AddToLog("No units enabled - skipping to monitoring")
        return MonitorStage()
    }

    placementPoints := PlacementPatternDropdown.Text = "Circle" ? GenerateCirclePoints() : PlacementPatternDropdown.Text = "Grid" ? GenerateGridPoints() : PlacementPatternDropdown.Text = "Spiral" ? GenerateSpiralPoints() : PlacementPatternDropdown.Text = "Up and Down" ? GenerateUpandDownPoints() : GenerateRandomPoints()
    
    ; Go through each slot
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        
        ; Get number of placements wanted for this slot
        placements := "placement" slotNum
        placements := %placements%
        placements := Integer(placements.Text)
        
        ; Initialize count if not exists
        if !placedCounts.Has(slotNum)
            placedCounts[slotNum] := 0
        
        ; If enabled, place all units for this slot
        if (enabled && placements > 0) {
            AddToLog("Placing Unit " slotNum " (0/" placements ")")
            ; Place all units for this slot
            while (placedCounts[slotNum] < placements) {
                for point in placementPoints {
                    ; Skip if this coordinate was already used successfully
                    alreadyUsed := false
                    for coord in successfulCoordinates {
                        if (coord.x = point.x && coord.y = point.y) {
                            alreadyUsed := true
                            break
                        }
                    }
                    if (alreadyUsed)
                        continue
                
                    if PlaceUnit(point.x, point.y, slotNum) {
                        successfulCoordinates.Push({x: point.x, y: point.y, slot: slotNum})
                        placedCounts[slotNum] += 1
                        AddToLog("Placed Unit " slotNum " (" placedCounts[slotNum] "/" placements ")")
                        CheckAbility()
                        FixClick(560, 560) ; Move Click
                        break
                    }
                    
                    if CheckForXp()
                        return MonitorStage()
                    Reconnect()
                    CheckEndAndRoute()
                }
                Sleep(500)
            }
        }
    }
    
    AddToLog("All units placed to requested amounts")
    UpgradeUnits()
}

CheckForXp() {
    ; Check for lobby text
    if (ok := FindText(&X, &Y, 340, 369, 437, 402, 0, 0, XpText) or (ok:=FindText(&X, &Y, 539, 155, 760, 189, 0, 0, XpText2))) {
        FixClick(325, 185)
        FixClick(560, 560)
        return true
    }
    return false
}


UpgradeUnits() {
    global successfulCoordinates, PriorityUpgrade, priority1, priority2, priority3, priority4, priority5, priority6

    totalUnits := Map()    
    upgradedCount := Map()  
    
    ; Initialize counters
    for coord in successfulCoordinates {
        if (!totalUnits.Has(coord.slot)) {
            totalUnits[coord.slot] := 0
            upgradedCount[coord.slot] := 0
        }
        totalUnits[coord.slot]++
    }

    AddToLog("Initiating Unit Upgrades...")

    if (PriorityUpgrade.Value) {
        AddToLog("Using priority upgrade system")
        
        ; Go through each priority level (1-6)
        for priorityNum in [1, 2, 3, 4, 5, 6] {
            ; Find which slot has this priority number
            for slot in [1, 2, 3, 4, 5, 6] {
                priority := "priority" slot
                priority := %priority%
                if (priority.Text = priorityNum) {
                    ; Skip if no units in this slot
                    hasUnitsInSlot := false
                    for coord in successfulCoordinates {
                        if (coord.slot = slot) {
                            hasUnitsInSlot := true
                            break
                        }
                    }
                    
                    if (!hasUnitsInSlot) {
                        continue
                    }

                    AddToLog("Starting upgrades for priority " priorityNum " (slot " slot ")")
                    
                    ; Keep upgrading current slot until all its units are maxed
                    while true {
                        slotDone := true
                        
                        for index, coord in successfulCoordinates {
                            if (coord.slot = slot) {
                                slotDone := false
                                UpgradeUnit(coord.x, coord.y)

                                if CheckForXp() {
                                    AddToLog("Stage ended during upgrades, proceeding to results")
                                    successfulCoordinates := []
                                    MonitorStage()
                                    return
                                }

                                if MaxUpgrade() {
                                    upgradedCount[coord.slot]++
                                    AddToLog("Max upgrade reached for Unit " coord.slot " (" upgradedCount[coord.slot] "/" totalUnits[coord.slot] ")")
                                    successfulCoordinates.RemoveAt(index)
                                    FixClick(325, 185) ;Close upg menu
                                    break
                                }

                                Sleep(200)
                                CheckAbility()
                                FixClick(560, 560) ; Move Click
                                Reconnect()
                                CheckEndAndRoute()
                            }
                        }
                        
                        if (slotDone || successfulCoordinates.Length = 0) {
                            AddToLog("Finished upgrades for priority " priorityNum)
                            break
                        }
                    }
                }
            }
        }
        
        AddToLog("Priority upgrading completed")
        return MonitorStage()
    } else {
        ; Normal upgrade (no priority)
        while true {
            if (successfulCoordinates.Length == 0) {
                AddToLog("All units maxed, proceeding to monitor stage")
                return MonitorStage()
            }

            for index, coord in successfulCoordinates {
                UpgradeUnit(coord.x, coord.y)

                if CheckForXp() {
                    AddToLog("Stage ended during upgrades, proceeding to results")
                    successfulCoordinates := []
                    MonitorStage()
                    return
                }

                if MaxUpgrade() {
                    upgradedCount[coord.slot]++
                    AddToLog("Max upgrade reached for Unit " coord.slot " (" upgradedCount[coord.slot] "/" totalUnits[coord.slot] ")")
                    successfulCoordinates.RemoveAt(index)
                    FixClick(325, 185) ;Close upg menu
                    continue
                }

                Sleep(200)
                CheckAbility()
                FixClick(560, 560) ; Move Click
                Reconnect()
                CheckEndAndRoute()
            }
        }
    }
}

ChallengeMode() {    
    AddToLog("Moving to Challenge mode")
    ChallengeMovement()
    
    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, Story)) {
        ChallengeMovement()
    }

    RestartStage()
}

StoryMode() {
    global StoryDropdown, StoryActDropdown
    
    ; Get current map and act
    currentStoryMap := StoryDropdown.Text
    currentStoryAct := StoryActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentStoryMap)
    StoryMovement()
    
    ; Start stage
    while !(ok:=FindText(&X, &Y, 390-150000, 464-150000, 390+150000, 464+150000, 0, 0, StoryUI)) {
        StoryMovement()
    }
    AddToLog("Starting " currentStoryMap " - " currentStoryAct)
    StartStory(currentStoryMap, currentStoryAct)

    ; Handle play mode selection
    PlayHere()
    RestartStage()
}


LegendMode() {
    global LegendDropdown, LegendActDropdown
    
    ; Get current map and act
    currentLegendMap := LegendDropdown.Text
    currentLegendAct := LegendActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentLegendMap)
    StoryMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, Story)) {
        StoryMovement()
    }
    AddToLog("Starting " currentLegendMap " - " currentLegendAct)
    StartLegend(currentLegendMap, currentLegendAct)

    ; Handle play mode selection
    if (MatchMaking.Value) {
        FindMatch()
    } else {
        PlayHere()
    }

    RestartStage()
}

RaidMode() {
    global RaidDropdown, RaidActDropdown
    
    ; Get current map and act
    currentRaidMap := RaidDropdown.Text
    currentRaidAct := RaidActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentRaidMap)
    RaidMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, Story)) {
        RaidMovement()
    }
    AddToLog("Starting " currentRaidMap " - " currentRaidAct)
    StartRaid(currentRaidMap, currentRaidAct)
    ; Handle play mode selection
    if (MatchMaking.Value) {
        FindMatch()
    } else {
        PlayHere()
    }

    RestartStage()
}

MonitorEndScreen() {
    global mode, StoryDropdown, StoryActDropdown, ReturnLobbyBox, MatchMaking, challengeStartTime, inChallengeMode

    Loop {
        Sleep(3000)  
        
        FixClick(560, 560)
        FixClick(560, 560)

        if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
            ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
        }

        if (ok := FindText(&X, &Y, 260, 400, 390, 450, 0, 0, NextText)) {
            ClickUntilGone(0, 0, 260, 400, 390, 450, NextText, 0, -40)
        }

        ; Now handle each mode
        if (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText) or (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText2))) {
            AddToLog("Found Lobby Text - Current Mode: " (inChallengeMode ? "Challenge" : mode))
            Sleep(2000)

            ; Challenge mode logic first
            if (inChallengeMode) {
                 AddToLog("Challenge completed - returning to " mode " mode")
                inChallengeMode := false
                challengeStartTime := A_TickCount
                ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
                return CheckLobby()
            }

            ; Check if it's time for challenge mode
            if (!inChallengeMode && ChallengeBox.Value) {
                timeElapsed := A_TickCount - challengeStartTime
                if (timeElapsed >= 1800000) {
                    AddToLog("30 minutes passed - switching to Challenge mode")
                    inChallengeMode := true
                    challengeStartTime := A_TickCount
                    ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
                    return CheckLobby()
                }
            }


            if (mode = "Story") {
                AddToLog("Handling Story mode end")
                if (StoryActDropdown.Text != "Infinity") {
                    if (NextLevelBox.Value && lastResult = "win") {
                        AddToLog("Next level")
                        ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, +260, -35, LobbyText2)
                    } else {
                        AddToLog("Replay level")
                        ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, +120, -35, LobbyText2)
                    }
                } else {
                    AddToLog("Story Infinity replay")
                    ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, +120, -35, LobbyText2)
                }
                return RestartStage()
            }
            else if (mode = "Raid") {
                AddToLog("Handling Raid end")
                if (ReturnLobbyBox.Value) {
                    AddToLog("Return to lobby")
                    ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
                    return CheckLobby()
                } else {
                    AddToLog("Replay raid")
                    ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, +120, -35, LobbyText2)
                    return RestartStage()
                }
            }
            else {
                AddToLog("Handling end case")
                if (ReturnLobbyBox.Value) {
                    AddToLog("Return to lobby enabled")
                    ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
                    return CheckLobby()
                } else {
                    AddToLog("Replaying")
                    ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, +120, -35, LobbyText2)
                    return RestartStage()
                }
            }
        }
        
        Reconnect()
    }
}


MonitorStage() {
    global Wins, loss, mode, StoryActDropdown

    lastClickTime := A_TickCount
    
    Loop {
        Sleep(1000)
        
        if (mode = "Story" && StoryActDropdown.Text = "Infinity") {
            timeElapsed := A_TickCount - lastClickTime
            if (timeElapsed >= 300000) {  ; 5 minutes
                AddToLog("Performing anti-AFK click")
                FixClick(560, 560)  ; Move click
                lastClickTime := A_TickCount
            }
        }
        ; Check for XP screen
        if CheckForXp() {
            AddToLog("Checking win/loss status")
            
            ; Calculate stage end time here, before checking win/loss
            stageEndTime := A_TickCount
            stageLength := FormatStageTime(stageEndTime - stageStartTime)

            if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
                ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
            } 
            
            ; Check for Victory or Defeat
            if (ok := FindText(&X, &Y, 150, 180, 350, 260, 0, 0, VictoryText)) {
                AddToLog("Victory detected - Stage Length: " stageLength)
                Wins += 1
                SendWebhookWithTime(true, stageLength)
                return MonitorEndScreen()  ; Original behavior for other modes
            }
            else if (ok := FindText(&X, &Y, 150, 180, 350, 260, 0, 0, DefeatText)) {
                AddToLog("Defeat detected - Stage Length: " stageLength)
                loss += 1
                SendWebhookWithTime(false, stageLength) 
                return MonitorEndScreen()  ; Original behavior for other modes
            }
        }
        Reconnect()
    }
}

StoryMovement() {
    FixClick(75, 250) ; Click Teleport
    sleep (1000)
    FixClick(280, 280) ; Click Play/Portals
    sleep (1000)
    FixClick(352, 245) ; Click Story Portal
    sleep (1000)
    FixClick(403, 268) ; Click play on story portal
    sleep (1000)
}

ChallengeMovement() {
    FixClick(765, 475)
    Sleep (500)
    FixClick(300, 415)
    SendInput ("{a down}")
    sleep (7000)
    SendInput ("{a up}")
}

RaidMovement() {
    FixClick(75, 250) ; Click Teleport
    sleep (1000)
    FixClick(280, 280) ; Click Play/Portals
    sleep (1000)
    FixClick(435, 237) ; Click Raid Portal
    sleep (1000)
    FixClick(480, 272) ; Click play on story portal
    sleep (1000)
}

StartStory(map, StoryActDropdown) {
    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)
    navKeys := GetNavKeys()
    for key in navKeys {
        SendInput("{" key "}")
    }
    Sleep(500)

    leftArrows := 7 ; Go Over To Story
    Loop leftArrows {
        SendInput("{Left}")
        Sleep(200)
    }

    downArrows := GetStoryDownArrows(map) ; Map selection down arrows
    Loop downArrows {
        SendInput("{Down}")
        Sleep(200)
    }

    SendInput("{Enter}") ; Select storymode
    Sleep(500)

    SendInput("{Right}") ; Go to act selection
    Sleep(1000)
    SendInput("{Right}")
    Sleep(1000)
    
    actArrows := GetStoryActDownArrows(StoryActDropdown) ; Act selection down arrows
    Loop actArrows {
        SendInput("{Down}")
        Sleep(200)
    }
    
    SendInput("{Enter}") ; Select Act
    Sleep(500)
    for key in navKeys {
        SendInput("{" key "}")
    }
}

StartLegend(map, LegendActDropdown) {
    
    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)
    navKeys := GetNavKeys()
    for key in navKeys {
        SendInput("{" key "}")
    }
    Sleep(500)
    SendInput("{Down}")
    Sleep(500)
    SendInput("{Enter}") ; Opens Legend Stage

    downArrows := GetLegendDownArrows(map) ; Map selection down arrows
    Loop downArrows {
        SendInput("{Down}")
        Sleep(200)
    }
    
    SendInput("{Enter}") ; Select LegendStage
    Sleep(500)

    Loop 4 {
        SendInput("{Up}") ; Makes sure it selects act
        Sleep(200)
    }

    SendInput("{Left}") ; Go to act selection
    Sleep(1000)
    
    actArrows := GetLegendActDownArrows(LegendActDropdown) ; Act selection down arrows
    Loop actArrows {
        SendInput("{Down}")
        Sleep(200)
    }

    SendInput("{Enter}") ; Select Act
    Sleep(500)
    for key in navKeys {
        SendInput("{" key "}")
    }
}

StartRaid(map, RaidActDropdown) {
    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)
    navKeys := GetNavKeys()
    for key in navKeys {
        SendInput("{" key "}")
    }
    Sleep(500)

    downArrows := GetRaidDownArrows(map) ; Map selection down arrows
    Loop downArrows {
        SendInput("{Down}")
        Sleep(200)
    }

    SendInput("{Enter}") ; Select Raid

    Loop 4 {
        SendInput("{Up}") ; Makes sure it selects act
        Sleep(200)
    }

    SendInput("{Left}") ; Go to act selection
    Sleep(500)
    
    actArrows := GetRaidActDownArrows(RaidActDropdown) ; Act selection down arrows
    Loop actArrows {
        SendInput("{Down}")
        Sleep(200)
    }
    
    SendInput("{Enter}") ; Select Act
    Sleep(300)
    for key in navKeys {
        SendInput("{" key "}")
    }
}

PlayHere() {
    FixClick(385, 429) ; Click Confirm
    Sleep (1000)
    FixClick(60, 410) ; Click Start
    Sleep (300)
}

FindMatch() {
    startTime := A_TickCount

    Loop {
        if (A_TickCount - startTime > 50000) {
            AddToLog("Matchmaking timeout, restarting mode")
            FixClick(400, 520)
            return StartSelectedMode()
        }
        FixClick(400, 435)  ; Play Here or Find Match 
        Sleep(300)
        FixClick(460, 330)  ; Click Find Match
        Sleep(300)
        return true
    }
}

GetStoryDownArrows(map) {
    switch map {
        case "Planet Greenie": return 0
    }
}

GetStoryActDownArrows(StoryActDropdown) {
    switch StoryActDropdown {
        case "Act 1": return 0
        case "Act 2": return 1
        case "Act 3": return 2
        case "Act 4": return 3
        case "Act 5": return 4
        case "Act 6": return 5
        case "Infinity": return 6
    }
}


GetLegendDownArrows(map) {
    switch map {
        case "Magic Hills": return 1
    }
}

GetLegendActDownArrows(LegendActDropdown) {
    switch LegendActDropdown {
        case "Act 1": return 1
    }
}

GetRaidDownArrows(map) {
    switch map {
        case "The Spider": return 1
    }
}

GetRaidActDownArrows(RaidActDropdown) {
    switch RaidActDropdown {
        case "Act 1": return 1
        case "Act 2": return 2
        case "Act 3": return 3
        case "Act 4": return 4
        case "Act 5": return 5
    }
}

Zoom() {
    MouseMove(400, 300)
    Sleep 100

    ; Zoom in smoothly
    Loop 10 {
        Send "{WheelUp}"
        Sleep 50
    }

    ; Look down
    Click
    MouseMove(400, 400)  ; Move mouse down to angle camera down
    
    ; Zoom back out smoothly
    Loop 20 {
        Send "{WheelDown}"
        Sleep 50
    }
    
    ; Move mouse back to center
    MouseMove(400, 300)
}

TpSpawn() {
    FixClick(26, 570) ;click settings
    Sleep 300
    FixClick(400, 215)
    Sleep 300
    loop 4 {
        Sleep 150
        SendInput("{WheelDown 1}") ;scroll
    }
    Sleep 300
    if (ok := FindText(&X, &Y, 215, 160, 596, 480, 0, 0, Spawn)) {
        AddToLog("Found Teleport to Spawn button")
        FixClick(X + 100, Y - 30)
    } else {
        AddToLog("Could not find Teleport button")
    }
    Sleep 300
    FixClick(583, 147)
    Sleep 300

    ;

}

CloseChat() {
    if (ok := FindText(&X, &Y, 123, 50, 156, 79, 0, 0, OpenChat)) {
        AddToLog "Closing Chat"
        FixClick(138, 30) ;close chat
    }
}

BasicSetup() {
    SendInput("{Tab}") ; Closes Player leaderboard
    Sleep 300
    FixClick(564, 72) ; Closes Player leaderboard
    Sleep 300
    CloseChat()
    Sleep 300
    Zoom()
    Sleep 300
    TpSpawn()
}

DetectMap() {
    AddToLog("Determining Movement Necessity on Map...")
    startTime := A_TickCount
    
    Loop {
        ; Check if we waited more than 5 minute for votestart
        if (A_TickCount - startTime > 300000) {
            if (ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, AreaText)) {
                AddToLog("Found in lobby - restarting selected mode")
                return StartSelectedMode()
            }
            AddToLog("Could not detect map after 5 minutes - proceeding without movement")
            return "no map found"
        }

        ; Check for vote screen
        if (ok := FindAndClickImage(UnitManager))  {
            AddToLog("No Map Found or Movement Unnecessary")
            return "no map found"
        }

        mapPatterns := Map(
            "Snowy Town", SnowyTown
        )

        for mapName, pattern in mapPatterns {
            if (ok := FindText(&X, &Y, 10, 90, 415, 160, 0, 0, pattern)) {
                    AddToLog("Detected map: " mapName)
                    return mapName
                }
            }
        Sleep 1000
        Reconnect()
    }
}

HandleMapMovement(MapName) {
    AddToLog("Executing Movement for: " MapName)
    
    switch MapName {
        case "Snowy Town":
            MoveForSnowyTown()
    }
}

MoveForSnowyTown() {
    Fixclick(700, 125, "Right")
    Sleep (6000)
    Fixclick(615, 115, "Right")
    Sleep (3000)
    Fixclick(725, 300, "Right")
    Sleep (3000)
    Fixclick(715, 395, "Right")
    Sleep (3000)
}

MoveForWinterEvent() {
    loop {
        if FindAndClickColor() {
            break
        }
        else {
            AddToLog("Color not found. Turning again.")
            SendInput ("{Left up}")
            Sleep 200
            SendInput ("{Left down}")
            Sleep 750
            SendInput ("{Left up}")
            KeyWait "Left" ; Wait for key to be fully processed
            Sleep 200
        }
    }
}

    
RestartStage() {
    currentMap := DetectMap()
    
    ; Wait for loading
    CheckLoaded()

    ; Do initial setup and map-specific movement during vote timer
    BasicSetup()
    if (currentMap != "no map found") {
        HandleMapMovement(currentMap)
    }

    ; Wait for game to actually start
    StartedGame()

    ; Begin unit placement and management
    PlacingUnits()
    
    ; Monitor stage progress
    MonitorStage()
}

Reconnect() {   
    ; Check for Disconnected Screen using FindText
    if (ok := FindText(&X, &Y, 330, 218, 474, 247, 0, 0, Disconnect)) {
        AddToLog("Lost Connection! Attempting To Reconnect To Private Server...")

        psLink := FileExist("Settings\PrivateServer.txt") ? FileRead("Settings\PrivateServer.txt", "UTF-8") : ""

        ; Reconnect to Ps
        if FileExist("Settings\PrivateServer.txt") && (psLink := FileRead("Settings\PrivateServer.txt", "UTF-8")) {
            AddToLog("Connecting to private server...")
            Run(psLink)
        } else {
            Run("roblox://placeID=8304191830")  ; Public server if no PS file or empty
        }

        Sleep(300000)
        
        ; Restore window if it exists
        if WinExist(rblxID) {
            forceRobloxSize() 
            Sleep(1000)
        }
        
        ; Keep checking until we're back in
        loop {
            AddToLog("Reconnecting to Roblox...")
            Sleep(5000)
            
            ; Check if we're back in lobby
            if (ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, AreaText)) {
                AddToLog("Reconnected Successfully!")
                return StartSelectedMode() ; Return to raids
            }
            else {
                ; If not in lobby, try reconnecting again
                Reconnect()
            }
        }
    }
}

PlaceUnit(x, y, slot := 1) {
    SendInput(slot)
    Sleep 50
    FixClick(x, y)
    Sleep 50
    SendInput("q")
    
    if UnitPlaced() {
        Sleep 15
        return true
    }
    return false
}

MaxUpgrade() {
    Sleep 500
    ; Check for max text
    if (ok := FindText(&X, &Y, 160, 215, 330, 420 , 0, 0, MaxText) or (ok:=FindText(&X, &Y, 160, 215, 330, 420, 0, 0, MaxText2))) {
        return true
    }
    return false
}

UnitPlaced() {
    PlacementSpeed() ; Custom Placement Speed
    ; Check for upgrade text
    if (ok := FindText(&X, &Y, 160, 215, 330, 420, 0, 0, UpgradeText) or (ok:=FindText(&X, &Y, 160, 215, 330, 420, 0, 0, UpgradeText2))) {
        AddToLog("Unit Placed Successfully")
        FixClick(325, 185) ; close upg menu
        return true
    }
    return false
}

CheckAbility() {
    global AutoAbilityBox  ; Reference your checkbox
    
    ; Only check ability if checkbox is checked
    if (AutoAbilityBox.Value) {
        if (ok := FindText(&X, &Y, 342, 253, 401, 281, 0, 0, AutoOff)) {
            FixClick(373, 237)  ; Turn ability on
            AddToLog("Auto Ability Enabled")
        }
    }
}

UpgradeUnit(x, y) {
    FixClick(x, y - 3)
    FixClick(264, 363) ; upgrade button 
    FixClick(264, 363) ; upgrade button
    FixClick(264, 363) ; upgrade button
}

CheckLobby() {
    loop {
        Sleep 1000
        if (ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, AreaText)) {
            break
        }
        Reconnect()
    }
    AddToLog("Returned to lobby, restarting selected mode")
    return StartSelectedMode()
}

CheckLoaded() {
    loop {
        Sleep(1000)
        
        ; Check for vote screen
        if (FindAndClickImage(UnitManager)) {
            AddToLog("Successfully Loaded In")
            Sleep(1000)
            break
        }

        Reconnect()
    }
}

StartedGame() {
    loop {
        Sleep(1000)
        if (FindAndClickImage(UnitManager)) {
            FixClick(350, 103) ; click yes
            FixClick(350, 100)
            FixClick(350, 97)
            continue  ; Keep waiting if vote screen is still there
        }
        
        ; If we don't see vote screen anymore the game has started
        AddToLog("Game started")
        global stageStartTime := A_TickCount
        break
    }
}

StartSelectedMode() {
    global inChallengeMode, firstStartup, challengeStartTime
    FixClick(400,340)
    FixClick(400,390)

    if (ChallengeBox.Value && firstStartup) {
        AddToLog("Auto Challenge enabled - starting with challenge")
        inChallengeMode := true
        firstStartup := false
        challengeStartTime := A_TickCount  ; Set initial challenge time
        ChallengeMode()
        return
    }
    ; If we're in challenge mode, do challenge
    if (inChallengeMode) {
        AddToLog("Starting Challenge Mode")
        ChallengeMode()
        return
    }    
    else if (ModeDropdown.Text = "Story") {
        StoryMode()
    }
    else if (ModeDropdown.Text = "Legend") {
        LegendMode()
    }
    else if (ModeDropdown.Text = "Raid") {
        RaidMode()
    }
}

FormatStageTime(ms) {
    seconds := Floor(ms / 1000)
    minutes := Floor(seconds / 60)
    hours := Floor(minutes / 60)
    
    minutes := Mod(minutes, 60)
    seconds := Mod(seconds, 60)
    
    return Format("{:02}:{:02}:{:02}", hours, minutes, seconds)
}

ValidateMode() {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before starting the macro!")
        return false
    }
    if (!confirmClicked) {
        AddToLog("Please click the confirm button before starting the macro!")
        return false
    }
    return true
}

GetNavKeys() {
    return StrSplit(FileExist("Settings\UINavigation.txt") ? FileRead("Settings\UINavigation.txt", "UTF-8") : "\,#,}", ",")
}

GenerateRandomPoints() {
    points := []
    gridSize := 40  ; Minimum spacing between units
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Define placement area boundaries (adjust these as needed)
    minX := centerX - 180  ; Left boundary
    maxX := centerX + 180  ; Right boundary
    minY := centerY - 140  ; Top boundary
    maxY := centerY + 140  ; Bottom boundary
    
    ; Generate 40 random points
    Loop 40 {
        ; Generate random coordinates
        x := Random(minX, maxX)
        y := Random(minY, maxY)
        
        ; Check if point is too close to existing points
        tooClose := false
        for existingPoint in points {
            ; Calculate distance to existing point
            distance := Sqrt((x - existingPoint.x)**2 + (y - existingPoint.y)**2)
            if (distance < gridSize) {
                tooClose := true
                break
            }
        }
        
        ; If point is not too close to others, add it
        if (!tooClose)
            points.Push({x: x, y: y})
    }
    
    ; Always add center point last (so it's used last)
    points.Push({x: centerX, y: centerY})
    
    return points
}

GenerateGridPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)
    
    ; Generate grid points row by row
    Loop squaresPerSide {
        currentRow := A_Index
        y := startY + ((currentRow - 1) * gridSize)
        
        ; Generate each point in the current row
        Loop squaresPerSide {
            x := startX + ((A_Index - 1) * gridSize)
            points.Push({x: x, y: y})
        }
    }
    
    return points
}

GenerateUpandDownPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)
    
    ; Generate grid points column by column (left to right)
    Loop squaresPerSide {
        currentColumn := A_Index
        x := startX + ((currentColumn - 1) * gridSize)
        
        ; Generate each point in the current column
        Loop squaresPerSide {
            y := startY + ((A_Index - 1) * gridSize)
            points.Push({x: x, y: y})
        }
    }
    
    return points
}

; circle coordinates
GenerateCirclePoints() {
    points := []
    
    ; Define each circle's radius
    radius1 := 45    ; First circle 
    radius2 := 90    ; Second circle 
    radius3 := 135   ; Third circle 
    radius4 := 180   ; Fourth circle 
    
    ; Angles for 8 evenly spaced points (in degrees)
    angles := [0, 45, 90, 135, 180, 225, 270, 315]
    
    ; First circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius1 * Cos(radians)
        y := centerY + radius1 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    ; second circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius2 * Cos(radians)
        y := centerY + radius2 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    ; third circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius3 * Cos(radians)
        y := centerY + radius3 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    ;  fourth circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius4 * Cos(radians)
        y := centerY + radius4 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    return points
}

; Spiral coordinates (restricted to a rectangle)
GenerateSpiralPoints(rectX := 4, rectY := 123, rectWidth := 795, rectHeight := 433) {
    points := []
    
    ; Calculate center of the rectangle
    centerX := rectX + rectWidth // 2
    centerY := rectY + rectHeight // 2
    
    ; Angle increment per step (in degrees)
    angleStep := 30
    ; Distance increment per step (tighter spacing)
    radiusStep := 10
    ; Initial radius
    radius := 20
    
    ; Maximum radius allowed (smallest distance from center to edge)
    maxRadiusX := (rectWidth // 2) - 1
    maxRadiusY := (rectHeight // 2) - 1
    maxRadius := Min(maxRadiusX, maxRadiusY)

    ; Generate spiral points until reaching max boundary
    Loop {
        ; Stop if the radius exceeds the max boundary
        if (radius > maxRadius)
            break
        
        angle := A_Index * angleStep
        radians := angle * 3.14159 / 180
        x := centerX + radius * Cos(radians)
        y := centerY + radius * Sin(radians)
        
        ; Check if point is inside the rectangle
        if (x < rectX || x > rectX + rectWidth || y < rectY || y > rectY + rectHeight)
            break ; Stop if a point goes out of bounds
        
        points.Push({ x: Round(x), y: Round(y) })
        
        ; Increase radius for next point
        radius += radiusStep
    }
    
    return points
}

CheckEndAndRoute() {
    if (ok := FindText(&X, &Y, 140, 130, 662, 172, 0, 0, LobbyText)) {
        AddToLog("Found end screen")
        return MonitorEndScreen()
    }
    return false
}

ClickUntilGone(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    while (ok := FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || 
           textToFind2 && FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {
        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY)  
        } else {
            FixClick(x, y) 
        }
        Sleep(1000)
    }
}

PlacementSpeed() {
    if PlaceSpeed.Text = "2.25 sec" {
        sleep 2250
    }
    else if PlaceSpeed.Text = "2 sec" {
        sleep 2000
    }
    else if PlaceSpeed.Text = "2.5 sec" {
        sleep 2500
    }
    else if PlaceSpeed.Text = "2.75 sec" {
        sleep 2.75
    }
    else if PlaceSpeed.Text = "3 sec" {
        sleep 3000
    }
}