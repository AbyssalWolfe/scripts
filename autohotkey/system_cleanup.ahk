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

CleanDir(Directory, Pattern, MoveDirectory?, MovePattern?) {
	If(Type(Directory) == "String") {
		MoveDir := MoveDirectory ?? Directory
		Loop Files, Directory "\*", "FD" {
			If(A_LoopFileName ~= Pattern) {
				If(InStr(FileGetAttrib(A_LoopFileFullPath), "D")) {
					If(MovePattern) {
						Loop Files, A_LoopFileFullPath "\*" {
							If(A_LoopFileName ~= MovePattern) {
								FileMove(A_LoopFileFullPath, MoveDir)
							}
						}
					}
					DirDelete(A_LoopFileFullPath, true)
				} Else {
					(MoveDir != Directory && A_LoopFileName ~= MovePattern) ? FileMove(A_LoopFileFullPath, MoveDir) : FileDelete(A_LoopFileFullPath)
				}
			}
		}
	} Else {
		For(Dir in Directory) {
			CleanDir(Dir, Pattern, MoveDirectory?, MovePattern?)
		}
	}
}

Cleanup() {
	StartMenuDirs := ["C:\ProgramData\Microsoft\Windows\Start Menu\Programs", A_AppData "\Microsoft\Windows\Start Menu\Programs"]
	CleanDir(StartMenuDirs, ".*\[GOG\.com\]")
}

SetTimer(Cleanup, 5000)
