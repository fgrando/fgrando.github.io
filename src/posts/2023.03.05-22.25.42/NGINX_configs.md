# NGINX configs
05/Mar/2023

## Guacamole proxy
Change access url from the default URL `http://127.0.0.1:8080/guacamole` to another port

In the site config file `/etc/nginx/sites-available/guacamole_server.conf`:
```nginx
server {
    listen 8000;
    location / {
        proxy_pass http://127.0.0.1:8080/guacamole/;
        include proxy_params;
    }
}
```
```sudo systemctl restart nginx.service```

## code-runner websockets
Enable websocket the site config file `/etc/nginx/sites-available/code_server.conf`:
```nginx
server {
    listen 8000;

    location / {
        proxy_pass http://127.0.0.1:8081/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
```
```sudo systemctl restart nginx.service```


## HTTP Basic Authentication

Add the `auth_basic` lines to the server config file.

Create the `.htpasswd` in `/etc/nginx/.htpasswd`.

Then add the `auth_basic` lines in the server config file (e.g: `/etc/nginx/sites-available/default`)
```sh
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    auth_basic "Restricted Content";
    auth_basic_user_file /etc/nginx/.htpasswd;
```

Finally, add the users to the password file:
```sh
#!/bin/bash

echo run this command:
echo sudo sh -c "echo -n 'myusername:' >> /etc/nginx/.htpasswd"
echo sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"
```
