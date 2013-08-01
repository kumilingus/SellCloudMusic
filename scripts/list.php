<?php

if ($usr->getID() > 0) {
    //variables
    $offset = (int) $_GET['import'];
    $limit = Config::_("tracks-per-page");
    
    //get database tracks
    $conn = new DBCommon();
    $statement = $conn->query("SELECT id_soundcloud, id_track, count_orders, exclusive FROM tracks WHERE id_user = " . $usr->getID());
    $data = array_map('reset', $statement->fetchAll(PDO::FETCH_GROUP | PDO::FETCH_ASSOC));
    // get soundcloud tracks
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
            $node->parentNode->insertBefore($xml->createElement("exclusive", $data[$node->nodeValue]['exclusive']), $node);
        }
    }

    //echo $xml->saveXML();
    // xsl document
    $xsl = new DOMDocument();
    $xsl->load('xsl/lst.track.xsl');

    //transform data to html
    $xsltproc = new XSLTProcessor();
    $xsltproc->importStyleSheet($xsl);
    print($xsltproc->transformToXML($xml));

    if ($usr->track_count > $limit) {
        //navigation
        echo '<div id="track-list-nav" style="opacity:0">Pages: ';
        for ($i = 0; $i < $usr->track_count; $i += $limit){
            echo '<a href="?import=' . $i . '">'.($i / $limit + 1).'</a>&nbsp;';
        }
        echo '</div>';
    }
            
}
?>