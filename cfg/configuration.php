<?php

//Configuration class
class Config {

    const FILE_NAME = "./cfg/config.ini";
    const TTL = 30;

    private static $__conf = null;

    public static function _($key) {

        if (!@isset(self::$__conf)) {
            $r = false;
            if (function_exists('apc_fetch')) {
//                self::$__conf = apc_fetch(__CLASS__, $r);
            }
            if (!$r) {
                try {
                    self::$__conf = parse_ini_file(self::FILE_NAME);
                    if (function_exists('apc_store')) {
                        apc_store(__CLASS__, self::$__conf, self::TTL);
                    }
                } catch (Exception $e) {
                    //TODO: error page / configuration can't be load
                    die($e);
                }
            }
        }
        if (@array_key_exists($key, self::$__conf)) {
            return self::$__conf[$key];
        } else {
            //TODO: exception
            die("configuration option doesn't exist");
        }
    }

}

//Soundcloud access token function
if (class_exists('Soundcloud') && class_exists('User')) {

    Soundcloud::$access_token_function = function() {
                return User::restore()->soundcloud_oauth_token;
            };
}
?>
