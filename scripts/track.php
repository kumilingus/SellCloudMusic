<?php

$conn = new DBCommon();
$track = new TrackView();
$track->setID($_GET['track']);

if ($conn->loadEntity($track) && $track->getID() > 0 && !$track->isSoldOut()) {

    $user = new User();
    $user->setID($track->id_user);

    if ($conn->loadEntity($user) && $user->getID() > 0) {

        $trackFrm = new Form($track, array(
            "action" => "https://www.sandbox.paypal.com/cgi-bin/webscr",
            "cancel_url" => Config::_('host').$_SERVER['REQUEST_URI'],
            "paypal_account" => $user->paypal_email,
            "return_url" => Config::_('sellcloudmusic-url').'/?thankyou'
        ));

        echo $trackFrm->toHTML();
    } else {
        include('./errors/track-not-found.html');
    }
} else {
    include('./errors/track-not-found.html');
}
?>