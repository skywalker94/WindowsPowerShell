## --- --- --- --- --- ALIASES --- --- --- --- ---

Set-Alias matrix Start-Matrix


## --- --- --- --- --- FUNCTIONS --- --- --- --- ---


# Display Matrix-like grid
function Start-Matrix {
    Param(
        [Parameter(Mandatory=$false)]
        [string]$Colour = "Green",

        [Parameter(Mandatory=$false)]
        [switch]$Help
    )

    # 1. Display Help if requested
    if ($Help) {
        Write-Host "`n--- Matrix Digital Rain Simulator ---" -ForegroundColor Cyan
        Write-Host "Description:" -NoNewline; Write-Host " A responsive, falling-code animation for your terminal."
        Write-Host "Usage:      " -NoNewline; Write-Host " matrix -colour <name>" -ForegroundColor White
        Write-Host "Example:    " -NoNewline; Write-Host " matrix -colour Cyan" -ForegroundColor Cyan
        Write-Host "Colours:    " -NoNewline; Write-Host " Red, Blue, Cyan, Yellow, Magenta, White, Gray, Green, etc." -ForegroundColor Gray
        Write-Host "Exit:       " -NoNewline; Write-Host " Press Ctrl+C to stop.`n"
        return
    }

    # 2. Validate the color input (Generated with: "[System.Enum]::GetNames([System.ConsoleColor])" )
    $validColours = @(
        "Black",
        "DarkBlue",
        "DarkGreen",
        "DarkCyan",
        "DarkRed",
        "DarkMagenta",
        "DarkYellow",
        "Gray",
        "DarkGray",
        "Blue",
        "Green",
        "Cyan",
        "Red",
        "Magenta",
        "Yellow",
        "White"
    )
    if ($validColours -notcontains $Colour) {
        $Colour = "Green" # Fallback if user types an invalid color
    }

    # 1. Prepare the environment
    $oldCursorSize = $Host.UI.RawUI.CursorSize
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*+-[]{}()_.,;:|~".ToCharArray()
    $Streams = @{} 
    # Adjust this multiplier to change trail length (0.5 = 50% of screen height)
    $TailMultiplier = 4.5

    try {
        $Host.UI.RawUI.CursorSize = 0
        Clear-Host

        while ($true) {
            # 1. Capture current dimensions
            $Width  = $Host.UI.RawUI.WindowSize.Width
            $Height = $Host.UI.RawUI.WindowSize.Height
            $DynamicTail = [math]::Max(5, [int]($Height * $TailMultiplier))

            if ((Get-Random -Maximum 10) -gt 2) {
                $col = Get-Random -Maximum $Width
                if (-not $Streams.ContainsKey($col)) { $Streams[$col] = 0 }
            }

            foreach ($col in @($Streams.Keys)) {
                # 2. THE FIX: Immediate boundary check
                # If the window shrank, remove the stream and skip this iteration
                if ($col -ge $Width) { 
                    $Streams.Remove($col)
                    continue 
                }

                $headRow = $Streams[$col]
                $tailRow = $headRow - $DynamicTail
                
                # DRAW THE HEAD
                if ($headRow -lt $Height -and $headRow -ge 0) {
                    try {
                        # Final safety check inside the Try to catch race conditions
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates($col, $headRow)
                        $color = if ((Get-Random -Maximum 10) -gt 8) { "White" } else { $Colour }
                        Write-Host $chars[(Get-Random -Maximum $chars.Length)] -ForegroundColor $color -NoNewline
                    } catch { $Streams.Remove($col); continue }
                }

                # ERASE THE TAIL
                if ($tailRow -lt $Height -and $tailRow -ge 0) {
                    try {
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates($col, $tailRow)
                        Write-Host " " -NoNewline
                    } catch { $Streams.Remove($col); continue }
                }

                $Streams[$col]++
                if ($tailRow -ge $Height) { $Streams.Remove($col) }
            }
            Start-Sleep -Milliseconds 20
        }
    }
    finally {
        $Host.UI.RawUI.CursorSize = $oldCursorSize
        Clear-Host
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates(0, 0)
        Write-Host "Exited Matrix Mode." -ForegroundColor Gray
    }
}