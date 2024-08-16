#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")

; Lock the state of the CapsLock, NumLock, and ScrollLock keys
SetCapsLockState("AlwaysOff")
SetNumLockState("AlwaysOn")
SetScrollLockState("AlwaysOff")

; Remap the CapsLock, NumLock, and ScrollLock keys to nothing
*CapsLock::Return
*NumLock::Return
*ScrollLock::Return

; Kill switch
F24::ExitApp
