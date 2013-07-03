<?php

require_once('./src/ent.order.php');
require_once('./kernel/db/class.dbcommon.php');

include_once('./cfg/configuration.php');
// Revision Notes
// 11/04/11 - changed post back url from https://www.paypal.com/cgi-bin/webscr to https://ipnpb.paypal.com/cgi-bin/webscr
// For more info see below:
// https://www.x.com/content/bulletin-ip-address-expansion-paypal-services
// "ACTION REQUIRED: if you are using IPN (Instant Payment Notification) for Order Management and your IPN listener script is behind a firewall that uses ACL (Access Control List) rules which restrict outbound traffic to a limited number of IP addresses, then you may need to do one of the following: 
// To continue posting back to https://www.paypal.com  to perform IPN validation you will need to update your firewall ACL to allow outbound access to *any* IP address for the servers that host your IPN script
// OR Alternatively, you will need to modify  your IPN script to post back IPNs to the newly created URL https://ipnpb.paypal.com using HTTPS (port 443) and update firewall ACL rules to allow outbound access to the ipnpb.paypal.com IP ranges (see end of message)."
// read the post from PayPal system and add 'cmd'
$req = 'cmd=_notify-validate';

foreach ($_POST as $key => $value) {
    $value = urlencode(stripslashes($value));
    $req .= "&$key=$value";
}

// post back to PayPal system to validate
$header = "POST /cgi-bin/webscr HTTP/1.0\r\n";
$header .= "Host: www.sandbox.paypal.com\r\n";
$header .= "Content-Type: application/x-www-form-urlencoded\r\n";
$header .= "Content-Length: " . strlen($req) . "\r\n\r\n";

//If testing on Sandbox use:
$fp = fsockopen('ssl://www.sandbox.paypal.com', 443, $errno, $errstr, 30);
//$fp = fsockopen('ssl://ipnpb.paypal.com', 443, $errno, $errstr, 30);

if (!$fp) {
// HTTP ERROR
} else {
    fputs($fp, $header . $req);
    while (!feof($fp)) {
        $res = fgets($fp, 1024);
        //$res = stream_get_contents($fp, 1024);
        if (stripos($res, "VERIFIED") !== false) {

// check the payment_status is Completed
// check that txn_id has not been previously processed
// check that receiver_email is your Primary PayPal email
// check that payment_amount/payment_currency are correct
// process payment

            $order = new Order();
            $order->loadArray($_POST);

            $conn = new dbCommon();
            $e = $conn->saveEntity($order);
            if ($e instanceof dbError || $e instanceof ntError) {
                $filename = './debug/order.txt'; //create a file telling me we're verified
                $filehandle = fopen($filename, 'a');
                fwrite($filehandle, $e->message);
                fclose($filehandle);
            } else {
                //change track(s)in db
            }
        } else if (stripos($res, "INVALID") !== false) {
            // log for manual investigation
        }
    }
    fclose($fp);
}
?>