#Requires AutoHotkey v2.0
#SingleInstance force
SendMode Input

Timeout := A_TickCount
LastActivityTime := A_TickCount
SetTimer(CheckIdleTime, 1000)

CheckIdleTime() {
	Global LastActivityTime
	CurrentTime := A_TickCount

	If(CurrentTime - LastActivityTime >= Timeout * 1000) {
		DllCall("ShowCursor", "int", 0)
	} Else {
		DllCall("ShowCursor", "int", 1)
	}

	LastActivityTime := CurrentTime
}
