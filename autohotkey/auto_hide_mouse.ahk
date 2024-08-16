#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")

Timeout := A_TickCount
LastActivityTime := A_TickCount

; Function to check for idle time
CheckIdleTime() {
	Global LastActivityTime
	CurrentTime := A_TickCount

	(CurrentTime - LastActivityTime >= Timeout * 1000) ? DllCall("ShowCursor", "int", 0) : DllCall("ShowCursor", "int", 1)

	LastActivityTime := CurrentTime
}

; Check for idle time every second
SetTimer(CheckIdleTime, 1000)

; Kill switch
F24::ExitApp
