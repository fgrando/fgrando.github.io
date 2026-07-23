# Jenkins Utilities
22/Jul/2026

## Shared Library
- Retrieval method: `Legacy SCM`
- Repository URL: `svn://192.168.1.228/myproject/jenkins-shared-library@${library.homelib.version}`

![shared-lib-config](jenkins-shared-lib-config.png)

- Include the library in Jenkinsfile like:

        @Library('homelib@25') _
           or 
        @Library(value='homelib@25', changelog=false) _


### Mount a folder to first drive available

- Maps `folderPath` to the first free letter from `driveLetters` using `subst`, on a Windows agent.
- Order of checks: path exists -> not already mounted -> compute free letters from `fsutil fsinfo drives` -> mount first free candidate.
- Returns the mounted drive letter (e.g. `E:`) or calls `error()` with the reason (`invalid path`, `already mounted`, `no drive available`).

```groovy
def mountFirstAvailableDrive(String folderPath, List<String> driveLetters) {
    if (!fileExists(folderPath)) {
        error "Invalid path: '${folderPath}' does not exist"
    }

    def substOutput = bat(script: '@subst', returnStdout: true).trim()
    def existingMapping = substOutput.readLines().find {
        it.toLowerCase().contains(folderPath.toLowerCase())
    }
    if (existingMapping) {
        error "Folder '${folderPath}' is already mounted: ${existingMapping}"
    }

    def fsInfo = bat(script: '@fsutil fsinfo drives', returnStdout: true).trim()
    def usedDrives = (fsInfo =~ /([A-Za-z]):\\/).collect { it[1].toUpperCase() }

    def candidates = driveLetters.collect { it.replace(':', '').trim().toUpperCase() } - usedDrives
    if (candidates.isEmpty()) {
        error "No drive available from ${driveLetters}: all candidates are in use"
    }

    for (letter in candidates) {
        def script = """@echo off
if exist ${letter}:\\ (
    echo USED
) else (
    subst ${letter}: "${folderPath}"
    echo MOUNTED
)"""
        def result = bat(script: script, returnStdout: true).trim()
        if (result.endsWith('MOUNTED')) {
            return "${letter}:"
        }
    }

    error "No drive available from ${driveLetters}: all candidates were taken by the time of mounting"
}
```

### Unmount a folder

- Receives a `driveLetter` (e.g. `E:` or `E`), checks it is really mounted via `subst`, then removes it with `subst /D`.
- If `driveLetter` is omitted/blank, falls back to `env.WORK_DRIVE` — and in that case the token check is **mandatory**, checked against `env.BUILD_URL`, since relying on ambient env state instead of an explicit argument deserves the stricter check. There's no separate `env.MOUNT_TOKEN` to track — the token is always just `env.BUILD_URL`, both when it's written by `mountFirstAvailableDrive` and when it's checked here.
- When an explicit `driveLetter` is passed instead, no token check runs at all — the caller might legitimately be unmounting a drive that wasn't mounted through this token-writing flow at all, so there'd be nothing to compare against.
- Logs and does nothing if the letter is not currently mounted, instead of failing the build.
- A mismatch means something else forcibly removed and remounted (or swapped) that letter in between, so it refuses to blindly `/D` it and fails loudly instead; because the token is a build URL, not a random value, whatever's actually sitting in the file directly identifies the other build that now owns that letter.
- Clears `env.WORK_DRIVE` after a successful unmount — otherwise it lingers as pipeline-global env for the rest of the build and would trip `mount_drive.bat`'s own `if defined WORK_DRIVE` guard on any later mount attempt, even though nothing is actually still mounted.

```groovy
def unmountDrive(String driveLetter = '') {
    def usingWorkDrive = (!driveLetter?.trim()) || ("${driveLetter.trim()}" == env.WORK_DRIVE)
    def letter = (usingWorkDrive ? env.WORK_DRIVE : driveLetter)?.trim()?.toUpperCase()
    if (!letter) {
        error "unmountDrive: no drive letter given and env.WORK_DRIVE is not set"
    }

    def substOutput = bat(script: '@subst', returnStdout: true).trim()
    def existingMapping = substOutput.readLines().find {
        it.toUpperCase().startsWith("${letter}\\")
    }
    if (!existingMapping) {
        echo "Drive '${letter}' is not mounted."
        return
    }

    if (usingWorkDrive) {
        def tokenOnDisk = bat(
            script: "@type \"${letter}\\.jenkins_mount_token\" 2>nul",
            returnStdout: true
        ).trim()
        if (tokenOnDisk != env.BUILD_URL) {
            error "unmountDrive: refusing to unmount ${letter}: - token mismatch (expected '${env.BUILD_URL}', found '${tokenOnDisk}')"
        }
        bat "@del /f /q \"${letter}:\\.jenkins_mount_token\""
    }

    bat "@subst ${letter} /D"
    env.WORK_DRIVE = null
}
```

