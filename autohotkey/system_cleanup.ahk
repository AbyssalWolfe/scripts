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
		MoveDirectory := MoveDirectory ?? Directory
		MovePattern := MovePattern ?? false
		Loop Files, Directory "\*", "FD" {
			If(A_LoopFileName ~= Pattern) {
				If(InStr(FileGetAttrib(A_LoopFileFullPath), "D") && MovePattern) {
					CleanDir(A_LoopFileFullPath, Pattern, MoveDirectory, MovePattern)
					DirDelete(A_LoopFileFullPath, true)
				} Else {
					FileDelete(A_LoopFileFullPath)
				}
			} Else If(Directory != MoveDirectory && A_LoopFileName ~= MovePattern) {
				FileMove(A_LoopFileFullPath, MoveDirectory)
			}
		}
	} Else {
		For(Dir in Directory) {
			CleanDir(Dir, Pattern, MoveDirectory?, MovePattern?)
		}
	}
}

Cleanup() {
	StartMenuWhitelist := "File Explorer\.lnk|Firefox\.lnk|Notepad\+\+\.lnk|GOG GALAXY\.lnk|Steam\.lnk|Epic Games Launcher\.lnk|Battle\.net\.lnk|EA\.lnk|Ubisoft Connect\.lnk|Battlestate Games Launcher\.lnk|Vortex\.lnk"
	CleanDir([A_ProgramsCommon, A_Programs], "^.*$(?<!Startup|desktop\.ini|" StartMenuWhitelist ")", A_Programs, StartMenuWhitelist)
	CleanDir([A_DesktopCommon, A_Desktop], "^.*$(?<!desktop\.ini)",,)
}

SetTimer(Cleanup, 5000)
