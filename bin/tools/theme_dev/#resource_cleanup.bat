@ECHO OFF
@REM ===========================================================================
SET QS_FOLDER_NAM_INI=Foldername.ini
SET QS_FOLDER_NAM_SYSTEM_START_NUM=4
SET QS_FOLDER_NAM_SYSTEM_NOT_NAM=ROMS
SET QS_FIND_EXE="%SystemRoot%\System32\FINDSTR.EXE"
IF NOT EXIST %QS_FIND_EXE% SET QS_FIND_EXE=FINDSTR

@REM ===========================================================================
CALL :CURRENT_DRIVE_CHK
IF NOT "%QS_CURRENT_DIR%" == "" SET QS_SD_DRIVE=%QS_CURRENT_DIR%&& GOTO :INPUT_CHECK1
IF NOT "%~1" == "" SET QS_SD_DRIVE=%~1&& GOTO :INPUT_CHECK1
@REM ===========================================================================
:INPUT_START

ECHO.
ECHO Please enter the drive or path where your working dir ^(or SD card^) is located e.g. %QS_CURRENT_DRV%
SET QS_DEFAULT_MESS=""
IF NOT "%QS_CURRENT_DIR%" == "" SET QS_DEFAULT_MESS="(ENTER for Default: [93m%QS_CURRENT_DIR%[0m) "
SET QS_SD_DRIVE=
SET /P QS_SD_DRIVE=%QS_DEFAULT_MESS%
SET QS_SD_DRIVE=%QS_SD_DRIVE%*
SET QS_SD_DRIVE=%QS_SD_DRIVE:"=%
@REM IF "%QS_SD_DRIVE%" == "*" GOTO :INPUT_START
@REM SET QS_SD_DRIVE=%QS_SD_DRIVE:~0,-1%
IF "%QS_SD_DRIVE%" == "*" (
  SET QS_SD_DRIVE=%QS_CURRENT_DIR%
) ELSE (
  SET QS_SD_DRIVE=%QS_SD_DRIVE:~0,-1%
)
IF "%QS_SD_DRIVE%" == "" GOTO :INPUT_START

@REM ===========================================================================
:INPUT_CHECK1

ECHO "%QS_SD_DRIVE%" | %QS_FIND_EXE% ":" >NUL
IF ERRORLEVEL 1 SET QS_SD_DRIVE=%QS_SD_DRIVE%:

IF NOT EXIST "%QS_SD_DRIVE%" (
  ECHO ! Specified drive or path is not accessible
  GOTO :INPUT_START
)

IF NOT EXIST "%QS_SD_DRIVE%\Resources" (
  ECHO ! Couldn't find Resources folder "[93m%QS_SD_DRIVE%\Resources[0m"
  ECHO   Please check the provided path points to the correct working dir or SD card!
  GOTO :INPUT_START
)

IF NOT EXIST "%QS_SD_DRIVE%\Resources\%QS_FOLDER_NAM_INI%" (
IF NOT EXIST "%QS_SD_DRIVE%\Resources\%QS_FOLDER_NAM_INI:e.ini=X.ini%" (
  ECHO ! Couldn't find "%QS_FOLDER_NAM_INI%" file "[93m%QS_SD_DRIVE%\Resources\%QS_FOLDER_NAM_INI%[0m"
  ECHO   Please check the provided path points to the correct working dir or SD card!
  GOTO :INPUT_START
)
)
:INPUT_CHECK1_BS_CHK
IF "%QS_SD_DRIVE:~-1%" == "\" (
  SET QS_SD_DRIVE=%QS_SD_DRIVE:~0,-1%
  GOTO :INPUT_CHECK1_BS_CHK
)

IF EXIST "%QS_SD_DRIVE%\Resources\%QS_FOLDER_NAM_INI:e.ini=X.ini%" (
  @REM ********* 13 MENU MODE *******************
  SET QS_FOLDER_NAM_INI=FoldernamX.ini
)

