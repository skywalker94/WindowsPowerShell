## --- --- --- --- --- ALIASES --- --- --- --- ---

Set-Alias port Get-PortStatus



## --- --- --- --- --- FUNCTIONS --- --- --- --- ---

function Test-ValidPortNumber($port) {
    # 1. Ensure it's not empty and is only digits
    if ($null -eq $port -or $port -notmatch '^\d+$') { return $false }

    # 2. Check length first! If it's more than 5 digits, it's impossible (max is 65535)
    # This prevents the [int] conversion crash for massive numbers
    if ($port.Length -gt 5) { 
        return $false
    }

    # 3. Now it's safe to convert to a number and check the range
    $portNum = [int]$port
    if ($portNum -ge 0 -and $portNum -le 65535) {
        return $true
    }

    return $false
}

# Port enquiry. Usage: "port 22" OR "Get-PortStatus 80" (REQUIRES: function 'Test-ValidPortNumber')
function Get-PortStatus {
    param($port)
    if (!$port) { Write-Host "Please specify a port. Example: port 8080" -ForegroundColor Cyan; return }

    # test whether the port is a valid number and within the acceptable range
    if (-not(Test-ValidPortNumber $port)) {
        Write-Host "[!] Invalid Port: '$port'. Please enter a number between 0 and 65535." -ForegroundColor Yellow
        return
    }

    # SilentlyContinue prevents the red error text if the port is empty
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    
    if ($connection) {
        $connection | Select-Object LocalPort, OwningProcess, State | Format-Table -AutoSize
        Write-Host "Tip: Use 'taskkill /PID <ID> /F' to force stop the process." -ForegroundColor DarkGray
    } else {
        Write-Host "Port $port is clear. No active connections found." -ForegroundColor Green
    }
}