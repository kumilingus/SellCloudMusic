<?php

require_once('./kernel/class.elist.php');
require_once('./src/ent.global.php');
require_once('./src/ent.order.php');

class TrackList extends EList {
    
    public function __construct() {
        parent::__construct('track');
    }
}

class TrackviewList extends EList {
    
    public function __construct() {
        parent::__construct('trackview');
    }    
}

class OrderList extends EList {
    
    public function __construct() {
        parent::__construct('order');
    }
}

?>
