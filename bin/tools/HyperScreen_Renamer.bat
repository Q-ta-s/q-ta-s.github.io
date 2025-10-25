@echo off
setlocal
title HyperScreen Renamer

rem --- settings ---
set "MAX_BYTES=12"

set "TARGET_DIR=renamed"

rem --- temp files ---
set "PS_MENU=%TEMP%\__hyperscreen_renamer_menu.ps1"
set "PS_MAIN=%TEMP%\__hyperscreen_renamer.ps1"
set "PS_CHOICE=%TEMP%\__hyperscreen_renamer_ch.tmp"

set "PUSHED=0"

rem --- build menu script ---
> "%PS_MENU%" echo $menu = @^('Rename to "renamed" folder ^(keep original file^)','Rename original file directly','Cancel rename'^)
>> "%PS_MENU%" echo $index = 0
>> "%PS_MENU%" echo $done = $false
>> "%PS_MENU%" echo $rawui = $Host.UI.RawUI
>> "%PS_MENU%" echo $rawui.CursorSize = 0
>> "%PS_MENU%" echo function Draw-Menu ^{
>> "%PS_MENU%" echo     Clear-Host
>> "%PS_MENU%" echo     for ^($i = 0; $i -lt $menu.Count; $i++^) ^{
>> "%PS_MENU%" echo         if ^($i -eq $index^) ^{
>> "%PS_MENU%" echo             Write-Host "> $($menu[$i])" -ForegroundColor White -BackgroundColor DarkBlue
>> "%PS_MENU%" echo         ^} else ^{
>> "%PS_MENU%" echo             Write-Host "  $($menu[$i])" -ForegroundColor Gray -BackgroundColor Black
>> "%PS_MENU%" echo         ^}
>> "%PS_MENU%" echo     ^}
>> "%PS_MENU%" echo     Write-Host ""
>> "%PS_MENU%" echo     Write-Host "(Use Up/Down arrow keys, Enter to select)" -ForegroundColor Yellow
>> "%PS_MENU%" echo     $pos = $rawui.CursorPosition
>> "%PS_MENU%" echo     $pos.Y = $index
>> "%PS_MENU%" echo     $pos.X = 0
>> "%PS_MENU%" echo     $rawui.CursorPosition = $pos
>> "%PS_MENU%" echo ^}
>> "%PS_MENU%" echo do ^{
>> "%PS_MENU%" echo     Draw-Menu
>> "%PS_MENU%" echo     $keyInfo = $Host.UI.RawUI.ReadKey^("NoEcho,IncludeKeyDown"^)
>> "%PS_MENU%" echo     switch ^($keyInfo.VirtualKeyCode^) ^{
>> "%PS_MENU%" echo         38 ^{ if ^($index -gt 0^) ^{ $index-- ^} ^}
>> "%PS_MENU%" echo         40 ^{ if ^($index -lt $menu.Count - 1^) ^{ $index++ ^} ^}
>> "%PS_MENU%" echo         13 ^{ $done = $true ^}
>> "%PS_MENU%" echo     ^}
>> "%PS_MENU%" echo ^} while ^(-not $done^)
>> "%PS_MENU%" echo Set-Content -Path "%PS_CHOICE%" -Value $index -Encoding Default
>> "%PS_MENU%" echo $rawui.CursorPosition = @{X=0; Y=$menu.Count + 1}
>> "%PS_MENU%" echo $rawui.CursorSize = 25

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_MENU%"
if errorlevel 1 (
  echo ERROR: Failed to launch PowerShell script.
  goto cleanup_exit
)

for /f "delims=" %%a in ('type "%PS_CHOICE%"') do set "CHOICE=%%a"

set "CHOICE_TEXT="
if "%CHOICE%"=="0" set "CHOICE_TEXT=Rename to ^"renamed^" folder (keep original file)"
if "%CHOICE%"=="1" set "CHOICE_TEXT=Rename original file directly"
if "%CHOICE%"=="2" set "CHOICE_TEXT=Cancel rename"

echo(
echo Select: %CHOICE_TEXT%
echo(

if "%CHOICE%"=="2" (
  echo Canceled by user.
  goto cleanup_exit
)

pushd "%~dp0" && set "PUSHED=1"

rem --- count target files (.z**) ---
set "count=0"
for /F "delims=" %%F in ('dir /b /a:-d "*.*" ^| findstr /i "\.z.*$"') do (
  set /a count+=1
)

if %count%==0 (
  echo Target file not found.
  goto cleanup_exit
)

rem --- build truncation script ---
> "%PS_MAIN%"  echo param^([string]$s,[int]$max^)
>> "%PS_MAIN%" echo $out = ''
>> "%PS_MAIN%" echo $len = 0
>> "%PS_MAIN%" echo foreach^($ch in $s.ToCharArray^()^) {
>> "%PS_MAIN%" echo    $cp = [int]$ch
>> "%PS_MAIN%" echo    if^($cp -le 0x7F^) { $b = 1 } elseif^($cp -ge 0xFF61 -and $cp -le 0xFF9F^) { $b = 1 } else { $b = 2 }
>> "%PS_MAIN%" echo    if^($len + $b -le $max^) { $out += $ch; $len += $b } else { break }
>> "%PS_MAIN%" echo }
>> "%PS_MAIN%" echo Write-Output $out

rem --- width calc for numbering ---
set "width=1"
set "threshold=10"
:calc_width
if %count% GEQ %threshold% (
  set /a width+=1
  set /a threshold*=10
  goto calc_width
)

if "%CHOICE%"=="0" (
  if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
)

set "num=1"
for /F "delims=" %%F in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "[IO.FileInfo[]]$arr=Get-ChildItem -File | Where-Object { $_.Extension -like '.z*' }; [Array]::Sort($arr, [System.Comparison[System.IO.FileInfo]]{ param($a,$b) [String]::CompareOrdinal($a.BaseName,$b.BaseName) }); $arr | ForEach-Object { $_.Name }" 2^>nul') do (
  call set "numStr=0000000000%%num%%"
  call set "numStr=%%numStr:~-%width%%%"
  for /F "usebackq delims=" %%T in (`powershell -ExecutionPolicy Bypass -NoProfile -File "%PS_MAIN%" "%%numStr%%-%%~nF" %MAX_BYTES%`) do (
    call set "newName=%%T%%~xF"
    if "%CHOICE%"=="0" (
      call echo Copying: "%%F" to "%TARGET_DIR%\%%newName%%"
      call copy "%%F" "%TARGET_DIR%\%%newName%%" >nul
      if errorlevel 1 call echo ERROR copying "%%F" to "%TARGET_DIR%\%%newName%%"
    ) else (
      call echo Renaming: "%%F" to "%%newName%%"
      call ren "%%F" "%%newName%%" 2>nul
      if errorlevel 1 call echo ERROR renaming "%%F" to "%%newName%%"
    )
  )
  set /a num+=1
)

echo(
echo Processing completed.
goto cleanup_exit

:cleanup_exit
echo Press any key to exit ...
pause>nul
goto cleanup

:cleanup
rem --- cleanup temp files & directory stack ---
if exist "%PS_MENU%"   del "%PS_MENU%"   >nul 2>&1
if exist "%PS_MAIN%"   del "%PS_MAIN%"   >nul 2>&1
if exist "%PS_CHOICE%" del "%PS_CHOICE%" >nul 2>&1
if "%PUSHED%"=="1" popd

endlocal
exit /b
