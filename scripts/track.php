<?php

$conn = new dbCommon();
$track = new TrackView();
$track->setID($_GET['track']);

if ($conn->loadEntity($track) && $track->getID() > 0) {

    $user = new User();
    $user->setID($track->id_user);

    if ($conn->loadEntity($user) && $user->getID() > 0) {

        $trackFrm = new Form($track, array(
            "action" => "https://www.sandbox.paypal.com/cgi-bin/webscr",
            "return_url" => Config::_('server-name').$_SERVER['REQUEST_URI'],
            "paypal_account" => $user->paypal_email));

        echo $trackFrm->toHTML();
        exit;
    }
}

include('./errors/track-not-found.html');
?>