#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\Lib\GUI.ahk
global confirmClicked := false
 
 ;Minimizes the UI
 minimizeUI(*){
    MainUI.Minimize()
 }
 
 Destroy(*){
    MainUI.Destroy()
    ExitApp
 }

 ;Login Text
 setupOutputFile() {
     content := "`n==" GameTitle "" version "==`nStart Time: [" currentTime "]`n"
     FileAppend(content, currentOutputFile)
 }
 
; Gets the current time in 12-hour format
getCurrentTime() {
    currentHour := A_Hour
    currentMinute := A_Min
    currentSecond := A_Sec
    amPm := (currentHour >= 12) ? "PM" : "AM"
    
    ; Convert to 12-hour format
    currentHour := Mod(currentHour - 1, 12) + 1

    return Format("{:d}:{:02}:{:02} {}", currentHour, currentMinute, currentSecond, amPm)
}

OnModeChange(*) {
    ; Hide all
    for ctrl in [StoryDropdown, StoryActDropdown, RaidDropdown, RaidActDropdown, PortalDropdown, PortalRoleDropdown]
        ctrl.Visible := false

    ; Show based on selection
    switch ModeDropdown.Text {
        case "Story":
            StoryDropdown.Visible := true
            StoryActDropdown.Visible := true
        case "Raid":
            RaidDropdown.Visible := RaidActDropdown.Visible := true
        case "Portal":
            PortalDropdown.Visible := PortalRoleDropdown.Visible := true
        case "Event":
            EventDropdown.Visible := EventDropdown.Visible := true
        case "Custom":
            ; Add handling if needed
    }

    if (ModeConfigurations.Value) {
        LoadUnitSettingsByMode()
    }
}

OnStoryChange(*) {
    if (StoryDropdown.Text != "") {
        StoryActDropdown.Visible := true
    } else {
        StoryActDropdown.Visible := false
    }
}

OnRaidChange(*) {
    if (RaidDropdown.Text != "") {
        RaidActDropdown.Visible := true
    } else {
        RaidActDropdown.Visible := false
    }
}

OnEventChange(*) {
    if (EventDropdown.Text != "") {
        EventDropdown.Visible := true
    } else {
        EventDropdown.Visible := false
    }

    if (EventHasDifficulty(EventDropdown.Text)) {
        EventDifficultyDropdown.Visible := true
    } else {
        EventDifficultyDropdown.Visible := false
    }
}

OnConfirmClick(*) {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before confirming")
        return
    }

    ; For Story mode, check if both Story and Act are selected
    if (ModeDropdown.Text = "Story") {
        if (StoryDropdown.Text = "" || StoryActDropdown.Text = "") {
            AddToLog("Please select both Story and Act before confirming")
            return
        }
        AddToLog("Selected " StoryDropdown.Text)
    }
    ; For Custom mode, check if coords are empty
    else if (ModeDropdown.Text = "Custom") {
        AddToLog("Selected Custom")
    }
    ; For Raid mode, check if both Raid and RaidAct are selected
    else if (ModeDropdown.Text = "Raid") {
        if (RaidDropdown.Text = "") {
            AddToLog("Please select both Raid and Act before confirming")
            return
        }
        AddToLog("Selected " RaidDropdown.Text)
    } else {
        AddToLog("Selected " ModeDropdown.Text " mode")
    }

    if (StartsInLobby(ModeDropdown.Text)) {
        AddToLog("[Reminder] Please rejoin the game to use default camera position")
    }

    ; Hide all controls if validation passes
    ModeDropdown.Visible := false
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    PortalDropdown.Visible := false
    PortalRoleDropdown.Visible := false
    EventDropdown.Visible := false
    EventDifficultyDropdown.Visible := false
    ConfirmButton.Visible := false
    modeSelectionGroup.Visible := false
    Hotkeytext.Visible := true
    Hotkeytext2.Visible := true
    Hotkeytext3.Visible := true
    global confirmClicked := true
}

