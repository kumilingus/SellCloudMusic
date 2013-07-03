<?php

require_once('./kernel/class.entity.php');

abstract class Elist extends Transformer implements Iterator {

    private $counter = 0;
    private $position = 0;
    private $slot = null;

    public function __construct($slot) {
        $this->slot = $slot;
    }
            
    function add($entity) {
        $this->{$this->slot . '_' . $this->counter++} = $entity;
    }

    function rewind() {
        $this->position = 0;
    }

    function next() {
        ++$this->position;
    }

    function valid() {
        return isset($this->{$this->key()});
    }

    function current() {
        return $this->{$this->key()};
    }

    function key() {
        return $this->slot . '_' . $this->position;
    }

    function allocate() {
        $alias = $this->slot;
        $slot = new $alias();
        $this->add($slot);
        return $slot;
    }

    function deallocate() {
        unset($this->{$this->slot . '_' . --$this->counter});
        $this->position = min($this->position,$this->counter);
    }
    
}

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
