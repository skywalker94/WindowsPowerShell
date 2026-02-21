## --- --- --- --- --- SETTINGS AND ENCODING --- --- --- --- ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

## --- --- --- --- --- ALIASES --- --- --- --- ---
## Format 1: Set-Alias -Name <alias> -Value <command>
## Example1: Set-Alias -Name ll -Value Get-ChildItem
## Format 2: New-Alias <alias> <command>
## Example2: New-Alias ll Get-ChildItem

Set-Alias -Name ss -Value btop4win

Set-Alias grep Select-String

Set-Alias port Get-PortStatus

Set-Alias google Invoke-GoogleSearch
Set-Alias youtube Invoke-YouTubeSearch

## --- --- --- --- --- FUNCTIONS --- --- --- --- ---

# quick function for a shortcut to edit the $PROFILE (the .bashrc equivalent)
function edit { code $PROFILE }

function editpro { code (Split-Path $PROFILE) }

# Nice path display for powershell
function files { Get-ChildItem | Select-Object Name, LastWriteTime, @{Name="Size(MB)";Expression={"{0:N2}" -f ($_.Length / 1MB)}} | Out-Host }

# Daily quote from ZenQuotes API (REQUIRES: function 'say')
function quote {
    try {
        # Using a more reliable API
        $url = "https://zenquotes.io/api/random"
        $data = curl.exe -s $url | ConvertFrom-Json
        
        # ZenQuotes returns an array, so we take the first object [0]
        $content = $data[0].q
        $author = $data[0].a

        Write-Host "`n`"$content`"" -Italic -ForegroundColor Yellow
        Write-Host " - $author`n" -ForegroundColor Gray
    } catch {
        Write-Host "Unable to fetch quote. System offline?" -ForegroundColor DarkGray
    }
}

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

# provide a countdown with an audio chime to announce completion
function countdown ($seconds, $taskName) {
    if (!$seconds) { $seconds = 10 }
    $total = $seconds
    $barWidth = 20 # You can adjust this to make the bar longer or shorter

    foreach ($i in $seconds..1) {
        # Calculate progress for the bar
        $completed = [math]::Floor((($total - $i) / $total) * $barWidth)
        $remaining = $barWidth - $completed
        
        # Build the bar string: [####______] using standard block characters that UTF-8 supports
        $bar = ("#" * $completed) + ("_" * $remaining)

        # Output the line
        Write-Host -NoNewline "`rTimer: "
	    Write-Host -NoNewline "s [$bar] "
        Write-Host -NoNewline "$i" -ForegroundColor Cyan 
	    Write-Host -NoNewline "s."
        
        Start-Sleep -Seconds 1
    }

    # Prepare the completion message
    $msg = "COMPLETE!"
    if ($taskName) { $msg = "Timer complete: $taskName" }

    # Clear the line (extra spaces at the end to overwrite any leftover characters)
    Write-Host "`r$msg                                                                    " -ForegroundColor Green
    
    # Alert Chime
    [Console]::Beep(432, 1000)
    
    # Tell user which countdown is complete
    if ($taskName) {
        say "Count-down complete for: $taskName"
    } else {
        say "Count-down complete"
    }
}

# HELPER: Test whether a search query is valid for use in a web search
function Test-SearchQuery {
    param([string]$Query)

    # 1. Check if empty or just whitespace
    if ([string]::IsNullOrWhiteSpace($Query)) { return $false }

    # 2. Length Check: Google's URL limit is 2048-ish, but 500 is plenty here.
    $AllowedQueryLength = 500
    if ($Query.Length -gt $AllowedQueryLength) {
        Write-Host "[!] Search query is too long (Max $AllowedQueryLength chars)." -ForegroundColor Yellow
        return $false
    }

    return $true
}

# HELPER: Convert a string to URL-encoded format (e.g., "Fish & Chips" -> "Fish%20%26%20Chips")
function ConvertTo-UrlEncoded {
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputString
    )
    
    # Using the robust .NET method to prevent "funny business"
    return [uri]::EscapeDataString($InputString)
}