FixClick(x, y, LR := "Left", shouldWiggle := false) {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    Sleep(50)
    if (shouldWiggle) {
        wiggle()
    }
    MouseClick(LR, -1, 0, , , , "R")
}

GetWindowCenter(WinTitle) {
    x := 0 y := 0 Width := 0 Height := 0
    WinGetPos(&X, &Y, &Width, &Height, WinTitle)

    centerX := X + (Width / 2)
    centerY := Y + (Height / 2)

    return { x: centerX, y: centerY, width: Width, height: Height }
}

FindAndClickColor(targetColor := 0xFAFF4D, searchArea := [0, 0, GetWindowCenter(rblxID).Width, GetWindowCenter(rblxID).Height]) {
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, targetColor, 0)) {
        ; Color found, click on the detected coordinates
        FixClick(foundX, foundY, "Right")
        AddToLog("Color found and clicked at: X" foundX " Y" foundY)
        return true

    }
}

FindAndClickImage(imagePath, searchArea := [0, 0, A_ScreenWidth, A_ScreenHeight]) {

    AddToLog(imagePath)

    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the image search
    if (ImageSearch(&foundX, &foundY, x1, y1, x2, y2, imagePath)) {
        ; Image found, click on the detected coordinates
        FixClick(foundX, foundY, "Right")
        AddToLog("Image found and clicked at: X" foundX " Y" foundY)
        return true
    }
}

FindAndClickText(textToFind, searchArea := [0, 0, GetWindowCenter(rblxID).Width, GetWindowCenter(rblxID).Height]) {
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the text search
    if (FindText(&foundX, &foundY, x1, y1, x2, y2, textToFind)) {
        ; Text found, click on the detected coordinates
        FixClick(foundX, foundY, "Right")
        AddToLog("Text found and clicked at: X" foundX " Y" foundY)
        return true
    }
}

OpenGithub() {
    Run("https://github.com/itsRynsRoblox?tab=repositories")
}

OpenDiscord() {
    Run("https://discord.gg/ycYNunvEzX")
}

StringJoin(array, delimiter := ", ") {
    result := ""
    ; Convert the array to an Object to make it enumerable
    for index, value in array {
        if (index > 1)
            result .= delimiter
        result .= value
    }
    return result
}

CopyMouseCoords(withColor := false) {
    MouseGetPos(&x, &y)
    color := PixelGetColor(x, y, "RGB")  ; Correct usage in AHK v2

    A_Clipboard := ""  ; Clear clipboard
    ClipWait(0.5)

    if (withColor) {
        A_Clipboard := x ", " y " | Color: " color
    } else {
        A_Clipboard := x ", " y
    }

    ClipWait(0.5)

    ; Check if the clipboard content matches the expected format

    if (withColor) {
        if (A_Clipboard = x ", " y " | Color: " color) {
            AddToLog("Copied: " x ", " y " | Color: " color)
        }
    } 
    else {
        if (A_Clipboard = x ", " y) {
            AddToLog("Copied: " x ", " y)
        }
    }
}

CalculateElapsedTime(startTime) {
    elapsedTimeMs := A_TickCount - startTime
    elapsedTimeSec := Floor(elapsedTimeMs / 1000)
    elapsedHours := Floor(elapsedTimeSec / 3600)
    elapsedMinutes := Floor(Mod(elapsedTimeSec, 3600) / 60)
    elapsedSeconds := Mod(elapsedTimeSec, 60)
    return Format("{:02}:{:02}:{:02}", elapsedHours, elapsedMinutes, elapsedSeconds)
}

GetPixel(color, x1, y1, extraX, extraY, variation) {
    global foundX, foundY
    try {
        if PixelSearch(&foundX, &foundY, x1, y1, x1 + extraX, y1 + extraY, color, variation) {
            return [foundX, foundY] and true
        }
        return false
    }
}

