<?php

abstract class Transformer {

    const XML_VERSION = '1.0';
    const XML_ENCODING = 'UTF-8';

    public function __construct($param = array()) {
        foreach ($param as $var => $val) {
            $this->$var = $val;
        }
    }

    public function toJSON() {
        return json_encode($this);
    }

    public function toDOM() {
        $doc = new DOMDocument(self::XML_VERSION, self::XML_ENCODING);
        $root = $doc->createElement((string) $this);
        $doc->appendChild($root);
        foreach (@get_object_vars($this) as $key => $val) {
            $node = null;
            if (is_a($val, __CLASS__)) {
                $node = $doc->importNode($val->toDOM()->documentElement, true);
            } else {
                if (is_array($val))
                    break;
                $node = $doc->createElement(@strtolower($key));
                $node->appendChild($doc->createTextNode((string) $val));
            }
            $root->appendChild($node);
        }
        return $doc;
    }

    public function toXML() {
        return $this->toDOM()->saveXML();
    }
    
    public function __toString() {
        return @strtolower(@get_class($this));
    }

}

?>
