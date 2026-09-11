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

## Setup with export

    bash -c "svn export --force http://192.168.1.x/svn/myapp/trunk ci > /dev/null && bash ci/intro.sh"

## Commit messages to Jira
```python
    #!/usr/bin/env python3
    """
    The ONLY valid commit identifier is one JIRA key in square brackets:
        [TASK-1234] Headline
        [TASK-1234][TASK-1235] Headline      several identifiers, one per bracket

    Anything else is treated as ordinary text and stays in the title, e.g.
        Fixed the problem (TASK-1234)        parentheses        -> not an identifier
        [TASK-1, TASK-2]                     list in brackets   -> not an identifier
        [ TASK-1 ] / [task-1]                spaces / lowercase -> not an identifier
        TASK-1: Fix                          bare key           -> not an identifier

    Usage as a module:
        from commit_title import CommitTitle
        ct = CommitTitle(msg)
        ct.title()     # -> "This is the headline"
        ct.issues()    # -> ["TASK-1234", "TASK-1235"]

    """

    import re
    import sys

    __all__ = ["CommitTitle"]


    class CommitTitle(object):
        """
        Parse a commit message once; query the result with .title() and .issues().

        Title rules:
        - First line that still has content after [KEY-n] identifiers, bullet
        markers and surrounding punctuation are removed.
        - If the message consists only of identifiers, the title is the keys.
        - If the message is empty, the title is `fallback`.
        - Truncated at a word boundary to `max_len` characters (None = no limit).

        Self-contained: the only external dependency is the `re` module.
        """

        # JIRA key: project key (uppercase letter, then uppercase/digits/_) + '-' + number
        _KEY = r"[A-Z][A-Z0-9_]*-\d+"
        # Valid identifier: exactly one key inside square brackets, no spaces
        _REF_RE = re.compile(r"\[(" + _KEY + r")\]")
        # List markers: "* ", "- ", "+ ", "1. ", "1) "
        _BULLET_RE = re.compile(r"^\s*(?:[*\-+]|\d+[.)])\s+")
        _WS_RE = re.compile(r"\s+")
        # Punctuation left dangling after removing identifiers
        _LEAD_PUNCT = " \t:;,"        # keep leading '.' / '-' (".cproject", "-Werror")
        _TRAIL_PUNCT = " \t-:;,."
        _ELLIPSIS = "..."

        def __init__(self, message, max_len=72, fallback="(no message)"):
            self._message = message or ""
            self._max_len = max_len
            self._fallback = fallback
            self._issues = self._parse_issues(self._message)
            self._title = self._parse_title(self._message)

        # --- public API -------------------------------------------------------
        def title(self):
            """Short one-line title."""
            return self._title

        def issues(self):
            """[KEY-n] identifiers in order of appearance, without duplicates."""
            return list(self._issues)   # copy: callers cannot alter internal state

        def message(self):
            """The original commit message."""
            return self._message

        def __str__(self):
            return self._title

        def __repr__(self):
            return "CommitTitle(title={!r}, issues={!r})".format(self._title, self._issues)

        # --- internals --------------------------------------------------------
        @classmethod
        def _parse_issues(cls, message):
            found = []
            for key in cls._REF_RE.findall(message):
                if key not in found:
                    found.append(key)
            return found

        def _parse_title(self, message):
            for line in message.splitlines():
                text = self._clean_line(line)
                if any(ch.isalnum() for ch in text):
                    return self._truncate(text)
            if self._issues:
                return self._truncate(", ".join(self._issues))
            return self._fallback

        @classmethod
        def _clean_line(cls, line):
            text = cls._BULLET_RE.sub("", line)
            text = cls._REF_RE.sub(" ", text)
            text = cls._BULLET_RE.sub("", text)  # "[TASK-1] - foo" -> "foo"
            text = cls._WS_RE.sub(" ", text)
            return text.lstrip(cls._LEAD_PUNCT).rstrip(cls._TRAIL_PUNCT)

        def _truncate(self, text):
            max_len = self._max_len
            ellipsis = self._ELLIPSIS
            if max_len is None or len(text) <= max_len:
                return text
            limit = max_len - len(ellipsis)
            if limit <= 0:
                return text[:max_len]
            cut = text.rfind(" ", 0, limit + 1)
            if cut < limit // 2:          # no sensible word boundary -> hard cut
                cut = limit
            return text[:cut].rstrip(self._TRAIL_PUNCT) + ellipsis
```