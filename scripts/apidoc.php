<h1>API Documentation</h1>
<h2>Resources</h2>
The Sellcloudmusic API allows producent to access their orders in machine-readable format using the HTTP method <strong>GET</strong>.
<br>
They can use it for example to integrate the Sellcloudmusic to their accounting software.
<br>
Every order has its unique URL defined by parameter <b>txn_id</b> (PayPal transaction ID).
<pre>
 www.sellcloudmusic.com/development/api.php?type=orderlist&amp;txn_id=PAYPAL_ID&auth_token=AUTHORIZATION_TOKEN
</pre>

Omitting <b>txn_id</b> causes there is all producent orders to be obtained.

<h2>Authorization token</h2>

It is meant to be used in order to access these orders at anytime. If desired, parameter <strong>auth_token</strong> can be added to the URL parameter query.
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
<p><i>You must be signed in in order to find out, what your token is.</i></p>
<?

}

?>

<h2>Output format</h2>

Resources can be obtained in two formats: <b>xml</b> and <b>json</b>. Choosing a format is done by adding parameter <strong>output</strong> to the URL parameter query.
<pre>
www.sellcloudmusic.com/development/api.php?type=orderlist&amp;output=json
</pre>

XML output can look like the example below.

<pre>
&lt;orderlist&gt;
  &lt;order&gt;
    &lt;id_order&gt;59&lt;/id_order&gt;
    &lt;id_user&gt;58&lt;/id_user&gt;
    &lt;txn_id&gt;5E408331C9919091D&lt;/txn_id&gt;
    &lt;timestamp&gt;2013-07-30 12:26:12.928648&lt;/timestamp&gt;
    &lt;items&gt;
      &lt;item&gt;
        &lt;id_item&gt;133&lt;/id_item&gt;
        &lt;id_order&gt;59&lt;/id_order&gt;
        &lt;item_name&gt;First track&lt;/item_name&gt;
        &lt;item_number&gt;220&lt;/item_number&gt;
        &lt;mc_gross_&gt;100.00&lt;/mc_gross_&gt;
     &lt;/item&gt;
     &lt;item&gt;
       &lt;id_item&gt;54&lt;/id_item&gt;
       &lt;id_order&gt;59&lt;/id_order&gt;
       &lt;item_name&gt;Second track&lt;/item_name&gt;
       &lt;item_number&gt;184&lt;/item_number&gt;
       &lt;mc_gross_&gt;94.00&lt;/mc_gross_&gt;
     &lt;/item&gt;
    &lt;/items&gt;
    &lt;secret_token&gt;51f7a2d4e2b5a&lt;/secret_token&gt;
  &lt;/order&gt;
&lt;/orderlist&gt;
</pre>
