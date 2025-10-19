#Requires AutoHotkey v2.0

StartCSMEvent() {

    while !(ok := isMenuOpen("CSM Event")) {
        FixClick(775, 255)
        Sleep(2500)
    }

    SelectEventDifficulty(EventDifficultyDropdown.Text)

    PlayEventOrMatchmake()
    RestartStage()

}

SelectEventDifficulty(Difficulty) {
    switch (Difficulty) {
        case "Easy":
            FixClick(235, 455)
            Sleep(500)
        case "Hard":
            FixClick(305, 455) ; Press play
            Sleep(500)
        case "Hell":
            FixClick(375, 455)
            Sleep(500)   
    }
}