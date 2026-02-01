@ECHO OFF
SET FROG_TOOL_FILE=frogtool.exe
@REM ===GAME SYSTEM FOLDER LIST=================================================

SET QS_SYS_NAME[0]=FC
SET QS_SYS_NAME[1]=SFC
SET QS_SYS_NAME[2]=MD
SET QS_SYS_NAME[3]=GB
SET QS_SYS_NAME[4]=GBC
SET QS_SYS_NAME[5]=GBA
SET QS_SYS_NAME[6]=ARCADE

@REM ===========================================================================

SET QS_FOLDER_NAM_INI=Foldername.ini
SET QS_FOLDER_NAM_SYSTEM_START_NUM=4
SET QS_FOLDER_NAM_SYSTEM_NOT_NAM=ROMS
SET QS_FIND_EXE="%SystemRoot%\System32\FINDSTR.EXE"
IF NOT EXIST %QS_FIND_EXE% SET QS_FIND_EXE=FINDSTR

@REM ===========================================================================
IF NOT EXIST "%~dp0\%FROG_TOOL_FILE%" (
  ECHO ! Please Place "[93m%FROG_TOOL_FILE%[0m" as same folder.
  ECHO Press enter to exit
  PAUSE>NUL
  EXIT /B -1
)

CALL :CURRENT_DRIVE_CHK
IF NOT "%~1" == "" SET QS_SD_DRIVE=%~1&& GOTO :INPUT_CHECK1
@REM ===========================================================================
:INPUT_START
 
ECHO.
ECHO Please enter the drive or path where your SF2000 SD card is located e.g. %QS_CURRENT_DRV%
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
  ECHO   Check the provided path points to an SF2000 SD card!
  GOTO :INPUT_START
)

