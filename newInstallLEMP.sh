#!/bin/bash

# Usage: $0 [MySQL RootPass] [MySQL Database] [mysqluser] [MySQL Pass] [web_domain] [web_email]
#
# Template for a generic CLI
#
# Optional args?  if not specified see usage above to install everything.
#     -c [web_domain] [web_email]    generate TLS/SSL certificate and install
#     -d [mysql rootpass] [mysql database] [mysqluser] [mysql pass] [db file] TODO: check if database exists 
#     feature: dev env.(ipv4 address) versus prod env.(domain name):  make backup of old database and replace with new one
#     -R [mysql rootpass] [database name ] [db file|new domain name or ipaddress] 
#

readonly WPDIR="/var/www/html"
readonly ARGS="$#"
#  Convert shell command arguments into an array with ()
readonly ARGV=($@)
declare -A args
args=(["mysqlrootpass"]="$1" ["mysqldb"]="$2" ["mysqluser"]="$3" ["mysqlpass"]="$4" ["webdomain"]="$5" ["webemail"]="$6")

# ---PRETTYPRINT---
declare NONEWLINE=1
# colours (v1.0)
declare BLUE='\E[1;49;96m' LIGHTBLUE='\E[2;49;96m'
declare RED='\E[1;49;31m' LIGHTRED='\E[2;49;31m'
declare GREEN='\E[1;49;32m' LIGHTGREEN='\E[2;49;32m'
declare YELLOW='\E[1;33m' LIGHTYELLOW='\E[2;49;33m'
declare RESETSCREEN='\E[0m'
# prettyprint (v1.0)
prettyprint() {
[[ -z $nocolor ]] && echo -ne $2
if [[ "$3" == "$NONEWLINE" ]]; then
	echo -n "$1"
else
    echo "$1"
fi
[[ -z $nocolor ]] && echo -ne ${RESETSCREEN}

}
# --- ---


usage () {
    prettyprint "      (c) 2022 Albert" $LIGHTBLUE
    prettyprint "      Licensed under the GPL 3.0" $LIGHTBLUE
    echo ""
	prettyprint "   Usage: $0 [MySQL RootPass] [MySQL Database] [mysqluser] [MySQL Pass] [web_domain] [web_email]" $YELLOW
	echo ""
    prettyprint "     -c [web_domain] [web_email]    generate TLS/SSL certificate and install " $YELLOW
    prettyprint "     -d [mysql rootpass] [mysql database] [mysqluser] [mysql pass] [db file] " $YELLOW 
    prettyprint "     -R [mysql rootpass] [database name ] [db file|new domain name or ipaddress] " $YELLOW
    echo ""
exit 0
}

[ -z $1 ] && { usage; }

# Methods:
# cert()
# newdb()
# replacedb()
# wpconfig()
# wpfiles()


# Function for generating and installing new SSL/TLS security certificate by certbot"
# You must have A and CNAME records added to your domain name registrar with correct IPs before running these commands$
cert(){
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot

# TODO: if -c switch is not specified install cert, else renew cert
# NOTE: only use certonly --force-renew if settings have changed (ie: ipv4 address on host)
# ARGV[1] is the web domain, ARGV[2] is the email address
if [[ $1 -ne '-c' ]]; then
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    certbot run -n --nginx --agree-tos -d ${ARGV[1]},www.${ARGV[1]}  -m  ${ARGV[2]} --redirect

else # ONLY WHEN NECESSARY: re-install because a main setting (ie: ipv4 address has changed)
    #sudo certbot certonly -n -v --nginx --agree-tos --force-renew -d ${ARGV[1]},www.${ARGV[1]} -m ${ARGV[2]}
    # run the following when certificate expires to renew certificate in normal situations
   certbot run -n --nginx --agree-tos -d ${ARGV[1]},www.${ARGV[1]}  -m  ${ARGV[2]} --redirect
fi
}

