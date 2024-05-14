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

SetTimer(CleanStartMenu, 5000)

CleanStartMenu() {
	SystemDir := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"
	UserDir := A_AppData "\Microsoft\Windows\Start Menu\Programs\"
	Loop Files, SystemDir "*", "D" {
		CheckFile(SystemDir, A_LoopFileName)
	}
	Loop Files, UserDir "*", "D" {
		CheckFile(UserDir, A_LoopFileName)
	}
}

CheckFile(dir, filename) {
	If(filename ~= ".*\[GOG\.com\]") {
		If(InStr(FileGetAttrib(dir filename), "D")) {
			DirDelete(dir filename, true)
		} Else {
			FileDelete(dir filename)
		}
	}
}
