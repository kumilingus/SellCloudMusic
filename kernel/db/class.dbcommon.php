<?php

require_once("class.dblayer.php");
require_once("./kernel/class.entity.php");
require_once("./kernel/class.elist.php");

define('DBC_FLG_NODB', 0x100);
define('DBC_FLG_KEY', 0x200);
define('DBC_FLG_NULL', 0x400);

class dbCommon extends dbConnection {

    const LABEL_TABLE = '__TBL';
    const QUERY_INSERT = "INSERT INTO %s (%s) VALUES (%s)";
    const QUERY_UPDATE = "UPDATE %s SET %s WHERE %s = %s";
    const QUERY_SELECT = "SELECT %s FROM %s WHERE %s";
    const QUERY_DELETE = "DELETE FROM %s WHERE %s";
    const QUERY_CONJUCTION = " AND ";
    const QUERY_DISJUCTION = " OR ";
    const QUERY_NULL = "NULL";
    const QUERY_PAIR = "%s = %s";
    const SEQUENCE_NAME = "%s_%s_seq";

    public function __construct() {
        parent::__construct(Config::_('dsn'));
    }

    private function nt_in(& $entity) {
        //before insert
        $e1 = $entity->beforeInsert();
        if ($e1 instanceof ntError)
            return $e1;
        
        if ($this->transactionsEnabled)
            $this->beginTransaction();
        //get entity slots
        $vars = $this->get_nt_vars($entity);
        //remove ID column from query
        unset($vars[$entity->getGlobalData(Entity::LABEL_ID)]);
        //build query
        $q = @sprintf(self::QUERY_INSERT, $entity->getGlobalData(self::LABEL_TABLE), //table name
                        @implode(@array_keys($vars), ','), //columns
                        @implode(@array_values($vars), ',')); //values
        //rows affected  
        $raff = $this->exec($q);
        if ($raff instanceof dbError) {
            if ($this->transactionsEnabled)
                $this->rollBack();
            return $raff;
        }
        //set ID to the entity object
        $entity->setID($this->lastInsertID(sprintf(self::SEQUENCE_NAME, $entity->getGlobalData(self::LABEL_TABLE), $entity->getGlobalData(Entity::LABEL_ID))));

        //after insert
        $e2 = $entity->afterInsert();
        if ($e2 instanceof ntError) {
            if ($this->transactionsEnabled)
                $this->rollBack();
            return $e2;
        }

        if ($this->transactionsEnabled)
            $this->commit();
        //returns number of affected rows        
        return $raff;
    }

    private function nt_up(& $entity) {

        //before update
        $e = $entity->beforeUpdate();
        if ($e instanceof ntError)
            return $e;

        $this->beginTransaction();
        //get entity slots
        $vars = $this->get_nt_vars($entity);
        //change slots value into a string pair

        @array_walk($vars, function (& $val, $key) {
                            $val = @sprintf(dbCommon::QUERY_PAIR, $key, $val);
                        });

        //build query
        $q = @sprintf(self::QUERY_UPDATE, $entity->getGlobalData(self::LABEL_TABLE), //table name
                        @implode($vars, ','), //pairs
                        $entity->getGlobalData(Entity::LABEL_ID), //id column name
                        $entity->getID()); //id value

        $raff = $this->exec($q);

        //after update
        $e = $entity->afterUpdate();
        if ($e instanceof ntError) {
            $this->rollBack();
            return $e;
        }

        if (!($raff instanceof dbError))
            $this->commit();

        //return number of rows affected
        return $raff;
    }

    public function saveEntity(& $param) {
        if ($param instanceof Entity) {
            if ($param->getID() > 0) {
                $param->setStatus(Entity::STATUS_UPD);
                return $this->nt_up($param);
            } else {
                $param->setStatus(Entity::STATUS_INS);
                return $this->nt_in($param);
            }
        }
        return -1;
    }

