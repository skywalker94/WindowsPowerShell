## --- --- --- --- --- ALIASES --- --- --- --- ---

Set-Alias google Invoke-GoogleSearch

Set-Alias youtube Invoke-YouTubeSearch



## --- --- --- --- --- FUNCTIONS --- --- --- --- ---

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