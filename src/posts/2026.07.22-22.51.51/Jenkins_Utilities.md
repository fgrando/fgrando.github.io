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

