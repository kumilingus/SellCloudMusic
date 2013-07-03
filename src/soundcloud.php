<?php

require_once('./src/ent.global.php');
require_once('./lib/soundcloud/Soundcloud.php');

class Soundcloud {

    public static $access_token_function;
    private static $soundcloud = null;

    private function __construct() {
        
    }

    public static function getInstance($oauth2 = null) {

        if (!@isset(self::$soundcloud)) {
            try {
                self::$soundcloud = new Services_Soundcloud(
                                Config::_('client-id'),
                                Config::_('client-secret'),
                                Config::_('redirect-uri')
                );
            } catch (Exception $e) {
                
            }
        }

        if (!$oauth2) {
            $oauth2 = call_user_func(self::$access_token_function);
        }

        self::$soundcloud->setAccessToken($oauth2);

        return self::$soundcloud;
    }

}

?>