Teleport(mode := "") {
    teleportCoords := [109, 357]
    playCoords := [316, 293]
    FixClick(teleportCoords[1], teleportCoords[2])
    Sleep 500
    FixClick(playCoords[1], playCoords[2])
    Sleep 500
    FixClick(244, 228) ; search bar
    Sleep 500
    SendInput(mode)
    Sleep 500
    FixClick(250, 276)
    Sleep 500
    FixClick(303, 317)
    Sleep(1000)
}

Scroll(times, direction, delay) {
    if (times < 1) {
        if (debugMessages) {
            AddToLog("Invalid number of times")
        }
        return
    }
    if (direction != "WheelUp" and direction != "WheelDown") {
        if (debugMessages) {
            AddToLog("Invalid scroll direction: " direction)
        }
        return
    }
    if (delay < 0) {
        if (debugMessages) {
            AddToLog("Invalid delay: " delay)
        }
        return
    }
    loop times {
        Send("{" direction "}")
        Sleep(delay)
    }
}

RotateCameraAngle() {
    Send("{Right down}")
    Sleep 800
    Send("{Right up}")
}

CloseLobbyPopups() {
    FixClick(650, 103) ; close leaderboard
    Sleep(500)
    FixClick(410, 470) ; close daily reward
    Sleep(500)
}

ClickUnit(slot) {
    global totalUnits
    baseX := 635
    baseY := 120
    colSpacing := 60
    rowSpacing := 90
    maxCols := 3

    totalCount := 0
    for _, count in totalUnits {
        totalCount += count
    }

    index := slot - 1
    row := Floor(index / maxCols)
    colInRow := Mod(index, maxCols)

    clickX := baseX + (colInRow * colSpacing)
    clickY := baseY + (row * rowSpacing)

    OpenMenu("Unit Manager")
    Sleep(500)

    FixClick(clickX, clickY)
    Sleep(150)
}


GetAutoAbilityTimer() {
    seconds := AutoAbilityTimer.Value
    return Round(seconds * 1000)
}

ToggleMenu(name := "") {
    if (!name)
        return

    key := ""
    if (name = "Unit Manager")
        key := "C"

    if (!key)
        return

    if (isMenuOpen(name)) {
        AddToLog("Closing " name)
        Send(key)
        Sleep(300)
    } else {
        Send(key)
        AddToLog("Opening " name)
        Sleep(300)
    }
}

CloseMenu(name := "") {
    if (!name)
        return

    key := ""
    clickX := 0, clickY := 0
    if (name = "Unit Manager")
        key := "F"

    if (!key)
        return  ; Unknown menu name

    if (isMenuOpen(name)) {
        AddToLog("Closing " name)
        Send(key)  ; Close menu if it's open
        Sleep(300)
    }
}

OpenMenu(name := "") {
    if (!name)
        return

    key := ""
    if (name = "Unit Manager")
        key := "F"
    else if (name = "Ability Manager")
        key := "Z"

    if (!key)
        return  ; Unknown menu name

    if (!isMenuOpen(name)) {
        AddToLog("Opening " name)
        Send(key)
        Sleep(1000)
    }
}

CheckAutoAbility() {
    global successfulCoordinates
    global totalUnits

    AddToLog("Checking for unactive abilities...")
    Sleep (1000)

    if (isMenuOpen("End Screen")) {
        AddToLog("Stopping auto ability check because the game ended")
        SetTimer(CheckAutoAbility, 0)  ; Stop the timer
        return
    }

    CheckUnitAbilities()

    Sleep (1000)
    AddToLog("Finished looking for abilities")
}

CleanString(str) {
    ; Remove emojis and any adjacent spaces (handles gaps)
    return RegExReplace(str, "\s*[^\x00-\x7F]+\s*", "")
}

OnPriorityChange(type, priorityNumber, newPriorityNumber) {
    if (newPriorityNumber == "") {
        newPriorityNumber := "Disabled"
    }
    if (type == "Placement") {
        AddToLog("Placement priority changed: Slot " priorityNumber " → " newPriorityNumber)
    } else {
        AddToLog("Upgrade priority changed: Slot " priorityNumber " → " newPriorityNumber)
    }
}

