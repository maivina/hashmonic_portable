<#
    ========================================================
    HASHMONIC TOOL v1.0
    Developer: Maivina
    ========================================================
    [!] For best visuals (Transparency), right-click the shortcut:
    Properties -> Compatibility -> Check "Run this program as an administrator".
#>

# --- 1. SETUP & CONSOLE ENHANCEMENTS ---
$Host.UI.RawUI.WindowTitle = "Hashmonic Tool v1.0 - by maivina"
$Host.UI.RawUI.ForegroundColor = "Cyan"
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

# --- 2. GLOBAL MEMORY & ASYNC AUDIO ENGINE ---
$Global:PendingDeletions = [hashtable]::Synchronized(@{}) 
$Global:StateCache       = [hashtable]::Synchronized(@{})
$Global:AudioQueue       = [System.Collections.Queue]::Synchronized([System.Collections.Queue]::new())

$Global:AudioRunspace = [runspacefactory]::CreateRunspace()
$Global:AudioRunspace.Open()
$Global:AudioPS = [powershell]::Create()
$Global:AudioPS.Runspace = $Global:AudioRunspace

$Global:AudioPS.AddScript({
    param($Queue)
    while ($true) {
        if ($Queue.Count -gt 0) {
            $note = $Queue.Dequeue()
            [Console]::Beep($note.Freq, $note.Dur)
        } else {
            Start-Sleep -Milliseconds 50
        }
    }
}).AddArgument($Global:AudioQueue).BeginInvoke()

function Play-Async {
    param([int]$Freq, [int]$Dur)
    $Global:AudioQueue.Enqueue(@{ Freq = $Freq; Dur = $Dur })
}

# --- 3. SOUND PRESETS ---
function Play-Startup { Play-Async 440 100; Play-Async 554 100; Play-Async 659 150 }
function Play-Success { Play-Async 880 100 }
function Play-Error   { Play-Async 220 150 }
function Play-Nav     { Play-Async 1109 40 }
function Play-Alert   { Play-Async 554 100 }
function Play-Move    { Play-Async 1109 150 }
function Play-Exit    { Play-Async 659 100; Play-Async 440 150; Start-Sleep 1 }

# --- 4. GLOBAL DEFAULTS & DIRECTORY BUILDER ---
$Global:CurrentAlg = "SHA256"
$Global:BaseReportDir    = "$PSScriptRoot\Reports"
$folders = @("single_file", "compare", "dir_scan", "dir_compare", "text_hash")
foreach ($f in $folders) { 
    $path = "$Global:BaseReportDir\$f"
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Force -Path $path | Out-Null }
}

# --- 5. VISUAL ENGINE ---
function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "                                _   _    _    ____  _   _ __  __  ___  _   _ ___ ____ " -ForegroundColor Cyan
    Write-Host "                               | | | |  / \  / ___|| | | |  \/  |/ _ \| \ | |_ _/ ___|" -ForegroundColor Cyan
    Write-Host "                               | |_| | / _ \ \___ \| |_| | |\/| | | | |  \| || | |    " -ForegroundColor White
    Write-Host "                               |  _  |/ ___ \ ___) |  _  | |  | | |_| | |\  || | |___ " -ForegroundColor White
    Write-Host "                               |_| |_/_/   \_\____/|_| |_|_|  |_|\___/|_| \_|___\____|" -ForegroundColor Cyan
    Write-Host "		                                   [ BY MAIVINA ]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "======================================================================================================================" -ForegroundColor DarkGray
    Write-Host "   CURRENT ALGORITHM: $Global:CurrentAlg" -ForegroundColor Yellow
    Write-Host ""
}

# --- 6. SMART INPUT HANDLER ---
function Request-Path {
    param([string]$Message, [string]$Type)
    while ($true) {
        Write-Host "$Message" -ForegroundColor Yellow
        Write-Host "   (Type 'b' to go back)" -ForegroundColor DarkGray
        $input = Read-Host "   > Input"
        $clean = $input.Trim() -replace '"', ''
        
        if ($clean -eq "b" -or $clean -eq "B") { Play-Nav; return "BACK_COMMAND" }
        if ([string]::IsNullOrWhiteSpace($clean)) { Play-Error; continue }
        
        if (Test-Path $clean) {
             $realPath = (Resolve-Path $clean).Path
             if ($Type -eq "File" -and (Test-Path $realPath -PathType Leaf)) { return $realPath }
             if ($Type -eq "Folder" -and (Test-Path $realPath -PathType Container)) { return $realPath }
        }
        Play-Error; Write-Host "   [!] Invalid path or file type." -ForegroundColor Red
    }
}

