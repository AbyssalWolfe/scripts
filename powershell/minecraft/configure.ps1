$jvm_base_args = @("-XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem -XX:+AggressiveOpts -XX:+UseFastAccessorMethods -XX:MaxInlineLevel=15 -XX:MaxVectorSize=32 -XX:+UseCompressedOops -XX:ThreadPriorityPolicy=1 -XX:+UseDynamicNumberOfGCThreads -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=350M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseFPUForSpilling", "-XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:AllocatePrefetchStyle=3 -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:+EagerJVMCI -Dgraal.TuneInlinerExploration=1")
$jvm_memory_args =  "-XX:+UseG1GC -XX:MaxGCPauseMillis=37 -XX:+PerfDisableSharedMem -XX:G1HeapRegionSize=16M -XX:G1NewSizePercent=23 -XX:G1ReservePercent=20 -XX:SurvivorRatio=32 -XX:G1MixedGCCountTarget=3 -XX:G1HeapWastePercent=20 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:MaxTenuringThreshold=1 -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5.0 -XX:GCTimeRatio=99 -XX:G1ConcRefinementServiceIntervalMillis=150 -XX:G1ConcRSHotCardLimit=16 -XX:+UseTransparentHugePages"
$ram = ((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb)

Switch ($ram) {
	{$_ -le 2} {
		$ram = 512
	}
	{$_ -gt 2 -and $_ -le 4} {
		$ram = 1024
	}
	{$_ -gt 4 -and $_ -le 6} {
		$ram = ($ram / 2) * 1024
	}	
	{$_ -lt 12} {
		$ram = 4096
	}
	{$_ -ge 12} {
		$ram = 8192
	}
}

ForEach($obj in (Get-Content -Path "$env:INST_DIR/mmc-pack.json" -Raw | ConvertFrom-Json).components) {
	If($obj.uid -eq "net.minecraft") {
		$mc_ver = (Select-String "(\d+\.\d+\.?\d*)" -InputObject $obj.version).Matches.Groups[1].Value
	}
}

Function editConfig($setting, $value) {
	(Get-Content -Path "$env:INST_DIR/instance.cfg") -Replace "$setting=.*", "$setting=$value" | Set-Content -Path "$env:INST_DIR/instance.cfg"
}

Write-Host "Configuring instance..."

Sleep 1

ForEach($setting in @("OverrideJavaLocation", "OverrideJavaArgs", "OverrideMemory", "MaxMemAlloc", "MinMemAlloc", "JavaPath", "JvmArgs")) {
	Switch ($setting) {
		"Override.*" {
			editConfig $setting "true"
		}
		".*MemAlloc" {
			editConfig $setting $ram
		}
		"JavaPath" {
			Switch -Regex ($mc_ver) {
				"^1\.(\d|1[0-6])\.?\d*$" {
					editConfig $setting "../java/8/bin/javaw.exe"
				}
				"^1\.(1[7-9]\.?\d*|20\.?[1-4]?)$" {
					editConfig $setting "../java/17/bin/javaw.exe"
				}
				"^1\.(20\.[5-9]|(2[1-9]|[3-9]\d)\.?\d*)$" {
					editConfig $setting "../java/21/bin/javaw.exe"
				}
			}
		}
		"JvmArgs" {
			Switch -Regex ($mc_ver) {
				"^1\.(\d|1[0-6])\.?\d*$" {
					editConfig $setting "`"$($jvm_base_args[0]) $jvm_memory_args`""
				}
				"^1\.(1[7-9]|[2-9]\d)\.?\d*$" {
					editConfig $setting "`"$($jvm_base_args[1]) $jvm_memory_args`""
				}
			}
		}
	}
}

[void](New-Object -ComObject Wscript.Shell).Popup("Instance configured, you may now relaunch.")