### Export from svn

- Runs the real `svn export` CLI (no `.svn` metadata, always a clean overwrite), exposing only `url`, `revision` and `localPath`.
- Prepends the known Cygwin `bin` folder to `PATH` via `withEnv` so the same known-good `svn.exe` is always the one resolved, regardless of what else is on the node's `PATH`.
- Validates `url`, `revision` and `localPath` before building the command line, so untrusted values can't break out of the intended arguments.
- Usage: `svnCheckout('http://repo.url/app.exe', '1234', 'some/relative/path/app.exe')`

```groovy
def svnCheckout(String url, String revision, String localPath) {
    def cygwinBin = 'C:\\cygwin64\\bin'

    if (!(revision ==~ /^(HEAD|[0-9]+)$/)) {
        error "Invalid revision: '${revision}'"
    }
    if (!(url ==~ /^(https?|svn|svn\+ssh):\/\/[\w\-.\/:@%]+$/)) {
        error "Invalid svn url: '${url}'"
    }
    if (!(localPath ==~ /^[\w\-.\/\\: ]+$/)) {
        error "Invalid local path: '${localPath}'"
    }

    withEnv(["PATH+CYGWIN=${cygwinBin}"]) {
        bat "svn export --force -r ${revision} \"${url}\" \"${localPath}\""
    }
}
```


### WithEnv

- Runs `setupScript` once in a throwaway `bat` call, dumps the resulting environment with `set`, and re-applies every `KEY=VALUE` pair via `withEnv` around `body`.
- Because `withEnv` re-injects its vars into every `bat` step it wraps, all calls inside `body` (e.g. `svn_export.bat`, `build.bat`) see the same environment the setup script produced, without re-running it each time.
- Usage:

```groovy
withSetupEnv('C:\\tools\\set_env_default.bat') {
    bat 'svn_export.bat "http://repo.url/app.exe" 1234 "some\\path\\app.exe"'
    bat 'build.bat'
}
```

```groovy
def withSetupEnv(String setupScript, Closure body) {
    def script = """@echo off
call "${setupScript}"
set"""
    def output = bat(script: script, returnStdout: true).trim()

    def envVars = output.readLines().findAll { it ==~ /^[A-Za-z_][A-Za-z0-9_]*=.*/ }

    withEnv(envVars) {
        body()
    }
}
```

### Setup env once (global for the whole pipeline)

- Runs `setupScript` a single time and writes each resulting `KEY=VALUE` straight into the pipeline's global `env` object, instead of scoping them to a closure.
- Vars set on `env` persist for the rest of the build and are injected into every later `bat`/`sh` step automatically, so callers don't need to wrap anything — call this once near the top of the Jenkinsfile.
- Guards against re-running the setup script if called more than once, via the `SETUP_ENV_DONE` sentinel.
- Usage:

```groovy
setupEnvOnce('C:\\tools\\set_env_default.bat')

bat 'svn_export.bat "http://repo.url/app.exe" 1234 "some\\path\\app.exe"'
bat 'build.bat'
```

```groovy
def setupEnvOnce(String setupScript) {
    if (env.SETUP_ENV_DONE == 'true') {
        return
    }

    def script = """@echo off
call "${setupScript}"
set"""
    def output = bat(script: script, returnStdout: true).trim()

    output.readLines().findAll { it ==~ /^[A-Za-z_][A-Za-z0-9_]*=.*/ }.each { line ->
        def (key, value) = line.split('=', 2)
        env."${key}" = value
    }

    env.SETUP_ENV_DONE = 'true'
}
```

- Minimum pipeline showing the vars set in the first stage are still there in the second:

```groovy
pipeline {
    agent any

    stages {
        stage('Setup') {
            steps {
                script {
                    setupEnvOnce('C:\\tools\\set_env_default.bat')
                }
            }
        }

        stage('Show env') {
            steps {
                bat 'set'
            }
        }
    }
}
```

