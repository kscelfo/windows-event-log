<#
.SYNOPSIS
Retrieves and formats "Run As" events from the Windows Security Event Log.

.DESCRIPTION
This script queries the Windows Security Event Log for events with ID 4648, which indicate 
an attempt to log on using explicit credentials (Run As). It extracts and formats relevant 
properties from the event data, such as the logged-in account, the account being used to 
run as, the target server, process information, and network details.

#>
$events = @()

Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id      = 4648
} | Select-Object -Property TimeCreated, `
@{Name = "LoggedInAccount"; Expression = { "$($_.Properties[2].Value)\$($_.Properties[1].Value)" } }, `
@{Name = "RunAsAccount"; Expression = { "$($_.Properties[6].Value)\$($_.Properties[5].Value)" } }, `
@{Name = "TargetServer"; Expression = { "$($_.Properties[8].Value)" } }, `
@{Name = "ProcessId"; Expression = { "$($_.Properties[10].Value)" } }, `
@{Name = "Process"; Expression = { "$($_.Properties[11].Value)" } }, `
@{Name = "NetworkAddress"; Expression = { "$($_.Properties[12].Value)" } }, `
@{Name = "NetworkPort"; Expression = { "$($_.Properties[13].Value)" } } | ForEach-Object {
    $events += $_
}

$events = @($events | Sort-Object -Property TimeCreated -Descending)
$events | Out-GridView -Title "Run As Events"