#!/bin/bash

CMD=`lynx -dump -dont_wrap_pre https://api.wordpress.org/secret-key/1.1/salt/`

LINE=`grep -n 'wp-config-sample.php' -e "define( 'AUTH_KEY'"| cut -d: -f 1`
echo $LINE


sed -i /_SALT/d wp-config-sample.php
sed -i /_KEY/d wp-config-sample.php
echo $CMD | sed -i -- "${LINE}r /dev/stdin" wp-config-sample.php