newdb(){

local dbsqlfile=$5
local mysqlrootpass=$1
local mysqldb=$2
local mysqluser=$3
local mysqlpass=$4

# Installing MariabDB Server
sudo apt install -y mariadb-server
# Starting MariaDB Service
sudo systemctl start mariadb
# Enabling MariaDB service so that it keeps up and running during restarts
sudo systemctl enable mariadb
# Installing expect tool to work with interactive commands
sudo apt install -y expect

# Automate the Database configuration ?? do i need to add sudo infront of spawn?
MYSQL_ROOT_PASSWORD=$mysqlrootpass
SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Switch to unix_socket authentication\"
send \"y\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"New password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
#echo "$SECURE_MYSQL"

if [[ $dbsqlfile ]]; then
	echo "importing database from sql file . . ."

	sudo mysql -u root -p$MYSQL_ROOT_PASSWORD < $dbsqlfile

else

# TODO: Add check to see if database exists?  Check already exists.
# Create new database and new database user for WordPress
sudo mysql -u root -p$MYSQL_ROOT_PASSWORD -e "create or replace database $mysqldb;
show warnings;
create user '$mysqluser'@localhost identified by '$mysqlpass';
grant all privileges on $mysqldb.* to '$mysqluser'@localhost;
flush privileges;
exit;"

fi
}


# Replace current WordPress database with a new one
# Feature: Use new web address or IP if specified (ie: for wordpress dev. environment)
#
# Usage:    replacedb [mysql rootpass] [database name ] [old domain or ip] [new domain or ip]
#         or replacedb [mysql rootpass] [database name] [new sql database]
replacedb(){

local mysqlrootpass=$1
local mysqldb=$2
local newsqldb=$3
local OLDADDRESS=$3
local NEWADDRESS=$4

local args=$#
echo "$args"

# backup old database to db.sql if there are only 3 arguments
if [[ args -eq 3 ]]; then
  echo "make backup sql file of old database in current directory "
  sudo mysqldump -u root -p$mysqlrootpass -x -B $mysqldb > db.sql.bak
  echo "import new database from sql file"
  sudo mysql -u root -p$mysqlrootpass < $newsqldb
  exit;
fi

  sudo mysqldump -u root -p$mysqlrootpass -x -B $mysqldb > dbs.sql
  echo "count of old addresses in sql file"
  grep -o $OLDADDRESS dbs.sql | wc -l

  echo "make backup sql file of old database in current directory and replace address"
  sed -i.bak -e "s/$OLDADDRESS/$NEWADDRESS/g w output.log" dbs.sql
  echo "count of new addresses in sql file"
  grep -o $NEWADDRESS dbs.sql | wc -l

  echo "import database from sql file"
  sudo mysql -u root -p$mysqlrootpass < dbs.sql
}

installPHPandWP(){
# Installing PHP and PHP Essential Extensions
sudo apt install -y php
sudo apt install -y php-mysql php-gd php-common php-mbstring php-curl php-cli
sudo apt install -y php-fpm

# uninstall apache2
sudo apt remove -y apache2

# Installing NGINX Server
sudo apt install -y nginx

# TODO: Check
# Starting NGINX Service
sudo systemctl start nginx
# Enabling NGINX service so that it keeps up and running during restarts
sudo systemctl enable nginx
# Restarting the NGINX Server
sudo systemctl restart nginx
# TODO: Check

# Installing and Configuring WordPress
wget https://wordpress.org/latest.zip
sudo apt install -y unzip
unzip -o $PWD/latest.zip

# Copying WordPress files to NGINX Default Directory
sudo rm -r /var/www/html/*
sudo mv $PWD/wordpress/* /var/www/html

# Configuring NGINX to host wordpress website
sudo rm /etc/nginx/sites-enabled/default
sudo touch /etc/nginx/sites-enabled/wordpress.conf
sudo chmod 666 /etc/nginx/sites-enabled/wordpress.conf

# Creating the NGINX configuration file for WordPress
sudo cat <<EOT >> /etc/nginx/sites-enabled/wordpress.conf
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
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }
    location ~ /\.ht {
        deny all;
    }
}
EOT

}

wpconfig(){

    local mysqldb=$1
    local mysqluser=$2
    local mysqlpass=$3
    
    #LINE numbers for config vars in wp-config.php file
    local dbname=`grep -n $WPDIR/wp-config-sample.php -e "define( 'DB_NAME'" | cut -d: -f1`
    local dbuser=`grep -n $WPDIR/wp-config-sample.php -e "define( 'DB_USER'" | cut -d: -f1`
    local dbpasswd=`grep -n $WPDIR/wp-config-sample.php -e "define( 'DB_PASSWORD'" | cut -d: -f1`

	#REPLACE WITH . . .
	REPLACEdbname="define( 'DB_NAME', '$mysqldb' );"
	REPLACEdbuser="define( 'DB_USER', '$mysqluser' );"
	REPLACEdbpasswd="define( 'DB_PASSWORD', '$mysqlpass' );"

	#WPDIR

	sed -i "${dbname}s/.*/${REPLACEdbname}/" $WPDIR/wp-config-sample.php
	sed -i "${dbuser}s/.*/${REPLACEdbuser}/" $WPDIR/wp-config-sample.php
	sed -i "${dbpasswd}s/.*/${REPLACEdbpasswd}/" $WPDIR/wp-config-sample.php

	mv wp-config-sample.php wp-config.php

	# Add SALTS
	CMD=`lynx -dump -dont_wrap_pre https://api.wordpress.org/secret-key/1.1/salt/`
	
	LINE=`grep -n 'wp-config.php' -e "define( 'AUTH_KEY'"| cut -d: -f 1`
	echo $LINE
	
	sed -i /_SALT/d wp-config.php
	sed -i /_KEY/d wp-config.php
	echo $CMD | sed -i -- "${LINE}r /dev/stdin" wp-config.php
}

