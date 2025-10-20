#Requires AutoHotkey v2.0

UpgradeUnits() {
    global successfulCoordinates, maxedCoordinates

    if (ShouldOpenUnitManager()) {
        OpenMenu("Unit Manager")
    }

    ; Auto-upgrade logic
    if (UnitManagerUpgradeSystem.Value) {
        if (AutoUpgrade.Value) {
            return HandleUnitManager("Auto-upgrade enabled for all units, monitoring stage.")
        }
    }

    if (PriorityUpgrade.Value) {
        upgradeWithPriority()
    } else {
        UpgradeWithoutPriority()
    }

    return MonitorStage()
}

UpgradeWithoutPriority() {
    global successfulCoordinates
    while (successfulCoordinates.Length > 0) {
        ProcessUpgrades(false, "")
    }
    AddToLog("All units maxed, proceeding to monitor stage")
}

UpgradeWithPriority() {
    global successfulCoordinates
    AddToLog("Using priority upgrade system")
    slotOrder := [1, 2, 3, 4, 5, 6]
    priorityOrder := [1, 2, 3, 4, 5, 6]

    if (UnitManagerUpgradeSystem.Value) {
        for priorityNum in priorityOrder {
            for slot in slotOrder {
                if (HasUnitsInSlot(slot, priorityNum, successfulCoordinates)) {
                    AddToLog("Starting upgrades for priority " priorityNum " (slot " slot ")")
                    ProcessUpgrades(slot, priorityNum)
                }
            }
        }
    } else {
        for priorityNum in priorityOrder {
            for slot in slotOrder {
                if (HasUnitsInSlot(slot, priorityNum, successfulCoordinates)) {
                    AddToLog("Starting upgrades for priority " priorityNum " (slot " slot ")")
                    ProcessUpgrades(slot, priorityNum)
                }
            }
        }
    }

    AddToLog("All units maxed, proceeding to monitor stage")
    CloseMenu("Unit Manager")
}

SetAutoUpgradeForAllUnits(testAmount := 0) {
    global successfulCoordinates

    ; Use test coordinates if testAmount is provided
    if (testAmount > 0) {
        coordinates := []
        loop testAmount {
            index := A_Index
            coordinates.Push({
                slot: index,
                upgradePriority: (index - 1) // 2 + 1, ; Just example logic
                placementIndex: index        ; Placement in visual order
            })
        }
        AddToLog("Test mode active: Using " testAmount " test coordinates.")
    } else {
        coordinates := successfulCoordinates.Clone()
    }

    ; Sort by placementIndex (simple bubble sort)
    sorted := coordinates
    loop sorted.Length {
        for i, val in sorted {
            if (i = sorted.Length)
                continue
            if (sorted[i].placementIndex > sorted[i + 1].placementIndex) {
                temp := sorted[i]
                sorted[i] := sorted[i + 1]
                sorted[i + 1] := temp
            }
        }
    }

    ; GUI positioning constants
    baseX := 650
    baseY := 175

    colSpacing := 65
    rowSpacing := 95
    maxCols := 3

    totalCount := sorted.Length
    fullRows := Floor(totalCount / maxCols)
    lastRowUnits := Mod(totalCount, maxCols)

    ; Loop through units in visual order
    for index, unit in sorted {
        slot := unit.slot
        priority := unit.upgradePriority

        ; Calculate click position
        placementIndex := index - 1 ; zero-based
        row := Floor(placementIndex / maxCols)
        colInRow := Mod(placementIndex, maxCols)
        isLastRow := (row = fullRows)

        if (lastRowUnits != 0 && isLastRow) {
            rowStartX := baseX + ((maxCols - lastRowUnits) * colSpacing / 2)
            clickX := rowStartX + (colInRow * colSpacing)
        } else {
            clickX := baseX + (colInRow * colSpacing)
        }

        clickY := baseY + (row * rowSpacing)

        ; Normalize priorities
        if (priority > 4 && priority != 7) {
            priority := 4
        }
        if (priority == 7) {
            priority := 0
        }

        AddToLog("Set slot: " slot " priority to " priority)
        FixClick(clickX, clickY)
        Sleep(150)
    }
}

