# siralbert/WPInstaller

An automated Wordpress installer and CLI with the following options.

    ./WPInstaller [MySQL RootPass] [MySQL Database] [mysqluser] [MySQL Pass] [web_domain] [web_email]

Template for a generic CLI

Optional args.  if not specified, specify above arguements to install everything (security certificate, database, and wordpress files for site
- -c [web_domain] [web_email]    generate TLS/SSL certificate and install
- -d [mysql rootpass] [mysql database] [mysqluser] [mysql pass] [db file] TODO: check if database exists  
   
   makes backup of old database and replace with new database with changed web address.
- -R [mysql rootpass] [database name ] [db file] 
- -R [mysql rootpass] [database name ] [old web address] [new web address]

   TODO: install user wordpress files