# change wpfiles permissions
wpfiles(){
	echo "Change file permissions and secure files in /var/www directory . . . "
	echo ". . . Please wait this may take a while . . ."

	echo "TODO: add feature to copy files for customized child themes and plugins"
	local themedir=$1

	if [[ $themedir ]]; then
		cp -r $themedir $WPDIR/wp-content/themes
	fi

	# add user to www-data group
	sudo adduser $USER www-data
	# change ownership of all directories and files in /var/www to $USER:www-data
	sudo chown $USER:www-data -R /var/www
	
	# allow new files to inherit the www-data group id of the parent directory
	sudo find /var/www/ -type d -exec chmod g+s {} \;
	
	# add group write to all files
	find /var/www -type f -exec sudo chmod g+w {} \;
	# add group write to all directories
	find /var/www -type d -exec sudo chmod g+w {} \;
	
}

main() {

# Check number of arguments
if [[ $ARGS -ge 4 ]]; then

	# TODO: execute production install if all arguments are given.  else do a dev. install
    echo "WP Install--dev environment"
#	echo ${args[mysqlrootpass]}
	newdb ${args[mysqlrootpass]} ${args[mysqldb]} ${args[mysqluser]} ${args[mysqlpass]};  #TODO: specify sql file to generate database from
#	replacedb ${args[mysqlrootpass]} ${args[mysqldb]} gmental.com 127.0.0.1;
	installPHPandWP
    wpconfig ${args[mysqldb]} ${args[mysqluser]} ${args[mysqlpass]};
    wpfiles;     #  TODO:  Use copy custom theme option


	# specified for production install
	if [[ $ARGS -eq 6 ]]; then
		cert ${args[webdomain]} ${args[webemail]} ;

		newdb ${args[mysqlrootpass]} ${args[mysqldb]} ${args[mysqluser]} ${args[mysqlpass]};

		#installPHPandWP ;
#	    wpconfig ${args[mysqldb]} ${args[mysqluser]} ${args[mysqlpass]};
	    wpfiles;

	fi
#	echo ${args[webdomain]}
#	echo ${args[webemail]}
	# END TODO:

# Generate and install new SSL/TLS security certificate"
elif [[ "${ARGV[0]}" == "-c" && $ARGS -eq 3 ]]; then
	echo "generate and install new SSL/TLS security certificate"
	cert ${ARGV[0]} ${ARGV[1]} ${ARGV[2]} ;

# Create a new database with specified arguments
elif [[ "${ARGV[0]}" == "-d" && $ARGS -ge 5 ]]; then
	echo "create a new database with specified arguments"
	newdb ${ARGV[1]} ${ARGV[2]} ${ARGV[3]} ${ARGV[4]} ${ARGV[5]} ;

# Replace the current database with specified sql file or replace current database with new ip/domain
elif [[ "${ARGV[0]}" == '-R' && $ARGS -ge 4 ]]; then
	echo "replace the current database with specified sql file"
	replacedb ${ARGV[1]} ${ARGV[2]} ${ARGV[3]} ${ARGV[4]} ;
else
    echo "Error: CLI"
fi

}

main
