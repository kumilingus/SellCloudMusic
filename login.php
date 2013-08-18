<?php

require_once('kernel/db/class.dbcommon.php');
require_once('src/ent.global.php');
require_once('kernel/class.form.php');

include_once('./cfg/configuration.php');

if (isset($_POST['login-form-submit'])) {

    session_start();
    header("Content-type: text/xml; charset=utf-8");

    $login = new Login();
    $form = new Form($login);

    if (!User::isStored()) {
        $login->loadArray($_POST);
        if ($form->dataFiltred()) {
            $usr = new User();
            $usr->loadObject($login);
            $conn = new DBCommon();
            if ($r = $conn->findEntity($usr)) {
                if ($r instanceof DBError) {
                    $form->errors->db = "Can't access the database. Please try later.";
                } else {
                    $usr->store();
                    $login->type = login::OUT;
                    $login->id_user = $usr->getID();
                }
            } else {
                $form->errors->password = login::USER_DOESNT_EXIST;
            }
        } else {
            $form->errors->password = login::USER_DOESNT_EXIST;
        }
    } else {
        User::clearStored();
    }
    $login->clear(FRM_FLG_PWD);
    $form->updateStatus();
    echo $form->toXML();

} elseif (isset($_POST['pwdreq-form-submit'])) {

    session_start();
    header("Content-type: text/xml; charset=utf-8");

    $pwdreq = new Pwdreq();
    $form = new Form($pwdreq);
    $pwdreq->loadArray($_POST);

    if ($form->dataFiltred()) {

        $conn = new DBCommon();
        $pwdreq->addFlags('email', DBC_FLG_KEY);

        if ($r = $conn->findEntity($pwdreq)) {

            if ($r instanceof DBError) {
                $form->errors->db = "Can't access the database. Please try later.";

            } else {
                // update user (token,timestamp)
                $r = $conn->saveEntity($pwdreq);
                if ($r instanceof DBError) {
                    $form->errors->db = "Can't access the database. Please try later.";
                } else {
                    // send an email
                    include('lib/mail/Mail.php');
                    $mail = @Mail::factory("mail");
                    $link = sprintf('%s/index.php?reset=%s', Config::_('sellcloudmusic-url'), $pwdreq->pwd_reset_token);
                    $header = array("From" => Config::_('mail-from'),"Subject" => Pwdreq::EMAIL_SUBJECT);
                    $r = $mail->send($pwdreq->email, $header, sprintf(Pwdreq::EMAIL_BODY, $link));

                    if ($r !== true) {
                        $form->errors->db = "Sending mail failed. Please try later.";
                    }
                }
            }
        } else {
            $form->errors->email = Pwdreq::EMAIL_DOESNT_EXIST;
        }
    }

    $form->updateStatus();
    echo $form->toXML();
    
} else {
    header("Location: index.php");
}
?>