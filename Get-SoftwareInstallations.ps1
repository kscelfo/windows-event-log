<#
.SYNOPSIS
Retrieves a list of software installation events from the Windows Event Log.

.DESCRIPTION
This script collects information about software installations by querying the Windows Event Log for specific events 
related to the "MsiInstaller" provider. It retrieves events with IDs 1033 and 11707, which correspond to installation 
and uninstallation events, respectively. The script extracts relevant details such as the product name, version, 
manufacturer, and the time of the event.

#>

$events = @()

Get-WinEvent -FilterHashtable @{LogName = "Application"; ID = 1033; ProviderName = "MsiInstaller" } | `
    Select-Object -Property TimeCreated, UserId, `
@{Name = "ProductName"; Expression = { $_.Properties[0].Value } }, `
@{Name = "ProductVersion"; Expression = { $_.Properties[1].Value } }, `
@{Name = "ProductManufacturer"; Expression = { $_.Properties[0].Value } } | ForEach-Object {
    
    $events += $_
}


Get-WinEvent -FilterHashtable @{LogName = "Application"; ID = 11707; ProviderName = "MsiInstaller" } | `
    Select-Object -Property TimeCreated, UserId, `
@{Name = "ProductName"; Expression = { $_.Message.Replace('Product: ', '').Split('--')[0].Trim() } }, `
@{Name = "ProductVersion"; Expression = { '-' } }, `
@{Name = "ProductManufacturer"; Expression = { '-' } } | ForEach-Object {
    $events += $_
}

$events = @($events | Sort-Object -Property TimeCreated -Descending)
$events | Out-GridView -Title "Software Installation Events"