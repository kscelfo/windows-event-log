<#
.SYNOPSIS
Retrieves and processes Windows Security log events related to user logoff activities.

.DESCRIPTION
This script queries the Windows Security event log for events with ID 4634, which correspond to user logoff actions. 
It extracts and formats relevant information such as the time of the event, the subject account, and the logon type. 
The logon type is further translated into a human-readable description for better understanding.
#>

$events = @()

Get-WinEvent -FilterHashtable @{LogName = "Security"; ID = 4634; } | `
    Select-Object -Property TimeCreated, `
@{Name = "Action"; Expression = { "Logoff" } }, `
@{Name = "SubjectAccount"; Expression = { "$($_.Properties[2].Value)\$($_.Properties[1].Value)" } }, `
@{Name = "LogonType"; Expression = { $logonType = $_.Properties[4].Value
        switch ($logonType) {
            0 { "System - Used only by the System account, for example at system startup." }
            2 { "Interactive - A user logged on to this computer using the local keyboard and screen." }
            3 { "Network - A user or computer logged on from the network (e.g., accessing a shared folder)." }
            4 { "Batch - Used by batch servers, where processes run on behalf of a user without direct intervention." }
            5 { "Service - The Service Control Manager started a service." }
            7 { "Unlock - The workstation was unlocked." }
            8 { "NetworkCleartext - A user logged on from the network with credentials in cleartext form." }
            9 { "NewCredentials - A caller cloned its current token and specified new credentials for outbound connections." }
            10 { "RemoteInteractive - A user logged on remotely using Terminal Services or Remote Desktop." }
            11 { "CachedInteractive - A user logged on with locally cached network credentials (domain controller not contacted)." }
            12 { "CachedRemoteInteractive - A user logged on remotely using cached credentials." }
            13 { "CachedUnlock - A user unlocked the workstation using cached credentials." }
            Default { $logonType }
        }
    }
} | ForEach-Object {
    $events += $_
}

$events = @($events | Sort-Object -Property TimeCreated -Descending)
$events | Out-GridView -Title "Logoff Events"