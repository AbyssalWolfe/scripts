#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
DetectHiddenWindows(True)

PID_list := Map()

Loop {
	Loop Files, A_WorkingDir "\Macros\*.ahk" {
		If(PID_list.Has(A_LoopFileName)) {
			If(ProcessExist(PID_list[A_LoopFileName]) && WinExist(A_LoopFileName)) {
				Break
			} Else If(!ProcessExist(PID_list[A_LoopFileName])) {
				If(WinExist(A_LoopFileName)) {
					WinClose(A_LoopFileName)
				}
				PID_list.Delete(A_LoopFileName)
			}
		}
		If(PID := ProcessExist(SubStr(A_LoopFileName, 1, -4) ".exe")) {
			PID_list[A_LoopFileName] := PID
			Try {
				Run(A_LoopFileFullPath, A_WorkingDir "\Macros")
			} Catch {
				MsgBox(A_LoopFileName " doesn't exist.")
			}
		}
	}
	Sleep(5000)
} Until GetKeyState("F24")

F24::ExitApp
