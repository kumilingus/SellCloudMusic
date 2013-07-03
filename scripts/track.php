<?php

$conn = new dbCommon();
$track = new TrackView();
$trackFrm = new Form($track, array(
    "action" => "https://www.sandbox.paypal.com/cgi-bin/webscr",
    "return_url" => $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']));

$track->setID($_GET['track']);

if ($conn->loadEntity($track)) {
    echo $trackFrm->toHTML();
} else {
    include('./errors/track-not-found.html');
}
?>