    public function loadEntity(& $param) {
        if ($param instanceof Entity && $param->getID() > 0) {
            $e = $param->beforeLoad();
            if ($e instanceof ntError)
                return $e;
            $param->setStatus(Entity::STATUS_SET);
            //build a select query
            $q = sprintf(self::QUERY_SELECT, '*', $param->getGlobalData(self::LABEL_TABLE), sprintf(self::QUERY_PAIR, $param->getGlobalData(Entity::LABEL_ID), $param->getID()));
            //run query and save result into a param
            $a = $this->query($q)->fetch(PDO::FETCH_ASSOC);
            if ($a) {
                $param->loadArray($a);
                $e = $param->afterLoad();
                if ($e instanceof ntError)
                    return $e;
            }
            return $a;
        }
        return -1;
    }

    public function deleteEntity(& $param) {
        if ($param instanceof Entity && $param->getID() > 0) {
            $param->setStatus(Entity::STATUS_DEL);
            //build a delete query
            $q = sprintf(self::QUERY_DELETE, $param->getGlobalData(self::LABEL_TABLE), sprintf(self::QUERY_PAIR, $param->getGlobalData(Entity::LABEL_ID), $param->getID()));
            //return number of rows affected
            return $this->exec($q);
        }
    }

    public function findEntity(& $param) {
        if ($param instanceof Entity && $param->getID() == 0) {

            $e1 = $param->beforeFind();
            if ($e1 instanceof ntError) {
                return $e1;
            }
            $param->setStatus(Entity::STATUS_SET);
            //get entity slots
            $vars = $this->get_nt_vars($param, DBC_FLG_KEY);
            //change slots value into a string pair
            @array_walk($vars, function (& $val, $key) {
                                $val = @sprintf(dbCommon::QUERY_PAIR, $key, $val);
                            });
            $q = sprintf(self::QUERY_SELECT, '*', $param->getGlobalData(self::LABEL_TABLE), @implode(@array_values($vars), self::QUERY_CONJUCTION));

            $r = $this->query($q)->fetch(PDO::FETCH_ASSOC);

            if ($r instanceof dbError) {
                return $r;
            }

            $param->loadArray($r);

            if ($r) {
                $e2 = $param->afterFind();
                if ($e2 instanceof ntError) { return $e2; }
            }
            
            return $r;
        }
        return 0;
    }


    public function loadEList(& $list, $param = array()) {
        if ($list instanceof EList) {

            $entity = $list->allocate();

            $q = sprintf(self::QUERY_SELECT, '*', $entity->getGlobalData(self::LABEL_TABLE), $this->strip_params($param, @get_class($entity)));

            $r = $this->query($q);

            $a = null;
            while ($a = $r->fetch(PDO::FETCH_ASSOC)) {
                $entity->beforeLoad();
                $entity->loadArray($a);
                $entity->afterLoad();
                $entity = $list->allocate();
            }

            $list->deallocate();
        }
    }

    private function strip_params($params, $class) {
        $r = 'true' . self::QUERY_CONJUCTION;
        foreach ($params as $ukey => $val) {

            // allow user to set a range of values
            // for example param@1=@lX, param@2=@gY
            // eguals: X > param < Y
            $key = preg_replace('/@[0-9]/', '', $ukey);
                    
            if (property_exists($class, $key)) {
                $op = ' = ';
                if (!strncmp($val, '@g', 2))
                    $op = ' > ';
                elseif (!strncmp($val, '@l', 2))
                    $op = ' < ';

                $t = $val;
                if (strcmp($op, ' = '))
                    $t = substr($val, 2);

                $r .= $key . $op . $this->quote($t) . self::QUERY_CONJUCTION;
            }
        }
        return substr($r, 0, strlen($r) - strlen(self::QUERY_CONJUCTION));
    }

    /**
     * quotes , escapes and filters null values from entity variables
     * @access private
     * @param  an entity object
     * @return array of not null variables
     * */
    private function get_nt_vars(& $entity, $flag = 0x00) {
        // get entity vars
        $vars = array();

        foreach(@get_object_vars($entity) as $key => $val) {
	  if (@isset($val) &&
	      !$entity->isFlagged($key, DBC_FLG_NODB) &&
	      $entity->isFlagged($key, $flag)) {
	    $vars[$key] = $this->quote($val);
          } elseif ($entity->isFlagged($key, DBC_FLG_NULL)) {
	    $vars[$key] = NULL;
          }
	}

        // escape values
        ///$vars = @array_map(array($this,'escape'),$vars);
        // quote values
	// $vars = @array_map(array($this, 'quote'), $vars);
        return $vars;
    }

}

?>