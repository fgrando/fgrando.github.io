# Useful batch scripts
05/Mar/2023

Useful batch snippets


### Get the script start directory:
```batch
ECHO Current Directory = %~dp0
ECHO Object Name With Quotations=%0
ECHO Object Name Without Quotes=%~0
ECHO Bat File Drive = %~d0
ECHO Full File Name = %~n0%~x0
ECHO File Name Without Extension = %~n0
ECHO File Extension = %~x0

```



### Python temporary env
```batch

SET PYENV="%~dp0\tempy"
SET PYTMP"%~dp0\tempy\Scripts\python"
SET PIPTMP"%~dp0\tempy\Scripts\pip"

python -m venv %PYENV%
%PIPTMP% freeze

%PYTMP% -V
```

### Usual labels for GOTO
```batch
SET STARTDIR="%~dp0"
SET ARG1=%1
SET ARG2=%2

IF "%FOLDER%" == "" (
    ECHO Missing argument.
)

CALL somescript.bat
IF NOT "%ERRORLEVEL%" == "0" (
    ECHO Failed to run command
    GOTO FAIL
)

GOTO END

:END
ECHO Done!
EXIT /B0

:SHOW_USAGE_AND_FAIL
ECHO Usage: %0 <argmument>
GOTO FAIL

:FAIL
ECHO FAILED!
EXIT /B 1

```


### Kill a task
```batch
FOR /F "TOKENS=1,2,* delims==, " %%a IN ('TASKLIST /FI "WindowTitle -eq %NAME% /NH /FO CSV') DO (
    SET PID_FOUND=%%b
    ECHO Kill %NAME% %%b
    TASKKILL /PID %%b /F
)
```


### Check if a file exists:
```batch
IF EXIST %filepath% (
    ECHO exists!
) ELSE (
    ECHO not found!
)

IF NOT EXIST %filepath% (
    ECHO not found!
)

IF NOT EXIST "C:\Program Files\7-Zip\7z" (
    WHERE 7z
    IF "%ERRORLEVEL%" == "1" (
        ECHO 7zip not found!
    )
)
```



### List all files in a directory:
```batch
FOR /F tokens^=* %%i IN ('where .:*')DO (
	ECHO/ Path: %%~dpi ^| Name: %%~nxi
)

FOR /F tokens^=* %%i IN ('where /r %FOLDER% *.txt')DO (
	ECHO/ Path: %%~dpi ^| Name: %%~nxi
)
```



### Checked mounted drives with subst:
```batch
FOR /F "delims=\" %%i IN ('SUBST')DO (
    IF "%%i" == "X:" (
        ECHO Drive X is already mounted
    )
)

FOR /f tokens^=* %%i in ('where /r %FOLDER% *.txt')DO (
	ECHO/ Path: %%~dpi ^| Name: %%~nxi
)
```

### Mount first available folder:
```batch
@echo off
setlocal EnableDelayedExpansion
REM ============================================================
REM  mapdrive.bat
REM  Mounts a folder to the first available drive using SUBST.
REM
REM  Usage:
REM     mapdrive.bat <folder> <drive1> [drive2] [drive3] ...
REM
REM  Example:
REM     mapdrive.bat "C:\Users\Fernando\projects" X Y Z
REM
REM  Machine-parseable contract:
REM     stdout : on success, the chosen drive letter ONLY, e.g.  X:
REM     stderr : all human-readable messages and errors
REM     exit   : 0 mounted OK
REM              1 folder does not exist
REM              2 folder is already mounted to a drive
REM              3 none of the informed drive letters is available
REM ============================================================
if "%~1"=="" (
    echo Usage: %~nx0 ^<folder^> ^<drive1^> [drive2] ... 1>&2
    endlocal & exit /b 1
)
REM Canonicalize the requested folder to a full path (no trailing slash)
set "FOLDER=%~f1"
REM --- (1) Folder must exist as a directory --------------------
if not exist "%FOLDER%\" (
    echo ERROR: folder "%FOLDER%" does not exist. 1>&2
    endlocal & exit /b 1
)
REM --- (2) Is this folder already mounted via SUBST? -----------
REM SUBST output line format:  Z:\: => C:\path\to\folder
for /f "tokens=1* delims==" %%a in ('subst') do (
    set "rest=%%b"
    REM strip the leading "> " (2 chars) that follows the '=' of '=>'
    set "tgt=!rest:~2!"
    if /i "!tgt!"=="%FOLDER%" (
        echo ERROR: folder is already mounted on %%a 1>&2
        endlocal & exit /b 2
    )
)
REM --- (3) Find the first available drive from the list --------
shift
set "MOUNTED="
:findloop
if "%~1"=="" goto nodrive
set "arg=%~1"
REM normalize "X" or "X:" -> "X:"
set "drv=!arg:~0,1!:"
REM Letter already in use (real, network or subst) -> skip it
if exist "!drv!\" (
    shift
    goto findloop
)
REM Letter looks free -> try to mount
subst !drv! "%FOLDER%" 2>nul
if not errorlevel 1 (
    set "MOUNTED=!drv!"
    goto done
)
REM subst failed even though the letter looked free -> try next
shift
goto findloop
:nodrive
echo ERROR: none of the informed drive letters is available. 1>&2
endlocal & exit /b 3
:done
REM Human-readable line -> stderr ; machine-readable drive -> stdout
echo Mounted "%FOLDER%" on !MOUNTED! 1>&2
REM %MOUNTED% is expanded at PARSE time (before endlocal runs), so its
REM value survives the endlocal on this same line. Do NOT use !MOUNTED! here.
endlocal & echo %MOUNTED% & exit /b 0
```

Using mapdrive.bat
```batch
@echo off
setlocal EnableDelayedExpansion
REM ============================================================
REM  caller.bat - example of consuming mapdrive.bat
REM
REM  Contract relied upon:
REM     stdout = chosen drive letter only (e.g. X:)
REM     stderr = human messages (passed through to console)
REM     exit   = 0 ok / 1 no folder / 2 already mounted / 3 no drive
REM ============================================================

set "TARGET=C:\Users\fgrando\Downloads\general_c_cpp"
set "OUT=%TEMP%\mf.out"

REM Run child. Redirect only stdout to the temp file; stderr stays
REM on the console. Capture the exit code on the VERY NEXT line,
REM before any other command can overwrite errorlevel.
call mapdrive.bat "%TARGET%" X Y Z > "%OUT%"
set "RC=%errorlevel%"

REM Read the single line of stdout (the drive) back out.
set "CHOSEN="
if exist "%OUT%" (
    set /p CHOSEN=<"%OUT%"
    del "%OUT%" 2>nul
)

if "%RC%"=="0" (
    echo SUCCESS: folder is on drive !CHOSEN!
    REM Use !CHOSEN! from here, e.g.:  dir !CHOSEN!\
) else if "%RC%"=="1" (
    echo FAIL: folder does not exist.
) else if "%RC%"=="2" (
    echo FAIL: already mounted.
) else if "%RC%"=="3" (
    echo FAIL: no drive letter available.
) else (
    echo FAIL: unexpected code %RC%.
)

endlocal & exit /b %RC%
```

