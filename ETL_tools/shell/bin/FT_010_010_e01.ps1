# 設定ファイルの呼出
$configPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $configPath "../conf/FT_010_010_config.ps1")
. (Join-Path $configPath "../lib/FT_010_log.ps1")

# catchに投げる
$ErrorActionPreference = "Stop"

######################## 処理開始 ########################

# 排他制御
$mutex = New-Object System.Threading.Mutex($false, "Global¥MUTEX_TEST")
if (!($mutex.WaitOne(0, $false))) {
    $logger.Warn("Already processing is executed")
    exit
}

# フォルダチェック、なければ作成
New-Item (Join-Path $configPath "../../upload/JE_e01") -ItemType Directory -Force
New-Item (Join-Path $configPath "../../temp/JE_e01") -ItemType Directory -Force
New-Item (Join-Path $configPath "../../original/JE_e01") -ItemType Directory -Force
New-Item (Join-Path $configPath "../../send/JE_e01") -ItemType Directory -Force
New-Item (Join-Path $configPath "../../backup/JE_e01") -ItemType Directory -Force
New-Item (Join-Path $configPath "../../reject/JE_e01") -ItemType Directory -Force

# スクリプトの変数設定
$uploadPath = (Join-Path $configPath "../../upload/JE_e01")
$tempPath = (Join-Path $configPath "../../temp/JE_e01")
$originalPath = (Join-Path $configPath "../../original/JE_e01")
$sendPath = (Join-Path $configPath "../../send/JE_e01")
$backupPath = (Join-Path $configPath "../../backup/JE_e01")
$rejectPath = (Join-Path $configPath "../../reject/JE_e01")

# uploadのファイル一覧を取得し、更新日順にソートする
$fileList = Get-ChildItem $uploadPath/* -include *.CSV | Sort-Object LastWriteTime
# ファイル１つずつ実行
foreach ($uploadCSV in $fileList) {
    # tempにファイルを移動
    $tempCSV = ((Join-Path $tempPath ($uploadCSV.BaseName + "_temp.csv")))
    Read-Host "temp"
    Move-Item $uploadCSV $tempCSV

    # originalにファイルを格納
    Read-Host "original"
    $originalCSV = ((Join-Path $originalPath ($uploadCSV.BaseName + ".csv")))
    Copy-Item $tempCSV $originalCSV
    
    try {
        # アップロード判定
        # 文字コード変換・重複排除
        $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
        $logger.INFO("Convert Shift-JIS to UTF-8N, and copy upload CSV to backup CSV")
        [System.IO.File]::WriteAllLines($uploadCSV, (Get-Content $tempCSV | Sort-Object | Get-Unique), $utf8NoBomEncoding)
        
        switch ($send) {
            1 {
                # TODO: upload to azure
            }
            2 {
                # TODO: オンプレ
                Read-Host "send"
                $sendCSV = ((Join-Path $sendPath ($uploadCSV.BaseName + ".csv")))
                Copy-Item $tempCSV $sendCSV
                break
            }
        }
        # backupに移動
        Read-Host "backup"
        $logger.INFO("Copy upload CSV to backup CSV")
        Move-Item $tempCSV ((Join-Path $backupPath ($uploadCSV.BaseName + "_backup.csv"))) -force
        $logger.INFO("Upload success")
    }
    catch {
        $logger.Error("Upload failured")
        $logger.INFO("Copy temp CSV to upload CSV")
        Copy-Item $tempCSV $uploadCSV

        $logger.INFO("Copy temp CSV to reject CSV")
        Copy-Item $tempCSV ((Join-Path $rejectPath ($uploadCSV.BaseName + "_reject.CSV")))

        $logger.INFO("Remove temp CSV")
        Remove-Item $tempCSV
    }
}

# 排他制御の開放
$mutex.ReleaseMutex()