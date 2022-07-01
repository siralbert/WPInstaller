# siralbert/WPInstaller

An automated Wordpress installer and CLI with the following options.

Usage: $0 [MySQL RootPass] [MySQL Database] [mysqluser] [MySQL Pass] [web_domain] [web_email]

Template for a generic CLI

Optional args?  if not specified install everything.
    -c [web_domain] [web_email]    generate TLS/SSL certificate and install
    -d [mysql rootpass] [mysql database] [mysqluser] [mysql pass] [db file] TODO: check if database exists     
    -rd [database name ] [db file] make backup of old database and replace with new database
