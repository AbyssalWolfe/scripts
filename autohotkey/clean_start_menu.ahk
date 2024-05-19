#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")

If(!A_IsAdmin) {
	If(!RegexMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)")) {
		Try {
			RunWait("*RunAs `"" A_AhkPath "`" /restart `"" A_ScriptFullPath "`"")
		}
	}
	MsgBox("This AHK script requires administrator privileges, please run as administrator.")
	ExitApp
}

CheckFiles(dir) {
	Loop Files, dir "*", "D" {
		If(A_LoopFileName ~= ".*\[GOG\.com\]") {
			If(InStr(FileGetAttrib(dir A_LoopFileName), "D")) {
				DirDelete(dir A_LoopFileName, true)
			} Else {
				FileDelete(dir A_LoopFileName)
			}
		}
	}
}

CleanStartMenu() {
	CheckFiles("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\")
	CheckFiles(A_AppData "\Microsoft\Windows\Start Menu\Programs\")
}

SetTimer(CleanStartMenu, 5000)
