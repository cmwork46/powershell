$configPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Remove-Item (Join-Path $configPath "../../upload/JE_e01/*.csv")
Remove-Item (Join-Path $configPath "../../temp/JE_e01/*.csv")
Remove-Item (Join-Path $configPath "../../reject/JE_e01/*.csv")
Remove-Item (Join-Path $configPath "../../backup/JE_e01/*.csv")
Remove-Item (Join-Path $configPath "../../original/JE_e01/*.csv")
Remove-Item (Join-Path $configPath "../../send/JE_e01/*.csv")
# Remove-Item (Join-Path $configPath "/logs/*.log*")
Copy-Item (Join-Path $configPath "test.csv") (Join-Path (Join-Path $configPath "../../upload/JE_e01") ((Get-Date -Format yyyyMMddhhmmss) + ".csv"))