# --- 7. SUPER REPORT ENGINE ---
function Write-Report-TXT {
    param([string]$Folder, [string]$Mode, [string]$Content, [string]$Prefix)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $filename  = "${Prefix}_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
    $fullPath  = "$Global:BaseReportDir\$Folder\$filename"
    
    $finalContent =  "================================================================================`r`n"
    $finalContent += "   HASHMONIC INTELLIGENCE BRIEF v1.0`r`n"
    $finalContent += "================================================================================`r`n"
    $finalContent += "   DATE GENERATED : $timestamp`r`n"
    $finalContent += "   OPERATION MODE : $Mode`r`n"
    $finalContent += "   HASH ALGORITHM : $Global:CurrentAlg`r`n"
    $finalContent += "================================================================================`r`n`r`n"
    $finalContent += $Content
    $finalContent += "`r`n`r`n================================================================================"
    $finalContent += "`r`n   [ END OF INTELLIGENCE REPORT ]"
    
    $finalContent | Out-File -FilePath $fullPath -Encoding UTF8
    Play-Success
    Write-Host "`n   [+] INTELLIGENCE EXPORTED TO:" -ForegroundColor Green
    Write-Host "       ...\Reports\$Folder\$filename" -ForegroundColor DarkGray
}

# --- [S] SETTINGS ENGINE ---
function Set-Algorithm {
    $valid = $false
    while (-not $valid) {
        Show-Header
        Write-Host "[ S ] ALGORITHM CONFIGURATION" -ForegroundColor Green
        Write-Host "   Type a number and press Enter to apply." -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "   [1] MD5"
        Write-Host "   [2] SHA1"
        Write-Host "   [3] SHA256 (Default)"
        Write-Host "   [4] SHA384"
        Write-Host "   [5] SHA512"
        Write-Host "   [B] Cancel & Back"
        Write-Host ""
        
        $choice = (Read-Host "   Select Option").Trim().ToUpper()

        if ($choice -eq "B") { Play-Nav; return }

        $algos = @{"1"="MD5"; "2"="SHA1"; "3"="SHA256"; "4"="SHA384"; "5"="SHA512"}

        if ($algos.ContainsKey($choice)) {
            $Global:CurrentAlg = $algos[$choice]
            Play-Success
            Write-Host "`n   [SUCCESS] Cryptographic engine locked to $($Global:CurrentAlg)." -ForegroundColor Green
            Write-Host "   Rebooting interface..." -ForegroundColor Yellow
            Start-Sleep -Milliseconds 800
            $valid = $true 
        } else {
            Play-Error
            Write-Host "   [!] Command not recognized. Use 1-5." -ForegroundColor Red
            Start-Sleep -Milliseconds 1000
        }
    }
}

