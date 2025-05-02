<#
.SYNOPSIS
Retrieves and formats user logon events from the Windows Security Event Log.

.DESCRIPTION
This script uses the `Get-WinEvent` cmdlet to query the Windows Security Event Log for logon events (Event ID 4624). 
It then formats the output to display relevant information such as the time of the event, the accounts involved, 
the type of logon, the logon process, and the authentication package used.
#>

$events = @()

Get-WinEvent -FilterHashtable @{LogName = "Security"; ID = 4624; } | `
    Select-Object -Property TimeCreated, `
@{Name = "Action"; Expression = { "Logon" } }, `
@{Name = "SubjectAccount"; Expression = { "$($_.Properties[2].Value)\$($_.Properties[1].Value)" } }, `
@{Name = "LogonAccount"; Expression = { "$($_.Properties[6].Value)\$($_.Properties[5].Value)" } }, `
@{Name = "LogonType"; Expression = { $logonType = $_.Properties[8].Value
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
}, `
@{Name = "LogonProcess"; Expression = { "$($_.Properties[9].Value)" } }, `
@{Name = "AuthenticationPackage"; Expression = { "$($_.Properties[10].Value)" } } | ForEach-Object {
    $events += $_
}

$events = @($events | Sort-Object -Property TimeCreated -Descending)
$events | Out-GridView -Title "Logon Events"