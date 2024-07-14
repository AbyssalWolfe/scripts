$global:ProgressPreference = "SilentlyContinue"
$java_tags = @(((Invoke-WebRequest -Uri https://github.com/adoptium/temurin8-binaries/releases/latest -Headers @{"Accept"="application/json"}).Content | ConvertFrom-Json).tag_name, ((Invoke-WebRequest -Uri https://github.com/adoptium/temurin11-binaries/releases/latest -Headers @{"Accept"="application/json"}).Content | ConvertFrom-Json).tag_name)
$java_tag_artifacts = @(($java_tags[0] | Select-String -Pattern "jdk([^-]*)-(.*)"), ($java_tags[1] | Select-String -Pattern "jdk-([^+]*)\+(.*)"))
$java_urls = @("https://github.com/adoptium/temurin8-binaries/releases/download/$($java_tags[0])/OpenJDK8U-jre_x64_windows_hotspot_$($java_tag_artifacts[0].Matches.Groups[1].Value)$($java_tag_artifacts[0].Matches.Groups[2].Value).zip", "https://github.com/adoptium/temurin8-binaries/releases/download/$($java_tags[0])/OpenJDK8U-jre_x64_windows_hotspot_$($java_tag_artifacts[0].Matches.Groups[1].Value)$($java_tag_artifacts[0].Matches.Groups[2].Value).zip.sha256.txt", "https://github.com/adoptium/temurin11-binaries/releases/download/$($java_tags[1])/OpenJDK11U-jre_x64_windows_hotspot_$($java_tag_artifacts[1].Matches.Groups[1].Value)_$($java_tag_artifacts[1].Matches.Groups[2].Value).zip", "https://github.com/adoptium/temurin11-binaries/releases/download/$($java_tags[1])/OpenJDK11U-jre_x64_windows_hotspot_$($java_tag_artifacts[1].Matches.Groups[1].Value)_$($java_tag_artifacts[1].Matches.Groups[2].Value).zip.sha256.txt", "https://download.oracle.com/graalvm/17/latest/graalvm-jdk-17_windows-x64_bin.zip", "https://download.oracle.com/graalvm/17/latest/graalvm-jdk-17_windows-x64_bin.zip.sha256", "https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_windows-x64_bin.zip", "https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_windows-x64_bin.zip.sha256")

Set-Location -Path $env:INST_DIR

ForEach($obj in (Get-Content -Path "mmc-pack.json" -Raw | ConvertFrom-Json).components) {
	If($obj.uid -eq "net.minecraft") {
		$mc_ver = (Select-String "(\d+\.\d+)\.?\d*" -InputObject $obj.version).Matches.Groups[1].Value
	}
}

Set-Location -Path "../../../scripts"

Write-Host "Checking for script updates..."
ForEach($script in @("configure.ps1", "pre-launch.ps1", "post-exit.ps1")) {
	If((Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AbyssalWolfe/scripts/master/powershell/minecraft/$script").RawContent -notmatch (Get-Content -Path $script)) {
		Write-Host "Updating $script..."
		Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AbyssalWolfe/scripts/master/powershell/minecraft/$script" -OutFile $script
		# If($script -eq "pre-launch.ps1") {
		# 	[void](New-Object -ComObject Wscript.Shell).Popup("Pre-launch script updated, relaunch required.")
		# 	Exit(1)
		# }
	}
}

Set-Location -Path "../java"

Write-Host "Checking for Java updates..."
@("8", "11", "17", "21") | ForEach-Object {$i = 0} {
	If((Invoke-WebRequest -Uri $java_urls[$i + 1]).RawContent -notmatch (Get-Content -Path "$_.sha256")) {
		Write-Host "Updating Java $_..."
		Remove-Item -Path $_ -Recurse
		Remove-Item -Path "$_.sha256"
		Invoke-WebRequest -Uri $java_urls[$i] -OutFile "$_.zip"
		Invoke-WebRequest -Uri $java_urls[$i + 1] -OutFile "$_.sha256"
		Expand-Archive -Path "$_.zip" -DestinationPath "."
		Remove-Item -Path "$_.zip"
		If($_ -eq "8" -or $_ -eq "11") {
			Get-Item -Path "*jre" | Rename-Item -NewName $_
		} Else {
			Get-Item -Path "graalvm-*" | Rename-Item -NewName $_
		}
	}
	$i += 2
}

Set-Location -Path "../"

If((Get-Content -Path "$env:INST_DIR/instance.cfg" | Select-String -Pattern "OverrideJavaLocation=") -match "OverrideJavaLocation=false") {
	Write-Host "Spawning new process to configure the instance post-exit, relaunch after configuration."
	Start-Process -FilePath "powershell" -ArgumentList "-File scripts/configure.ps1" -Style Hidden
	Exit(1)
}

Write-Host "Cleaning up lingering symlinks..."
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

Write-Host "Creating symlinks to shared resources..."
Switch -Regex ($mc_ver) {
	"^1\.[0-5]$" {
		Break
	}
	"^1\.([6-9]|\d{2,})$" {
		Get-ChildItem -Path "shared/resourcepacks" -Filter "*.zip" | ForEach-Object {
			[void](New-Item -ItemType SymbolicLink -Force -Path "$env:INST_MC_DIR/resourcepacks/$_" -Target "shared/resourcepacks/$_")
		}
	}
	"^1\.(1[3-9]|[2-9]\d)$" {
		Get-ChildItem -Path "shared/datapacks" -Filter "*.zip" | ForEach-Object {
			[void](New-Item -ItemType SymbolicLink -Force -Path "$env:INST_MC_DIR/datapacks/$_" -Target "shared/datapacks/$_")
		}
	}
}
If(Test-Path -Path "shared/resourcepacks/$mc_ver") {
	Get-ChildItem -Path "shared/resourcepacks/$mc_ver" -Filter "*.zip" | ForEach-Object {
		If([Int]($mc_ver.SubString($mc_ver.IndexOf(".") + 1)) -ge 6) {
			[void](New-Item -ItemType SymbolicLink -Force -Path "$env:INST_MC_DIR/resourcepacks/$_" -Target "shared/resourcepacks/$mc_ver/$_")
		} Else {
			[void](New-Item -ItemType SymbolicLink -Force -Path "$env:INST_MC_DIR/texturepacks/$_" -Target "shared/resourcepacks/$mc_ver/$_")
		}
	}
}
Get-ChildItem -Path "shared/shaderpacks" -Filter "*.zip" | ForEach-Object {
	[void](New-Item -ItemType SymbolicLink -Force -Path "$env:INST_MC_DIR/shaderpacks/$_" -Target "shared/shaderpacks/$_")
}
[void](New-Item -ItemType SymbolicLink -Force -Path "$env:INST_MC_DIR/servers.dat" -Target "shared/servers.dat")