# --- [1] SINGLE FILE ---
function Analyze-File {
    Show-Header
    Write-Host "[1] SINGLE FILE FORENSICS" -ForegroundColor Green
    $path = Request-Path "Drag file to analyze:" "File"
    if ($path -eq "BACK_COMMAND") { return }
    
    Write-Host "   [*] Analyzing artifact..." -ForegroundColor Yellow
    $item = Get-Item $path
    $hash = (Get-FileHash -Path $path -Algorithm $Global:CurrentAlg).Hash
    Play-Success
    
    Write-Host "`n   [ FORENSIC RESULT ]" -ForegroundColor Green
    Write-Host "   TARGET : $(Split-Path $path -Leaf)" -ForegroundColor White
    Write-Host "   HASH   : $hash" -ForegroundColor Cyan
    
    while ($true) {
        $save = (Read-Host "`n   > Save Intelligence Report? (y/n)").Trim().ToLower()
        if ($save -eq "y") {
            $sb = [System.Text.StringBuilder]::new()
            $sb.AppendLine("   [ TARGET METADATA ]") | Out-Null
            $sb.AppendLine("   -------------------") | Out-Null
            $sb.AppendLine("   FILENAME    : $($item.Name)") | Out-Null
            $sb.AppendLine("   PATH        : $($item.FullName)") | Out-Null
            
            # FORMATTED BYTES
            $sb.AppendLine("   SIZE        : $($item.Length.ToString('N0')) bytes") | Out-Null
            
            $sb.AppendLine("   CREATED     : $($item.CreationTime)") | Out-Null
            $sb.AppendLine("   MODIFIED    : $($item.LastWriteTime)") | Out-Null
            $sb.AppendLine("   ATTRIBUTES  : $($item.Attributes)") | Out-Null
            $sb.AppendLine("") | Out-Null
            $sb.AppendLine("   [ CRYPTOGRAPHIC SIGNATURE ]") | Out-Null
            $sb.AppendLine("   ---------------------------") | Out-Null
            $sb.AppendLine("   ALGORITHM   : $Global:CurrentAlg") | Out-Null
            $sb.AppendLine("   HASH        : $hash") | Out-Null
            
            Write-Report-TXT -Folder "single_file" -Mode "SINGLE FORENSICS" -Content $sb.ToString() -Prefix "FILE_REPORT"
            Start-Sleep 1
            break
        } elseif ($save -eq "n") {
            break
        } else {
            Play-Error
            Write-Host "   [!] Invalid input. Please type 'y' or 'n'." -ForegroundColor Red
        }
    }
}

# --- [2] COMPARE FILES ---
function Compare-Files {
    Show-Header
    Write-Host "[2] COMPARISON ENGINE" -ForegroundColor Green
    $f1 = Request-Path "1. Drag SOURCE file:" "File"
    if ($f1 -eq "BACK_COMMAND") { return }
    $f2 = Request-Path "2. Drag TARGET file:" "File"
    if ($f2 -eq "BACK_COMMAND") { return }
    
    Write-Host "`n   [*] Computing cryptographic signatures..." -ForegroundColor Yellow
    $h1 = (Get-FileHash $f1 -Algorithm $Global:CurrentAlg).Hash
    $h2 = (Get-FileHash $f2 -Algorithm $Global:CurrentAlg).Hash
    
    Write-Host "`n   FILE 1 : $(Split-Path $f1 -Leaf)" -ForegroundColor DarkGray
    Write-Host "   HASH 1 : $h1" -ForegroundColor Cyan
    Write-Host "   FILE 2 : $(Split-Path $f2 -Leaf)" -ForegroundColor DarkGray
    Write-Host "   HASH 2 : $h2" -ForegroundColor Cyan
    
    $status = "UNKNOWN"
    if ($h1 -eq $h2) { 
        Play-Success
        Write-Host "`n   [ INTEGRITY CONFIRMED: MATCH ]" -ForegroundColor White -BackgroundColor DarkGreen
        $status = "MATCH CONFIRMED"
    } else {
        Play-Error
        Write-Host "`n   [ SECURITY ALERT: MISMATCH ]" -ForegroundColor White -BackgroundColor DarkRed
        $status = "CRITICAL MISMATCH"
    }
    
    while ($true) {
        $save = (Read-Host "`n   > Save Intelligence Report? (y/n)").Trim().ToLower()
        if ($save -eq "y") {
            $sb = [System.Text.StringBuilder]::new()
            $sb.AppendLine("   [ COMPARISON STATUS: $status ]") | Out-Null
            $sb.AppendLine("   ==========================================================") | Out-Null
            $sb.AppendLine("") | Out-Null
            $sb.AppendLine("   [ 1. SOURCE ARTIFACT ]") | Out-Null
            $sb.AppendLine("   Path : $f1") | Out-Null
            $sb.AppendLine("   Hash : $h1") | Out-Null
            $sb.AppendLine("") | Out-Null
            $sb.AppendLine("   [ 2. TARGET ARTIFACT ]") | Out-Null
            $sb.AppendLine("   Path : $f2") | Out-Null
            $sb.AppendLine("   Hash : $h2") | Out-Null
            $sb.AppendLine("") | Out-Null
            $sb.AppendLine("   [ ANALYSIS NOTE ]") | Out-Null
            if ($status -eq "MATCH CONFIRMED") {
                $sb.AppendLine("   These files are cryptographically identical.") | Out-Null
            } else {
                $sb.AppendLine("   WARNING: These files have different content. Integrity compromised.") | Out-Null
            }
            
            Write-Report-TXT -Folder "compare" -Mode "FILE COMPARISON" -Content $sb.ToString() -Prefix "COMPARE_REPORT"
            Start-Sleep 1
            break
        } elseif ($save -eq "n") {
            break
        } else {
            Play-Error
            Write-Host "   [!] Invalid input. Please type 'y' or 'n'." -ForegroundColor Red
        }
    }
}

