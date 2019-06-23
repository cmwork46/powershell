# 設定ファイルの呼出
$configPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $configPath "../conf/FT_010_030_config.ps1")
. (Join-Path $configPath "../lib/FT_010_log.ps1")

$logger.INFO("FT_010_030")

# 対象フォルダの指定(original,backup,reject)
$originalPath = Join-Path $configPath "/../../original/JE_e01/*"
$backupPath = Join-Path $configPath "/../../backup/"
$rejectPath = Join-Path $configPath "/../../original/"

# 排他制御
$mutex = New-Object System.Threading.Mutex($false, "Global¥MUTEX_TEST")
if (!($mutex.WaitOne(0, $false))) {
    $logger.Warn("Already processing is executed")
    exit
}

# ファイルの削除
if (Test-Path $originalPath) {
    Get-ChildItem $originalpath | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1 * $Days) } | Remove-Item
    $logger.INFO("finish!")
}
else {
    $logger.Warn("non file")
}

# 排他制御の開放
$mutex.ReleaseMutex()