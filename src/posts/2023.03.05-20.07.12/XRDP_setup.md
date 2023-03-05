# XRDP setup
05/Mar/2023

# Tested on Debian 11:
```bash
root@deblx:/home/user# apt install xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils
root@deblx:/home/user# apt install xrdp
root@deblx:/home/user# adduser xrdp ssl-cert
root@deblx:/home/user# systemctl restart xrdp
user@deblx:~$ echo xfce4-session >~/.xsession
```