#Requires AutoHotkey v2.0

StartSummerEvent() {

    while !(ok := isMenuOpen("Summer Event")) {
        FixClick(775, 305)
        Sleep(2500)
    }

    PlayEventOrMatchmake()
    RestartStage()

}

PlayEventOrMatchmake() {
    if (Matchmaking.Value) {
        FixClick(356, 422)
    } else {
        FixClick(250, 422) ; Press play
        Sleep(500)
        FixClick(108, 286) ; Press Create Match
        Sleep(500)
        FixClick(78, 399)
    }
    WaitForMapChange()
    RestartStage()
}