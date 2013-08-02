<h1>REST API</h1>
<h2>Secret token</h2>
<?php

if (User::isStored()) {

    $auth = new AuthToken();
    $auth->setID($usr->getID());
    $frm = new Form($auth);

    $conn = new DBCommon();
    $conn->loadEntity($auth);

    echo $frm->toHTML();

} else {

?>
<p>You must be signed in in order to find out your secret token.</p>
<?

}

?>
<h2>Resources</h2>
<ul>
    <li>Order</li>
    <li>Track</li>
</ul>