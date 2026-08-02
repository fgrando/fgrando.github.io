# Linux cheatsheet

## Packages
List installed packages:

    dpkg --get-selections | grep -v deinstall
    apt list --installed

## Files created by systemd services
Fix the group permissions with:

    [Service]
    UMask=0002

Or by hand with:

    chmod -R g+w *.mp4