CheckForCardSelection() {
    if (FindText(&X, &Y, 352, 432, 452, 456, 0.20, 0.20, CardSelection)) {
        SelectCardsByMode()
        return true
    }
    return false
}

SearchForImage(X1, Y1, X2, Y2, image) {
    if !WinExist(rblxID) {
        AddToLog("Roblox window not found.")
        return false
    }

    WinActivate(rblxID)

    return ImageSearch(&FoundX, &FoundY, X1, Y1, X2, Y2, image)
}

OpenCardConfig() {
    if (ModeDropdown.Text = "Spirit Invasion") {
        SwitchCardMode("Spirit Invasion")
    } else {
        AddToLog("No card configuration available for mode: " (ModeDropdown.Text = "" ? "None" : ModeDropdown.Text))
    }
}

AddWaitingFor(action) {
    global waitingState, waitingForClick
    waitingState := action
    waitingForClick := true
}

WaitingFor(action) {
    global waitingState
    if (waitingState = action) {
        return true
    }
    return false
}

RemoveWaiting() {
    global waitingState, waitingForClick
    waitingForClick := false
    waitingState := ""
}

HasMinionInSlot(slot) {
    if (slot = 1)
        return !!MinionSlot1.Value
    else if (slot = 2)
        return !!MinionSlot2.Value
    else if (slot = 3)
        return !!MinionSlot3.Value
    else if (slot = 4)
        return !!MinionSlot4.Value
    else if (slot = 5)
        return !!MinionSlot5.Value
    else if (slot = 6)
        return !!MinionSlot6.Value
    return false
}

CheckUnitAbilities() {
    global successfulCoordinates, maxedCoordinates

    AddToLog("Checking auto abilities of placed units...")

    for coord in successfulCoordinates {

        slot := coord.slot

        if (isMenuOpen("End Screen")) {
            AddToLog("Stopping auto ability check because the game ended")
            return MonitorStage()
        }

        if (CheckForCardSelection()) {
            SelectCardsByMode()
        }

        if (NukeUnitSlotEnabled.Value && slot = NukeUnitSlot.Value) {
            AddToLog("Skipping nuke unit in slot " slot)
            continue
        }

        FixClick(coord.x, coord.y)
        Sleep(500)

        HandleAutoAbility(slot)
    }
}

; Global variable to track current coordinate mode (default is Screen)
global currentCoordMode := "Screen"
global oldCoordMode := ""

; Wrapper function to set coord mode and save state
SetCoordModeTracked(mode) {
    global currentCoordMode, oldCoordMode
    oldCoordMode := currentCoordMode
    CoordMode("Mouse", mode)
    currentCoordMode := mode
}

isInLobby() {
    return FindText(&X, &Y, 13, 588, 40, 615, 0.20, 0.20, LobbySettings)
}

isInGame() {
    return GetPixel(0x017334, 543, 47, 4, 4, 20) or GetPixel(0x02FF73, 543, 47, 4, 4, 20) or FindText(&X, &Y, 13, 588, 40, 615, 0.20, 0.20, LobbySettings)
}

StartContent(mapName, actName, getMapFunc, getActFunc, mapScrollMousePos, actScrollMousePos) {
    ;AddToLog("Selecting : " mapName " - " actName)

    ; Get the map
    Map := getMapFunc.Call(mapName)
    if !Map {
        AddToLog("Error: Map '" mapName "' not found.")
        return false
    }

    ; Scroll map if needed
    if Map.scrolls > 0 {
        AddToLog(Format("Scrolling down {} times for {}", Map.scrolls, mapName))
        MouseMove(mapScrollMousePos.x, mapScrollMousePos.y)
        Scroll(Map.scrolls, 'WheelDown', 250)
    }

    Sleep(1000)
    FixClick(Map.x, Map.y)
    Sleep(1000)

    ; Get the act
    Act := getActFunc.Call(actName)
    if !Act {
        AddToLog("ERROR: Act '" actName "' not found.")
        return false
    }

    if (ModeDropdown.Text = "Story") {
        SelectDifficulty(StoryDifficulty.Text)
    }

    ; Scroll act if needed
    if Act.scrolls > 0 {
        AddToLog(Format("Scrolling down {} times for {}", Act.scrolls, actName))
        MouseMove(actScrollMousePos.x, actScrollMousePos.y)
        Scroll(Act.scrolls, 'WheelDown', 250)
    }

    Sleep(1000)
    FixClick(Act.x, Act.y)
    Sleep(1000)

    return true
}

