# Borg notes
10/Aug/2026

## Mount a borg repo to navigate the available backups
```
mkdir /tmp/geral
borg mount <user>@<server>:/mnt/scsi1/borgs/geral /tmp/geral/
ls /tmp/geral
borg umount /tmp/geral
```
