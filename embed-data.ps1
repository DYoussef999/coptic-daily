# Embed fasting-data.json into index.html to create a standalone version

$jsonPath = Join-Path $PSScriptRoot "fasting-data.json"
$htmlPath = Join-Path $PSScriptRoot "index.html"
$outputPath = Join-Path $PSScriptRoot "index-standalone.html"

# Read JSON data
$fastingData = Get-Content $jsonPath | ConvertFrom-Json

# Read HTML
$html = Get-Content $htmlPath -Raw

# Create embedded data
$jsonStr = $fastingData | ConvertTo-Json -Depth 10
$embeddedData = @"
        // Embedded fasting data (generated from fasting-data.json)
        const EMBEDDED_FASTING_DATA = $jsonStr;
"@

# Replace the fetch-based loading
$oldCode = @"
        // Load fasting data from JSON file
        function loadFastingData() {
            return new Promise(function(resolve, reject) {
                try {
                    fetch('fasting-data.json')
                        .then(response => response.json())
                        .then(data => {
                            // Convert Easter dates from strings to Date objects
                            copticEasterDates = {};
                            for (const [year, dateStr] of Object.entries(data.copticEasterDates)) {
                                const [y, m, d] = dateStr.split('-').map(Number);
                                copticEasterDates[year] = new Date(y, m - 1, d);
                            }
                            
                            fastingSeasons = data.fastingSeasons;
                            
                            // Store fixed feasts globally for use in getFastSeason
                            window.fixedFeasts = data.fixedFeasts || [];
                            
                            resolve();
                        })
                        .catch(error => {
                            console.error('Error loading fasting data:', error);
                            reject(error);
                        });
                } catch (error) {
                    console.error('Error loading fasting data:', error);
                    reject(error);
                }
            });
        }
"@

$newCode = $embeddedData + @"

        // Load fasting data from embedded data
        function loadFastingData() {
            return new Promise(function(resolve) {
                try {
                    const data = EMBEDDED_FASTING_DATA;
                    
                    // Convert Easter dates from strings to Date objects
                    copticEasterDates = {};
                    for (const [year, dateStr] of Object.entries(data.copticEasterDates)) {
                        const [y, m, d] = dateStr.split('-').map(Number);
                        copticEasterDates[year] = new Date(y, m - 1, d);
                    }
                    
                    fastingSeasons = data.fastingSeasons;
                    
                    // Store fixed feasts globally for use in getFastSeason
                    window.fixedFeasts = data.fixedFeasts || [];
                    
                    resolve();
                } catch (error) {
                    console.error('Error loading fasting data:', error);
                    resolve();
                }
            });
        }
"@

# Replace in HTML
$html = $html -replace [regex]::Escape($oldCode), $newCode

# Remove async/await from DOMContentLoaded
$html = $html -replace "document\.addEventListener\('DOMContentLoaded', async function\(\) \{", "document.addEventListener('DOMContentLoaded', function() {"
$html = $html -replace "await loadFastingData\(\);", "loadFastingData();"

# Write output
Set-Content -Path $outputPath -Value $html -Encoding UTF8

Write-Host "✓ Successfully embedded fasting data into: $outputPath" -ForegroundColor Green
Write-Host "✓ The standalone HTML file is ready to use without fasting-data.json" -ForegroundColor Green
