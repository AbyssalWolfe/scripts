#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")

; Check if the script is running as administrator
If(!A_IsAdmin) {
	If(!RegexMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)")) {
		Try {
			RunWait("*RunAs `"" A_AhkPath "`" /restart `"" A_ScriptFullPath "`"")
		}
	}
	MsgBox("This AHK script requires administrator privileges, please run as administrator.")
	ExitApp
}

; Function to clean directories
CleanDir(Directory, Pattern, MoveDirectory?, MovePattern?) {
	If(Type(Directory) == "String") {
		MoveDirectory := MoveDirectory ?? Directory
		MovePattern := MovePattern ?? false

		Loop Files, Directory "\*", "FD" {
			If(A_LoopFileName ~= Pattern) {
				; If file matches the pattern, delete it, checking directories recursively
				If(InStr(FileGetAttrib(A_LoopFileFullPath), "D") && MovePattern) {
					CleanDir(A_LoopFileFullPath, Pattern, MoveDirectory, MovePattern)
					DirDelete(A_LoopFileFullPath, true)
				} Else {
					FileDelete(A_LoopFileFullPath)
				}
			} Else If(Directory != MoveDirectory && A_LoopFileName ~= MovePattern) {
				; If file is not in the move directory and matches the move pattern, move it
				FileMove(A_LoopFileFullPath, MoveDirectory)
			}
		}
	} Else {
		; If multiple directories are passed, call this function recursively
		For(Dir in Directory) {
			CleanDir(Dir, Pattern, MoveDirectory?, MovePattern?)
		}
	}
}

; Main cleanup function
Cleanup() {
	; Which shortcuts to keep in the Start Menu
	StartMenuWhitelist := "File Explorer\.lnk|Firefox\.lnk|Notepad\+\+\.lnk|MPos\.lnk|Sandboxie\.lnk|Steam Desktop Authenticator\.lnk|GOG GALAXY\.lnk|Steam\.lnk|Epic Games Launcher\.lnk|Battle\.net\.lnk|EA\.lnk|Ubisoft Connect\.lnk|Battlestate Games Launcher\.lnk|Intrepid Studios Launcher\.lnk|Prism Launcher\.lnk|Nolvus\.lnk|Vortex\.lnk|Unity Mod Manager\.lnk|BG3 Mod Manager\.lnk|Mod Finder\.lnk"

	; Clean up the Start Menu
	CleanDir([A_ProgramsCommon, A_Programs], "^.*$(?<!Startup|desktop\.ini|" StartMenuWhitelist ")", A_Programs, StartMenuWhitelist)

	; Clean up the Desktop
	CleanDir([A_DesktopCommon, A_Desktop], "^.*$(?<!desktop\.ini)",,)
}

; Run the cleanup function every 5 seconds
SetTimer(Cleanup, 5000)

; Kill switch
F24::ExitApp
