<?php
define('AUTH_KEY', '-6gbVl=R;32~KhQxzzg}+4{&F]hG K]$=k!_#|(zH|Cc#G}aUPCMJy<Q:{c-}8$@'); define('SECURE_AUTH_KEY', 'qZ-IcR4G*/gA|DgY.lgAE@759[:VK5)FF)p10$9k[4[`qk{{q>/sfH*vJ_`T1@hZ'); define('LOGGED_IN_KEY', 'ncw@Sz?J$#@p(H.vk(5!`Eyy?U`{2{36eYn!L5M=4:$dR>pb/b/{7]M@N6+D{]|F'); define('NONCE_KEY', 'AVD!4b+LP/LO5a.X5o4=gA6FwWcuETyj-IqH;a8]~!Wqh|f%M`zL<Ko;t;-r7/1-'); define('AUTH_SALT', 'Xyp,R(+]F/$Yd8FPoH+-sfG926%#${FnLFAt-<q|+=(oj|MACxnb@[|zOR{$Js%q'); define('SECURE_AUTH_SALT', '3mSS&bDvmw.)7%!S%QYZ[WWq90]@gr&Qtk-Rx++{+SyI]^CPmjZGlX#,P0Ngu*L/'); define('LOGGED_IN_SALT', '.V|}rw^1jNQ6lr-Y Rq<zxw>-+o0{]GIfAyguID6U}-4? N/!/HDHDTBy**v5?<f'); define('NONCE_SALT', '><X7FCV[OSYOxOwL+d<]9dFhSH>YW0h=-Z)c3W@~t qu1UE+}t5b%YdyzFYjog*.');
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'gmentalc_user' );

/** Database password */
define( 'DB_PASSWORD', 'D-wp729' );

/** Database hostname */
define( 'DB_HOST', 'localhost' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
