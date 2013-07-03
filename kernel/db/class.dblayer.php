<?php

class dbError {

    private static $__messages = array(
        23505 => "already exists",
    );
    public $code;
    public $message;

    public function __call($m, $a) {
        return $this;
    }

    public function __construct($msg) {
        $m = $msg;
        preg_match('/SQLSTATE\[([0-9P]+)\]/', $m, $r);
        if (count($r) > 0) {
            if (@array_key_exists($r[1], self::$__messages)) {
                $this->code = $r[1];
                $m = self::$__messages[$r[1]];
            } elseif ($r[1] == 'P0001') {
                preg_match('/ERROR:\ ([^\']+)/', $m, $r);
                if (count($r) > 0) {
                    $m = $r[1];
                }
            }
        } else {
            //$m = "Unknown error";
        }
        $this->message = $m;
    }

}

abstract class dbConnection {

    private static $conn = NULL; // connection link
    public $transactionsEnabled = true;

    protected function __construct($dsn) {

        if (!@isset(self::$conn)) {
            try {
                self::$conn = new PDO($dsn);
            } catch (PDOException $e) {
                if (preg_match("/\b1045\b/i", $e->getMessage()))
                    print("Access denied.");
                else
                    print($e->getMessage());
            }
            self::$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            self::$conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        }
    }

    // provides access to $conn methods
    public function __call($method, $args) {

        if (@method_exists(self::$conn, $method)) {
            try {
                $result = call_user_func_array(array(self::$conn, $method), $args);
            } catch (PDOException $e) {
                if ($this->transactionsEnabled && self::$conn->inTransaction()) {
                    self::$conn->rollBack();
                }
                $result = new dbError($e);
            }
            return $result;
        }
        throw new Exception(sprintf("[%s] : method doesn't exists.", $method));
    }

}

?>