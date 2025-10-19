#Requires AutoHotkey v2.0

StartStoryMode() {
    
    ; Get current map and act
    currentStoryMap := StoryDropdown.Text
    currentStoryAct := StoryActDropdown.Text
        
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentStoryMap)
    
    ; Start stage
    while !(ok := isMenuOpen("Story")) {
        Teleport("Story")
    }

    AddToLog("Starting " currentStoryMap " - " currentStoryAct)
    StartStory(currentStoryMap, currentStoryAct)

    ; Handle play mode selection
    PlayHereOrMatchmake()
    RestartStage()
}

StartStory(map, act) {
    return StartContent(map, act, GetStoryMap, GetStoryAct, { x: 220, y: 265 }, { x: 350, y: 255 })
}

GetStoryMap(map) {
    switch map {
        case "Large Village": return {x: 220, y: 265, scrolls: 0}
        case "Hollow Land": return {x: 220, y: 315, scrolls: 0}
        case "Monster City": return {x: 220, y: 375, scrolls: 0}
        case "Academy Demon": return {x: 220, y: 420, scrolls: 0}
    }
}

GetStoryAct(act) {
    baseX := 350
    baseY := 255
    spacing := 35

    if (act = "Infinite") {
        y := baseY
        return { x: 348, y: 423, scrolls: 1 }
    }

    ; Handle numbered Acts
    if RegExMatch(act, "Act\s*(\d+)", &match) {
        actNumber := match[1]
        y := baseY + spacing * (actNumber - 1)
        scrolls := (actNumber >= 6) ? 1 : 0
        return { x: baseX, y: y, scrolls: scrolls }
    }

    ; Fallback for invalid input
    return { x: baseX, y: baseY, scrolls: 0 }
}

SelectDifficulty(name := "") {

    if (StoryActDropdown.Text = "Infinite") {
        name := "Nightmare"
    }

    switch name {
        case "Normal":
            FixClick(545, 355)
        case "Nightmare":
            FixClick(615, 355)    
    }
    Sleep(1000)
}

WalkToStoryRoom() {
    Walk("a", 1500)
    Walk("w", 1500)
    Walk("a", 3200)
    Walk("w", 2500)
}

TestStory() {
    currentStoryMap := StoryDropdown.Text
    currentStoryAct := StoryActDropdown.Text
    StartStory(currentStoryMap, currentStoryAct)
}