<?php

require_once('kernel/db/class.dbcommon.php');
require_once('kernel/class.form.php');
require_once('kernel/class.elist.php');
require_once('src/ent.global.php');
require_once('src/ent.order.php');
require_once('src/ent.list.php');
include_once('./cfg/configuration.php');

if (!@isset($_GET))
    exit;

// helpers
function display($entity) {
    echo (@isset($_GET['json']) ? $entity->toJSON() : $entity->toXML());
}

function error($message) {
    display(new Errors(array("message" => $message)));
    exit;
}

// output either in JSON or XML
if (@isset($_GET['json'])) {
    header("Content-type: text/json; charset=utf-8");
} else {
    header("Content-type: text/xml; charset=utf-8");
}

if (@isset($_GET['type'])) {

    $type = $_GET['type'];

    if (is_subclass_of($type, 'Entity')) {

        // forms requires session to save its token
        session_start();

        $ent = new $type();
        $frm = new Form($ent);

        // entity access level
        // PUBLIC (default) | PRIVILEGED (user logged in) | NONE (noone through API)
        $access = $ent->getGlobalData(Entity::LABEL_ACCESS);

        // additional formula to the end of the query
        // we are making sure it's being manipulated with records belonging
        // to currently logged in user
        $add2q = '';

        $method = $_SERVER['REQUEST_METHOD'];

        if ($access === 'privileged') {

            if (!User::isStored()) {

                // noone who is not signed in can request existing record
                if (@isset($_GET['id']) && $_GET['id'] > 0) error("Unauthorized access!");

            } else {

                $user = User::restore();
                // AND id_user = id(user)
                $add2q = DBCommon::QUERY_CONJUCTION . sprintf(DBCommon::QUERY_PAIR, 'id_user', $user->getID());
            }
        }

        switch ($method) {

            case 'POST':

                if ($access === 'none')
                    error("Access denied!");

                $ent->loadArray($_POST);

                if ($frm->dataFiltred()) {

                    if ($add2q != '' && @isset($ent->id_user) && $ent->id_user != $user->getID()) {
                        error("Unauthorized access!");
                    }

                    $conn = new DBCommon();
                    $e = $conn->saveEntity($ent, $add2q);

                    if ($e instanceof DBError) {
                        $frm->errors->db = @sprintf("%s %s.", @get_class($ent), $e->message);
                    } elseif ($e instanceof NTError) {
                        $frm->errors->{$e->slot} = @sprintf($e->message);
                    }
                    // empty passwords slots. we don't want them to be sent to client
                    $ent->clear(FRM_FLG_PWD);
                }

                break;

            case 'GET':

                if (@isset($_GET['id']) && $_GET['id'] > 0) {

                    if ($access === 'none')
                        error("Access denied!");

                    $ent->setID($_GET['id']);
                    $conn = new DBCommon();
                    $e = $conn->loadEntity($ent, $add2q);
                    if ($e instanceof NTError) {
                        $frm->errors->{$e->slot} = $e->message;
                    } elseif (!$e) {
                        error("Record not found");
                    }
                    $ent->clear(FRM_FLG_PWD);
                }
                break;

            case 'DELETE':

                // manage access
                if ($access === 'none')
                    error("Access denied!");

                if (@isset($_GET['id'])) {

                    // set entity id to be deleted
                    $ent->setID($_GET['id']);

                    // there in PHP are arrays assigned by copy
                    $clone_GET = $_GET;
                    // deleting reserved names for slots
                    unset($clone_GET['id']);
                    unset($clone_GET['type']);

                    $ent->loadArray($clone_GET);

                    $conn = new DBCommon();
                    $e = $conn->deleteEntity($ent, $add2q);

                    if ($e instanceof DBError) {

                        $frm->errors->db = @sprintf("%s %s.", @get_class($ent), $e->message);

                    } elseif ($e instanceof NTError) {

                        $frm->errors->{$e->slot} = $e->message;

                    } else {
                        // set error if affected arrows equal 0
                        if ($e == 0)
                            $frm->errors->db = "Don't exists";
                        // empty entity
                        $ent->clear();
                    }
                }
                break;
        }

        // update form status if any errors occured
        $frm->updateStatus();
        // send form to output
        display($frm);
    } elseif (is_subclass_of($type, 'EList')) {

        $list = new $type();

        // manage access
        switch ($list->entity->getGlobalData(Entity::LABEL_ACCESS)) {

            case 'none':
                error("Access denied!");
                break;

            case 'privileged':

                session_start();
                if (!User::isStored())
                    error("Unauthorized access!");

                // make sure that we query records belonging just to logged user
                $_GET['id_user'] = User::restore()->id_user;
                break;
        }

        // load elist from db
        $conn = new DBCommon();
        $e = $conn->loadEList($list, $_GET);

        if ($e instanceof DBError) {
            error($e->message);
        } else {
            display($list);
        }
    } else {
        // neither entity neither elist exists
        error("Unknown type");
    }
} else {
    error("Invalid request");
}
?>