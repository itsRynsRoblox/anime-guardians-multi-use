#Requires AutoHotkey v2.0

StartRaidMode() {

    ; Get current map and act
    currentRaidMap := RaidDropdown.Text
    currentRaidAct := RaidActDropdown.Text

    ; Start stage
    while !(ok := isMenuOpen("Raids")) {
        Teleport("Raid")
    }

    AddToLog("Starting " currentRaidMap " - " currentRaidAct)
    StartRaid(currentRaidMap, currentRaidAct)
    PlayHereOrMatchmake()
    RestartStage()
}

StartRaid(map, act) {
    return StartContent(map, act, GetRaidMap, GetRaidAct, { x: 220, y: 265 }, { x: 350, y: 255 })
}

GetRaidMap(map) {

    RaidMapNames := [
        "Lawless City", "Temple", "Orc Castle", "Kingdom of Wandenreich", "Namakora Village", "Central Command", "The Crimson Eclipse", "Hidden Leaf Village"
    ]

    baseX := 220
    baseY := 265
    spacing := 55

    for index, name in RaidMapNames {
        if (map = name) {
            y := baseY + spacing * (index - 1)
            scrolls := (index > 4 && index < 7) ? 1 : 0  ; Adjust this threshold as needed
            scrolls := (index > 7) ? 2 : scrolls
            if (index = 4) {
                y := 340
            }
            else if (index = 5) {
                y := 395
            }
            else if (index = 6) {
                y := 350
            }
            else if (index = 7) {
                y := 405
            }
            return { x: baseX, y: y, scrolls: scrolls }
        }
    }

    ; Fallback if map not found
    return { x: baseX, y: baseY, scrolls: 0 }
}

GetRaidAct(act) {
    baseX := 350
    baseY := 255
    spacing := 45

    ; Handle numbered Acts
    if RegExMatch(act, "Act\s*(\d+)", &match) {
        actNumber := match[1]
        y := baseY + spacing * (actNumber - 1)
        scrolls := (actNumber >= 5) ? 1 : 0
        return { x: baseX, y: y, scrolls: scrolls }
    }

    ; Fallback for invalid input
    return { x: baseX, y: baseY, scrolls: 0 }
}

TestRaid() {
    currentRaidMap := RaidDropdown.Text
    currentRaidAct := RaidActDropdown.Text
    StartRaid(currentRaidMap, currentRaidAct)
}