#!/bin/bash

CMD=`sudo service --status-all 2>/dev/null | grep -oE 'php[0-9]+.[0-9]+' | cut -d- -f1 | tail -n1`
PHPVER=$CMD
sudo cat <<EOT >> test.conf
server {
    listen 80 default_server;
        listen [::]:80 default_server;
                server_name ubuntuserver.com;
                    root /var/www/html;

                        index index.php;

                            location / {
                                    try_files \$uri \$uri/ /index.php?\$args;
                                        }
                                            location ~ \.php$ {
                                                    include snippets/fastcgi-php.conf;
                                                            fastcgi_pass unix:/run/php/php$PHPVER-fpm.sock;
                                                                }
                                                                    location ~ /\.ht {
                                                                            deny all;
                                                                                }
                                                                                }
EOT
