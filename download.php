<?php

/**
 * Description of pdf
 *
 * @author robur
 */
require_once('kernel/db/class.dbcommon.php');
require_once('src/ent.global.php');
require_once('src/ent.order.php');
include_once('./cfg/configuration.php');

if (@isset($_GET) && @isset($_GET['id_order'])) {

    $conn = new dbCommon();

    $order = new Order();
    $order->setID($_GET['id_order']);

    if ($conn->loadEntity($order) && $order->getID() > 0) {

        $user = new User();

        if (@isset($_GET['secret_token'])) {

            if ($order->secret_token !== $_GET['secret_token']) {

                header('Location: index.php');
                exit;
            }

            $user->setID($order->id_user);
            $conn->loadEntity($user);

        } else {

            session_start();
            $user = User::restore();

        }

        //check if logged in user requesting his own order        
        if ($user->getID() > 0 && $user->getID() == $order->id_user) {

            //change XML wrapper 'login' to 'user'
            $user->type = 'user';
            $order->s0 = $user;

            $pdffname = $order->txn_id . '.pdf';
            $tmpfname = tempnam("tmp", "order");

            $handle = fopen($tmpfname, "w");
            fwrite($handle, $order->toXML());
            fclose($handle);

            $fopcmd = sprintf("fop -xsl xsl/pdf.order.xsl -xml %s -pdf -", $tmpfname);

            // we'll be outputting a PDF
            header('Content-type: application/pdf');
            // we'll give the file a name
            header(sprintf('Content-Disposition: attachment; filename="%s"', $pdffname));

            // send fop stdout to browser
            passthru($fopcmd);

            // delete temporary file
            unlink($tmpfname);

            exit;
        }
    }
}

header('Location: index.php');
?>