TeleportToSpawn() {
    FixClick(35, 600) ; open settings
    Sleep (250)
    MouseMove(545, 195)
    Sleep (100)
    Scroll(5, 'WheelDown', 250)
    Sleep (100)
    FixClick(535, 365)
    Sleep (100)
    FixClick(35, 600) ; close settings
}

DoesntHaveSeamless(ModeName) {

    static modesWithoutSeamless := ["Gates", "Portal"]

    for mode in modesWithoutSeamless {
        if (mode = ModeName)
            return true
    }
    return false
}

ModesWithMatchmaking(ModeName) {
    static modesWithMatchmaking := ["Story", "Raid", "Portal", "Gates", "Spirit Invasion"]

    for mode in modesWithMatchmaking {
        if (mode = ModeName)
            return true
    }
    return false
}

PlayHereOrMatchmake() {
    if (Matchmaking.Value && ModesWithMatchmaking(ModeDropdown.Text)) {
        FixClick(488, 350)
        AddToLog("[Info] Waiting for game to start...")
        ; Failed teleport failsafe
        if (MatchmakingFailsafe.Value) {
            TimerManager.Start("Teleport Failsafe", MatchmakingFailsafeTimer.Value * 1000)
        }
        while (isInLobby()) {
            Sleep(1000)
            if (MatchmakingFailsafe.Value) {
                if (TimerManager.HasExpired("Teleport Failsafe")) {
                    AddToLog("[Failsafe] Teleport seems to have failed, reconnecting...")
                    return Reconnect(true)
                }
            }
        }
        AddToLog("[Info] Match has been found!")
        if (MatchmakingFailsafe.Value) {
            TimerManager.Reset("Teleport Failsafe", MatchmakingFailsafeTimer.Value * 1000)
        }
    } else {
        if (isInGame()) {
            FixClick(331, 350)
        } else {
            FixClick(580, 453)
            Sleep(1500)
            FixClick(101, 428)
            WaitForMapChange()
        }
    }
}

ActiveAbilityEnabled() {
    if (autoAbilityDisabled) {
        return false
    }

    if (AutoAbilityBox.Value) {
        return true
    }
    return false
}

ClickNextLevel(testing := false) {
    while (isMenuOpen("End Screen")) {
        pixelChecks := [{ color: 0x79A7DC, x: 395, y: 482 }]

        for pixel in pixelChecks {
            if GetPixel(pixel.color, pixel.x, pixel.y, 4, 4, 20) {
                FixClick(pixel.x, pixel.y, (testing ? "Right" : "Left"))
                if (testing) {
                    Sleep(1500)
                }
            }
        }
    }
}

OpenInventory(tab := "All") {
    FixClick(40, 320)
    Sleep(500)
    if (tab = "Portals") {
        FixClick(420, 270)
        Sleep(500)
    }
}