IF NOT EXIST "%QS_SD_DRIVE%\Resources\%QS_FOLDER_NAM_INI%" (
IF NOT EXIST "%QS_SD_DRIVE%\Resources\%QS_FOLDER_NAM_INI:e.ini=X.ini%" (
  ECHO ! Couldn't find "%QS_FOLDER_NAM_INI%" file "[93m%QS_SD_DRIVE%\Resources\%QS_FOLDER_NAM_INI%[0m"
  ECHO   Check the provided path points to an SF2000 SD card!
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

CALL :REPAIR_CHCK "%QS_SD_DRIVE%"
CALL :GET_FOLDER_NAM "%QS_SD_DRIVE%"
IF ERRORLEVEL 1 (
  SET QS_FOLDER_NAM_INI=Foldername.ini
  GOTO :INPUT_START
)

ECHO === [[93m%QS_SD_DRIVE%[0m] was specified ===

IF NOT "%~2" == "" SET QS_SD_SYSTEM=%~2&& GOTO :INPUT_CHECK2
@REM ===========================================================================
:INPUT_NEXT

ECHO.
ECHO Please enter the system to rebuild game list for: %QS_SYSTEM_LIST% or ALL
SET QS_SD_SYSTEM=
SET /P QS_SD_SYSTEM=""
SET QS_SD_SYSTEM=%QS_SD_SYSTEM%*
SET QS_SD_SYSTEM=%QS_SD_SYSTEM:"=%
IF "%QS_SD_SYSTEM%" == "*" GOTO :INPUT_NEXT
SET QS_SD_SYSTEM=%QS_SD_SYSTEM:~0,-1%

@REM ===========================================================================
:INPUT_CHECK2
CALL :UCASE %QS_SD_SYSTEM%
SET QS_SD_SYSTEM=%QS_UCASE_STR%

IF "%QS_SD_SYSTEM%" == "ALL" GOTO :INPUT_CONFIRM

SET QS_I=0
:CHECK_LOOP
CALL SET QS_SYS=%%QS_SYSTEM_NAME[%QS_I%]%%
IF DEFINED QS_SYS (
  IF "%QS_SD_SYSTEM%" == "%QS_SYS%" GOTO :INPUT_CONFIRM
  SET /A QS_I=%QS_I% + 1
  GOTO :CHECK_LOOP
)

ECHO ! Specified system is not one of the accepted options
GOTO :INPUT_NEXT

@REM ===========================================================================
:INPUT_CONFIRM
ECHO === [[93m%QS_SD_SYSTEM%[0m] was specified ===
SET QS_SC_FLG=0
IF "%~3" == "-sc" SET QS_SC_FLG=1&& GOTO :START_FROGTOOL

ECHO.
ECHO = Start processing.
ECHO.
ECHO Type Y to continue, or anything else to cancel
SET QS_SD_SC=
SET /P QS_SD_SC=""
IF "%QS_SD_SC%" == "Y" GOTO :START_FROGTOOL
IF "%QS_SD_SC%" == "y" GOTO :START_FROGTOOL

ECHO Cancelling, game list not modified.
ECHO Press enter to exit
PAUSE>NUL
EXIT /B

@REM ===========================================================================
:START_FROGTOOL

CALL :CHECK_13_MODE

SET QS_I=0
:FROGTOOL_LOOP
CALL SET QS_SYS=%%QS_SYS_NAME[%QS_I%]%%
CALL SET QS_SYSTEM=%%QS_SYSTEM_NAME[%QS_I%]%%

IF NOT DEFINED QS_SYS SET QS_SYS=GBC

IF DEFINED QS_SYSTEM (
  IF "%QS_SD_SYSTEM%" == "ALL"         CALL :EXEC_FROG_TOOL "%QS_SYS%" "%QS_SYSTEM%" "%QS_SD_DRIVE%" %QS_I%
  IF "%QS_SD_SYSTEM%" == "%QS_SYSTEM%" CALL :EXEC_FROG_TOOL "%QS_SYS%" "%QS_SYSTEM%" "%QS_SD_DRIVE%" %QS_I%

  IF NOT EXIST "%QS_SD_DRIVE%\%QS_SYSTEM%\save" MD "%QS_SD_DRIVE%\%QS_SYSTEM%\save"
  SET /A QS_I=%QS_I% + 1
  GOTO :FROGTOOL_LOOP
)

IF %QS_SC_FLG%==0 (
  ECHO Press enter to exit
  PAUSE>NUL
)

EXIT /B 0


@REM ###########################################################################
:EXEC_FROG_TOOL

CALL SET QS_ORIGINAL_FOLDER_NAME=%~1

SET QS_ALT_FOLDER=
IF "%~2" NEQ "%QS_ORIGINAL_FOLDER_NAME%" (
  IF EXIST "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs" (
    CALL :EMPTY_FOLDER_CHK "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs"
    IF EXIST "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs" (
      IF EXIST "%~3\%QS_ORIGINAL_FOLDER_NAME%" (
        CALL :EMPTY_FOLDER_CHK "%~3\%QS_ORIGINAL_FOLDER_NAME%"
        IF EXIST "%~3\%QS_ORIGINAL_FOLDER_NAME%" (
          ECHO ! Exist folder "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs", Error.
          EXIT /B 1
        )
      )
      REN "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs" "%QS_ORIGINAL_FOLDER_NAME%"
      IF ERRORLEVEL 1 (
        ECHO ! Exist folder "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs", Error.
        EXIT /B 1
      )
    )
  )
  CALL :WAIT_SEC 3 3 "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs"
  REN "%~3\%QS_ORIGINAL_FOLDER_NAME%" "%QS_ORIGINAL_FOLDER_NAME%_Qs"
  IF ERRORLEVEL 1 (
    ECHO ! SD card read error. "%~3\%QS_ORIGINAL_FOLDER_NAME%" -^> "%QS_ORIGINAL_FOLDER_NAME%_Qs"
    ECHO ! Please [93mclose Explorer[0m or [96mFiler[0m once and try again.
    EXIT /B 1
  )
  CALL :WAIT_SEC 3 3 "%~3\%QS_ORIGINAL_FOLDER_NAME%"
  REN "%~3\%~2" "%QS_ORIGINAL_FOLDER_NAME%"
  IF ERRORLEVEL 1 (
    IF EXIST "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs" (
      IF NOT EXIST "%~3\%QS_ORIGINAL_FOLDER_NAME%" (
        REN "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs" "%QS_ORIGINAL_FOLDER_NAME%"
      )
    )
    ECHO ! SD card read error. "%~3\%~2" -^> "%QS_ORIGINAL_FOLDER_NAME%"
    ECHO ! Please [93mclose Explorer[0m or [96mFiler[0m once and try again.
    EXIT /B 1
  )
  SET QS_ALT_FOLDER= ^(%QS_ORIGINAL_FOLDER_NAME%^)
)

@REM *** 13 MENU FUNCTION ***
CALL :CHECK_13_GAME_LIST %4 %1

ECHO %FROG_TOOL_FILE% %3 %~2%QS_ALT_FOLDER%
"%~dp0%FROG_TOOL_FILE%" %3 %QS_ORIGINAL_FOLDER_NAME% -sc

SET QS_EXT1=
SET QS_EXT2=
CALL :GET_EXT %QS_ORIGINAL_FOLDER_NAME%
SET QS_EXT1=%QS_EXT%
CALL :GET_EXT %~2
SET QS_EXT2=%QS_EXT%

IF "%QS_EXT1%" == "%QS_EXT2%" GOTO :END_FROG_TOOL
IF "%QS_EXT1%" == "zfb" GOTO :END_FROG_TOOL

SET QS_FOR_FILE_CNT=0
FOR %%A IN ("%~3\%QS_ORIGINAL_FOLDER_NAME%\*.*") DO (
  CALL SET /A QS_FOR_FILE_CNT=%%QS_FOR_FILE_CNT%% + 1
)
IF %QS_FOR_FILE_CNT% EQU 0 GOTO :END_FROG_TOOL

ECHO Finalizing ...
REN "%~3\%QS_ORIGINAL_FOLDER_NAME%\*.%QS_EXT1%" "*.%QS_EXT2%">NUL 2>&1
TIMEOUT /T 1 /NOBREAK>NUL
"%~dp0%FROG_TOOL_FILE%" %3 %QS_ORIGINAL_FOLDER_NAME% -sc>NUL

:END_FROG_TOOL
TIMEOUT /T 1 /NOBREAK>NUL

@REM *** 13 MENU FUNCTION ***
CALL :RENAME_13_GAME_LIST %4 %1
IF ERRORLEVEL 1 (
  ECHO ! SD card write error. "Rename to mXX.ta"
  EXIT /B 1
)

IF "%~2" NEQ "%QS_ORIGINAL_FOLDER_NAME%" (
  REN "%~3\%QS_ORIGINAL_FOLDER_NAME%" "%~2"
  IF ERRORLEVEL 1 (
    IF EXIST "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs" (
      IF NOT EXIST "%~3\%QS_ORIGINAL_FOLDER_NAME%" (
        REN "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs" "%QS_ORIGINAL_FOLDER_NAME%"
      )
    )
    ECHO ! SD card write error. "%~3\%QS_ORIGINAL_FOLDER_NAME%" -^> "%~2"
    REM EXIT /B 1
  )
  CALL :WAIT_SEC 3 3 "%~3\%QS_ORIGINAL_FOLDER_NAME%"
  REN "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs" "%QS_ORIGINAL_FOLDER_NAME%"
  IF ERRORLEVEL 1 (
    ECHO ! SD card write error. "%~3\%QS_ORIGINAL_FOLDER_NAME%_Qs" -^> "%QS_ORIGINAL_FOLDER_NAME%"
    EXIT /B 1
  )
)

EXIT /B 0

@REM ===========================================================================
:REPAIR_CHCK

SET QS_I=0
:REPAIR_LOOP
CALL SET QS_SYS=%%QS_SYS_NAME[%QS_I%]%%
IF DEFINED QS_SYS (
  CALL :EMPTY_FOLDER_CHK "%~1\%QS_SYS%"
  IF NOT EXIST "%~1\%QS_SYS%" (
    IF EXIST "%~1\%QS_SYS%_Qs" (
      REN "%~1\%QS_SYS%_Qs" "%QS_SYS%"
    ) ELSE (
      MD "%~1\%QS_SYS%"
    )
  )
  SET /A QS_I=%QS_I% + 1
  GOTO :REPAIR_LOOP
)

EXIT /B 0

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
  CALL :GET_FOLDER_NAM_CHK "%~1\%%QS_FOR_SYS%%"
  SET QS_FOLDER_NAM_CMM=, 
)

:GET_FOLDER_NAM_CHK
IF NOT EXIST "%~1" (
  IF NOT EXIST "%~1_Qs" MD "%~1"
)
EXIT /B

:GET_FOLDER_NAM_EXIT
IF NOT "%QS_SYSTEM_LIST%" == "" EXIT /B 0

ECHO ! SD card not read file. "[93m%~1\Resources\%QS_FOLDER_NAM_INI%[0m"
ECHO ! If [93m%QS_FOLDER_NAM_INI%[0m is open, close and try running again.
EXIT /B 1

@REM ###########################################################################
:CHECK_13_MODE

SET QS_13_MENU_MODE=0
IF %QS_FOLDER_NAM% GTR 7 (
  IF EXIST "%QS_SD_DRIVE%\Resources\m01.mm" GOTO :CHECK_13_MODE_EXIT
)
EXIT /B

:CHECK_13_MODE_EXIT
ECHO *** [93mA [0m[36mnew menu extended version[0m[93m has been detected.[0m ***
SET QS_13_MENU_MODE=1
EXIT /B

@REM ###########################################################################
:CHECK_13_GAME_LIST

SET /A QS_RES_NUM=%1 + 1
SET QS_RES_NUM=00%QS_RES_NUM%
SET QS_RES_NUM=%QS_RES_NUM:~-2%

PUSHD "%QS_SD_DRIVE%\Resources"

IF %QS_13_MENU_MODE% == 0 GOTO :CHECK_13_GAME_LIST_EXIT

IF %1 EQU 0 (
  IF NOT EXIST rdbui.tax (
    IF EXIST m%QS_RES_NUM%.ta REN m%QS_RES_NUM%.ta rdbui.tax
  )
  IF NOT EXIST fhcfg.nec (
    IF EXIST m%QS_RES_NUM%.ne REN m%QS_RES_NUM%.ne fhcfg.nec
  )
  IF NOT EXIST nethn.bvs (
    IF EXIST m%QS_RES_NUM%.bv REN m%QS_RES_NUM%.bv nethn.bvs
  )
)
IF %1 EQU 1 (
  IF NOT EXIST urefs.tax (
    IF EXIST m%QS_RES_NUM%.ta REN m%QS_RES_NUM%.ta urefs.tax
  )
  IF NOT EXIST adsnt.nec (
    IF EXIST m%QS_RES_NUM%.ne REN m%QS_RES_NUM%.ne adsnt.nec
  )
  IF NOT EXIST xvb6c.bvs (
    IF EXIST m%QS_RES_NUM%.bv REN m%QS_RES_NUM%.bv xvb6c.bvs
  )
)
IF %1 EQU 2 (
  IF NOT EXIST scksp.tax (
    IF EXIST m%QS_RES_NUM%.ta REN m%QS_RES_NUM%.ta scksp.tax
  )
  IF NOT EXIST setxa.nec (
    IF EXIST m%QS_RES_NUM%.ne REN m%QS_RES_NUM%.ne setxa.nec
  )
  IF NOT EXIST wmiui.bvs (
    IF EXIST m%QS_RES_NUM%.bv REN m%QS_RES_NUM%.bv wmiui.bvs
  )
)
IF %1 EQU 3 (
  IF NOT EXIST vdsdc.tax (
    IF EXIST m%QS_RES_NUM%.ta REN m%QS_RES_NUM%.ta vdsdc.tax
  )
  IF NOT EXIST umboa.nec (
    IF EXIST m%QS_RES_NUM%.ne REN m%QS_RES_NUM%.ne umboa.nec
  )
  IF NOT EXIST qdvd6.bvs (
    IF EXIST m%QS_RES_NUM%.bv REN m%QS_RES_NUM%.bv qdvd6.bvs
  )
)
IF %1 EQU 4 (
  IF NOT EXIST pnpui.tax (
    IF EXIST m%QS_RES_NUM%.ta REN m%QS_RES_NUM%.ta pnpui.tax
  )
  IF NOT EXIST wjere.nec (
    IF EXIST m%QS_RES_NUM%.ne REN m%QS_RES_NUM%.ne wjere.nec
  )
  IF NOT EXIST mgdel.bvs (
    IF EXIST m%QS_RES_NUM%.bv REN m%QS_RES_NUM%.bv mgdel.bvs
  )
)
IF %1 EQU 5 (
  IF NOT EXIST vfnet.tax (
    IF EXIST m%QS_RES_NUM%.ta REN m%QS_RES_NUM%.ta vfnet.tax
  )
  IF NOT EXIST htuiw.nec (
    IF EXIST m%QS_RES_NUM%.ne REN m%QS_RES_NUM%.ne htuiw.nec
  )
  IF NOT EXIST sppnp.bvs (
    IF EXIST m%QS_RES_NUM%.bv REN m%QS_RES_NUM%.bv sppnp.bvs
  )
)
IF %1 EQU 6 (
  IF NOT EXIST mswb7.tax (
    IF EXIST m%QS_RES_NUM%.ta REN m%QS_RES_NUM%.ta mswb7.tax
  )
  IF NOT EXIST msdtc.nec (
    IF EXIST m%QS_RES_NUM%.ne REN m%QS_RES_NUM%.ne msdtc.nec
  )
  IF NOT EXIST mfpmp.bvs (
    IF EXIST m%QS_RES_NUM%.bv REN m%QS_RES_NUM%.bv mfpmp.bvs
  )
)
IF %1 GEQ 7 (
  IF NOT EXIST pnpui.tax (
    IF EXIST m%QS_RES_NUM%.ta REN m%QS_RES_NUM%.ta pnpui.tax
  )
  IF NOT EXIST wjere.nec (
    IF EXIST m%QS_RES_NUM%.ne REN m%QS_RES_NUM%.ne wjere.nec
  )
  IF NOT EXIST mgdel.bvs (
    IF EXIST m%QS_RES_NUM%.bv REN m%QS_RES_NUM%.bv mgdel.bvs
  )
)

:CHECK_13_GAME_LIST_EXIT

IF %1 EQU 0 (
  IF NOT EXIST rdbui.tax TYPE NUL> rdbui.tax
  IF NOT EXIST fhcfg.nec TYPE NUL> fhcfg.nec
  IF NOT EXIST nethn.bvs TYPE NUL> nethn.bvs
)
IF %1 EQU 1 (
  IF NOT EXIST urefs.tax TYPE NUL> urefs.tax
  IF NOT EXIST adsnt.nec TYPE NUL> adsnt.nec
  IF NOT EXIST xvb6c.bvs TYPE NUL> xvb6c.bvs
)
IF %1 EQU 2 (
  IF NOT EXIST scksp.tax TYPE NUL> scksp.tax
  IF NOT EXIST setxa.nec TYPE NUL> setxa.nec
  IF NOT EXIST wmiui.bvs TYPE NUL> wmiui.bvs
)
IF %1 EQU 3 (
  IF NOT EXIST vdsdc.tax TYPE NUL> vdsdc.tax
  IF NOT EXIST umboa.nec TYPE NUL> umboa.nec
  IF NOT EXIST qdvd6.bvs TYPE NUL> qdvd6.bvs
)
IF %1 EQU 4 (
  IF NOT EXIST pnpui.tax TYPE NUL> pnpui.tax
  IF NOT EXIST wjere.nec TYPE NUL> wjere.nec
  IF NOT EXIST mgdel.bvs TYPE NUL> mgdel.bvs
)
IF %1 EQU 5 (
  IF NOT EXIST vfnet.tax TYPE NUL> vfnet.tax
  IF NOT EXIST htuiw.nec TYPE NUL> htuiw.nec
  IF NOT EXIST sppnp.bvs TYPE NUL> sppnp.bvs
)
IF %1 EQU 6 (
  IF NOT EXIST mswb7.tax TYPE NUL> mswb7.tax
  IF NOT EXIST msdtc.nec TYPE NUL> msdtc.nec
  IF NOT EXIST mfpmp.bvs TYPE NUL> mfpmp.bvs
)
IF %1 GEQ 7 (
  IF NOT EXIST pnpui.tax TYPE NUL> pnpui.tax
  IF NOT EXIST wjere.nec TYPE NUL> wjere.nec
  IF NOT EXIST mgdel.bvs TYPE NUL> mgdel.bvs
)

POPD

EXIT /B

@REM ###########################################################################
:RENAME_13_GAME_LIST

IF %QS_13_MENU_MODE% == 0 GOTO :RENAME_13_GAME_LIST_EXIT

SET /A QS_RES_NUM=%1 + 1
SET QS_RES_NUM=00%QS_RES_NUM%
SET QS_RES_NUM=%QS_RES_NUM:~-2%

PUSHD "%QS_SD_DRIVE%\Resources"

ECHO *** Renaming [m%QS_RES_NUM%] ***
IF %1 EQU 0 (
  ECHO rdbui.tax -^> m%QS_RES_NUM%.ta 
  COPY /Y rdbui.tax m%QS_RES_NUM%.ta>NUL&&DEL rdbui.tax
  IF ERRORLEVEL 1 EXIT /B 1
  ECHO fhcfg.nec -^> m%QS_RES_NUM%.ne
  COPY /Y fhcfg.nec m%QS_RES_NUM%.ne>NUL&&DEL fhcfg.nec
  ECHO nethn.bvs -^> m%QS_RES_NUM%.bv
  COPY /Y nethn.bvs m%QS_RES_NUM%.bv>NUL&&DEL nethn.bvs
)
IF %1 EQU 1 (
  ECHO urefs.tax -^> m%QS_RES_NUM%.ta 
  COPY /Y urefs.tax m%QS_RES_NUM%.ta>NUL&&DEL urefs.tax
  IF ERRORLEVEL 1 EXIT /B 1
  ECHO adsnt.nec -^> m%QS_RES_NUM%.ne
  COPY /Y adsnt.nec m%QS_RES_NUM%.ne>NUL&&DEL adsnt.nec
  ECHO xvb6c.bvs -^> m%QS_RES_NUM%.bv
  COPY /Y xvb6c.bvs m%QS_RES_NUM%.bv>NUL&&DEL xvb6c.bvs
)
IF %1 EQU 2 (
  ECHO scksp.tax -^> m%QS_RES_NUM%.ta 
  COPY /Y scksp.tax m%QS_RES_NUM%.ta>NUL&&DEL scksp.tax
  IF ERRORLEVEL 1 EXIT /B 1
  ECHO setxa.nec -^> m%QS_RES_NUM%.ne
  COPY /Y setxa.nec m%QS_RES_NUM%.ne>NUL&&DEL setxa.nec
  ECHO wmiui.bvs -^> m%QS_RES_NUM%.bv
  COPY /Y wmiui.bvs m%QS_RES_NUM%.bv>NUL&&DEL wmiui.bvs
)
IF %1 EQU 3 (
  ECHO vdsdc.tax -^> m%QS_RES_NUM%.ta 
  COPY /Y vdsdc.tax m%QS_RES_NUM%.ta>NUL&&DEL vdsdc.tax
  IF ERRORLEVEL 1 EXIT /B 1
  ECHO umboa.nec -^> m%QS_RES_NUM%.ne
  COPY /Y umboa.nec m%QS_RES_NUM%.ne>NUL&&DEL umboa.nec
  ECHO qdvd6.bvs -^> m%QS_RES_NUM%.bv
  COPY /Y qdvd6.bvs m%QS_RES_NUM%.bv>NUL&&DEL qdvd6.bvs
)
IF %1 EQU 4 (
  ECHO pnpui.tax -^> m%QS_RES_NUM%.ta 
  COPY /Y pnpui.tax m%QS_RES_NUM%.ta>NUL&&DEL pnpui.tax
  IF ERRORLEVEL 1 EXIT /B 1
  ECHO wjere.nec -^> m%QS_RES_NUM%.ne
  COPY /Y wjere.nec m%QS_RES_NUM%.ne>NUL&&DEL wjere.nec
  ECHO mgdel.bvs -^> m%QS_RES_NUM%.bv
  COPY /Y mgdel.bvs m%QS_RES_NUM%.bv>NUL&&DEL mgdel.bvs
)
IF %1 EQU 5 (
  ECHO vfnet.tax -^> m%QS_RES_NUM%.ta 
  COPY /Y vfnet.tax m%QS_RES_NUM%.ta>NUL&&DEL vfnet.tax
  IF ERRORLEVEL 1 EXIT /B 1
  ECHO htuiw.nec -^> m%QS_RES_NUM%.ne
  COPY /Y htuiw.nec m%QS_RES_NUM%.ne>NUL&&DEL htuiw.nec
  ECHO sppnp.bvs -^> m%QS_RES_NUM%.bv
  COPY /Y sppnp.bvs m%QS_RES_NUM%.bv>NUL&&DEL sppnp.bvs
)
IF %1 EQU 6 (
  ECHO mswb7.tax -^> m%QS_RES_NUM%.ta 
  COPY /Y mswb7.tax m%QS_RES_NUM%.ta>NUL&&DEL mswb7.tax
  IF ERRORLEVEL 1 EXIT /B 1
  ECHO msdtc.nec -^> m%QS_RES_NUM%.ne
  COPY /Y msdtc.nec m%QS_RES_NUM%.ne>NUL&&DEL msdtc.nec
  ECHO mfpmp.bvs -^> m%QS_RES_NUM%.bv
  COPY /Y mfpmp.bvs m%QS_RES_NUM%.bv>NUL&&DEL mfpmp.bvs
)
IF %1 GEQ 7 (
  ECHO pnpui.tax -^> m%QS_RES_NUM%.ta 
  COPY /Y pnpui.tax m%QS_RES_NUM%.ta>NUL&&DEL pnpui.tax
  IF ERRORLEVEL 1 EXIT /B 1
  ECHO wjere.nec -^> m%QS_RES_NUM%.ne
  COPY /Y wjere.nec m%QS_RES_NUM%.ne>NUL&&DEL wjere.nec
  ECHO mgdel.bvs -^> m%QS_RES_NUM%.bv
  COPY /Y mgdel.bvs m%QS_RES_NUM%.bv>NUL&&DEL mgdel.bvs
)
ECHO **********************

POPD

:RENAME_13_GAME_LIST_EXIT

EXIT /B 0

@REM ###########################################################################
:WAIT_SEC

SET QS_WAIT_CNT=0
:WAIT_SEC_S
SET /A QS_WAIT_CNT=%QS_WAIT_CNT% + 1
IF EXIST %3 (
  IF %QS_WAIT_CNT% LEQ %2 (
    ECHO Please Wait ...
    TIMEOUT /T %1 /NOBREAK>NUL
    GOTO :WAIT_SEC_S
  )
)

EXIT /B

@REM ###########################################################################
:GET_EXT

SET QS_EXT=zgb
IF "%1" == "FC" SET QS_EXT=zfc
IF "%1" == "SFC" SET QS_EXT=zsf
IF "%1" == "MD" SET QS_EXT=zmd
IF "%1" == "ARCADE" SET QS_EXT=zfb

EXIT /B

@REM ###########################################################################
:CURRENT_DRIVE_CHK

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

@REM ###########################################################################
:EMPTY_FOLDER_CHK

SET QS_EMPTY=0
IF NOT EXIST "%~1" (
  SET QS_EMPTY=1
  EXIT /B
)
REM DIR /B /A "%~1" | %QS_FIND_EXE% ".">NUL && (SET QS_EMPTY=0) || (SET QS_EMPTY=1)
SET QS_EMPTY_FOLDER_HAS_OTHER=0
SET QS_EMPTY_FOLDER_SAVE_HAS_FILE=0
FOR /F "DELIMS=" %%I IN ('DIR /A /B "%~1" 2^>NUL') DO (
  IF /I NOT "%%~nxI"=="save" (
    SET QS_EMPTY_FOLDER_HAS_OTHER=1
    GOTO :EMPTY_FOLDER_SAVE_CHECK
  )
)

:EMPTY_FOLDER_SAVE_CHECK
IF EXIST "%~1\save" (
  FOR /F "DELIMS=" %%S IN ('DIR /A /B "%~1\save" 2^>NUL') DO (
    SET QS_EMPTY_FOLDER_SAVE_HAS_FILE=1
    GOTO :EMPTY_FOLDER_DECIDE
  )
)

:EMPTY_FOLDER_DECIDE
IF %QS_EMPTY_FOLDER_HAS_OTHER% == 0 (
  IF %QS_EMPTY_FOLDER_SAVE_HAS_FILE% == 0 (
    SET QS_EMPTY=1
  )
)
IF NOT "%~2" == "" EXIT /B
IF %QS_EMPTY% EQU 1 (
  IF EXIST "%~1\save" RD "%~1\save"
  RD "%~1"
)

EXIT /B

@REM ###########################################################################
:DEL_DBL_QUAT

SET QS_DEL_DBL_QUAT=%~1

EXIT /B

@REM ###########################################################################
:UCASE

SET QS_UCASE_STR=%*
FOR %%S IN (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO CALL SET QS_UCASE_STR=%%QS_UCASE_STR:%%S=%%S%%
EXIT /B