HandleUnitManager(msg) {
    AddToLog(msg)
    if (AutoAbilityBox.Value) {
        SetTimer(CheckAutoAbility, GetAutoAbilityTimer())
    }
    CloseMenu("Unit Manager")
    return MonitorStage()
}

GetUpgradePriority(slotNum) {
    global
    priorityVar := "upgradePriority" slotNum
    return %priorityVar%.Value
}

SortByPriority(a, b) {
    if a.upgradePriority != b.upgradePriority
        return a.upgradePriority < b.upgradePriority ? -1 : 1
    return a.placementIndex < b.placementIndex ? -1 : 1
}

UnitManagerUpgradeWithLimit(coord, index, upgradeLimit) {
    if !(GetPixel(0x1643C5, 77, 357, 4, 4, 2)) {
        ClickUnit(coord.upgradePriority)
        Sleep(500)
    }
    if (WaitForUpgradeLimitText(upgradeLimit + 1, 750)) {
        HandleMaxUpgrade(coord, index)
    } else {
        SendInput("T")
    }
    
}

ProcessUpgrades(slot := false, priorityNum := false, singlePass := false) {
    global successfulCoordinates, UnitManagerUpgradeSystem

    if (singlePass) {
        for index, coord in successfulCoordinates {
            if ((!slot || coord.slot = slot) && (!priorityNum || coord.upgradePriority = priorityNum)) {
                if (StageEndedDuringUpgrades()) {
                    return HandleStageEnd()
                }

                UpgradeUnitWithLimit(coord, index)

                if (StageEndedDuringUpgrades()) {
                    return HandleStageEnd()
                }

                PostUpgradeChecks(coord)

                if (MaxUpgrade()) {
                    HandleMaxUpgrade(coord, index)
                }

                if (!UnitManagerUpgradeSystem.Value) {
                    FixClick(341, 226)
                }

                PostUpgradeChecks(coord)
            }
        }

        if (slot || priorityNum)
            AddToLog("Finished single-pass upgrades for slot " slot " priority " priorityNum)

        return
    }

    ; Full upgrade loop
    while (true) {
        slotDone := true  ; Assume done, set false if any upgrade performed

        for index, coord in successfulCoordinates {
            if ((!slot || coord.slot = slot) && (!priorityNum || coord.upgradePriority = priorityNum)) {
                slotDone := false  ; Found unit to upgrade => not done yet

                if (StageEndedDuringUpgrades()) {
                    return HandleStageEnd()
                }

                UpgradeUnitWithLimit(coord, index)

                if (StageEndedDuringUpgrades()) {
                    return HandleStageEnd()
                }

                PostUpgradeChecks(coord)

                if (MaxUpgrade()) {
                    HandleMaxUpgrade(coord, index)
                }

                FixClick(341, 226)

                PostUpgradeChecks(coord)
            }
        }

        if ((slot || priorityNum) && (slotDone || successfulCoordinates.Length = 0)) {
            AddToLog("Finished upgrades for priority " priorityNum)
            break
        }

        if (!slot && !priorityNum)
            break
    }
}

WaitForUpgradeText(timeout := 4500) {
    startTime := A_TickCount
    while (A_TickCount - startTime < timeout) {
        if (ok := GetPixel(0x352964, 34, 371, 2, 2, 5)) {
            return true
        }
        Sleep 100  ; Check every 100ms
    }
    return false  ; Timed out, upgrade text was not found
}

WaitForUpgradeLimitText(upgradeCap, timeout := 4500) {
    upgradeTexts := [
        Upgrade0, Upgrade1, Upgrade2, Upgrade3, Upgrade4, Upgrade5, Upgrade6, Upgrade7, Upgrade8, Upgrade9, Upgrade10, Upgrade11, Upgrade12, Upgrade13, Upgrade14
    ]
    targetText := upgradeTexts[upgradeCap]

    startTime := A_TickCount
    while (A_TickCount - startTime < timeout) {
        if (FindText(&X, &Y, 279, 311, 377, 334, 0, 0, targetText)) {
            AddToLog("Found Upgrade Cap")
            return true
        }
        Sleep 100
    }
    return false  ; Timed out
}

