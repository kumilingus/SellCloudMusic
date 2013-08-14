<?php

define('FRM_LBL_NAME', '%s-form');
define('FRM_LBL_TOKEN', 'token');

define('FRM_STAT_ERR', 'errors');

define('FRM_DFLT_METHOD', 'post');
define('FRM_DFLT_ENCTYPE', 'multipart/form-data');

// Metadata restrictions flags
define('FRM_NO_FLAG', 0x00);
define('FRM_NOT_MT', 0x01);
define('FRM_FLG_EMAIL', 0x02);
define('FRM_FLG_PWD', 0x04);
define('FRM_FLG_TOKEN', 0x08);
define('FRM_FLG_MATCH', 0x10);
define('FRM_FLG_NUMBER', 0x20);

class Errors extends Transformer {

    public function exist() {
        return count(get_object_vars($this)) > 0;
    }

}

class Form extends Transformer {

    const SESSION = "form-data";
    const XSL = 'xsl/frm.%s.xsl';

// Flag & function table contains validation functions
    static private $__FFExe = array();
    static private $__FFMsg = array(
        FRM_NO_FLAG => "",
        FRM_NOT_MT => "Mandotory field.",
        FRM_FLG_EMAIL => "Invalid email address.",
        FRM_FLG_PWD => "Password is not strong enough.",
        FRM_FLG_TOKEN => "Form was already sent.",
        FRM_FLG_MATCH => "Fields don't match.",
        FRM_FLG_NUMBER => "Value must be a number.",
    );
    public $entity;
    public $errors;
    public $status;
    public $name;
    public $action;
    public $xsheet = null;
    public $method = FRM_DFLT_METHOD;
    public $enctype = FRM_DFLT_ENCTYPE;

    public function __construct(& $entity, $params = array()) {

        $this->entity = & $entity;
        $this->errors = new Errors();

        $defaults = array(
            "name" => sprintf(FRM_LBL_NAME, $entity),
            "action" => $_SERVER['REQUEST_URI']
        );

        parent::__construct($params + $defaults);

        //token
        $entity->{FRM_LBL_TOKEN} = null;
        $entity->setFlags(FRM_LBL_TOKEN, DBC_FLG_NODB | FRM_FLG_TOKEN);

        $this->status = $entity->getStatus();

        if (count(Form::$__FFExe) == 0) {

            Form::setFlagAndFunction(FRM_FLG_TOKEN, function($p, $t) {
                        $token = $_SESSION[Form::SESSION][$t->name];
                        unset($_SESSION[Form::SESSION][$t->name]);
                        return $token == $p;
                    });

            Form::setFlagAndFunction(FRM_NOT_MT, function($p, $t) {
                        return !empty($p);
                    });

            Form::setFlagAndFunction(FRM_FLG_EMAIL, function ($p, $t) {
                        return preg_match("/^[[:alnum:]][a-z0-9_.-]*@[a-z0-9.-]+\.[a-z]{2,4}$/i", $p);
                    });

            Form::setFlagAndFunction(FRM_FLG_NUMBER, function($p, $t) {
                        return is_numeric($p);
                    });

            Form::setFlagAndFunction(FRM_FLG_PWD, function($p, $t) {
                        return strlen($p) > 7 && preg_match("#[0-9]+#", $p) && preg_match("#[a-zA-Z]+#", $p);
                    });

            Form::setFlagAndFunction(FRM_FLG_MATCH, function($p, $t) {
                        static $record;
                        if (!@isset($record)) {
                            $record = $p;
                            return true;
                        }
                        $result = ($record == $p);
                        unset($record);
                        return $result;
                    });
        }
    }

    public function generateToken() {

        if (!@isset($_SESSION))
            trigger_error("Session doesn't exists.", E_USER_NOTICE);

        $token = @substr(@md5(@time() + @rand()), 0, 10);
        $this->entity->{FRM_LBL_TOKEN} = $token;
        $_SESSION[Form::SESSION][$this->name] = $token;
    }

    /**
     * run predicates through any slot value
     * @access public
     * @param  slot name
     * @return flag number when validation fails , 0 when filtred
     * */
    public function filterSlot($var) {

        $first_flag = 0;
        $res = 0;
        $SMD = $this->entity->getFlags($var);
        reset(self::$__FFExe);
        while ($flag = @key(self::$__FFExe)) {
            if ($SMD & $flag) {
                if (!@call_user_func(self::$__FFExe[$flag], $this->entity->$var, $this)) {
                    if ($first_flag == 0)
                        $first_flag = $flag;
                    $res |= $flag;
                }
            }
            @next(self::$__FFExe);
        }
        if ($res > 0) {
            $this->errors->$var = self::$__FFMsg[$first_flag];
        }
        return $res;
    }

    /**
     * @access public
     * @param  none
     * @return
     * */
    public function dataFiltred() {

        $res = false;
        foreach (@get_object_vars($this->entity) as $key => $val) {
            $res |= (bool) $this->filterSlot($key);
        }
        $this->updateStatus();
        return !$res;
    }

    public function updateStatus() {
        $this->prev_status = $this->entity->getStatus();
        if ($this->errors->exist()) {
            $this->status = FRM_STAT_ERR;
        } else {
            $this->status = $this->prev_status;
        }
    }

    public function data() {
        return $this->entity;
    }

    static public function setFlagAndFunction($flag, $function) {

        //is $flag a power of two
        if (($flag & ($flag - 1)) == 0) {
            Form::$__FFExe[$flag] = $function;
        } else
            trigger_error(sprintf("[%s] : An ambiguous flag value.", $flag), E_USER_NOTICE);
    }

    public function getXSL() {
        if ($this->xsheet) {
            return $this->xsheet;
        } else {
            return sprintf(self::XSL, $this->entity);
        }
    }

    public function toHTML() {
        $this->generateToken();
        $doc = new DOMDocument();

        $xslfile = $this->getXSL();
        if (!file_exists($xslfile)) {
            return "No stylesheet associated";
        }

	$doc->load($xslfile);
        $xs = new XSLTProcessor();
        $xs->importStyleSheet($doc);
        return $xs->transformToXML($this->toDOM());
    }

    public function toXML() {
        $this->generateToken();
        return parent::toXML();
    }

}

?>