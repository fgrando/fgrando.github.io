# VSCode in Browser
05/Mar/2023


Install code-server in ubuntu: https://coder.com/docs/code-server/latest/install#debian-ubuntu

```
sudo apt update && sudo apt upgrade -y && apt install htop curl -y
```

For this example, an account called `user` (with sudo rights) is used to run the following commands:

```
curl -fsSL https://code-server.dev/install.sh | sh -s -- --dry-run

curl -fsSL https://code-server.dev/install.sh | sh
```

And finally:
```
sudo systemctl enable --now code-server@$USER
# Now visit http://127.0.0.1:8080. Your password is in ~/.config/code-server/config.yaml
```