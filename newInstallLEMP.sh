#!/bin/bash

# Usage: $0 [MySQL RootPass] [MySQL Database] [mysqluser] [MySQL Pass] [web_domain] [web_email]
#
# Template for a generic CLI
#
# Optional args?  if not specified install everything.
#     -c [web_domain] [web_email]    generate TLS/SSL certificate and install
#     -d [mysql rootpass] [mysql database] [mysqluser] [mysql pass] [db file] TODO: check if database exists 
#     dev env.(ipv4 address) versus prod env.(domain name):  make backup of old database and replace with new one
#     -rd [database name ] [db file]
#


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
    prettyprint "     -c [web_domain] [web_email]    generate TLS/SSL certificate and install" $YELLOW
    prettyprint "     -d [mysql rootpass] [mysql database] [mysqluser] [mysql pass] [db file] TODO: check if database exists" $YELLOW 
    prettyprint "     -R [database name ] [db file]" $YELLOW
    echo ""
exit 0
}

[ -z $1 ] && { usage; }

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
    certbot run -n --nginx --agree-tos -d ${ARGV[1]},www.${ARGV[1]}  -m  ${ARGV[2]}

else # ONLY WHEN NECESSARY: re-install because a main setting (ie: ipv4 address has changed)
    #sudo certbot certonly -n -v --nginx --agree-tos --force-renew -d ${ARGV[1]},www.${ARGV[1]} -m ${ARGV[2]}
    # run the following when certificate expires to renew certificate in normal situations
   certbot run -n --nginx --agree-tos -d ${ARGV[1]},www.${ARGV[1]}  -m  ${ARGV[2]}
fi
}

main() {

# Check number of arguments
if [[ $ARGS -eq 6 ]]; then
    echo "Correct number of arguments including command"

    echo ${args[mysqlrootpass]}
	echo ${args[mysqldb]}
	echo ${args[mysqluser]}
	echo ${args[mysqlpass]}
	echo ${args[webdomain]}
	echo ${args[webemail]}

# Generate and install new SSL/TLS security certificate"
elif [[ "${ARGV[0]}" == "-c" && $ARGS -eq 3 ]]; then
	echo "generate and install new SSL/TLS security certificate"
	cert ${ARGV[0]} ${ARGV[1]} ${ARGV[2]} ;

# Create a new database with specified arguments
elif [[ "${ARGV[0]}" == "-d" && $ARGS -ge 4 ]]; then
	echo "${ARGV[0]}"
	echo "create a new database with specified arguments"

# Replace the current database with specified sql file
elif [[ "${ARGV[0]}" == '-R' && $ARGS -eq 2 ]]; then
	echo "${ARGV[0]}"
	echo "replace the current database with specified sql file"
else
    echo "$ARGV"
fi

}

main




# COMMENT block
: <<COMMENT
echo ${args[mysqlrootpass]}
echo ${args[mysqldb]}
echo ${args[mysqluser]}
echo ${args[mysqlpass]}
echo ${args[webdomain]}
COMMENT