# --- [3] DIRECTORY SCAN ---
function Scan-Directory {
    Show-Header
    Write-Host "[3] DIRECTORY INTEGRITY SCAN" -ForegroundColor Green
    $folder = Request-Path "Drag folder to scan:" "Folder"
    if ($folder -eq "BACK_COMMAND") { return }
    
    Write-Host "   [*] Executing deep forensic scan. Please wait..." -ForegroundColor Yellow
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    
    # Forensic Scan: Includes hidden/system files, bypasses locked files, avoids junction loops
    $files = Get-ChildItem -Path $folder -Recurse -File -Force -Attributes !ReparsePoint -ErrorAction SilentlyContinue
    $results = $files | Get-FileHash -Algorithm $Global:CurrentAlg
    $timer.Stop()
    
    # EXACT BYTES
    $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $totalSize) { $totalSize = 0 }
    
    $sb = [System.Text.StringBuilder]::new()
    $sb.AppendLine("   [ EXECUTIVE SUMMARY ]") | Out-Null
    $sb.AppendLine("   Target Folder : $folder") | Out-Null
    $sb.AppendLine("   Files Scanned : $($files.Count.ToString('N0'))") | Out-Null
    $sb.AppendLine("   Total Size    : $($totalSize.ToString('N0')) bytes") | Out-Null
    $sb.AppendLine("   Time Taken    : $($timer.Elapsed.ToString())") | Out-Null
    $sb.AppendLine("") | Out-Null
    $sb.AppendLine("   [ FULL HASH MANIFEST ]") | Out-Null
    $sb.AppendLine("   ----------------------------------------------------------") | Out-Null
    
    foreach ($item in $results) {
        $relPath = $item.Path.Replace($folder, "")
        $sb.AppendLine("   FILE : $relPath") | Out-Null
        $sb.AppendLine("   HASH : $($item.Hash)") | Out-Null
        $sb.AppendLine("   ----") | Out-Null
    }
    
    Play-Success
    Write-Host "`n   [SUCCESS] $($files.Count.ToString('N0')) items processed in $($timer.Elapsed.TotalSeconds.ToString('0.00'))s" -ForegroundColor Green
    Write-Report-TXT -Folder "dir_scan" -Mode "DEEP SCAN" -Content $sb.ToString() -Prefix "SCAN_FULL"
    
    Write-Host "`n   Press Enter to return..." -ForegroundColor DarkGray
    Read-Host
}

