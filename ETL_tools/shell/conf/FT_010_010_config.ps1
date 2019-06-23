# スクリプトの変数設定
$configPath = Split-Path -Parent $MyInvocation.MyCommand.Path
# $jobId = "JE_e01"
# $CSVId = "JE_e01\*"
$uploadPath = (Join-Path $configPath "../../upload/JE_e01")
$uploadCSV = (Join-Path $configPath "../../upload/JE_e01/*")
$tempPath = (Join-Path $configPath "../../temp/JE_e01")
# $originalPath = Join-Path "original" $jobId
# $rejectPath = Join-Path "reject" $jobId
# $backupPath = Join-Path "backup" $jobId
# $sendPath = Join-Path "send"
$send = 2