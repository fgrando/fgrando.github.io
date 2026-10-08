# cygwin notes
08/Oct/2026

# Stuck cygwin processes

```bat
:: 1. See what is holding cygwin1.dll
tasklist /m cygwin1.dll

:: 2. Stop Cygwin services, if any are installed
net stop cygserver 2>nul
net stop sshd 2>nul

:: 3. Kill everything using the DLL, including child trees
taskkill /f /t /fi "MODULES eq cygwin1.dll"

:: 4. Confirm nothing is left
tasklist /m cygwin1.dll
```

# SVN vs TortoiseSVN

To prevent mixing both, makefile can define
```bat
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c
SVN := '/cygdrive/c/Program Files/TortoiseSVN/bin/svn.exe'

info:
	$(SVN) info . | tee log.txt

```

# file search
```bat
dir /s /b "C:\folder\this-file-name.txt"
where /r C:\folder this-file-name.txt
```
- dir /s /b searches all subfolders and prints the full path of each match.
- where /r does the same and is easier to use in if checks. Add /q for no output, just the exit code.

Both dir and where set ERRORLEVEL to 1 when nothing is found, so ... >nul 2>&1 && echo found works.


# SVN

```bat
@echo off
rem ===========================================================================
rem  svn_example.bat - unattended SVN usage with TortoiseSVN command-line tools
rem
rem  Requires: TortoiseSVN installed with "command line client tools" selected
rem            (installer option, not enabled by default). Use svn.exe only;
rem            TortoiseProc.exe is the GUI and is not meant for scripts.
rem  Safe for unattended use (Jenkins): never prompts, never pauses.
rem
rem  Exit codes: 0 = OK, 1 = svn error, 2 = setup error,
rem              3 = conflicts after update, 4 = local modifications present
rem ===========================================================================
setlocal EnableExtensions

rem ---- Configuration --------------------------------------------------------
set "SVN_BIN=C:\Program Files\TortoiseSVN\bin"
set "REPO_URL=https://svn.example.local/repos/project/trunk"
set "WC=C:\work\project"
set "LOG_DIR=%~dp0logs"
rem 1 = revert local changes and delete unversioned/ignored files before update
set "CLEAN_WC=0"

rem Put TortoiseSVN first in PATH so a Cygwin svn is never picked up by mistake.
set "PATH=%SVN_BIN%;%PATH%"

rem Options for every command (all are global options, accepted by any subcommand):
rem   --non-interactive  never prompt; fail instead of waiting for input
rem   --no-auth-cache    do not store credentials in %%APPDATA%%\Subversion\auth
rem   http-timeout       give up after N seconds instead of hanging on a dead link
set "SVN_OPTS=--non-interactive --no-auth-cache --config-option servers:global:http-timeout=120"

rem Optional (svn 1.9+): accept specific TLS certificate problems.
rem Only for an internal CA you trust. Requires --non-interactive.
rem   Values: unknown-ca, cn-mismatch, expired, not-yet-valid, other
set "SVN_OPTS=%SVN_OPTS% --trust-server-cert-failures=unknown-ca"

rem Optional: isolated config directory, so per-user settings on the build
rem machine cannot change the build behaviour.
set "SVN_OPTS=%SVN_OPTS% --config-dir "%~dp0svn-config""

rem Optional: credentials from environment variables (e.g. Jenkins withCredentials).
rem Warning: command-line arguments are visible in Task Manager / Process Explorer.
rem set "SVN_OPTS=%SVN_OPTS% --username "%SVN_USER%" --password "%SVN_PASS%""

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

rem ---- 1. Tool check --------------------------------------------------------
if not exist "%SVN_BIN%\svn.exe" (
    echo ERROR: svn.exe not found in "%SVN_BIN%".
    echo        Reinstall TortoiseSVN with "command line client tools" enabled.
    exit /b 2
)
echo svn executables found on PATH ^(first one is used^):
where svn
echo svn version:
svn --version --quiet

echo SVN steps completed OK.
endlocal & exit /b 0

:svn_error
set "RC=%ERRORLEVEL%"
echo ERROR: svn command failed with exit code %RC%.
echo        If the working copy is locked, run: svn cleanup "%WC%"
endlocal & exit /b 1
```

# tee replacement
```bat
@echo off
rem make_with_log.bat - two ways to run make with live output AND a log file
rem   1. GNU tee from Cygwin (needs Cygwin)
rem   2. Pure Windows: built-in PowerShell, no admin rights, no Cygwin
rem Both log stdout + stderr and keep make's exit code (pipefail behaviour).
setlocal

set "CYG_BIN=C:\cygwin64\bin"

rem ---- 1. Cygwin tee --------------------------------------------------------
rem tee is called as /usr/bin/tee, so it works even if Cygwin's bin folder
rem is not on PATH; make is found the same way as in your original command.
"%CYG_BIN%\bash.exe" -c "set -o pipefail && make all 2>&1 | /usr/bin/tee out_tee.log"
set "RC_TEE=%ERRORLEVEL%"

rem ---- 2. PowerShell (pure Windows) -------------------------------------------
call :tee_run out_ps.log make all
set "RC_PS=%ERRORLEVEL%"

echo.
echo Cygwin tee : exit code %RC_TEE%, log out_tee.log
echo PowerShell : exit code %RC_PS%, log out_ps.log
exit /b %RC_PS%


rem ===========================================================================
rem  :tee_run <logfile> <command ...>
rem  Runs the command, prints its output live and writes it to <logfile> (ANSI,
rem  overwritten each run). Returns the command's exit code.
rem ===========================================================================
:tee_run
setlocal
set "TEE_LOG=%~f1"
rem Command = all arguments after the first one.
set "TEE_CMD=%*"
call set "TEE_CMD=%%TEE_CMD:*%1=%%"
if exist "%TEE_LOG%" del "%TEE_LOG%"
powershell -NoProfile -NonInteractive -Command "cmd /c ($env:TEE_CMD + ' 2>&1') | ForEach-Object { $_; Add-Content -LiteralPath $env:TEE_LOG -Value $_ -Encoding Default }; exit $LASTEXITCODE"
endlocal & exit /b %ERRORLEVEL%
```