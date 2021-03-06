<#
.SYNPOSIS
	Utilities for working with environment variables in powershell	
	
#>
function Set-EnvironmentVariable
{
<#

#>
    param(
        [Parameter(Position=0)][String] $variable,
        [Parameter(Position=1)][String] $value,
        [String] $defaultValue=[String]::Empty)

    if([String]::IsNullOrEmpty( $value))
    {
        $value=$defaultValue;
    }       
    
    Set-Content -Path "env:\$variable" -Value $value
       
}

function Set-EnvironmentVariablesFromHashTable
{
<#
.SYNOPSIS
 	Sets environment variables from a hashtable

.EXAMPLE
 	Set-EnvironmentVariablesFromHashTable @{x_coffee="bitter";x_apple="sweet"}

#>
	param([Parameter(Position=0)][System.Collections.Hashtable] $hashTableWithVariables)
	
    if($hashTableWithVariables -eq $Null -or $hashTableWithVariables.Count -eq 0)
    {
        return;
    }
    
	foreach ($key in $hashTableWithVariables.Keys)
	{
        Set-EnvironmentVariable $key $hashTableWithVariables.get_Item($key)
	}
	
}

function invoke-cmdScript
{
<#
.SYNOPSIS
 	Load environment variables from a command script

.DESCRIPTION
    
    Poached from OReilly - Windows PowerShell Cookbook, http://oreilly.com/catalog/9780596528492/
    Minor modifications
        
.EXAMPLE
 	invoke-cmdScript -script "BatchInteractionWithPowershell.bat" -parameters "CAT DOG"

    Note that you must figure out the quoting of arguments for yourself.
#>
    param([string] $script, [string] $parameters)

    $tempFile = [IO.Path]::GetTempFileName()
    $useFile=(Resolve-Path $script).Path;
    ## Store the output of cmd.exe.  We also ask cmd.exe to output
    ## the environment table after the batch file completes
    cmd /c " `"$useFile`" $parameters && set > `"$tempFile`" "

    ## Go through the environment variables in the temp file.
    ## For each of them, set the variable in our local environment.
    Get-Content $tempFile | Foreach-Object {
        if($_ -match "^(.*?)=(.*)$")
        {
            Set-Content "env:\$($matches[1])" $matches[2]
        }
    }

    Remove-Item $tempFile

}
