<#
	.SYNOPSIS
    Build support for daptiv product
#>
Import-Module  $PSScriptRoot\load-EnvironmentVariables.psm1

[String] $Global:MsBuildExe

function find-ToolsDir
{
	param([string] $frameWorkDir, [string] $frameworkVersion)
    
    if([string]::IsNullOrEmpty($frameWorkDir)) 
    {
        $FrameworkDir = $env:frameworkDir
    }
    
    if([string]::IsNullOrEmpty($frameworkVersion))
    {
        $frameworkVersion = $env:FrameworkVersion
    }
    
	$toolsDir=[System.IO.Path]::Combine($frameWorkDir, $frameworkVersion)			
    return (Resolve-Path $toolsDir).Path
}

function find-MsBuild
{
	param([string] $frameWorkDir, [string] $frameworkVersion)
	$toolsDir= (find-ToolsDir -frameWorkDir $frameWorkDir -frameworkVersion $frameworkVersion)
	$msbuild = [System.IO.Path]::Combine($toolsDir, "msbuild.exe")
	
    write-host "Using msbuild at $msbuild"
	if ($msbuild -eq $Null -or !(Test-Path $msbuild))
	{
		throw ("msbuild.exe not found for " + $frameworkVersion)
	}
	
	return $msbuild
}

function IsNetFx2Installed
{
	return (![String]::IsNullOrEmpty($env:VS90COMNTOOLS));
}

function IsNetFx35Installed
{
	return (!([String]::IsNullOrEmpty($env:VS90COMNTOOLS) -or [String]::IsNullOrEmpty($env:Framework35Version)) )
}

function IsNetFx4Installed
{
	return (![String]::IsNullOrEmpty($env:VS100COMNTOOLS));
}

function IsNetFx45Installed
{
	return (![String]::IsNullOrEmpty($env:VS110COMNTOOLS));
}

function import-VariablesFromVs
{
<#
.SYNOPSIS
Load variables from a visual studio command prompt

.PARAMETER platform
A supported platform, one of

	x86      
	amd64    
	x64      
	ia64     
	x86_amd64
	x86_ia64 

.PARAMETER $toolsDir
The visual studio tools directory 

#>
	param([string] $platform="x86", [string] $toolsDir=$env:VS110COMNTOOLS)
	
    $batchFile = Resolve-Path ([System.IO.Path]::Combine("$toolsDir..\..\vc", "vcvarsall.bat"))
    
    invoke-cmdScript -script $batchFile -parameters $platform
    
	Write-Host @"
Visual Studio Powershell
Variables loaded from $batchFile 
"@
    [System.Console]::Title = "Visual Studio PowerShell"
}

function import-VariablesFromVSLatest
{
<#
.SYNOPSIS
Load variables from latest available visual studio command prompt

.PARAMETER platform
A supported platform, one of

	x86      
	amd64    
	x64      
	ia64     
	x86_amd64
	x86_ia64 

#>
	param([string] $platform="x86")
	
	if (IsNetFx45Installed)
	{
		import-VariablesFromVs -platform $platform -toolsDir $env:VS110COMNTOOLS
	}
	elseif( IsNetFx4Installed ) 
	{	
		import-VariablesFromVs -platform $platform -toolsDir $env:VS100COMNTOOLS
	}
	else
	{
		throw "These build scripts only support .net fx 4"
	}
}

import-VariablesFromVSLatest
$Global:MsBuildExe = find-msbuild