#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
DetectHiddenWindows(True)

; List of all running macros
PID_List := Map()

Loop {
	Loop Files, "Macros\*.ahk" {
		; If the macro is already running, check if the process is still running, if not, stop the macro
		If(PID_List.Has(A_LoopFileName)) {
			If(ProcessExist(PID_List[A_LoopFileName]) && WinExist(A_LoopFileName)) {
				Break
			} Else If(!ProcessExist(PID_List[A_LoopFileName])) {
				If(WinExist(A_LoopFileName)) {
					WinClose(A_LoopFileName)
				}
				PID_List.Delete(A_LoopFileName)
			}
		}

		; If the macro is not running, start it
		If(PID := ProcessExist(SubStr(A_LoopFileName, 1, -4) ".exe")) {
			PID_List[A_LoopFileName] := PID
			Try {
				Run(A_LoopFileFullPath, A_WorkingDir "\Macros")
			} Catch {
				MsgBox(A_LoopFileName " doesn't exist.")
			}
		}
	}
	Sleep(5000)
} Until GetKeyState("F24")

; Kill switch
F24::ExitApp
