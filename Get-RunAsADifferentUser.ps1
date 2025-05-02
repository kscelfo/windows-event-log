# RunAs events are logged in the Security event log with ID 4648.
# This script retrieves those events and formats the output for easier reading.
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
@{Name = "NetworkPort"; Expression = { "$($_.Properties[13].Value)" } }