﻿<#
.SYNOPSIS
   Displays available free space. 
.DESCRIPTION
   Displays available free space on local drives. System Reserved and Recovery drives are excluded.
.EXAMPLE
   Get-FreeSpace | Where-Object {$_."Free(GB)" -lt "10"}

   Returns computers with less than 10 GB free space.
.EXAMPLE
   Get-FreeSpace | Where-Object {$_."Free(%)" -lt "20"}

   Returns computers with less than 20% free space.
.EXAMPLE
   Get-ADComputer -Filter 'OperatingSystem -like "*server*"' | Get-FreeSpace | ft

   Builds server list from AD and gathers free space.
#>
function Get-FreeSpace
{
    [CmdletBinding()]
    Param
    (
        [Alias('ComputerName')]
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$Name = 'localhost'
    )
    Begin
    {
           Write-Verbose 'Testing'
    }
    Process
    {
        Foreach($Computer in $Name)
        {
            Try{
                $volume = Get-WmiObject -ComputerName $Computer Win32_Volume -ErrorAction Stop -ErrorVariable GFSError
        
                Foreach($drive in $volume){
                    If ($drive.drivetype -eq 3 -and $drive.label -ne "System Reserved" -and $drive.label -ne "Recovery"){
                    
                        $Prop = [ordered]@{
                            'ComputerName' = $Computer
                            'Drive'        = $drive.name
                            'Description'  = $drive.label
                            'Total(GB)'    = [math]::round($drive.capacity / 1GB)
                            'Free(GB)'     = [math]::round($drive.freespace / 1GB)
                            'Free(%)'      = [math]::round(($drive.freespace / $drive.capacity)*100)
                        }
      
                     $Obj = New-Object -TypeName PSObject -Property $Prop
                     Write-Output $Obj

                    }
                }
            }
            Catch [System.Runtime.InteropServices.COMException]{
                Write-Warning "Could not connect to $Computer."    
            }
            Catch{
                Write-Error $GFSError
            }
        }
    }
    End
    {
    }
}