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

## Pinning Revisions
Using @123 or -r123 have differences. \
Example: A dependency folder `/deps/libmath`, and a completely unrelated rewrite living alongside it as `/deps/libmath-ng`.

    r2    /deps/libmath/version.h     = "libmath 1.0"
          /deps/libmath-ng/version.h  = "libmath-ng 0.1"
    r123  /deps/libmath/version.h     = "libmath 1.1"   <-- the revision you pin
    r124  /deps/libmath-ng/version.h  = "libmath-ng 0.2"
    r125  svn mv /deps/libmath    -> /deps/libmath-legacy    (old one retired)
    r126  svn mv /deps/libmath-ng -> /deps/libmath           (ng promoted into the name)

Nothing exotic — upstream retired a component and promoted its replacement into the canonical path. Happens constantly.

Result, both commands succeed:

    ^/deps/libmath/version.h@123    ->  #define LIBMATH_VERSION "libmath 1.1"
    -r123 ^/deps/libmath/version.h  ->  #define LIBMATH_VERSION "libmath-ng 0.1"

No error, no warning. The operative-only form went to HEAD, found that `/deps/libmath` is now the ng line of history, walked that line back to r123, and handed you a different library. Your pin still says 123 and it is still resolving faithfully — **to the wrong component**.