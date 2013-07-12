<?php

require_once('./kernel/class.entity.php');
require_once('./kernel/db/class.dbcommon.php');
require_once('./kernel/class.elist.php');

class Items extends Elist {

    const QUERY_SELECT = 'SELECT * FROM items WHERE id_order = %s';

    public function __construct() {
        parent::__construct('item');
    }
    
}

class Item extends Entity {

    public $id_item;
    public $id_order;
    public $item_name;
    public $item_number;
    public $mc_gross_;

    public function __construct() {
        $this->setGlobalData(Entity::LABEL_ID, 'id_item');
        $this->setGlobalData(Entity::LABEL_ACCESS, 'none');
        $this->setGlobalData(dbCommon::LABEL_TABLE, 'items');
    }

}

class Order extends Entity {

    const NUMBER_ITEMS = 'num_cart_items';

    public $id_order;
    public $id_user;
    public $txn_id;
    public $timestamp;
    public $items;

    public function __construct() {
        $this->setGlobalData(Entity::LABEL_ID, 'id_order');
        $this->setGlobalData(Entity::LABEL_ACCESS, 'privileged');
        $this->setGlobalData(dbCommon::LABEL_TABLE, 'orders');
        $this->setFlags('items', DBC_FLG_NODB);
        //inicialization
        $this->items = new Items();
    }

    public function loadArray(&$param, $postfix ='') {
        if (@array_key_exists(self::NUMBER_ITEMS, $param)) {
            for ($i = 1; $i <= $param[self::NUMBER_ITEMS]; $i++) {
                $item = new Item();
                $this->items->add($item->loadArray($param, $i));
            }
        }
        parent::loadArray($param);
    }

    public function afterLoad() {
        $conn = new dbCommon();
        $r = $conn->query(sprintf(Items::QUERY_SELECT, $conn->quote($this->id_order)));
        if ($r instanceof dbError) {
            return new ntError("Can not load items from database.");
        } else {
            foreach ($r->fetchAll(PDO::FETCH_CLASS, 'Item') as $item) {
                $this->items->add($item);
            }
        }
    }

    public function beforeInsert() {
        // Avoid manual setting of timestamp. Value must be always time when
        // the order is created.
        unset($this->timestamp);
    }

    public function beforeUpdate() {
        $this->beforeInsert();
    }

    public function afterInsert() {
        $conn = new dbCommon();
        $conn->transactionsEnabled = false;
        foreach ($this->items as $item) {
            $item->id_order = $this->id_order;
            if ($conn->saveEntity($item) instanceof dbError) {
                return new ntError("Item insertion failed.");
            }
        }
    }

}

?>
