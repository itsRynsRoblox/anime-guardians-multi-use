#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Event"
CoordMode("Mouse", "Window")
CoordMode("Pixel", "Window")
global scriptInitialized := false

; === Testing and Debugging ===
#Include %A_ScriptDir%/lib/Toggles.ahk

; === Main Script ===
#Include %A_ScriptDir%/lib/GUI.ahk
#Include %A_ScriptDir%/lib/GameMango.ahk

; === Saving and Loading Configs ===
#Include %A_ScriptDir%/lib/Config.ahk

; === Tool Libraries ===
#Include %A_ScriptDir%/lib/Tools/FindText.ahk
#Include %A_ScriptDir%/lib/Tools/Image.ahk
#Include %A_ScriptDir%\Lib\OCR-main\Lib\OCR.ahk

; === Game Modes ===
#Include %A_ScriptDir%/lib/Modes/Portal.ahk
#Include %A_ScriptDir%/lib/Modes/Story.ahk
#Include %A_ScriptDir%/lib/Modes/Raid.ahk

; === Limited Time Game Modes ===
#Include %A_ScriptDir%/lib/Modes/Limited/SummerEvent.ahk
#Include %A_ScriptDir%/lib/Modes/Limited/CSMEvent.ahk

; === Core Mechanics ===
#Include %A_ScriptDir%/lib/Functions/Functions.ahk
#Include %A_ScriptDir%/lib/Functions/Upgrading.ahk
#Include %A_ScriptDir%/lib/Functions/UnitPlacement.ahk
#Include %A_ScriptDir%/lib/Functions/WalkManager.ahk
#Include %A_ScriptDir%/lib/PlacementPatterns.ahk
#Include %A_ScriptDir%/lib/Functions/NukeManager.ahk
#Include %A_ScriptDir%/lib/Functions/CardManager.ahk
#Include %A_ScriptDir%/lib/Functions/CooldownManager.ahk
#Include %A_ScriptDir%/lib/Functions/TimerManager.ahk

; === Webhook Integration ===
#Include %A_ScriptDir%/lib/WebhookSettings.ahk

global scriptInitialized := true