# --- [4] DIRECTORY COMPARISON ---
function Compare-Directories {
    Show-Header
    Write-Host "[4] DIRECTORY COMPARISON" -ForegroundColor Green
    $dir1 = Request-Path "1. Drag SOURCE folder:" "Folder"
    if ($dir1 -eq "BACK_COMMAND") { return }
    $dir2 = Request-Path "2. Drag TARGET folder:" "Folder"
    if ($dir2 -eq "BACK_COMMAND") { return }
    
    Write-Host "`n   [*] Analyzing Source structure (Including Hidden/System)..." -ForegroundColor Yellow
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $files1 = Get-ChildItem -Path $dir1 -Recurse -File -Force -Attributes !ReparsePoint -ErrorAction SilentlyContinue
    $hashes1 = $files1 | Get-FileHash -Algorithm $Global:CurrentAlg
    
    Write-Host "   [*] Analyzing Target structure (Including Hidden/System)..." -ForegroundColor Yellow
    $files2 = Get-ChildItem -Path $dir2 -Recurse -File -Force -Attributes !ReparsePoint -ErrorAction SilentlyContinue
    $hashes2 = $files2 | Get-FileHash -Algorithm $Global:CurrentAlg
    
    # EXACT BYTES FOR COMPARISON DIRECTORIES
    $totalSize1 = ($files1 | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $totalSize1) { $totalSize1 = 0 }
    $totalSize2 = ($files2 | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $totalSize2) { $totalSize2 = 0 }
    
    $dict1 = @{}; $hashes1 | ForEach-Object { $dict1[$_.Path.Replace($dir1, "")] = $_.Hash }
    $dict2 = @{}; $hashes2 | ForEach-Object { $dict2[$_.Path.Replace($dir2, "")] = $_.Hash }
    
    $allKeys = $dict1.Keys + $dict2.Keys | Select-Object -Unique
    
    $matches      = @()
    $mismatches   = @()
    $sourceOnly   = @()
    $targetOnly   = @()
    
    foreach ($relPath in $allKeys) {
        if ($dict1.ContainsKey($relPath) -and $dict2.ContainsKey($relPath)) {
            if ($dict1[$relPath] -eq $dict2[$relPath]) { 
                $matches += $relPath 
            } else { 
                $mismatches += [PSCustomObject]@{ File=$relPath; HashS=$dict1[$relPath]; HashT=$dict2[$relPath] } 
            }
        } elseif ($dict1.ContainsKey($relPath)) { 
            $sourceOnly += [PSCustomObject]@{ File=$relPath; Hash=$dict1[$relPath] } 
        } elseif ($dict2.ContainsKey($relPath)) { 
            $targetOnly += [PSCustomObject]@{ File=$relPath; Hash=$dict2[$relPath] } 
        }
    }
    $timer.Stop()

    $sb = [System.Text.StringBuilder]::new()
    $sb.AppendLine("   [ EXECUTIVE SUMMARY ]") | Out-Null
    $sb.AppendLine("   SOURCE      : $dir1") | Out-Null
    $sb.AppendLine("   TARGET      : $dir2") | Out-Null
    $sb.AppendLine("   TIME TAKEN  : $($timer.Elapsed.ToString())") | Out-Null
    $sb.AppendLine("") | Out-Null
    $sb.AppendLine("   [ STATISTICS ]") | Out-Null
    $sb.AppendLine("   [+] TOTAL FILES SCANNED : $($allKeys.Count.ToString('N0'))") | Out-Null
    $sb.AppendLine("   [+] SOURCE SIZE         : $($totalSize1.ToString('N0')) bytes") | Out-Null
    $sb.AppendLine("   [+] TARGET SIZE         : $($totalSize2.ToString('N0')) bytes") | Out-Null
    $sb.AppendLine("   [=] PERFECT MATCHES     : $($matches.Count.ToString('N0'))") | Out-Null
    $sb.AppendLine("   [!] HASH MISMATCHES     : $($mismatches.Count.ToString('N0'))") | Out-Null
    $sb.AppendLine("   [<] MISSING IN TARGET   : $($sourceOnly.Count.ToString('N0'))") | Out-Null
    $sb.AppendLine("   [>] MISSING IN SOURCE   : $($targetOnly.Count.ToString('N0'))") | Out-Null
    $sb.AppendLine("") | Out-Null
    
    if ($mismatches.Count -gt 0) {
        $sb.AppendLine("   [ SECURITY INTELLIGENCE: CRITICAL MISMATCHES ]") | Out-Null
        $sb.AppendLine("   ----------------------------------------------------------") | Out-Null
        foreach ($item in $mismatches) {
            $sb.AppendLine("   [!] FILE    : $($item.File)") | Out-Null
            $sb.AppendLine("       SOURCE  : $($item.HashS)") | Out-Null
            $sb.AppendLine("       TARGET  : $($item.HashT)") | Out-Null
            $sb.AppendLine("   ----------------------------------------------------------") | Out-Null
        }
        $sb.AppendLine("") | Out-Null
    }

    if ($sourceOnly.Count -gt 0) {
        $sb.AppendLine("   [ INTELLIGENCE: MISSING IN TARGET (Source Only) ]") | Out-Null
        foreach ($item in $sourceOnly) { $sb.AppendLine("   [<] $($item.File)") | Out-Null }
        $sb.AppendLine("") | Out-Null
    }

    if ($targetOnly.Count -gt 0) {
        $sb.AppendLine("   [ INTELLIGENCE: MISSING IN SOURCE (Target Only) ]") | Out-Null
        foreach ($item in $targetOnly) { $sb.AppendLine("   [>] $($item.File)") | Out-Null }
        $sb.AppendLine("") | Out-Null
    }

    Play-Success
    Write-Host "`n   [SUCCESS] Cross-reference complete." -ForegroundColor Green
    $reportContent = $sb.ToString()
    Write-Report-TXT -Folder "dir_compare" -Mode "DIR COMPARISON" -Content $reportContent -Prefix "COMPARE_REPORT"
    
    Write-Host "`n   Press Enter to return..." -ForegroundColor DarkGray
    Read-Host
}

