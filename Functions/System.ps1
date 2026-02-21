## --- --- --- --- --- ALIASES --- --- --- --- ---
Set-Alias beep Send-Notification

Set-Alias reload Restart-Profile


## --- --- --- --- --- FUNCTIONS --- --- --- --- ---

# Provides asynchronous audio feedback using Console Beeps.
function Send-Notification {

    [CmdletBinding()]
    param(
        # Presets
        [switch]$Short,
        [switch]$Long,
        [switch]$Alert,
        [switch]$Success,

        # Manual overrides
        [int]$Frequency = 432,
        [int]$Duration = 1000,

        # Blocking controls (Default is Async)
        [switch]$Async,
        [switch]$Sync,
        [switch]$Wait,

        # TYPO PROTECTION: 
        # This captures any undefined arguments (like -ong) so the script doesn't error out.
        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$IgnoreExtra
    )

    # APPLY PRESETS
    if ($Short)      { $Frequency = 600; $Duration = 200 }
    elseif ($Long)   { $Frequency = 432; $Duration = 3000 }
    elseif ($Alert)  { $Frequency = 1000; $Duration = 500 }
    elseif ($Success){ $Frequency = 528; $Duration = 400 }

    # # DEFINE THE ACTION
    # $BeepBlock = {
    #     param($f, $d)
    #     [Console]::Beep($f, $d)
    # }

    # EXECUTION LOGIC
    # It runs in SYNC only if -Sync or -Wait is specifically called.
    if ($Sync -or $Wait) {
        # Blocking: Terminal waits here
        [Console]::Beep($Frequency, $Duration)
    }
    else {
        # Fast Async: Spins up a lightweight background thread
        $PowerShell = [powershell]::Create().AddScript({
            param($f, $d)
            [Console]::Beep($f, $d)
        }).AddArgument($Frequency).AddArgument($Duration)
        
        $AsyncResult = $PowerShell.BeginInvoke()
        # Note: We don't need to EndInvoke for a simple beep; 
        # the thread will close itself when done.
    }
}

# Terminal speaks (Add a '-wait' OR' -Wait' after the argument to stall the terminal I/O until the speech ends.)
function say ($text, [switch]$Wait) {
    if (!$text) { $text = "Hello" } # Default if no argument is provided
    Add-Type -AssemblyName System.Speech
    $speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $speaker.SelectVoice("Microsoft Hazel Desktop")

    if ($Wait) {
        # Use this for it to finish talking before the script ends
        $speaker.Speak($text)
    } else {
        # Speak asynchronously in the background
        $speaker.SpeakAsync($text) | Out-Null
    }
}

# greet user on terminal launch (REQUIRES: function 'say')
function Send-Greeting {
    # Possible greetings
    $greetings = @(
    	"Systems online.",
        "Welcome back!",
    	"Initialising...",
    	"What do you need?",
    	"Terminal ready.",
        "Lovely to see you again.",
        "Locked and loaded.",
        "knee how?"
    )

    # Acknowledge time of day
    $hour = (Get-Date).Hour
    $timeofdaymessage = if ($hour -lt 12) { "Good morning" } elseif ($hour -lt 18) { "Good afternoon" } else { "Good evening" }

    # Speak a random greeting
    $randomGreeting = $greetings | Get-Random
    say "$timeofdaymessage. $randomGreeting"
}

# A function to reload the profile without needing to restart the terminal
function Restart-Profile {
    . $PROFILE
    Send-Notification -Frequency 528 -Sync -Duration 150
    Write-Host "Profile reloaded successfully!" -ForegroundColor Green
}