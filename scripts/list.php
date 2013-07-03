<?php

if ($usr->getID() > 0) {
    //variables
    $offset = (int) $_GET['import'];
    $limit = Config::_("tracks-per-page");
    
    //tracks
    $conn = new dbCommon();
    $statement = $conn->query("SELECT id_soundcloud, id_track, count_orders FROM tracks WHERE id_user = " . $usr->getID());
    $data = array_map('reset', $statement->fetchAll(PDO::FETCH_GROUP | PDO::FETCH_ASSOC));
    $soundcloud = Soundcloud::getInstance();
    $soundcloud->setResponseFormat('xml');
    $tracks = $soundcloud->get('me/tracks', array('limit' => $limit, 'offset' => $offset));
    $xml = new DOMDocument();
    $xml->loadXML($tracks);
    $xpath = new DOMXpath($xml);
    foreach ($xpath->query("/tracks/track/id") as $node) {
        $node->parentNode->insertBefore($xml->createElement("import-user-id", $usr->getID()), $node);
        if ($node->hasChildNodes() && $node->firstChild->nodeType == XML_TEXT_NODE && @array_key_exists($node->nodeValue, $data)) {
            $node->parentNode->insertBefore($xml->createElement("import-id", $data[$node->nodeValue]['id_track']), $node);
            $node->parentNode->insertBefore($xml->createElement("count-orders", $data[$node->nodeValue]['count_orders']), $node);
        }
    }
    $xsl = new DOMDocument();
    $xsl->load('xsl/lst.track.xsl');
    $xsltproc = new XSLTProcessor();
    $xsltproc->importStyleSheet($xsl);
    print($xsltproc->transformToXML($xml));

    if ($usr->track_count > $limit) {
        //navigation
        echo '<div id="track-list-nav">Pages: ';
        for ($i = 0; $i < $usr->track_count; $i += $limit){
            echo '<a href="?import=' . $i . '">'.($i / $limit + 1).'</a>&nbsp;';
        }
        echo '</div>';
    }
            
}
?>