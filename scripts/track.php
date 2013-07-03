<?php

$conn = new dbCommon();
$track = new TrackView();
$trackFrm = new Form($track, array("action" => "https://www.sandbox.paypal.com/cgi-bin/webscr"));
$track->setID($_GET['track']);

if ($conn->loadEntity($track)) {

    echo $trackFrm->toHTML();

//    $tracks = $conn->query("SELECT * FROM tracks WHERE id_user = " . $track->id_user)->rowCount();
//    echo "Show another $tracks tracks from this producent.";
    
//    $moreTracks = new TrackviewList();
//    $conn->loadEList($moreTracks, array("id_user" => $track->id_user));
//    var_dump($moreTracks);
    
    
    
} else {

    include('./errors/track-not-found.html');
}
?>