## Replacement bat files

### mount_drive.bat

```bat
@echo off

if defined WORK_DRIVE ( goto :ALREADY_SET )

set "FOLDER=%~f1"
if "%FOLDER%"=="" set "FOLDER=%CD%"
if not exist "%FOLDER%\" ( goto :NOT_EXIST )

set "DRIVES=%2"
if "%DRIVES%"=="" set "DRIVES=F G H I J"

subst | findstr /I /E /C:"%FOLDER%" > nul
if %ERRORLEVEL% EQU 0 ( goto :ALREADY_MOUNTED )

for %%A in (%DRIVES%) do (
    if not exist %%A: (
        subst %%A: "%FOLDER%" > nul 2>&1
        REM check to see if we actually won the drive letter since other process could have taken it in the meantime
        subst | findstr /I /X /C:"%%A:\: => %FOLDER%" > nul
        if not errorlevel 1 (
            set "WORK_DRIVE=%%A:"
            goto :SUCCESS
        )
	)
)
goto :NOT_AVAILABLE

REM the output messages may be parsed so they must have a consistent format to make it easier
:SUCCESS
echo [%~n0] OK: %WORK_DRIVE% points to "%FOLDER%". && exit /b 0
:ALREADY_SET
echo [%~n0] ERROR: WORK_DRIVE set to %WORK_DRIVE%. Unmount first! && exit /b 1
:NOT_EXIST
echo [%~n0] ERROR: '%FOLDER%' does not exist. && exit /b 2
:ALREADY_MOUNTED
echo [%~n0] ERROR: '%FOLDER%' already mounted. && exit /b 3
:NOT_AVAILABLE
echo [%~n0] ERROR: '%DRIVES%' not available. && exit /b 4


```

### Jenkins wrapper for mount_drive.bat

- Thin wrapper: validates `folderPath` and `driveLetters` in Groovy, then delegates the actual check/parse/subst logic to `mount_drive.bat`.
- `driveLetters` is a plain space-separated string of bare letters, e.g. `"A B C D"` — the `:` needed by `mount_drive.bat`'s own `exist`/`subst` checks is appended once, right when building the argument string.
- Chains `&& set WORK_DRIVE` onto the same `bat` invocation instead of parsing any of `mount_drive.bat`'s own echoed text — `set WORK_DRIVE` prints exactly one `WORK_DRIVE=<letter>:` line when the mount succeeded, so there's no custom marker/prefix to parse. A second, separate `bat` call couldn't do this instead: each `bat` step is a fresh `cmd.exe`, so a variable set by `mount_drive.bat` wouldn't survive into a later step.
- Uses plain `returnStdout: true` — no `returnStatus`, no manual exit-code check. If `mount_drive.bat` fails, `&&` skips `set WORK_DRIVE`, the compound command's exit code stays non-zero, and Jenkins aborts the step (and build) on its own; there's nothing to recover from, so there's no reason to intercept that. `mount_drive.bat`'s own `ERROR: ...` line is still visible in the Jenkins console log regardless, since step output streams live independent of `returnStdout`.

```groovy
def mountFirstAvailableDrive(String folderPath, String driveLetters) {
    if (!(folderPath ==~ /^[\w\-.\/\\: ]+$/)) {
        error "Invalid path: '${folderPath}'"
    }
    if (!(driveLetters.trim() ==~ /^[A-Za-z](\s+[A-Za-z])*$/)) {
        error "Invalid drive letters: '${driveLetters}' (expected e.g. 'A B C D')"
    }

    def drivesArg = driveLetters.trim().split(/\s+/).collect { "${it.toUpperCase()}:" }.join(' ')

    def output = bat(
        script: "@call \"C:\\tools\\mount_drive.bat\" \"${folderPath}\" \"${drivesArg}\" && set WORK_DRIVE",
        returnStdout: true
    ).trim()

    def drive = output.readLines().find { it.startsWith('WORK_DRIVE=') }?.substring('WORK_DRIVE='.length())
    if (!drive) {
        error "mountFirstAvailableDrive: could not read WORK_DRIVE from output: ${output}"
    }

    def token = env.BUILD_URL
    bat "@echo ${token}> \"${folderPath}\\.jenkins_mount_token\""

    env.WORK_DRIVE = drive
    return drive
}
```

