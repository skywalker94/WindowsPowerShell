## --- --- --- --- --- SETTINGS AND ENCODING --- --- --- --- ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8



## --- --- --- --- --- SCRIPT LIBRARY --- --- --- --- ---

$ScriptsPath = Join-Path (Split-Path $PROFILE) "Functions"

# # Create the folder if it doesn't exist yet (enable line if required)
# if (!(Test-Path $ScriptsPath)) { New-Item $ScriptsPath -ItemType Directory }

# THE SCRIPT-LOADER: Loop through and load every .ps1 file from the ScriptsPath folder.
Get-ChildItem -Path $ScriptsPath -Filter *.ps1 | ForEach-Object { . $_.FullName }



## --- --- --- --- --- ALIASES --- --- --- --- ---
## Format 1: Set-Alias -Name <alias> -Value <command>
## Example1: Set-Alias -Name ll -Value Get-ChildItem
## Format 2: New-Alias <alias> <command>
## Example2: New-Alias ll Get-ChildItem

Set-Alias -Name ss -Value btop4win # htop quivalent for windows (REQUIRES: btop4win installed and in PATH)

Set-Alias grep Select-String # Because linux habits die hard

Set-Alias suggestfunctionprefix Get-Verb # PowerShell has preferred function prefixes (like Get-, Set-, Invoke- etc.)

## --- --- --- --- --- FUNCTIONS --- --- --- --- ---

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

## --- --- --- --- --- ON_LAUNCH: WELCOME MESSAGE AND SCRIPTS --- --- --- --- ---

# greet on launch
Send-Greeting

# welcome message
Write-Host "Welcome back, $env:USERNAME!" -ForegroundColor Cyan
Write-Host "Session started at $(Get-Date -Format 'HH:mm')" -ForegroundColor Gray
Write-Host "-------------------------------"