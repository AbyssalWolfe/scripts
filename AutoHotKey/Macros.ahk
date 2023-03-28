#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
DetectHiddenWindows True

Loop {
	Loop Files, A_WorkingDir "\Macros\*.ahk" {
		If (PID := ProcessExist(SubStr(A_LoopFileName, 1, -4) ".exe")) {
			Try Run(A_LoopFileFullPath, A_WorkingDir "\Macros")
			Catch
				MsgBox(A_LoopFileName " doesn't exist.")
			ProcessWaitClose(PID)
			If WinExist(A_LoopFileName)
				WinClose
		}
	}
	Sleep 5000
} Until GetKeyState("F24")

F24::ExitApp