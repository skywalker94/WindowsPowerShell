## --- --- --- --- --- ALIASES --- --- --- --- ---

Set-Alias quote Request-Quote # Quick access to a random inspirational quote (REQUIRES: function 'Request-Quote')


## --- --- --- --- --- FUNCTIONS --- --- --- --- ---

# Fetches a random quote from the ZenQuotes API
function Request-Quote {
    try {
        # Fairly reliable API
        $url = "https://zenquotes.io/api/random"
        $data = curl.exe -s $url | ConvertFrom-Json
        
        # ZenQuotes returns an array, so we take the first object [0]
        $content = $data[0].q
        $author = $data[0].a

        Write-Host "`n `"$content`"" -ForegroundColor Cyan
        Write-Host " - $author`n" -ForegroundColor Cyan
    } catch {
        Write-Host "Unable to fetch quote. System offline?" -ForegroundColor DarkGray
    }
}