UpgradeUnitWithLimit(coord, index) {
    global totalUnits
    global unitUpgradeLimitDisabled  ; Make sure this variable is declared global

    upgradeLimitEnabled := "upgradeLimitEnabled" coord.slot
    upgradeLimitEnabled := %upgradeLimitEnabled%

    upgradeLimit := "upgradeLimit" coord.slot
    upgradeLimit := %upgradeLimit%
    upgradeLimit := String(upgradeLimit.Text)

    upgradePriority := "upgradePriority" coord.slot
    upgradePriority := %upgradePriority%
    upgradePriority := String(upgradePriority.Text)

    ; Check if upgrade limit is disabled globally OR the toggle is off
    if (!upgradeLimitEnabled.Value || unitUpgradeLimitDisabled) {
        if (UnitManagerUpgradeSystem.Value) {
            UnitManagerUpgrade(coord.placementIndex)
        } else {
            UpgradeUnit(coord.x, coord.y)
        }
    } else {
        if (UnitManagerUpgradeSystem.Value) {
            UnitManagerUpgradeWithLimit(coord, index, upgradeLimit)
        } else {
            UpgradeUnitLimit(coord, index, upgradeLimit)
        }
    }
}

UpgradeUnitLimit(coord, index, upgradeLimit) {
    FixClick(coord.x, coord.y)
    if (WaitForUpgradeLimitText(upgradeLimit + 1, 750)) {
        HandleMaxUpgrade(coord, index)
    } else {
        SendInput("T")
    }
}

HandleMaxUpgrade(coord, index) {
    global successfulCoordinates, maxedCoordinates, upgradedCount, totalUnits

    if (IsSet(totalUnits) && IsSet(upgradedCount)) {
        upgradedCount[coord.slot]++
        AddToLog("Max upgrade reached for Unit: " coord.slot " (" upgradedCount[coord.slot] "/" totalUnits[coord.slot] ")")
    } else {
        AddToLog("Max upgrade reached for Unit: " coord.slot)
        maxedCoordinates.Push(coord)
    }
    maxedCoordinates.Push(coord)
    successfulCoordinates.RemoveAt(index)
}

PostUpgradeChecks(coord) {
    HandleAutoAbility(coord.slot)

    if (HasCards(ModeDropdown.Text)) {
        CheckForCardSelection()
    }

    Reconnect()
}

StageEndedDuringUpgrades() {
    return isMenuOpen("End Screen")
}

IsUpgradeEnabled(slotNum) {
    setting := "upgradeEnabled" slotNum
    return %setting%.Value
}

TestAllUpgradeFindTexts() {
    foundCount := 0
    notFoundCount := 0

    Loop 15 {
        upgradeCap := A_Index  ; Now 1–15, aligns with AHK v2 arrays
        result := WaitForUpgradeLimitText(upgradeCap, 500)

        if (result) {
            AddToLog("Found Upgrade Level: " upgradeCap - 1)
            foundCount++
        } else {
            AddToLog("Did NOT Find Upgrade Level: " upgradeCap - 1)
            notFoundCount++
        }
    }

    AddToLog("Found: " foundCount " | Not Found: " notFoundCount)
}

HasUnitsInSlot(slot, priorityNum, coordinates) {
    for coord in coordinates {
        if (coord.slot = slot && coord.upgradePriority = priorityNum)
            return true
    }
    return false
}

ShouldOpenUnitManager() {
    if (UnitManagerUpgradeSystem.Value) {
        return true
    }
}

MaxUpgrade() {
    Sleep 500
    ok := (
        FindText(&X, &Y, 117, 374, 226, 400, 0.10, 0.10, MaxUpgradeText)
    )
    return ok
}

UnitManagerUpgrade(slot) {
    if !(GetPixel(0x1643C5, 77, 357, 4, 4, 2)) {
        ClickUnit(slot)
        Sleep(500)
    }
    loop 3 {
        SendInput("T")
    }
}