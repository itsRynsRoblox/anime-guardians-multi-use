#Requires AutoHotkey v2.0

global alreadyNuked := false
global nukeTimerActive := false
global nukePaused := false
global nukeScheduledTime := 0

StartNukeCapture() {
    global nukeCoords

    ; Reset saved walk coordinates
    nukeCoords := []

    ; Activate Roblox window
    if (WinExist(rblxID)) {
        WinActivate(rblxID)
    }

    AddWaitingFor("Nuke")
    AddToLog("Press LShift to stop coordinate capture")
    SetTimer UpdateTooltip, 50  ; Update tooltip position every 50ms
}

PrepareToNuke() {
    global successfulCoordinates, maxedCoordinates
    if (NukeUnitSlotEnabled.Value) {
        ; try to find in successfulCoordinates
        for index, coord in successfulCoordinates {
            if (coord.slot == NukeUnitSlot.Value) {
                ClickUnit(index)
                return true
            }
        }
        ; try to find in maxedCoordinates
        for index, coord in maxedCoordinates {
            if (coord.slot == NukeUnitSlot.Value) {
                ClickUnit(index)
                return true
            }
        }
        ; Not found in either list
        return false
    }
}

GetNukeDelay() {
    ms := NukeDelay.Value
    return Round(ms * 1000)
}

Nuke() {
    global nukeCoords, alreadyNuked, nukeTimerActive, nukeScheduledTime

    nukeTimerActive := true

    if (PrepareToNuke()) {
        Sleep(150)
        FixClick(nukeCoords.x, nukeCoords.y) ; click nuke
        Sleep(150)
        SendInput("X") ;close unit menu
        alreadyNuked := true
        nukeTimerActive := false  ; reset the flag
    } else {
        nukeScheduledTime := A_TickCount + GetNukeDelay() ; For logging purposes
    }
}

HandleNuke() {
    global alreadyNuked, nukeTimerActive, nukeScheduledTime

    if (!NukeUnitSlotEnabled.Value)
        return false

    if (nukeTimerActive) {
        nukeScheduledTime := A_TickCount + GetNukeDelay()
        return
    }

    nukeScheduledTime := A_TickCount + GetNukeDelay()
    nukeTimerActive := true
    SetTimer(Nuke, GetNukeDelay())
    AddToLog("Nuke scheduled for " nukeScheduledTime " (in " GetNukeDelay() " ms)")
}

ClearNuke() {
    global alreadyNuked, nukeTimerActive
    alreadyNuked := false
    nukeTimerActive := false
    nukePaused := false
    SetTimer(WatchForTargetWave, 0)
    SetTimer(Nuke, 0)
}

GetRemainingNukeTime() {
    global nukeScheduledTime
    remaining := nukeScheduledTime - A_TickCount
    return (remaining > 0) ? remaining : 0
}

PauseNuke() {
    global nukeTimerActive, nukePaused, nukeResumeDelay

    if nukeTimerActive {
        SetTimer(Nuke, 0)
        nukeTimerActive := false
        nukePaused := true
        nukeResumeDelay := GetRemainingNukeTime()
        AddToLog("Nuke check paused with " Round(nukeResumeDelay / 1000, 1) " seconds remaining.")
    }
}

ResumeNuke() {
    global nukePaused, nukeTimerActive, nukeResumeDelay

    if nukePaused {
        SetTimer(Nuke, (NukeAtSpecificWave.Value ? -nukeResumeDelay : nukeResumeDelay))
        nukePaused := false
        nukeTimerActive := true
        AddToLog("Nuke check resumed, will check in " Round(nukeResumeDelay / 1000, 1) " seconds.")
    }
}

CheckWaveText(waveNumber) {
    static coord := [{ x1: 255, y1: 52, x2: 310, y2: 70 }]

    for coords in coord {
        ocrText := OCRFromFile(coords.x1, coords.y1, coords.x2, coords.y2, 2.0, true)
        ocrText := RegExReplace(ocrText, "[^\d\w\s]", "")
        if (debugMessages) {
            AddToLog("Wave Text: " ocrText)
        }

        if (InStr(ocrText, "Wave " waveNumber) || InStr(ocrText, "WAVE " waveNumber) || InStr(ocrText, "wave " waveNumber) | InStr(ocrText, "Wave" waveNumber) || RegExMatch(ocrText, "Wave\s*" waveNumber)) {
            AddToLog("Wave " waveNumber " found.")
            return true
        }
        Sleep 50
    }
    return false
}

StartNukeTimer() {
    global nukeTimerActive, alreadyNuked

    alreadyNuked := false
    nukeTimerActive := false

    if (NukeUnitSlotEnabled.Value) {
        if (NukeAtSpecificWave.Value) {
            ; Start checking for the wave every X ms
            SetTimer(WatchForTargetWave, 1000)  ; Adjust interval as needed
            AddToLog("Started watching for wave " NukeWave.Value "...")
        } else {
            ; Schedule regular time-based nuke
            HandleNuke()
        }
    }
}

WatchForTargetWave() {
    global alreadyNuked, nukePaused

    if (alreadyNuked) {
        SetTimer(WatchForTargetWave, 0) ; stop checking
        return
    }

    if (CheckWaveText(NukeWave.Value) && !nukePaused) {
        AddToLog("Wave " NukeWave.Value " found. Nuking...")
        Nuke()
        alreadyNuked := true
        SetTimer(WatchForTargetWave, 0) ; stop checking after nuke
    }
}