# --- [5] TEXT HASH ---
function Hash-Text {
    Show-Header
    Write-Host "[5] TEXT / STRING CRYPTOGRAPHY" -ForegroundColor Green
    while ($true) {
        Write-Host "   Enter Text/String to Hash:" -ForegroundColor Yellow
        Write-Host "   (Type 'b' to go back)" -ForegroundColor DarkGray
        $text = Read-Host "   > Input"
        $text = $text.Trim()
        if ($text -eq "b" -or $text -eq "B") { Play-Nav; return }
        if (-not [string]::IsNullOrWhiteSpace($text)) { break }
        Play-Error
    }
    
    $stream = [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($text))
    $hash = (Get-FileHash -InputStream $stream -Algorithm $Global:CurrentAlg).Hash
    Play-Success
    
    Write-Host "`n   [ CIPHER RESULT ]" -ForegroundColor Green
    Write-Host "   DATA : $text" -ForegroundColor White
    Write-Host "   HASH : $hash" -ForegroundColor Cyan
    
    while ($true) {
        $save = (Read-Host "`n   > Save Intelligence Report? (y/n)").Trim().ToLower()
        if ($save -eq "y") {
            $sb = [System.Text.StringBuilder]::new()
            $sb.AppendLine("   [ CRYPTOGRAPHIC MEMO ]") | Out-Null
            $sb.AppendLine("   ----------------------") | Out-Null
            $sb.AppendLine("   INPUT STRING : $text") | Out-Null
            
            # FORMATTED CHARACTER COUNT
            $sb.AppendLine("   LENGTH       : $($text.Length.ToString('N0')) characters") | Out-Null
            
            $sb.AppendLine("") | Out-Null
            $sb.AppendLine("   [ GENERATED HASH ]") | Out-Null
            $sb.AppendLine("   $Global:CurrentAlg : $hash") | Out-Null
            
            Write-Report-TXT -Folder "text_hash" -Mode "TEXT CRYPTO" -Content $sb.ToString() -Prefix "TEXT_HASH"
            Start-Sleep 1
            break
        } elseif ($save -eq "n") {
            break
        } else {
            Play-Error
            Write-Host "   [!] Invalid input. Please type 'y' or 'n'." -ForegroundColor Red
        }
    }
}

