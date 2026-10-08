@echo off
rem ===========================================================================
rem  svn_prime.bat - unattended credential priming for Jenkins.
rem
rem  Caches SVN credentials for native svn (TortoiseSVN command line tools)
rem  and for Cygwin svn, so later steps can call svn without --password.
rem
rem  Usage (Jenkinsfile):
rem    withCredentials([usernamePassword(credentialsId: 'svn-creds',
rem                       usernameVariable: 'SVN_USER',
rem                       passwordVariable: 'SVN_PASS')]) {
rem        bat 'svn_prime.bat https://svn.example.com/repo'
rem    }
rem    bat 'svn update --non-interactive C:\\work\\project'   // no password
rem
rem  Arguments: [REPO_URL]  (default below, or REPO_URL environment variable)
rem  Exit codes: 0 = OK, 1 = native svn failed, 2 = Cygwin svn failed,
rem              3 = setup error
rem
rem  Notes:
rem  - The cache is per Windows user. Every later step must run as the same
rem    account as this one (same agent, same service user).
rem  - Native svn stores the password DPAPI-encrypted in %APPDATA%\Subversion.
rem  - Cygwin svn has no encrypted store without a keyring, so the password
rem    is saved in PLAIN TEXT under <cygwin home>\.subversion\auth.
rem  - The password is passed on the command line (visible in the process
rem    list while svn runs) and must not contain a double quote.
rem ===========================================================================
setlocal EnableExtensions

rem ---- Configuration --------------------------------------------------------
if not defined REPO_URL set "REPO_URL=https://svn.example.com/repo"
if not "%~1"=="" set "REPO_URL=%~1"
if not defined SVN_EXE set "SVN_EXE=svn"
if not defined CYG_BIN set "CYG_BIN=C:\cygwin64\bin"
set "CYG_SVN=%CYG_BIN%\svn.exe"

rem Uncomment to accept an internal CA without the interactive "p" prompt.
rem Later --non-interactive svn calls need the same option: it is not cached.
set "TRUST_OPT=--trust-server-cert-failures=unknown-ca"

if not defined SVN_USER (
    echo ERROR: SVN_USER is not set. Call this script inside withCredentials.
    exit /b 3
)
if not defined SVN_PASS (
    echo ERROR: SVN_PASS is not set. Call this script inside withCredentials.
    exit /b 3
)
echo Repository: %REPO_URL%
echo SVN user:   %SVN_USER%
echo Windows user: %USERNAME%

rem ---- 1. Native svn --------------------------------------------------------
echo.
echo ===== 1/2 native svn =====
where "%SVN_EXE%" >nul 2>&1 || if not exist "%SVN_EXE%" (
    echo ERROR: "%SVN_EXE%" not found. Install TortoiseSVN with command line tools.
    exit /b 3
)

rem Already cached? Then nothing to do.
"%SVN_EXE%" info --non-interactive %TRUST_OPT% "%REPO_URL%" >nul 2>&1 && (
    echo OK: credentials already cached.
    goto :cygwin
)

rem Log in once with the Jenkins credentials and let svn cache them.
"%SVN_EXE%" info --non-interactive %TRUST_OPT% ^
    --username "%SVN_USER%" --password "%SVN_PASS%" ^
    --config-option servers:global:store-passwords=yes ^
    "%REPO_URL%" >nul || goto :svn_error

rem Verify: the same request must now work without credentials.
"%SVN_EXE%" info --non-interactive %TRUST_OPT% "%REPO_URL%" >nul 2>&1 || goto :svn_error
echo OK: credentials cached in %APPDATA%\Subversion\auth

rem ---- 2. Cygwin svn --------------------------------------------------------
:cygwin
echo.
echo ===== 2/2 Cygwin svn =====
if not exist "%CYG_SVN%" (
    echo SKIPPED: "%CYG_SVN%" not found.
    goto :done
)

rem Cygwin svn writes to ~/.subversion. A service account such as SYSTEM
rem usually has no Cygwin home yet, and plain bash -c does not create it.
"%CYG_BIN%\bash.exe" -c "/usr/bin/mkdir -p ~" || goto :svn_error_cygwin
set "CYG_HOME="
for /f "delims=" %%H in ('call "%CYG_BIN%\bash.exe" -c "/usr/bin/cygpath -w ~"') do set "CYG_HOME=%%H"
echo Cygwin home: %CYG_HOME%

"%CYG_SVN%" info --non-interactive %TRUST_OPT% "%REPO_URL%" >nul 2>&1 && (
    echo OK: credentials already cached.
    goto :done
)

rem store-plaintext-passwords must be yes: with "no" Cygwin svn caches only
rem the username, and later --non-interactive calls fail authentication.
"%CYG_SVN%" info --non-interactive %TRUST_OPT% ^
    --username "%SVN_USER%" --password "%SVN_PASS%" ^
    --config-option servers:global:store-passwords=yes ^
    "%REPO_URL%" >nul || goto :svn_error_cygwin
rem --config-option servers:global:store-plaintext-passwords=yes ^

"%CYG_SVN%" info --non-interactive %TRUST_OPT% "%REPO_URL%" >nul 2>&1 || (
    echo ERROR: login worked but the password was not cached. This Cygwin svn
    echo        build may have plain-text password storage compiled out.
    endlocal & exit /b 2
)
echo OK: credentials cached in %CYG_HOME%\.subversion\auth

rem ---- Done -------------------------------------------------------------------
:done
echo.
echo All available svn clients are primed.
endlocal & exit /b 0

:svn_error
echo ERROR: native svn could not log in to %REPO_URL% ^(wrong credentials,
echo        untrusted server certificate, or server unreachable^).
endlocal & exit /b 1

:svn_error_cygwin
echo ERROR: Cygwin svn could not log in to %REPO_URL% ^(wrong credentials,
echo        untrusted server certificate, or Cygwin stuck^).
endlocal & exit /b 2
