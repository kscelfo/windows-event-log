<#
.SYNOPSIS
Retrieves and displays the boot history events (startup and shutdown) from the Windows Event Log.

.DESCRIPTION
This script queries the Windows Event Log for events with IDs 6005 (indicating system startup) 
and 6006 (indicating system shutdown) from the "System" log. It processes these events to 
categorize them as either "Startup" or "Shutdown" and sorts them in descending order by 
their creation time. The results are displayed in an interactive grid view.
#>
$events = @()

Get-WinEvent -FilterHashtable @{LogName = "System"; ID = 6006, 6005 } | `
    Select-Object -Property TimeCreated, `
@{Name = "EventName"; Expression = { if ($_.Id -eq 6005) { "Startup" } else { "Shutdown" } } } | `
    ForEach-Object {
    $events += $_
}

$events = $events | Sort-Object TimeCreated -Descending
$events | Out-GridView -Title "Boot History Events"
