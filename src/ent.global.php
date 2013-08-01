<?php

require_once('./kernel/class.entity.php');
require_once('./kernel/class.form.php');
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

class TrackView extends Track {

    public function __construct() {
        parent::__construct();
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
                return new NTError($e->getMessage());
            }
        }
    }

}

class Track extends Entity {

    public $id_track;
    public $price;
    public $exclusive = 1;
    public $id_user;
    public $id_soundcloud;
    public $count_orders = 0;

    public function __construct() {
        $this->setGlobalData(Entity::LABEL_ID, 'id_track');
        $this->setGlobalData(Entity::LABEL_ACCESS, 'public');
        $this->setGlobalData(DBCommon::LABEL_TABLE, 'tracks');
        $this->setFlags('price', FRM_FLG_NUMBER | FRM_NOT_MT);
        $this->setFlags('exclusive', FRM_NO_FLAG);
        $this->setFlags('count_orders', DBC_FLG_NODB);
    }

    public function beforeInsert() {
        $soundcloud = Soundcloud::getInstance();
        try {
            $r = json_decode($soundcloud->get('me/tracks/' . $this->id_soundcloud));
            if ($this->exclusive < 2)
                return new NTError('Not available in BETA', 'exclusive');
            // if download counts > 0 then can't be exclusive 
            if ($this->exclusive > 1 && $r->download_count > 0) {
                return new NTError('Track has been already downloaded. Can not be imported as "exclusive"', 'exclusive');
            }
        } catch (Exception $e) {
            return new NTError($e->getMessage());
        }
    }

    public function afterInsert() {
        $soundcloud = Soundcloud::getInstance();
        $shopping_url = Config::_('shopping-url') . $this->id_track;
        try {
            $soundcloud->put('tracks/' . $this->id_soundcloud, array(
                "track[downloadable]" => false,
                "track[streamable]" => true,
                "track[sharing]" => "public",
                "track[purchase_url]" => $shopping_url
            ));
        } catch (Exception $e) {
            return new NTError($e->getMessage());
        }
        $this->shopping_url = $shopping_url;
    }

    public function beforeDelete() {
        $soundcloud = Soundcloud::getInstance();
        try {
            $soundcloud->put('tracks/' . $this->id_soundcloud, array(
                "track[purchase_url]" => ''
            ));
        } catch (Exception $e) {
            return new NTError($e->getMessage());
        }
    }

    public function beforeUpdate() {
        if ($this->exclusive < 2)
            return new NTError('Not available in BETA', 'exclusive');
        if ($this->exclusive > 1 && $this->count_orders > 0) {
            return new NTError('Track has been already sold and is marked down as exlusive. Can not be changed now.', 'exclusive');
        }
        return $this->beforeInsert();
    }

    public function isSoldOut() {
        return $this->count_orders > 0 && $this->exclusive == 2;
    }
}

// Password request (forgotten password)
class Pwdreq extends Entity {

    const TOKEN_LIFETIME = 1800; // 30 Minutes
    const EMAIL_DOESNT_EXIST = "Email doesn't match our records.";
    const EMAIL_SUBJECT = "Password reset";
    const EMAIL_BODY = <<<BODY
Hi,
you have requested changing your password. Please click the link
bellow to reset it.

%s
BODY;

    public $id_user;
    public $email;
    public $pwd_reset_token;
    public $pwd_reset_timestamp;

    public function __construct() {
        $this->setGlobalData(Entity::LABEL_ACCESS, 'none');
        $this->setGlobalData(DBCommon::LABEL_TABLE, 'users');
        $this->setGlobalData(Entity::LABEL_ID, 'id_user');
        $this->setFlags('email', FRM_NOT_MT | FRM_FLG_EMAIL);
    }

    public function beforeUpdate() {
        $this->pwd_reset_timestamp = time();
        $this->pwd_reset_token = uniqid('', true);
    }

    public function afterFind() {
        if ((time() - $this->pwd_reset_timestamp) > Pwdreq::TOKEN_LIFETIME) {
            return new NTError('Token has expired.');
        }
    }

}

class Pwdchng extends Entity {

    public $password;
    public $password_re;

    public function __construct() {
        $this->setFlags('password', FRM_NOT_MT | FRM_FLG_PWD | FRM_FLG_MATCH);
        $this->setFlags('password_re', FRM_NOT_MT | FRM_FLG_PWD | FRM_FLG_MATCH | DBC_FLG_NODB);
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
    //addresss
    public $address_company_name;
    public $address_number_street;
    public $address_town;
    public $address_zip;

    public function __construct($type = __CLASS__) {
        parent::__construct();
        $this->type = @strtolower($type);
        $this->setGlobalData(Entity::LABEL_ID, 'id_user');
        $this->setGlobalData(Entity::LABEL_ACCESS, 'privileged');
        $this->setGlobalData(DBCommon::LABEL_TABLE, 'users');
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
            return new NTError($e->getMessage(), 'soundcloud');
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
            return new NTError($e->getMessage());
        }
    }

}

?>