# --- [6] LIVE MONITOR ---
function Live-Monitor {
    Show-Header
    Write-Host "[6] LIVE SURVEILLANCE DASHBOARD" -ForegroundColor Green
    Write-Host "    (Memory Only - No Log Files)" -ForegroundColor DarkGray
    
    $folder = Request-Path "Drag folder to watch:" "Folder"
    if ($folder -eq "BACK_COMMAND") { return }
    
    Clear-Host
    Write-Host "===================================================================================================" -ForegroundColor DarkGray
    Write-Host " TIME        | TYPE      | ACTION            | DETAILS " -ForegroundColor White
    Write-Host "===================================================================================================" -ForegroundColor DarkGray

    $Global:RenderBlock = { param($Color, $Icon, $ActionText, $DetailText, $FlashColor) 
        $time = Get-Date -Format "HH:mm:ss"
        if ($FlashColor -ne $null) {
            Write-Host " $time " -NoNewline -ForegroundColor White -BackgroundColor $FlashColor
            Write-Host " $Icon " -NoNewline -ForegroundColor White -BackgroundColor $FlashColor
            Write-Host " $($ActionText.PadRight(16)) " -NoNewline -ForegroundColor White -BackgroundColor $FlashColor
            Write-Host "| $DetailText" -ForegroundColor White -BackgroundColor $FlashColor
        } else {
            Write-Host " $time " -NoNewline -ForegroundColor DarkGray
            Write-Host " $Icon " -NoNewline -ForegroundColor $Color
            Write-Host " $($ActionText.PadRight(16)) " -NoNewline -ForegroundColor White
            Write-Host "| $DetailText" -ForegroundColor DarkGray
        }
    }
    
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $folder
    $watcher.IncludeSubdirectories = $true
    $watcher.InternalBufferSize = 65536 
    $watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::DirectoryName -bor [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::Attributes -bor [System.IO.NotifyFilters]::Size -bor [System.IO.NotifyFilters]::Security
    $watcher.EnableRaisingEvents = $true
    
    $action = { 
        try {
            $path = $Event.SourceEventArgs.FullPath
            $type = $Event.SourceEventArgs.ChangeType
            $name = $Event.SourceEventArgs.Name
            
            switch ($type) {
                "Renamed" {
                    $oldName = Split-Path $Event.SourceEventArgs.OldFullPath -Leaf
                    Play-Move
                    & $Global:RenderBlock Cyan "[ > ]" "RENAMED" "$oldName -> $name" $null
                }
                "Deleted" { 
                    $fileNameOnly = Split-Path $name -Leaf
                    $Global:PendingDeletions[$fileNameOnly] = @{
                        Path = $name; Time = (Get-Date); Printed = $false
                    }
                }
                "Created" {
                    $fileNameOnly = Split-Path $name -Leaf
                    if ($Global:PendingDeletions.ContainsKey($fileNameOnly)) {
                        $Global:PendingDeletions.Remove($fileNameOnly)
                        Play-Move
                        & $Global:RenderBlock Cyan "[ > ]" "MOVED" "Internal Move: $name" $null
                    } else {
                        if (Test-Path $path -PathType Container) { 
                            & $Global:RenderBlock Green "[ + ]" "NEW FOLDER" "$name" $null
                        } else { 
                            & $Global:RenderBlock Green "[ + ]" "NEW FILE" "$name" $null
                        }
                    }
                }
                "Changed" {
                    $item = $null; $attr = "Normal"
                    if (Test-Path $path) { 
                        $item = Get-Item $path -Force -ErrorAction SilentlyContinue 
                        if ($item) { $attr = $item.Attributes }
                    }

                    $currentState = "Normal"
                    if ($attr -match "Hidden") { $currentState = "Hidden" }
                    if ($attr -match "ReadOnly") { $currentState = "ReadOnly" }
                    if (($attr -match "Hidden") -and ($attr -match "ReadOnly")) { $currentState = "HighSec" }
                    
                    $cacheKey = "$path"
                    $lastState = $Global:StateCache[$cacheKey]
                    if ($lastState -eq $currentState -and $currentState -ne "Normal") { return }
                    $Global:StateCache[$cacheKey] = $currentState

                    if (Test-Path $path -PathType Container) {
                        if ($attr -match "Hidden") {
                            Play-Alert
                            & $Global:RenderBlock Blue "[ ! ]" "FOLDER HIDDEN" "Visibility: Hidden" "DarkCyan"
                        } else {
                            $isContentChange = $false
                            if ($item) {
                                if (((Get-Date) - $item.LastWriteTime).TotalSeconds -lt 3) { $isContentChange = $true }
                            }
                            if ($isContentChange) {
                                & $Global:RenderBlock DarkGray "[ * ]" "CONTENTS MOD" "Items added/removed/edited" $null
                            } else {
                                & $Global:RenderBlock Cyan "[ i ]" "FOLDER UNHIDDEN" "Visibility: Visible" $null
                            }
                        }
                    } else {
                         if (($attr -match "Hidden") -and ($attr -match "ReadOnly")) {
                            Play-Alert
                            & $Global:RenderBlock Magenta "[ ! ]" "ATTR: HIGH SEC" "File Hidden & Locked: $name" "DarkMagenta"
                        } elseif ($attr -match "ReadOnly") {
                            Play-Alert
                            & $Global:RenderBlock Magenta "[ ! ]" "ATTR: LOCKED" "File Read-Only: $name" "DarkMagenta"
                        } elseif ($attr -match "Hidden") {
                            Play-Alert
                            & $Global:RenderBlock Magenta "[ ! ]" "ATTR: HIDDEN" "File Hidden: $name" "DarkMagenta"
                        } else {
                             $timeDiff = 99
                             if ($item) { $timeDiff = ((Get-Date) - $item.LastWriteTime).TotalSeconds }
                             if ($timeDiff -lt 2) { 
                                & $Global:RenderBlock Yellow "[ * ]" "MODIFIED" "Content Updated: $name" $null
                             } else {
                                & $Global:RenderBlock Cyan "[ i ]" "ATTR: NORMAL" "File Unlocked/Unhidden: $name" $null
                             }
                        }
                    }
                }
            }
        } catch { }
    }
    
    $Register = @(
        Register-ObjectEvent $watcher "Created" -Action $action
        Register-ObjectEvent $watcher "Changed" -Action $action
        Register-ObjectEvent $watcher "Deleted" -Action $action
        Register-ObjectEvent $watcher "Renamed" -Action $action
    )
    
    Write-Host ""
    Write-Host "   [ SURVEILLANCE ACTIVE ] Press 'Q' to Kill Task." -ForegroundColor Cyan
    
    while ($true) {
        if ($Host.UI.RawUI.KeyAvailable) {
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($key.Character -eq 'q' -or $key.Character -eq 'Q') {
                $Register | ForEach-Object { Unregister-Event -SourceIdentifier $_.Name }
                $watcher.Dispose()
                Play-Exit
                Start-Sleep 1
                break
            }
        }
        
        $now = Get-Date
        $keys = [array]$Global:PendingDeletions.Keys
        foreach ($k in $keys) {
            $entry = $Global:PendingDeletions[$k]
            if (($now - $entry.Time).TotalMilliseconds -gt 500) {
                Play-Error
                & $Global:RenderBlock Red "[ - ]" "MOVED/DEL" $entry.Path "DarkRed"
                $Global:PendingDeletions.Remove($k)
            }
        }
        Start-Sleep -Milliseconds 100
    }
}

# --- [7] OPEN REPORTS FOLDER ---
function Open-Reports-Folder {
    Show-Header
    Write-Host "[7] MOUNTING INTELLIGENCE DIRECTORY..." -ForegroundColor Green
    
    $path = $Global:BaseReportDir
    if (Test-Path $path) {
        Invoke-Item $path
        Play-Success
        Write-Host "   [SUCCESS] System Explorer initialized." -ForegroundColor Yellow
    } else {
        Play-Error
        Write-Host "   [!] Error: Directory not found." -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 1200
}

# --- UNBREAKABLE MAIN MENU LOOP ---
Play-Startup
try {
    while ($true) {
        Show-Header
        Write-Host "   [1] Single File Forensics"
        Write-Host "   [2] Comparison Engine"
        Write-Host "   [3] Scan Directory"
        Write-Host "   [4] Comparison Directory"
        Write-Host "   [5] Text / String Hasher"
        Write-Host "   [6] Live Surveillance Dashboard"
        Write-Host "   [7] Open Intelligence Folder"
        Write-Host "   [S] Configure Hash Engine" -ForegroundColor Yellow
        Write-Host "   [X] Terminate Session" -ForegroundColor Red
        Write-Host ""
        
        $c = (Read-Host "   Execute Command").Trim().ToLower()

        switch ($c) {
            "1" { Play-Nav; Analyze-File }
            "2" { Play-Nav; Compare-Files }
            "3" { Play-Nav; Scan-Directory }
            "4" { Play-Nav; Compare-Directories }
            "5" { Play-Nav; Hash-Text }
            "6" { Play-Nav; Live-Monitor }
            "7" { Play-Nav; Open-Reports-Folder }
            "s" { Play-Nav; Set-Algorithm }
            "x" { exit } # Exits clean, relies on 'finally' block for the exit sound.
            default { 
                Play-Error
                Write-Host "`n   [!] Command sequence not recognized." -ForegroundColor Red
                Start-Sleep -Milliseconds 1000 
            }
        }
    }
} finally {
    # Guarantees a clean exit if closed via Ctrl+C or pressing 'X'
    Play-Exit
}