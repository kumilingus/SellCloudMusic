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

if (!isset($_GET['output']))
    $_GET['output'] = 'xml';

// helpers
function display($entity) {

    switch (strtolower($_GET['output'])) {

        case 'json':
            echo $entity->toJSON();
            break;
        case 'html':
            if ($entity instanceof Errors) {
                echo $entity->message;
            } else echo $entity->toHTML();
            break;
        default:
            echo $entity->toXML();
            break;
    }
}

function error($message) {
    display(new Errors(array("message" => $message)));
    exit;
}

// output either in JSON, XML or HTML
switch (strtolower($_GET['output'])) {
    case 'json':
        header("Content-type: text/json; charset=utf-8");
        break;
    case 'html':
        $_GET['formwrap'] = true;
        break;
    default:
        header("Content-type: text/xml; charset=utf-8");
        break;
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

            $authTokenUsed = @isset($_GET['auth_token']);

            if (!User::isStored() && !$authTokenUsed) {

                // noone who is not signed in can request existing record
                if (@isset($_GET['id']) && $_GET['id'] > 0) error("Unauthorized access!");

            } else {

                if ($authTokenUsed) {

                    $authToken = new AuthToken();
                    $authToken->auth_token = $_GET['auth_token'];
                    // try to look for authToken in database
                    $conn =  new DBCommon();
                    $r = $conn->findEntity($authToken);

                    if ($r instanceof NTError || $authToken->getID() < 1) {
                        error("Unauthorized access!");
                    } else {
                        $userID = $authToken->getID();
                    }

                } else {
                    $user = User::restore();
                    $userID = $user->getID();
                }
                // AND id_user = id(user)
                $add2q = DBCommon::QUERY_CONJUCTION . sprintf(DBCommon::QUERY_PAIR, 'id_user', $userID);
            }
        }

        switch ($method) {

            case 'POST':

                if ($access === 'none')
                    error("Access denied!");

                $ent->loadArray($_POST);

                if (!isset($_GET['formwrap'])) {
                    // if we not dealing with forms we don't want to check token
                    unset($ent->token);
                }

                if ($frm->dataFiltred()) {

                    if ($add2q != '' && @isset($ent->id_user) && $ent->id_user != $userID) {
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

        // send form or entity to output
        if (isset($_GET['formwrap'])) {
            // output entity wrapped with form
            display($frm);
        } else {
            // if there are any errors output them
            display($frm->errors->exist() ? $frm->errors : $ent);
        }

    } elseif (is_subclass_of($type, 'EList')) {

        if ($_GET['output'] === 'html') {
            error("Lists can't be displayed as HTML");
        }

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