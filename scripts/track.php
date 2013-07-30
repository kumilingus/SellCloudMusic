<?php

$conn = new dbCommon();
$track = new TrackView();
$track->setID($_GET['track']);

if ($conn->loadEntity($track) && $track->getID() > 0 && !$track->isSoldOut()) {

    $user = new User();
    $user->setID($track->id_user);

    if ($conn->loadEntity($user) && $user->getID() > 0) {

        $trackFrm = new Form($track, array(
            "action" => "https://www.sandbox.paypal.com/cgi-bin/webscr",
            "cancel_url" => Config::_('server-name').$_SERVER['REQUEST_URI'],
            "paypal_account" => $user->paypal_email,
            "return_url" => Config::_('host').'/?thankyou'
        ));

        echo $trackFrm->toHTML();
        exit;
    }
}

include('./errors/track-not-found.html');
?>