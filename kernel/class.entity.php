<?php

require_once('kernel/class.transformer.php');

define('ENT_NO_FLAG', 0x00);
define('ENT_FLG_SAFE', 0x40);

define('SLOT_FLAG', 0);
define('SLOT_DATA', 1);

class NTError {

    public $message;
    public $slot;

    public function __construct($msg, $slot = 'default') {
        $this->message = $msg;
        $this->slot = strtolower($slot);
    }

}

/**
 * @package  ?
 * @version  1.0
 * @author   Roman Bruckner
 * @license  ?
 * @access   ?
 * @php      5.1 or higher 
 * */
abstract class Entity extends Transformer implements Serializable {

    const STATUS_NEW = 'new';
    const STATUS_UPD = 'update';
    const STATUS_INS = 'insert';
    const STATUS_DEL = 'delete';
    const STATUS_SET = 'load';
    const LABEL_ID = '__IDN';
    const LABEL_STATUS = '__STATUS';
    const LABEL_ACCESS = '__ACCESS';

// general metadata
    private $__GMData = array(
        self::LABEL_ID => 'id',
        self::LABEL_STATUS => self::STATUS_NEW
    );
// slots metadata 
    private $__SMData = array();

//SLOT_FLAG => array(),SLOT_DATA => array());

    /**
     * deteminates whether a selected slot is an private variable.
     * @access private
     * @param  slot
     * @return boolean
     * */
    private function is_public($var) {

        return @ctype_alnum(@substr($var, 0, 2));
    }

    /**
     * fills object vars from an assocciative array
     * @access public
     * @param  an array
     * @return instance of this class
     * */
    public function loadArray(& $param, $postfix = '') {

        $vars = @get_object_vars($this);
        while ($key = @key($vars)) {
            // eliminates private variables (starting with '__'). Fixing scoping behaviour.	
            if ($this->is_public($key) && @isset($param[$key . $postfix]) && !@empty($param[$key . $postfix])) {
                $this->$key = $param[$key . $postfix];
            }
            @next($vars);
        }
        $this->setStatus(self::STATUS_SET);
        return $this;
    }

    /**
     * fills object vars from an object
     * @access public
     * @param  an object
     * @return instance of this class
     * */
    public function loadObject(& $param) {

        $vars = @get_object_vars($this);
        $inputs = @get_object_vars($param);
        while ($key = @key($vars)) {
            // eliminates private variables (starting with '__'). Fixing scoping behaviour.	
            if ($this->is_public($key) && @property_exists($param, $key))
                $this->$key = $inputs[$key];
            @next($vars);
        }
        $this->setStatus(self::STATUS_SET);
        return $this;
    }

    /**
     * returns a selected general metadata
     * @access public
     * @param  string , object
     * @return none
     * */
    public function setGlobalData($key, $val) {

        if (@isset($val)) {
            $this->__GMData[$key] = $val;
        } else {
            unset($this->__GMData[$key]);
        }
    }

    /**
     * sets data up in the slots metadata
     * @access public
     * @param  string
     * @return none
     * */
    public function setSlotData($nvar, $data) {

        if (@property_exists($this, $nvar) && $this->is_public($nvar)) {
            $this->__SMData[$nvar][SLOT_DATA] = $data;
        }
    }

    /**
     * adds data into the slots metadata
     * @access public
     * @param  string
     * @return none
     * */
    public function addSlotData($nvar, $label, $value) {

        if (@property_exists($this, $nvar) && $this->is_public($nvar)) {
            $this->__SMData[$nvar][SLOT_DATA][$label] = $value;
        }
    }

    /**
     * @access public
     * @param  string
     * @return none
     * */
    public function setFlags($nvar, $flg) {

        if (@property_exists($this, $nvar) && $this->is_public($nvar)) {
            $this->__SMData[$nvar][SLOT_FLAG] = $flg;
        }
    }

    /**
     * @access public
     * @param  string
     * @return none
     * */
    public function addFlags($nvar, $flg) {

        if (@property_exists($this, $nvar) && $this->is_public($nvar)) {
            $this->__SMData[$nvar][SLOT_FLAG] |= $flg;
        }
    }

    /**
     * returns a selected general metadata
     * @access public
     * @param  string
     * @return object
     * */
    public function getGlobalData($key) {

        if (@array_key_exists($key, $this->__GMData)) {
            return $this->__GMData[$key];
        }
    }

    /**
     * returns metadata of a selected slot
     * @access public
     * @param  string
     * @return object
     * */
    public function getSlotData($key) {

        if (@isset($this->__SMData[$key][SLOT_DATA])) {
            return $this->__SMData[$key][SLOT_DATA];
        }

        return null;
    }

    /**
     * returns metadata of a selected slot
     * @access public
     * @param  string
     * @return object
     * */
    public function getFlags($key) {

        if (@isset($this->__SMData[$key][SLOT_FLAG])) {

            return $this->__SMData[$key][SLOT_FLAG];
        }

        return 0;
    }

    /**
     * fills the id slot with param
     * @access public
     * @param  string | integer
     * @return none
     * */
    public function setID($param) {

        $this->{$this->__GMData[self::LABEL_ID]} = $param;
    }

    /**
     * returns a value of the id slot
     * @access public
     * @param  none
     * @return object
     * */
    public function getID() {

        if (@property_exists($this, $this->__GMData[self::LABEL_ID])) {
            return (int) $this->{$this->__GMData[self::LABEL_ID]};
        }
        return 0;
    }

    public function setStatus($param) {
        $this->__GMData[self::LABEL_STATUS] = $param;
    }

    public function getStatus() {
        return $this->__GMData[self::LABEL_STATUS];
    }

    /**
     * returns true whether is a choosen slot flagged with param flag
     * @access public
     * @param  string,int
     * @return boolean
     * */
    public function isFlagged($var, $flag) {

        return ($this->getFlags($var) & $flag) == $flag;
    }

//serializing
    public function serialize() {
        return serialize(get_object_vars($this));
    }

    public function unserialize($data) {
        foreach (unserialize($data) as $var => $value) {
            $this->$var = $value;
        }
    }

    public function clear($flag = ENT_NO_FLAG) {
        $vars = @get_object_vars($this);
        while ($key = @key($vars)) {
            if ($this->is_public($key) && $this->isFlagged($key, $flag)) {
                $this->$key = "";
            }
            @next($vars);
        }
    }

    public function safe() {
        $this->clear(ENT_FLG_SAFE);
    }

    //TODO: allow stack entities with store
    public function store() {
        $_SESSION[@get_called_class()] = serialize($this);
    }

    public static function restore() {
        $nt = @get_called_class();
        if (@isset($_SESSION[$nt])) {
            return unserialize($_SESSION[$nt]);
        } else {
            return (new $nt());
        }
    }

    public static function isStored() {
        return @isset($_SESSION[@get_called_class()]);
    }

    public static function clearStored() {
        unset($_SESSION[@get_called_class()]);
    }

    public function __toString() {
        return @strtolower(@get_class($this));
    }

    public function beforeInsert() {
        
    }

    public function afterInsert() {
        
    }

    public function beforeUpdate() {
        
    }

    public function afterUpdate() {
        
    }

    public function beforeLoad() {
        
    }

    public function afterLoad() {
        
    }

    public function beforeFind() {
        
    }

    public function afterFind() {
        
    }

    public function beforeDelete() {

    }
}

?>