CALL :GET_FOLDER_NAM "%QS_SD_DRIVE%"
IF ERRORLEVEL 1 (
  SET QS_FOLDER_NAM_INI=Foldername.ini
  GOTO :INPUT_START
)

REM ECHO === [[93m%QS_SD_DRIVE%[0m] was specified ===
ECHO === Target dir: [[93m%QS_SD_DRIVE%\Resources[0m] ===

@REM ===========================================================================
:START_CLEANUP

CALL :CHECK_DEVICE

CALL :CHECK_13_MODE

ECHO.
ECHO Clean up resource files.
ECHO Push Enter to continue, or Type N to cancel
SET QS_SD_SC=
SET /P QS_SD_SC=""
IF "%QS_SD_SC%" == "n" GOTO :CANCEL_CLEANUP
IF "%QS_SD_SC%" == "N" GOTO :CANCEL_CLEANUP

@REM *** Execute Clean up *** 
CALL :CLEAN_UP

ECHO.
ECHO Cleanup completed!
ECHO Press enter to exit
PAUSE>NUL
EXIT /B 0

:CANCEL_CLEANUP

ECHO Cancelled.
ECHO Press enter to exit
PAUSE>NUL
EXIT /B

@REM ###########################################################################
:CLEAN_UP

PUSHD "%QS_SD_DRIVE%\Resources"


rem IF %QS_13_MENU_MODE% == 0 (
  IF EXIST rdbui.tax ECHO cleanup rdbui.tax ...&&DEL rdbui.tax
  IF EXIST urefs.tax ECHO cleanup urefs.tax ...&&DEL urefs.tax
  IF EXIST scksp.tax ECHO cleanup scksp.tax ...&&DEL scksp.tax
  IF EXIST vdsdc.tax ECHO cleanup vdsdc.tax ...&&DEL vdsdc.tax
  IF EXIST pnpui.tax ECHO cleanup pnpui.tax ...&&DEL pnpui.tax
  IF EXIST vfnet.tax ECHO cleanup vfnet.tax ...&&DEL vfnet.tax
  IF EXIST mswb7.tax ECHO cleanup mswb7.tax ...&&DEL mswb7.tax

  IF EXIST fhcfg.nec ECHO cleanup fhcfg.nec ...&&DEL fhcfg.nec
  IF EXIST adsnt.nec ECHO cleanup adsnt.nec ...&&DEL adsnt.nec
  IF EXIST setxa.nec ECHO cleanup setxa.nec ...&&DEL setxa.nec
  IF EXIST umboa.nec ECHO cleanup umboa.nec ...&&DEL umboa.nec
  IF EXIST wjere.nec ECHO cleanup wjere.nec ...&&DEL wjere.nec
  IF EXIST htuiw.nec ECHO cleanup htuiw.nec ...&&DEL htuiw.nec
  IF EXIST msdtc.nec ECHO cleanup msdtc.nec ...&&DEL msdtc.nec

  IF EXIST nethn.bvs ECHO cleanup nethn.bvs ...&&DEL nethn.bvs
  IF EXIST xvb6c.bvs ECHO cleanup xvb6c.bvs ...&&DEL xvb6c.bvs
  IF EXIST wmiui.bvs ECHO cleanup wmiui.bvs ...&&DEL wmiui.bvs
  IF EXIST qdvd6.bvs ECHO cleanup qdvd6.bvs ...&&DEL qdvd6.bvs
  IF EXIST mgdel.bvs ECHO cleanup mgdel.bvs ...&&DEL mgdel.bvs
  IF EXIST sppnp.bvs ECHO cleanup sppnp.bvs ...&&DEL sppnp.bvs
  IF EXIST mfpmp.bvs ECHO cleanup mfpmp.bvs ...&&DEL mfpmp.bvs
rem )

IF %QS_DEVICE_MODE% == GB300V2 (
  IF EXIST kjbyr.tax ECHO cleanup kjbyr.tax ...&&DEL kjbyr.tax
  IF EXIST djoin.nec ECHO cleanup djoin.nec ...&&DEL djoin.nec
  IF EXIST ke89a.bvs ECHO cleanup ke89a.bvs ...&&DEL ke89a.bvs
)

rem IF %QS_13_MENU_MODE% == 1 (
  IF EXIST m01.ta ECHO cleanup m01.ta ...&&DEL m01.ta
  IF EXIST m02.ta ECHO cleanup m02.ta ...&&DEL m02.ta
  IF EXIST m03.ta ECHO cleanup m03.ta ...&&DEL m03.ta
  IF EXIST m04.ta ECHO cleanup m04.ta ...&&DEL m04.ta
  IF EXIST m05.ta ECHO cleanup m05.ta ...&&DEL m05.ta
  IF EXIST m06.ta ECHO cleanup m06.ta ...&&DEL m06.ta
  IF EXIST m07.ta ECHO cleanup m07.ta ...&&DEL m07.ta
  IF EXIST m08.ta ECHO cleanup m08.ta ...&&DEL m08.ta
  IF EXIST m09.ta ECHO cleanup m09.ta ...&&DEL m09.ta
  IF EXIST m10.ta ECHO cleanup m10.ta ...&&DEL m10.ta
  IF EXIST m11.ta ECHO cleanup m11.ta ...&&DEL m11.ta
  IF EXIST m12.ta ECHO cleanup m12.ta ...&&DEL m12.ta

  IF EXIST m01.ne ECHO cleanup m01.ne ...&&DEL m01.ne
  IF EXIST m02.ne ECHO cleanup m02.ne ...&&DEL m02.ne
  IF EXIST m03.ne ECHO cleanup m03.ne ...&&DEL m03.ne
  IF EXIST m04.ne ECHO cleanup m04.ne ...&&DEL m04.ne
  IF EXIST m05.ne ECHO cleanup m05.ne ...&&DEL m05.ne
  IF EXIST m06.ne ECHO cleanup m06.ne ...&&DEL m06.ne
  IF EXIST m07.ne ECHO cleanup m07.ne ...&&DEL m07.ne
  IF EXIST m08.ne ECHO cleanup m08.ne ...&&DEL m08.ne
  IF EXIST m09.ne ECHO cleanup m09.ne ...&&DEL m09.ne
  IF EXIST m10.ne ECHO cleanup m10.ne ...&&DEL m10.ne
  IF EXIST m11.ne ECHO cleanup m11.ne ...&&DEL m11.ne
  IF EXIST m12.ne ECHO cleanup m12.ne ...&&DEL m12.ne

  IF EXIST m01.bv ECHO cleanup m01.bv ...&&DEL m01.bv
  IF EXIST m02.bv ECHO cleanup m02.bv ...&&DEL m02.bv
  IF EXIST m03.bv ECHO cleanup m03.bv ...&&DEL m03.bv
  IF EXIST m04.bv ECHO cleanup m04.bv ...&&DEL m04.bv
  IF EXIST m05.bv ECHO cleanup m05.bv ...&&DEL m05.bv
  IF EXIST m06.bv ECHO cleanup m06.bv ...&&DEL m06.bv
  IF EXIST m07.bv ECHO cleanup m07.bv ...&&DEL m07.bv
  IF EXIST m08.bv ECHO cleanup m08.bv ...&&DEL m08.bv
  IF EXIST m09.bv ECHO cleanup m09.bv ...&&DEL m09.bv
  IF EXIST m10.bv ECHO cleanup m10.bv ...&&DEL m10.bv
  IF EXIST m11.bv ECHO cleanup m11.bv ...&&DEL m11.bv
  IF EXIST m12.bv ECHO cleanup m12.bv ...&&DEL m12.bv
rem )


rem IF EXIST TSMFK.TAX      ECHO cleanup TSMFK.TAX ...&&     DEL TSMFK.TAX
IF EXIST Favorites.bin  ECHO cleanup Favorites.bin ...&& DEL Favorites.bin
IF EXIST History.bin    ECHO cleanup History.bin ...&&   DEL History.bin
IF EXIST KeyMapInfo.kmp ECHO cleanup KeyMapInfo.kmp ...&&DEL KeyMapInfo.kmp


POPD

:CLEAN_UP_EXIT

EXIT /B

@REM ###########################################################################
:GET_FOLDER_NAM

SET QS_SYSTEM_LIST=
SET QS_FOLDER_NAM=0
SET QS_FOLDER_NAM_CMM=
SET QS_FOR_PARAM=usebackq skip=%QS_FOLDER_NAM_SYSTEM_START_NUM% tokens=1,2*
FOR /F "%QS_FOR_PARAM%" %%R IN ("%~1\Resources\%QS_FOLDER_NAM_INI%") DO (
  SET QS_FOR_SYS=
  IF "%%S" == "" (
    @REM ********* 13 MENU MODE *******************
    IF "%%R" == "" GOTO :GET_FOLDER_NAM_EXIT
    CALL :NUMBER_CHK %%R
    IF NOT DEFINED QS_NUM GOTO :GET_FOLDER_NAM_EXIT
    SET QS_FOR_SYS=%%R
    @REM ******************************************
  ) ELSE (
    IF "%%S" == "%QS_FOLDER_NAM_SYSTEM_NOT_NAM%" GOTO :GET_FOLDER_NAM_EXIT
    CALL :NUMBER_CHK %%S
    IF NOT DEFINED QS_NUM GOTO :GET_FOLDER_NAM_EXIT
    SET QS_FOR_SYS=%%S
    IF NOT "%%T" == "" SET QS_FOR_SYS=%%S %%T
  )
  CALL SET QS_SYSTEM_LIST=%%QS_SYSTEM_LIST%%%%QS_FOLDER_NAM_CMM%%%%QS_FOR_SYS%%
  CALL SET QS_SYSTEM_NAME[%%QS_FOLDER_NAM%%]=%%QS_FOR_SYS%%
  CALL SET /A QS_FOLDER_NAM=%%QS_FOLDER_NAM%% + 1
  @REM CALL ECHO %%QS_FOR_SYS%% - %%QS_FOLDER_NAM%%
  SET QS_FOLDER_NAM_CMM=, 
)

:GET_FOLDER_NAM_EXIT
IF NOT "%QS_SYSTEM_LIST%" == "" EXIT /B 0

ECHO ! SD card not read file. "[93m%~1\Resources\%QS_FOLDER_NAM_INI%[0m"
ECHO ! If [93m%QS_FOLDER_NAM_INI%[0m is open, close and try running again.
EXIT /B 1

@REM ###########################################################################
:CHECK_DEVICE

SET QS_DEVICE_MODE=SF2000

SET QS_FOR_PARAM=usebackq tokens=1
FOR /F "%QS_FOR_PARAM%" %%A IN ("%QS_SD_DRIVE%\Resources\%QS_FOLDER_NAM_INI%") DO (
  SET QS_DEVICE_MODE=%%A
  GOTO :CHECK_DEVICE_ON
)

:CHECK_DEVICE_ON

IF %QS_FOLDER_NAM% GTR 7 (
  IF EXIST "%QS_SD_DRIVE%\Resources\m01.mm" GOTO :CHECK_DEVICE_EXIT
  SET QS_DEVICE_MODE=GB300V2
)

:CHECK_DEVICE_EXIT
ECHO *** Device: [93m%QS_DEVICE_MODE%[0m ***
EXIT /B

@REM ###########################################################################
:CHECK_13_MODE

SET QS_13_MENU_MODE=0
IF %QS_FOLDER_NAM% GTR 8 (
  IF EXIST "%QS_SD_DRIVE%\Resources\m01.mm" GOTO :CHECK_13_MODE_EXIT
)
EXIT /B

:CHECK_13_MODE_EXIT
ECHO ***[93m [0m[36mNew menus extended version[0m[93m has been detected.[0m ***
SET QS_13_MENU_MODE=1
EXIT /B

@REM ###########################################################################
:CURRENT_DRIVE_CHK

PUSHD %~dp0

SET QS_CURRENT_DIR=%CD%
SET QS_CURRENT_DRV=
IF EXIST "%QS_CURRENT_DIR%\Resources" (
  IF EXIST "%QS_CURRENT_DIR%\Resources\%QS_FOLDER_NAM_INI%" GOTO :CURRENT_DRIVE_CHK_NEXT
  IF EXIST "%QS_CURRENT_DIR%\Resources\%QS_FOLDER_NAM_INI:e.ini=X.ini%" GOTO :CURRENT_DRIVE_CHK_NEXT
)

POPD

PUSHD %~dp0\..

SET QS_CURRENT_DIR=%CD%
SET QS_CURRENT_DRV=
IF EXIST "%QS_CURRENT_DIR%\Resources" (
  IF EXIST "%QS_CURRENT_DIR%\Resources\%QS_FOLDER_NAM_INI%" GOTO :CURRENT_DRIVE_CHK_NEXT
  IF EXIST "%QS_CURRENT_DIR%\Resources\%QS_FOLDER_NAM_INI:e.ini=X.ini%" GOTO :CURRENT_DRIVE_CHK_NEXT
)

POPD

PUSHD %~dp0\..\..

SET QS_CURRENT_DIR=%CD%
SET QS_CURRENT_DRV=
IF NOT EXIST "%QS_CURRENT_DIR%\Resources" (
  SET QS_CURRENT_DIR=*
) ELSE (
  IF EXIST "%QS_CURRENT_DIR%\Resources\%QS_FOLDER_NAM_INI%" GOTO :CURRENT_DRIVE_CHK_NEXT
  IF EXIST "%QS_CURRENT_DIR%\Resources\%QS_FOLDER_NAM_INI:e.ini=X.ini%" GOTO :CURRENT_DRIVE_CHK_NEXT
  SET QS_CURRENT_DIR=*
)
IF "%QS_CURRENT_DIR%" == "*" (
  IF EXIST "%~d0\Resources" (
    IF EXIST "%~d0\Resources\%QS_FOLDER_NAM_INI%" SET QS_CURRENT_DIR=%~d0
    IF EXIST "%~d0\Resources\%QS_FOLDER_NAM_INI:e.ini=X.ini%" SET QS_CURRENT_DIR=%~d0
  )
)
:CURRENT_DRIVE_CHK_NEXT
IF "%QS_CURRENT_DIR:~-1%" == "\" SET QS_CURRENT_DIR=%QS_CURRENT_DIR:~0,-1%
IF "%QS_CURRENT_DIR:~-1%" == ":" SET QS_CURRENT_DRV=%QS_CURRENT_DIR%
IF "%QS_CURRENT_DIR%" == "*" SET QS_CURRENT_DIR=
IF "%QS_CURRENT_DRV%" == "" SET QS_CURRENT_DRV=F:

POPD

EXIT /B

@REM ###########################################################################
:NUMBER_CHK

SET QS_NUM=%1

IF DEFINED QS_NUM SET QS_NUM=%QS_NUM:0=%
IF DEFINED QS_NUM SET QS_NUM=%QS_NUM:1=%
IF DEFINED QS_NUM SET QS_NUM=%QS_NUM:2=%
IF DEFINED QS_NUM SET QS_NUM=%QS_NUM:3=%
IF DEFINED QS_NUM SET QS_NUM=%QS_NUM:4=%
IF DEFINED QS_NUM SET QS_NUM=%QS_NUM:5=%
IF DEFINED QS_NUM SET QS_NUM=%QS_NUM:6=%
IF DEFINED QS_NUM SET QS_NUM=%QS_NUM:7=%
IF DEFINED QS_NUM SET QS_NUM=%QS_NUM:8=%
IF DEFINED QS_NUM SET QS_NUM=%QS_NUM:9=%

EXIT /B
