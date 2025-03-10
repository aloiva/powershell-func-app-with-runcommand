using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

$command = $Request.Query.Command
if (-not $command) {
    $command = $Request.Body.Command
}

$clearCache = $Request.Query.ClearCache
if (-not $clearCache) {
    $clearCache = $Request.Body.ClearCache
}

function RunCommand($command) {
    try {
        $output = Invoke-Expression -Command $command
        return $output
    } catch {
        return $_.Exception.Message
    }
}

$response = ""

if ($name) {
    $response = "Hello, $name. This HTTP triggered function executed successfully."
} elseif ($command) {
    $response = RunCommand $command
} elseif($clearCache -eq "true"){
    $localTime = Get-Date
    $localTimeZone = [System.TimeZoneInfo]::Local.DisplayName
    $timeZoneEnv = $env:TZ
    $res = "Current local time: $localTime, `nLocal time zone: $localTimeZone, `nTZ environment variable: $timeZoneEnv."
    # reset TZ
    if ($timeZoneEnv) {
        [System.TimeZoneInfo]::ClearCachedData()
        # [System.DateTime]::Now
    }

    $localTime = Get-Date
    $localTimeZone = [System.TimeZoneInfo]::Local.DisplayName
    $timeZoneEnv = $env:TZ
    $res += "`nAfter clearing cache. `nCurrent local time: $localTime`nLocal time zone: $localTimeZone, `nTZ environment variable: $timeZoneEnv."

    $response = $res
} else {
    $response = "This http trigger function executed successfully at $(Get-Date). Timezone: $([System.TimeZoneInfo]::Local.DisplayName)."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $response
})
