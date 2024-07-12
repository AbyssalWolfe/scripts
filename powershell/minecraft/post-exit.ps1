Write-Host "Cleaning up symlinks..."
ForEach($dir in @("$env:INST_MC_DIR/texturepacks", "$env:INST_MC_DIR/resourcepacks", "$env:INST_MC_DIR/datapacks", "$env:INST_MC_DIR/shaderpacks")) {
	If(Test-Path -Path $dir) {
		Get-ChildItem -Path $dir -Attributes ReparsePoint | ForEach-Object {
			Remove-Item -Path "$dir\$_"
		}
	}
}
If((Get-Item -Path "$env:INST_MC_DIR/servers.dat").Attributes -band [IO.FileAttributes]::ReparsePoint) {
	Remove-Item -Path "$env:INST_MC_DIR/servers.dat"
}
