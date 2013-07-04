<?php

require_once('./kernel/class.entity.php');
require_once('./kernel/db/class.dblayer.php');
require_once('./src/soundcloud.php');

/**
 * @package  ?
 * @version  1.0
 * @author   Roman Bruckner
 * @license  ?
 * @access   public
 * @php      5.1 or higher 
 * */
class Slot extends Transformer {

    private $_name = __CLASS__;

    public function __construct($name, $param = array()) {
        $this->_name = $name;
        parent::__construct($param);
    }

    public function __toString() {
        return $this->_name;
    }

}

class TrackView extends Entity {

    public $id_track;
    public $price;
    public $exclusive = 1;
    public $id_user;
    public $id_soundcloud;

    public function __construct() {
        $this->setGlobalData(Entity::LABEL_ID, 'id_track');
        $this->setGlobalData(Entity::LABEL_ACCESS, 'public');
        $this->setGlobalData(dbCommon::LABEL_TABLE, 'tracks');
        $this->setFlags('price', FRM_FLG_NUMBER | FRM_NOT_MT);
        $this->setFlags('exclusive', FRM_NO_FLAG);        
    }

    public function afterLoad() {
        if (!is_subclass_of($this, __CLASS__)) {
            $soundcloud = Soundcloud::getInstance();
            try {
                $r = json_decode($soundcloud->get('tracks/' . $this->id_soundcloud));
                $this->s0 = new Slot('user', $r->user);
                unset($r->user);
                $this->s1 = new Slot('track', $r);
            } catch (Exception $e) {
                return new ntError($e->getMessage());
            }
        }
    }

}

class Track extends TrackView {

    public $count_orders = 0;

    public function __construct() {
        parent::__construct();
        $this->setFlags('count_orders', DBC_FLG_NODB);
    }

    public function beforeInsert() {
        $soundcloud = Soundcloud::getInstance();
        try {
            $r = json_decode($soundcloud->get('me/tracks/' . $this->id_soundcloud));
            // if download counts > 0 then can't be exclusive 
            if ($this->exclusive > 1 && $r->download_count > 0) {
                return new ntError('Track has been already downloaded. Can not be imported as "exclusive"', 'exclusive');
            }
        } catch (Exception $e) {
            return new ntError($e->getMessage());
        }
    }

    public function afterInsert() {
        $soundcloud = Soundcloud::getInstance();
        $shopping_url = Config::_('shopping-url') . $this->id_track;
        try {
            $soundcloud->put('tracks/' . $this->id_soundcloud, array(
                "track[downloadable]" => false,
                "track[purchase_url]" => $shopping_url
            ));
        } catch (Exception $e) {
            return new ntError($e->getMessage());
        }
        $this->shopping_url = $shopping_url;
    }

    public function beforeUpdate() {
        if ($this->exclusive > 1 && $this->count_orders > 0) {
            return new ntError('Track has been already sold and is marked down as exlusive. Can not be changed now.', 'exclusive');
        }
        return $this->beforeInsert();
    }

}

class Login extends Entity {

    const IN = 'login';
    const OUT = 'logout';
    const CRYPT_METHOD = '$2a$07$%s$';
    const USER_DOESNT_EXIST = "User or password don't match our records.";

    public $password;
    public $email;
    public $type = self::IN;

    public function __construct() {
        $this->setGlobalData(Entity::LABEL_ACCESS, 'none');
        $this->setFlags('email', FRM_NOT_MT | FRM_FLG_EMAIL);
        $this->setFlags('password', FRM_NOT_MT | FRM_FLG_PWD);
        $this->setFlags('type', DBC_FLG_NODB);
    }

    public function __toString() {
        return $this->type;
    }

}

class User extends Login {

    const SESSION = 'user_data';

    public $id_user;
    public $id_soundcloud;
    public $soundcloud_oauth_token;
    public $soundcloud_username;
    public $password_re;
    public $track_count = 0;
    public $paypal_email;

    public function __construct($type = __CLASS__) {
        parent::__construct();
        $this->type = @strtolower($type);
        $this->setGlobalData(Entity::LABEL_ID, 'id_user');
        $this->setGlobalData(Entity::LABEL_ACCESS, 'privileged');
        $this->setGlobalData(dbCommon::LABEL_TABLE, 'users');
        $this->setFlags('password_re', FRM_NOT_MT | FRM_FLG_PWD | FRM_FLG_MATCH | DBC_FLG_NODB);
        $this->addFlags('password', FRM_FLG_MATCH | DBC_FLG_KEY);
        $this->addFlags('email', DBC_FLG_KEY);
        $this->setFlags('paypal_email', FRM_NOT_MT | FRM_FLG_EMAIL);
        $this->setFlags('soundcloud_username', DBC_FLG_NODB);
        $this->setFlags('track_count', DBC_FLG_NODB);
    }

    protected function hsh_pwd() {
        $this->password = hash('ripemd160', $this->password);
    }

    public function beforeInsert() {

        $soundcloud = Soundcloud::getInstance($this->soundcloud_oauth_token);
        try {
            $r = json_decode($soundcloud->get('me'));
            $this->id_soundcloud = $r->id;
        } catch (Exception $e) {
            return new ntError($e->getMessage(), 'soundcloud');
        }

        $this->hsh_pwd();
    }

    public function beforeUpdate() {
        $this->beforeInsert();
    }

    public function afterLoad() {
        return $this->get_via_sc(Soundcloud::getInstance());
    }

    public function beforeFind() {
        $this->hsh_pwd();
    }

    public function afterFind() {
        return $this->get_via_sc(Soundcloud::getInstance($this->soundcloud_oauth_token));
    }

    private function get_via_sc($soundcloud) {
        try {
            $r = json_decode($soundcloud->get('me'));
            $this->soundcloud_username = $r->username;
            $this->track_count = $r->track_count;
        } catch (Exception $e) {
            return new ntError($e->getMessage());
        }
    }

}

?>