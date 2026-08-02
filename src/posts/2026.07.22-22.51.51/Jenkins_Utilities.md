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

## Node setup
The node work dir is C:\jenkins
Download [/winswhttps://github.com/winsw](https://github.com/winsw/winsw/releases/) to C:\jenkins and rename to jenkins-agent.exe
Create an xml with the service config
```
<service>
  <id>jenkins-agent</id>
  <name>Jenkins Agent (windao)</name>
  <description>Jenkins inbound agent</description>
  <executable>C:\Program Files\Eclipse Adoptium\jdk-17.0.x-hotspot\bin\java.exe</executable>
  <arguments>-jar "C:\jenkins\agent.jar" -url http://192.168.1.227:8080/ -secret @C:\jenkins\secret-file -name windao -webSocket -workDir "C:\jenkins"</arguments>
  <workingdirectory>C:\jenkins</workingdirectory>
  <logmode>rotate</logmode>
  <onfailure action="restart" delay="10 sec"/>
</service>
```
cd C:\jenkins
jenkins-agent.exe install
jenkins-agent.exe start

Adjust the user it is running as:
Open services.msc → Jenkins Agent → Log On tab → set it to run as your tool account. Otherwise builds fail with missing-tool or license errors.


### Export from svn

- Runs the real `svn export` CLI (no `.svn` metadata, always a clean overwrite), exposing only `url`, `revision` and `localPath`.
- Prepends the known Cygwin `bin` folder to `PATH` via `withEnv` so the same known-good `svn.exe` is always the one resolved, regardless of what else is on the node's `PATH`.
- Validates `url`, `revision` and `localPath` before building the command line, so untrusted values can't break out of the intended arguments.
- Usage: `svnCheckout('http://repo.url/app.exe', '1234', 'some/relative/path/app.exe')`

```groovy
def svnCheckout(String url, String revision, String localPath) {
    def cygwinBins = 'C:\\cygwin64\\bin'

    if (!(revision ==~ /^(HEAD|[0-9]+)$/)) {
        error "Invalid revision: '${revision}'"
    }
    if (!(url ==~ /^(https?|svn|svn\+ssh):\/\/[\w\-.\/:@%]+$/)) {
        error "Invalid svn url: '${url}'"
    }
    if (!(localPath ==~ /^[\w\-.\/\\: ]+$/)) {
        error "Invalid local path: '${localPath}'"
    }

    withEnv(["PATH+CYGWIN=${cygwinBins}"]) {
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
// Runs a .bat script (by path, relative to the workspace) and promotes any
// environment variables it sets or changes into the Jenkins `env` object, so
// later stages/steps - which each run in their own fresh cmd.exe process -
// can see them (e.g. MOUNT_DRIVE set by mount.bat, read by unmount.bat).
//
// How it works: captures `set` output before and after running the script in
// the same cmd.exe session, then diffs the two snapshots. Vars that are new
// or changed get set on `env`; vars that disappeared (e.g. unmount.bat
// clearing MOUNT_DRIVE) get unset via `env.KEY = null`. Vars present in
// `blacklist` are never propagated (noisy or dangerous to override, e.g.
// TEMP/COMSPEC). The script's own stdout is redirected to stderr so it
// doesn't get mixed into the captured `set` output that gets diffed/parsed.
//
// Fails the step (throws) if batScriptPath exits with a non-zero code, so a
// real mount/unmount failure fails the build instead of being swallowed.
def batSetEnv(String batScriptPath) {
    def prefix = "batSetEnv"
    def before = bat(label: "[${prefix}] save current env.",
                    script: '@set',
                    returnStdout: true).trim()

    // "call" is required so a called script's own `exit /b` returns control
    // here rather than ending the whole session. ".\" is required because
    // this agent has NoDefaultCurrentDirectoryInExePath set, so a bare
    // script name is not found even though it's in the current directory.
    def after = bat(label: "[${prefix}] run script ${batScriptPath}",
                    script: """
                    @echo off
                    call ${batScriptPath} 1>&2 && set""",
                    returnStdout: true
                    ).trim()

    def parseVars = { String output ->
        output.readLines().collectEntries { line ->
            def idx = line.indexOf('=')
            idx > 0 ? [(line.substring(0, idx)): line.substring(idx + 1)] : [:]
        }
    }
    def blacklist = ['SystemRoot', 'COMSPEC', 'WINDIR', 'TEMP', 
                     'TMP', 'HUDSON_COOKIE',]
    def beforeVars = parseVars(before)
    def afterVars = parseVars(after)

    afterVars.each { key, value ->
        if (beforeVars[key] != value) {
            if (!blacklist.contains(key)) {
                echo "[$prefix] set ${key}=${value}"
                env."${key}" = value
            }
        }
    }

    beforeVars.each { key, value ->
        if (!afterVars.containsKey(key)) {
            if (!blacklist.contains(key)) {
                echo "[$prefix] unset ${key}"
                env."${key}" = null
            }
        }
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


## Replacement bat files

### mount.bat
```bat
@echo off
rem Usage: mount.bat ["path to mount"] ["comma,separated,drive,letters"]
rem   path defaults to the current directory
rem   drive letters default to F,G,H
rem Sets MOUNT_DRIVE (e.g. "F:") to the drive that ends up mounted so that
rem unmount.bat, run later in the same cmd session, knows what to unmount.

if defined MOUNT_DRIVE (
    echo mount.bat: MOUNT_DRIVE already set to "%MOUNT_DRIVE%", skipping mount.
    exit /b 0
)

setlocal EnableExtensions EnableDelayedExpansion

set "MOUNT_PATH=%~1"
if not defined MOUNT_PATH set "MOUNT_PATH=%CD%"
if "%MOUNT_PATH:~-1%"=="\" set "MOUNT_PATH=%MOUNT_PATH:~0,-1%"

set "MOUNT_DRIVES=%~2"
if not defined MOUNT_DRIVES set "MOUNT_DRIVES=F,G,H"

rem bail out if MOUNT_PATH is already mounted to some drive
set "FOUND_DRIVE="
for /f "delims=" %%L in ('subst') do (
    set "line=%%L"
    set "target=!line:~8!"
    if /i "!target!"=="!MOUNT_PATH!" set "FOUND_DRIVE=!line:~0,2!"
)

if defined FOUND_DRIVE (
    echo mount.bat: "%MOUNT_PATH%" is already mounted as %FOUND_DRIVE%
REM It it is already mounted, but MOUNT_DRIVE not set, something wrong happen.
REM    endlocal & set "MOUNT_DRIVE=%FOUND_DRIVE%"
    endlocal
    exit /b 0
)

for %%D in (%MOUNT_DRIVES%) do (
    if not defined MOUNT_DRIVE (
        if not exist %%D:\ (
            subst %%D: "%MOUNT_PATH%"
            if not errorlevel 1 set "MOUNT_DRIVE=%%D:"
        )
    )
)

if not defined MOUNT_DRIVE (
    echo mount.bat: no available drive letter in "%MOUNT_DRIVES%" >&2
    exit /b 1
)

echo mount.bat: mounted "%MOUNT_PATH%" as %MOUNT_DRIVE%
endlocal & set "MOUNT_DRIVE=%MOUNT_DRIVE%"
exit /b 0

```

### unmount.bat
```bat
@echo off
rem Usage: unmount.bat ["drive letter"]
rem   drive defaults to MOUNT_DRIVE
rem Clears MOUNT_DRIVE (when it matches the drive being unmounted) so a
rem later mount.bat run in the same cmd session knows it needs to mount again.

setlocal EnableExtensions EnableDelayedExpansion

set "UNMOUNT_DRIVE=%~1"
if not defined UNMOUNT_DRIVE set "UNMOUNT_DRIVE=%MOUNT_DRIVE%"

if not defined UNMOUNT_DRIVE (
    echo unmount.bat: no drive given and MOUNT_DRIVE not set, nothing to unmount.
    endlocal
    exit /b 0
)

set "UNMOUNT_DRIVE=%UNMOUNT_DRIVE:~0,1%:"

set "FOUND="
for /f "delims=" %%L in ('subst') do (
    set "line=%%L"
    if /i "!line:~0,2!"=="!UNMOUNT_DRIVE!" set "FOUND=1"
)

set "RESULT=0"
if defined FOUND (
    subst %UNMOUNT_DRIVE% /d
    if errorlevel 1 (
        echo unmount.bat: failed to unmount %UNMOUNT_DRIVE% >&2
        set "RESULT=1"
    ) else (
        echo unmount.bat: unmounted %UNMOUNT_DRIVE%
    )
) else (
    echo unmount.bat: %UNMOUNT_DRIVE% is not a subst'd drive, nothing to unmount.
)

if /i "%UNMOUNT_DRIVE%"=="%MOUNT_DRIVE%" (
    endlocal & set "MOUNT_DRIVE=" & exit /b %RESULT%
) else (
    endlocal & exit /b %RESULT%
)
```

### Example pipeline
```groovy

pipeline {
    agent { label 'windows' }

    stages {
        stage('mount drive') {
            steps {
                echo "Mounting drive..."
                script {
                    batSetEnv(".\\mount.bat \"${env.WORKSPACE}\" \"A,B,J,K\"")
                }
            }
        }

        // when batSetEnv() is used
        // local SET vars survive between bat calls

        stage('unmount drive') {
            steps {
                echo "MOUNT_DRIVE mounted at ${env.MOUNT_DRIVE}"
                script {
                    batSetEnv(".\\unmount.bat")
                }
                echo "MOUNT_DRIVE now ${env.MOUNT_DRIVE}"
            }
        }
    }

    post {
        failure {
            echo "Build failed, unmounting drive..."
            script {
                bat(".\\unmount.bat")
            }
        }
    }
}
```



## Retriving data
Auth (almost always needed). Use an API token, not your password — generate it under User → Configure → API Token.

```
# wget
wget --auth-no-challenge --user=<user> --password=<api_token> \
     https://jenkins.example/job/app-fw/512/artifact/build/firmware.bin

# curl (often cleaner)
curl -fsSL -u <user>:<api_token> \
     https://jenkins.example/job/app-fw/512/artifact/build/firmware.bin -o firmware.bin
```


Finding the exact path programmatically — the build's JSON API lists artifacts:
```
bash
curl -s -u <user>:<tok> \
  "https://jenkins.example/job/app-fw/512/api/json?tree=artifacts[relativePath]"
```

### Artifactory replacement
| **Artifactory feature**            | **Useful?**        | **Minimal equivalent**                                        |
| ---------------------------------- | ------------------- | ------------------------------------------------------------------ |
| Content-addressed store + dedup    | **Yes - core**      | file-per-key JSON, sharded dir                                     |
| Properties / metadata on artifacts | **Yes**             | the JSON record fields                                             |
| Build Info (CI → artifact linkage) | **Yes**             | Jenkins writes commit + build # into the record                    |
| Search / query (AQL)               | Light               | dict lookup by key; filter by tag/date in Python                   |
| Immutability / retention           | **Yes**             | append-only records, never rewrite; VCS history is the audit trail |
| Checksum verification              | Optional            | recompute CRC over region vs stored field                          |
| Promotion / staging (dev→release)  | Optional            | a status field or rc/release/ subdirs                              |
| Binary storage / re-download       | Optional            | bins kept as jenkins artifacts                                     |
| Access control                     | **Skip**            | VCS repo permissions cover it                                      |
| REST API / web UI                  | **Skip**            | CLI + git/svn                                                      |
| Replication / HA                   | **Skip**            | the VCS repo is already distributed                                |
| Virtual/remote repos, proxying     | **Skip**            | irrelevant to your use case                                        |

Stored in jenkins as

      ARTIFACT_REL="build/load_package.bin"       # path relative to archive root
      ARTIFACT_URL="${BUILD_URL}artifact/${ARTIFACT_REL}"
      # -> https://jenkins.example/job/app-fw/512/artifact/build/load_package.bin
      or query:
      curl -fsS -u "$U:$T" "${BUILD_URL}api/json?tree=artifacts[relativePath,fileName]"

Structure

      releaserecords/
         README.md
         records/
            6413bd...<load_package_md5>.json

each json with version information like
```json
{
  "schema_version": 2,
  "load_package_md5": "6413bd...(same as file name)",
  "jenkins_artifact_url": "https://jenkins.example/job/app-fw/530/artifact/build/load_package.bin",
  "svn_url": "svn://scm.example/app/trunk",
  "svn_revision": "r18690",
  "notes": "new telemetry feature",
  "components": [
    {"component": "bootloader",  "crc32": "0xc251516f"},
    {"component": "application", "crc32": "0x082f23c5"},
    {"component": "gainconfig",  "crc32": "0x174fe53c"}
  ]
}
```


```
// vars/registerLoadPackage.groovy
//
// Jenkins Shared Library step: build a loaddb record (schema 2) for a load
// package and commit it to the records repo (SVN).
//
// Usage from a Jenkinsfile (after the load package is built & archived):
//
//   registerLoadPackage(
//     loadPackage    : 'build/load_package.bin',        // path in the workspace
//     componentManifest: 'build/components.json',       // {name:crc32} or [{component,crc32}]
//     recordsRepoUrl : 'svn://scm.example/loaddb/packages',
//     credentialsId  : 'svn-records',                   // SVN user/pass credential
//     notes          : params.NOTES ?: env.SVN_COMMIT_MSG
//   )
//
// Data sources (all overridable via args):
//   load_package_md5  : md5 of loadPackage, computed on the agent
//   jenkins_build_url : "${BUILD_URL}artifact/${artifactRelPath}"
//   svn_url/revision  : env.SVN_URL / env.SVN_REVISION (source checkout)
//   components/crc32  : from componentManifest, or an inline `components` map
//
// The build is responsible for emitting the per-component CRC32s (the values
// it embedded into each image) into componentManifest. This step does not
// extract CRCs from binaries, since their offset/layout is target specific.

import groovy.json.JsonOutput
import groovy.json.JsonSlurper

def call(Map args = [:]) {
    // ---- required -------------------------------------------------------
    String loadPackage    = args.loadPackage    ?: error('registerLoadPackage: loadPackage is required')
    String recordsRepoUrl = args.recordsRepoUrl ?: error('registerLoadPackage: recordsRepoUrl is required')

    // ---- defaults (mostly from the build environment) -------------------
    int    schemaVersion   = (args.schemaVersion ?: 2) as int
    String srcUrl          = args.srcUrl       ?: env.SVN_URL      ?: env.SVN_URL_1      ?: ''
    String srcRevision     = args.srcRevision  ?: env.SVN_REVISION ?: env.SVN_REVISION_1 ?: ''
    String notes           = (args.notes ?: '') as String
    String credentialsId   = args.credentialsId   ?: 'svn-records'
    String artifactRelPath = args.artifactRelPath ?: loadPackage   // path as archived

    // ---- gather the pieces ---------------------------------------------
    Map    components  = resolveComponents(args)
    String md5         = md5OfFile(loadPackage)
    String artifactUrl = "${env.BUILD_URL}artifact/${artifactRelPath}"
    String json        = buildRecordJson(schemaVersion, md5, artifactUrl,
                                         srcUrl, srcRevision, notes, components)

    // ---- write + commit -------------------------------------------------
    boolean committed = commitRecord(recordsRepoUrl, credentialsId, md5, json, srcRevision)
    echo committed ? "loaddb: registered ${md5} (${components.size()} components)"
                   : "loaddb: ${md5} already present, nothing to commit"
    return md5
}

// ---------------------------------------------------------------------------
// component resolution
// ---------------------------------------------------------------------------

Map resolveComponents(Map args) {
    if (args.components instanceof Map) {
        return normalizeCrcMap(args.components)
    }
    if (args.componentManifest) {
        String txt = readFile(file: args.componentManifest)   // reads the agent workspace
        return parseManifest(txt)
    }
    error('registerLoadPackage: provide components (Map name->crc32) or componentManifest (path)')
}

@NonCPS
Map parseManifest(String txt) {
    def parsed = new JsonSlurper().parseText(txt)
    def out = [:]
    if (parsed instanceof Map) {
        parsed.each { k, v -> out[k.toString()] = normCrc(v.toString()) }
    } else if (parsed instanceof List) {
        parsed.each { item -> out[item.component.toString()] = normCrc(item.crc32.toString()) }
    } else {
        throw new IllegalArgumentException('component manifest must be a JSON object or list')
    }
    return out
}

@NonCPS
Map normalizeCrcMap(Map m) {
    def out = [:]
    m.each { k, v -> out[k.toString()] = normCrc(v.toString()) }
    return out
}

@NonCPS
String normCrc(String v) {
    String n = v.trim().toLowerCase()
    if (n.startsWith('0x')) n = n.substring(2)
    return '0x' + n.padLeft(8, '0')
}

// ---------------------------------------------------------------------------
// record construction (pure, CPS-safe)
// ---------------------------------------------------------------------------

@NonCPS
String buildRecordJson(int schema, String md5, String artifactUrl,
                       String srcUrl, String srcRev, String notes, Map components) {
    def rec = [
        schema_version   : schema,
        load_package_md5 : md5,
        jenkins_build_url: artifactUrl,
        svn_url          : srcUrl,
        svn_revision     : srcRev,
        notes            : notes,
        components       : components.collect { name, crc -> [component: name, crc32: crc] }
    ]
    return JsonOutput.prettyPrint(JsonOutput.toJson(rec)) + '\n'
}

// ---------------------------------------------------------------------------
// md5 on the agent (where the file actually lives)
// ---------------------------------------------------------------------------

String md5OfFile(String path) {
    if (isUnix()) {
        return sh(returnStdout: true,
                  script: "md5sum \"${path}\" | cut -d' ' -f1").trim().toLowerCase()
    }
    // Windows: certutil prints the hash on its own line
    String out = bat(returnStdout: true,
                     script: "@certutil -hashfile \"${path}\" MD5").trim()
    def hex = out.readLines().collect { it.trim() }.find { it ==~ /(?i)[0-9a-f]{32}/ }
    if (!hex) error("could not parse md5 from certutil output:\n${out}")
    return hex.toLowerCase()
}

// ---------------------------------------------------------------------------
// SVN commit (idempotent on the load_package_md5)
// ---------------------------------------------------------------------------

boolean commitRecord(String repoUrl, String credId, String md5, String json, String srcRev) {
    String file    = "${md5}.json"
    String fileUrl = "${repoUrl}/${file}"
    boolean committed = false

    withCredentials([usernamePassword(credentialsId: credId,
                                      usernameVariable: 'SVN_U',
                                      passwordVariable: 'SVN_P')]) {
        if (svn("info \"${fileUrl}\"", true) == 0) {
            return false                       // this exact package already recorded
        }
        dir('.loaddb-wc') {
            deleteDir()
            svn("checkout --depth empty \"${repoUrl}\" .")   // no need to pull existing records
            writeFile file: file, text: json
            svn("add \"${file}\"")
            svn("commit -m \"loaddb: register ${md5} (src ${srcRev})\" \"${file}\"")
            committed = true
        }
    }
    return committed
}

// Run an svn command with injected credentials. Returns exit status when
// status==true, otherwise throws on non-zero. $SVN_U/$SVN_P come from
// withCredentials; reference syntax differs between sh and bat.
def svn(String argsLine, boolean status = false) {
    if (isUnix()) {
        String auth = '--username "$SVN_U" --password "$SVN_P" ' +
                      '--no-auth-cache --non-interactive --trust-server-cert'
        return sh(returnStatus: status, script: "svn ${auth} ${argsLine}")
    }
    String auth = '--username "%SVN_U%" --password "%SVN_P%" ' +
                  '--no-auth-cache --non-interactive --trust-server-cert'
    return bat(returnStatus: status, script: "svn ${auth} ${argsLine}")
}
```