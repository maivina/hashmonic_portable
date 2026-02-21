@echo off
setlocal EnableDelayedExpansion
Title Hashmonic Tool - System Integrity
cls

:: ==========================================
:: 1. SETUP ANSI COLORS (The Modern Way)
:: ==========================================
:: This creates the "ESC" character so we can use colors
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"
)

:: Define Colors
set "Red=%ESC%[91m"
set "Green=%ESC%[92m"
set "Yellow=%ESC%[93m"
set "Cyan=%ESC%[96m"
set "White=%ESC%[97m"
set "Gray=%ESC%[90m"
set "Reset=%ESC%[0m"
set "Bold=%ESC%[1m"

:: ==========================================
:: 2. CONFIGURATION
:: ==========================================
set "LNK_NAME=Launch Tool.lnk"
set "SCRIPT_NAME=hashmonic.ps1"

:: Get current folder path
set "CURRENT_DIR=%~dp0"
set "CURRENT_DIR=%CURRENT_DIR:~0,-1%"

set "FULL_LNK=%CURRENT_DIR%\%LNK_NAME%"
set "FULL_SCRIPT=%CURRENT_DIR%\%SCRIPT_NAME%"

:: Header
echo.
echo  %Bold%%Cyan%================================================%Reset%
echo   %Bold%%White%[SYSTEM] HASHMONIC TOOL - INTEGRITY CHECK%Reset%
echo  %Bold%%Cyan%================================================%Reset%
echo.

:: ==========================================
:: 3. VERIFY FILES (Red for Critical Errors)
:: ==========================================
echo  %Gray%[*] Verifying file structure...%Reset%

if not exist "%FULL_SCRIPT%" (
    echo.
    echo  %Red%[CRITICAL ERROR] Core script missing!%Reset%
    echo  %Red%Expected: %SCRIPT_NAME%%Reset%
    echo  %Red%Status:   NOT FOUND%Reset%
    echo.
    echo  %Yellow%ACTION: Please extract all files from the zip.%Reset%
    pause
    exit
)

if not exist "%FULL_LNK%" (
    echo.
    echo  %Red%[CRITICAL ERROR] Shortcut file missing!%Reset%
    echo  %Red%Expected: %LNK_NAME%%Reset%
    echo  %Red%Status:   NOT FOUND%Reset%
    echo.
    echo  %Yellow%ACTION: Make sure "Launch Tool.lnk" is in this folder.%Reset%
    pause
    exit
)

:: ==========================================
:: 4. ANALYZE SHORTCUT TARGET
:: ==========================================
echo  %Gray%[*] Analyzing link targeting...%Reset%

:: PowerShell probe to check if path matches
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$w=New-Object -COM WScript.Shell; $s=$w.CreateShortcut('%FULL_LNK%'); if ($s.Arguments.ToLower().Contains('%FULL_SCRIPT%'.ToLower())) { Write-Host 'MATCH' } else { Write-Host 'MISMATCH' }"`) do set "STATUS=%%I"

if "%STATUS%"=="MATCH" (
    goto :STATE_GOOD
) else (
    goto :STATE_REPAIR
)

:: ==========================================
:: 5. OUTCOME: GREEN (ALL GOOD)
:: ==========================================
:STATE_GOOD
echo.
echo  %Green%[STATUS] SYSTEM INTEGRITY VERIFIED%Reset%
echo  %Gray%-----------------------------------%Reset%
echo  %White%The shortcut is correctly linked to:%Reset%
echo  %Cyan%"%CURRENT_DIR%"%Reset%
echo.
echo  %Green%No repairs required.%Reset%
echo.
goto :LAUNCH_PROMPT

:: ==========================================
:: 6. OUTCOME: YELLOW (AUTO-REPAIR)
:: ==========================================
:STATE_REPAIR
echo.
echo  %Yellow%[STATUS] PATH DRIFT DETECTED%Reset%
echo  %Gray%----------------------------%Reset%
echo  %White%The shortcut is pointing to an old location.%Reset%
echo  %Yellow%[*] Initiating Auto-Repair Sequence...%Reset%

:: REPAIR COMMAND (Silent)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%FULL_LNK%'); $s.TargetPath='powershell.exe'; $s.Arguments='-ExecutionPolicy Bypass -File \"""%FULL_SCRIPT%\"""'; $s.WorkingDirectory='%CURRENT_DIR%'; $s.Save()"

echo  %Green%[+] Repair Complete.%Reset%
echo  %Green%[+] Custom styles (Colors/Opacity) preserved.%Reset%
echo.
goto :LAUNCH_PROMPT

:: ==========================================
:: 7. LAUNCH PROMPT (Using Choice)
:: ==========================================
:LAUNCH_PROMPT
echo  %Cyan%================================================%Reset%
echo  %Bold%%White%[?] Launch tool now? (Y/N)%Reset%
echo.

:: /C YN = Allows keys Y and N
:: /N    = Hides the default [Y,N]? prompt so we use our custom one
:: /M "" = No extra message
choice /C YN /N /M ""

:: Check error level (Y=1, N=2)
if errorlevel 2 goto :EXIT_APP
if errorlevel 1 goto :LAUNCH

:LAUNCH
start "" "%FULL_LNK%"
goto :EXIT_APP

:EXIT_APP
exit