ShowPlacements(ShowNumbers := false) {
    points := UseCustomPoints()
    if (points.Length = 0) {
        return
    }

    AddToLog("[Info] Showing dots where placements are set...")

    global placementDots := []
    duration := 2000
    fontSize := 16
    dotSize := 8

    for i, point in points {
        dotGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound") ; Transparent, click-through

        if (ShowNumbers) {
            ; Number mode
            dotGui.BackColor := "Fuchsia"
            WinSetTransColor("Fuchsia", dotGui)
            dotGui.SetFont("s" fontSize " cff0000 bold", "Segoe UI")
            dotGui.Add("Text", "BackgroundTrans", i)
            dotGui.Show("AutoSize NA x" (point.x - dotSize) " y" (point.y - dotSize // 2))
        } else {
            ; Dot mode - draw a small red square (no text)
            dotGui.BackColor := "ff0000"
            ; Set size of dotGui to dotSize x dotSize, position centered on point
            dotGui.Show("x" (point.x - dotSize) " y" (point.y - dotSize // 2) " w" dotSize " h" dotSize " NA")
        }
        placementDots.Push(dotGui)
    }
    SetTimer(ClearPreviewDots, -duration)
}

ClearPreviewDots() {
    global placementDots
    for dotGui in placementDots {
        try dotGui.Destroy()
    }
    placementDots := []  ; Clear the list
}

HandleWaveSelection() {
    while (isMenuOpen("Wave Selection")) {
       result := FindText(&X, &Y, 0, 0, A_ScreenHeight, A_ScreenWidth, 0.50, 0.50, SuperFastWave)
       if (result) {
            FixClick(630, 315)
            Sleep(200)
            FixClick(510, 315)
            Sleep(1000)
       }
    }
}

HandleVoteStart() {
    while (GetPixel(0x12E611, 357, 146, 2, 2, 10)) {
        FixClick(357, 146)
        Sleep(1000)
    }
}

EventHasDifficulty(EventName) {
    static hasDifficulty := ["CSM Event"]

    for mode in hasDifficulty {
        if (mode = EventName)
            return true
    }
    return false
}

CheckIfAnyUnitWasSold() {
    global successfulCoordinates, maxedCoordinates, pausePlacementTracking

    if (successfulCoordinates.Length = 0 && maxedCoordinates.Length = 0) {
        return false
    }

    ; 🖱️ Save current mouse position
    MouseGetPos(&originalX, &originalY)

    AddToLog("Checking if any unit was sold...")

    unitHandled := false  ; <-- Track if any unit was re-placed or found not sold

    if (successfulCoordinates.Length > 0) {
        SendInput("Q")
        for coord in successfulCoordinates {
            slot := coord.slot

            if (isMenuOpen("End Screen")) {
                AddToLog("Stopping unit sold check because the game ended")
                MouseMove originalX, originalY, 0
                return MonitorStage()
            }

            pausePlacementTracking := true

            FixClick(coord.x, coord.y)
            Sleep(500)

            if (WaitForUpgradeText(GetPlacementSpeed())) {
                AddToLog("Unit still exists at x: " coord.x " y: " coord.y)
                CloseUnitUI()
                unitHandled := true
            } else {
                if (PlaceUnit(coord.x, coord.y, slot)) {
                    CloseUnitUI()
                    unitHandled := true
                }
            }

            pausePlacementTracking := false
        }
    }

    if (maxedCoordinates.Length > 0) {
        SendInput("Q")
        i := 1
        while (i <= maxedCoordinates.Length) {
            coord := maxedCoordinates[i]
            slot := coord.slot

            if (isMenuOpen("End Screen")) {
                AddToLog("Stopping unit sold check because the game ended")
                MouseMove originalX, originalY, 0
                SetTimer(CheckIfAnyUnitWasSold, 0)
                return MonitorStage()
            }

            pausePlacementTracking := true

            FixClick(coord.x, coord.y)
            Sleep(500)

            if (WaitForUpgradeText(GetPlacementSpeed())) {
                AddToLog("Unit still exists at x: " coord.x " y: " coord.y)
                CloseUnitUI()
                unitHandled := true
                i++  ; Move to next item
            } else {
                if (PlaceUnit(coord.x, coord.y, slot)) {
                    CloseUnitUI()
                    maxedCoordinates.RemoveAt(i)  ; Remove current unit
                    successfulCoordinates.Push(coord)
                    unitHandled := true
                } else {
                    i++  ; Only increment if not removed
                }
            }

            pausePlacementTracking := false
        }
    }

    ; 🖱️ Restore original mouse position
    MouseMove originalX, originalY, 0

    return unitHandled  ; ✅ Returns true if any unit was confirmed or replaced
}



CloseUnitUI() {
    FixClick(230, 255)
}