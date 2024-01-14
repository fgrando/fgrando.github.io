# Setup WRP - Web Rendering Proxy
14/Jan/2024

Into the ubuntu server LXC as root:

```
cd /opt

# install proxy
wget https://github.com/tenox7/wrp/releases/download/4.6.2/wrp-amd64-linux
chmod +x wrp-amd64-linux

# install chrome
apt-get install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install ./google-chrome*.deb

apt-get install -f

apt install htop

```

## Add to crontab
```
    @reboot /opt/wrp-amd64-linux -l :80 -t=gif -g=800x600x16
```
