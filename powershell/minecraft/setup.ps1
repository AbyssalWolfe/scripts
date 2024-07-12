$global:ProgressPreference = "SilentlyContinue"
$java_tags = @(((Invoke-WebRequest -Uri https://github.com/adoptium/temurin8-binaries/releases/latest -Headers @{"Accept"="application/json"}).Content | ConvertFrom-Json).tag_name, ((Invoke-WebRequest -Uri https://github.com/adoptium/temurin11-binaries/releases/latest -Headers @{"Accept"="application/json"}).Content | ConvertFrom-Json).tag_name)
$java_tag_artifacts = @(($java_tags[0] | Select-String -Pattern "jdk([^-]*)-(.*)"), ($java_tags[1] | Select-String -Pattern "jdk-([^+]*)\+(.*)"))
$java_urls = @("https://github.com/adoptium/temurin8-binaries/releases/download/$($java_tags[0])/OpenJDK8U-jre_x64_windows_hotspot_$($java_tag_artifacts[0].Matches.Groups[1].Value)$($java_tag_artifacts[0].Matches.Groups[2].Value).zip", "https://github.com/adoptium/temurin8-binaries/releases/download/$($java_tags[0])/OpenJDK8U-jre_x64_windows_hotspot_$($java_tag_artifacts[0].Matches.Groups[1].Value)$($java_tag_artifacts[0].Matches.Groups[2].Value).zip.sha256.txt", "https://github.com/adoptium/temurin11-binaries/releases/download/$($java_tags[1])/OpenJDK11U-jre_x64_windows_hotspot_$($java_tag_artifacts[1].Matches.Groups[1].Value)_$($java_tag_artifacts[1].Matches.Groups[2].Value).zip", "https://github.com/adoptium/temurin11-binaries/releases/download/$($java_tags[1])/OpenJDK11U-jre_x64_windows_hotspot_$($java_tag_artifacts[1].Matches.Groups[1].Value)_$($java_tag_artifacts[1].Matches.Groups[2].Value).zip.sha256.txt", "https://download.oracle.com/graalvm/17/latest/graalvm-jdk-17_windows-x64_bin.zip", "https://download.oracle.com/graalvm/17/latest/graalvm-jdk-17_windows-x64_bin.zip.sha256", "https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_windows-x64_bin.zip", "https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_windows-x64_bin.zip.sha256")
$prism_tag = ((Invoke-WebRequest https://github.com/PrismLauncher/PrismLauncher/releases/latest -Headers @{"Accept"="application/json"}).Content | ConvertFrom-Json).tag_name
$prism_url = "https://github.com/PrismLauncher/PrismLauncher/releases/download/$prism_tag/PrismLauncher-Windows-MSVC-Portable-$prism_tag.zip"

Write-Host "Creating game directory..."
[void](New-Item -Path "Minecraft" -Type Directory)
Set-Location -Path "Minecraft"

[void](New-Item -Path "java","launcher", "scripts","shared/datapacks","shared/resourcepacks","shared/shaderpacks" -Type Directory)
[void](New-Item -Path "shared/servers.dat" -Type File)

Set-Location -Path "java"

@("8", "11", "17", "21") | ForEach-Object {$i = 0} {
	Write-Host "Downloading Java $_..."
	Invoke-WebRequest -Uri $java_urls[$i] -OutFile "$_.zip"
	Invoke-WebRequest -Uri $java_urls[$i + 1] -OutFile "$_.sha256"
	Expand-Archive -Path "$_.zip" -DestinationPath "."
	Remove-Item -Path "$_.zip"
	If($_ -eq "8" -or $_ -eq "11") {
		Get-Item -Path "*jre" | Rename-Item -NewName $_
	} Else {
		Get-Item -Path "graalvm-*" | Rename-Item -NewName $_
	}
	$i += 2
}

Set-Location -Path "../"

Write-Host "Downloading Prism Launcher..."
Invoke-WebRequest -Uri $prism_url -OutFile "prism.zip"
Expand-Archive -Path "prism.zip" -DestinationPath "launcher"
Remove-Item -Path "prism.zip"

Write-Host "Configuring Prism Launcher..."
[void](New-Item -Path "launcher/prismlauncher.cfg" -Type File)
Add-Content -Path "launcher/prismlauncher.cfg" "[General]
ConfigVersion=1.2
ApplicationTheme=dark
IconTheme=pe_colored
LastHostname=null
Language=en_US
JavaPath=../java/8/bin/javaw.exe
MaxMemAlloc=4096
MinMemAlloc=4096
PostExitCommand=powershell ../../../../scripts/post-exit.ps1
PreLaunchCommand=powershell ../../../../scripts/pre-launch.ps1
ConsoleOverflowStop=false
ShowConsoleOnError=false"

Set-Location -Path "scripts"

ForEach($script in @("configure.ps1", "pre-launch.ps1", "post-exit.ps1")) {
	Write-Host "Downloading $script..."
	Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AbyssalWolfe/scripts/master/powershell/minecraft/$script" -OutFile $script
}

Set-Location -Path "../"

Write-Host "Creating shared resource README..."
Set-Content -Path "shared/README.txt" -Value "This folder is for shared resources, such as texture/resource packs, shader packs and data packs.`n`nFor pre 1.6 texture packs or resource packs you only want to show on specific versions, create a folder inside the 'resourcepacks' folder named after the major version number (e.g. '1.8' or '1.17', but not '1.8.9' or '1.17.1') and place the pack in there."

Set-Location -Path "launcher"
Start-Process -FilePath "./prismlauncher.exe"
Sleep 1
Stop-Process -Name "prismlauncher"

Set-Location -Path "../../"
Remove-Item -Path "setup.ps1"

Clear
Write-Host "Done"
[void](New-Object -ComObject Wscript.Shell).Popup("Setup finished!`r`n`nAll Java settings (such as RAM and JVM arguments) within Prism Launcher will be managed by my scripts, so don't change them.`r`n`nYou can put resource/data/shader packs in their designated folders in the 'shared' folder, make sure to read the README for info about pre 1.6 texture packs and version specific folders.")
