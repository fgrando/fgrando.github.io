# SVN usage notes
29/Jul/2026

## Re-clonning trunk to an existing branch
```batch
svn checkout --depth empty svn://server/repo/branches wc
cd wc
svn update --depth empty oldbranch     # brings just this one node into the WC
svn rm oldbranch
svn cp ^/trunk oldbranch
svn commit -m "Re-branch oldbranch from trunk@HEAD"
```

## SVN Credentials
When automating SVN commands always include the flags `--no-auth-cache --non-interactive --trust-server-cert`
If user and pass are defined in env vars add also: `--username "%SVN_U%" --password "%SVN_P%"`

## Create a new repo (server side)

    svnadmin create /srv/svn/repos/myapp

    nano myapp/conf/svnserve.conf # example:
        [general]
        anon-access = none
        auth-access = write
        password-db = passwd
        realm = myapp

    nano myapp/conf/passwd # example
        [users]
        dev1 = password
        dev2 = password

    svn mkdir -m "init layout" \
        svn://<server>/myapp/trunk \
        svn://<server>/myapp/branches \
        svn://<server>/myapp/tags

If websvn is used, check if it will have the correct permissions in the file system (if not runs with same user as svnserve)

## Keywords
Set svn:keywords Revision on `resources/VERSION` - tells SVN which keywords to expand in that file.
The placeholder test should match `$Revision$` - SVN requires both delimiters to recognize and expand a keyword.
SVN will expand it to something like `$Revision: 1234$` and keep updating it on future commits to that file.