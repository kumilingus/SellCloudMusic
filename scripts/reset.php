<?php

require_once('kernel/db/class.dbcommon.php');
require_once('src/ent.global.php');
require_once('kernel/class.form.php');

include_once('./cfg/configuration.php');

$pwdreq = new Pwdreq();
$pwdreq->pwd_reset_token = $_GET['reset'];
$pwdreq->setFlags('pwd_reset_token', DBC_FLG_KEY);
$conn = new dbCommon();
$r = $conn->findEntity($pwdreq);

if ($r instanceof dbError) {
    // database error
    include('./errors/database-error.html');
} elseif (($r instanceof ntError) || ($pwdreq->getID() == 0)) {
    // token expired or not found
    include('./errors/token-expired.html');
} else {
    // success
    $pwdchng = new Pwdchng();
    $form = new Form($pwdchng);

    if (isset($_POST) && isset($_POST['pwdchng-form-submit'])) {

        $pwdchng->loadArray($_POST);

        if ($form->dataFiltred()) {

            $user = new User();
            $user->setID($pwdreq->id_user);
            // create new slot. it will be loaded from db
            $user->pwd_reset_token = '';

            $r = $conn->loadEntity($user);

            if ($r instanceof dbError) {
                //database error
                include('./errors/database-error.html');
            } elseif ($user->pwd_reset_token === $pwdreq->pwd_reset_token) {
                //erase used token
                $user->pwd_reset_token = '';
                $user->setFlags('pwd_reset_token', DBC_FLG_NULL);
                //set new password
                $user->loadObject($pwdchng);
                
                $r = $conn->saveEntity($user);

                if ($r instanceof dbError) {
                    //database error
                    include('./errors/database-error.html');
                } else {
                    //sucess
                    echo "<pre>Your password has been sucessfully changed. You can sign in now.</pre>";
                }
                
            } else {
                echo "<pre>An unauthorized access!</pre>";
            }
        } else {
            echo $form->toHTML();
        }
    } else {
        echo $form->toHTML();
    }
}
?>