# WebSearch functionlity. Usage: google "how to bake sourdough" (REQUIRES: function 'Test-SearchQuery', 'ConvertTo-UrlEncoded')
function Invoke-GoogleSearch {
    param(
        [Parameter(Position = 0)]
        [string]$Query
    )

    # A. Interactively prompt if the user didn't provide a query on the command line
    if ([string]::IsNullOrWhiteSpace($Query)) {
        Write-Host "Enter your search query:" -ForegroundColor Cyan
        $Query = Read-Host ">>"
    }

    # B. Use the Validator (The 'Contract' check)
    if (-not (Test-SearchQuery -Query $Query)) {
        # Note: Test-SearchQuery already handles the 'Long query' message
        return
    }

    # C. Use the Sanitizer (The 'Formatting' check)
    $EncodedQuery = ConvertTo-UrlEncoded -InputString $Query
    $BaseUrl = "https://www.google.com/search?q="

    # D. Execute
    try {
        Start-Process "$BaseUrl$EncodedQuery"
    } catch {
        Write-Host "Error: Could not open browser." -ForegroundColor Red
    }
}

# YouTube Search functionality. Usage: yt "lofi hip hop"
function Invoke-YouTubeSearch {
    param(
        [Parameter(Position = 0)]
        [string]$Query
    )

    # 1. Handle missing parameters interactively
    if ([string]::IsNullOrWhiteSpace($Query)) {
        Write-Host "What would you like to watch on YouTube?" -ForegroundColor Cyan
        $Query = Read-Host ">>"
    }

    # 2. Validate the query using the helper
    if (-not (Test-SearchQuery -Query $Query)) {
        return
    }

    # 3. Sanitize the string and prepare the URL
    $EncodedQuery = ConvertTo-UrlEncoded -InputString $Query
    $BaseUrl = "https://www.youtube.com/results?search_query="

    # 4. Attempt to launch the search in the default browser
    try {
        Start-Process "$BaseUrl$EncodedQuery"
    } catch {
        Write-Host "[!] Failed to launch browser: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# A simple guide to the custom tools in this profile
function guide {
    Write-Host "`n--- CUSTOM TERMINAL TOOLS ---" -ForegroundColor Cyan
    Write-Host "ss            " -NoNewline; Write-Host "-> Launches btop (System Monitor)" -ForegroundColor Gray
    Write-Host "countdown [s] " -NoNewline; Write-Host "-> Starts a timer with a task name" -ForegroundColor Gray
    Write-Host "matrix        " -NoNewline; Write-Host "-> Digital Rain (Ctrl+C to exit)" -ForegroundColor Gray
    Write-Host "say [text]    " -NoNewline; Write-Host "-> Text-to-speech engine" -ForegroundColor Gray
    Write-Host "edit          " -NoNewline; Write-Host "-> Opens this profile in VS Code" -ForegroundColor Gray
    Write-Host "-----------------------------`n"
}

## --- --- --- --- --- SCRIPT LIBRARY --- --- --- --- ---

# Define the path to your script library
$ScriptsPath = Join-Path (Split-Path $PROFILE) "Functions"

# Create the folder if it doesn't exist yet (enable line if required)
# if (!(Test-Path $ScriptsPath)) { New-Item $ScriptsPath -ItemType Directory }

# THE AUTO-LOADER: Loop through and load every .ps1 file
Get-ChildItem -Path $ScriptsPath -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

## --- --- --- --- --- ON_LAUNCH: WELCOME MESSAGE AND SCRIPTS --- --- --- --- ---

# greet on launch
Send-Greeting

# welcome message
Write-Host "Welcome back, $env:USERNAME!" -ForegroundColor Cyan
Write-Host "Session started at $(Get-Date -Format 'HH:mm')" -ForegroundColor Gray
Write-Host "-------------------------------"