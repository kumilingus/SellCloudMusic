<?php
require_once('kernel/db/class.dbcommon.php');
require_once('kernel/class.form.php');
require_once('kernel/class.elist.php');
require_once('src/ent.global.php');
require_once('src/ent.order.php');
require_once('src/ent.list.php');
include_once('./cfg/configuration.php');

if (!@isset($_GET)) exit;

if (@isset($_GET['json'])) {
    header("Content-type: text/json; charset=utf-8");
} else {
    header("Content-type: text/xml; charset=utf-8");
}

function display($entity) {
    echo (@isset($_GET['json']) ? $entity->toJSON() : $entity->toXML());
}

if (@isset($_GET['type'])) {

    $type = $_GET['type'];
            
    if (is_subclass_of($type, 'Entity')) {

        session_start();

        $ent = new $type();
        $frm = new Form($ent);

        switch ($_SERVER['REQUEST_METHOD']) {

            case 'POST':

                $ent->loadArray($_POST);
                if ($frm->dataFiltred()) {
                    $conn = new dbCommon();
                    $e = $conn->saveEntity($ent);
                    if ($e instanceof dbError) {
                        $frm->errors->db = @sprintf("%s %s.", @get_class($ent), $e->message);
                    } elseif ($e instanceof ntError) {
                        $frm->errors->{$e->slot} = @sprintf($e->message);
                    }
                    $ent->clear(FRM_FLG_PWD);
                }

                break;

            case 'GET':
                if (@isset($_GET['id']) && $_GET['id'] > 0) {
                    $ent->setID($_GET['id']);
                    $conn = new dbCommon();
                    $e = $conn->loadEntity($ent);
                    if ($e instanceof ntError) {
                        $frm->errors->{$e->slot} = @sprintf($e->message);
                    } elseif (!$e) {
                        $e = new Errors(array("message" => "Record not found"));
                        display($e);
                        return;
                    }
                    $ent->clear(FRM_FLG_PWD);
                }
                break;

            case 'DELETE':
                if (@isset($_GET['id'])) {
                    $ent->setID($_GET['id']);
                    $conn = new dbCommon();
                    $e = $conn->deleteEntity($ent);
                    if ($e instanceof dbError) {
                        $frm->errors->db = @sprintf("%s %s.", @get_class($ent), $e->message);
                    } else {
                        if ($e == 0) {
                            $frm->errors->db = "Don't exists";
                        }
                        $ent->clear();
                    }
                }
                break;
        }

        $frm->updateStatus();
        display($frm);
    } elseif (is_subclass_of($type, 'EList')) {
        $list = new $type();
        $conn = new dbCommon();
        $e = $conn->loadEList($list,$_GET);
        if ($e instanceof dbError) {
            $e = new Errors(array("message" => $e->message));
            display($e);
        } else {
            display($list);
        }
    } else {
        $e = new Errors(array("message" => "Unknown type"));
        display($e);
    }
} else {
    $e = new Errors(array("message" => "Invalid request"));
    display($e);
}
?>