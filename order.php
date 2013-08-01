<?php

require_once('./src/ent.order.php');
require_once('./src/ent.global.php');
require_once('./src/ent.list.php');
require_once('./kernel/db/class.dbcommon.php');

include_once('./cfg/configuration.php');

// helper
function log_e($message) {
    // logging errors
    $filehandle = fopen('./debug/order-error.txt', 'a');
    fwrite($filehandle, date("F j, Y, g:i a") . PHP_EOL);
    fwrite($filehandle, $message . PHP_EOL);
    fwrite($filehandle, var_export($_POST, true) . PHP_EOL . PHP_EOL);
    fclose($filehandle);
}

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
    log_e($errno.' : ',$errstr);

} else {

    fputs($fp, $header . $req);
    while (!feof($fp)) {

        $res = fgets($fp, 1024);
        //$res = stream_get_contents($fp, 1024);

        if (stripos($res, "VERIFIED") !== false) {

            //close socket
            fclose($fp);

            // check the payment_status is Completed
            if ($_POST['payment_status'] !== 'Completed') {
                return;
            }

            //create db connection
            $conn = new DBCommon();

            //id user is kept in custom variable. see frm.trackview.xsl
            $user = new User();
            $user->setID($_POST['custom']);
            $eu = $conn->loadEntity($user);

            if ($eu instanceof DBError) {
                log_e($eu->message);
                return;
            };

            // check if user exists
            if ($user->getID() < 1) {
                log_e('ID USER');
                return;
            }

            // check that receiver_email is your Primary PayPal email
            if ($_POST['receiver_email'] !== $user->paypal_email) {
                log_e('RECEIVER EMAIL');
                return;
            }

            // create new order
            $order = new Order();
            $order->loadArray($_POST);
            $order->id_user = $user->getID();

            // build array of all track id
            $trackids = array();
            foreach ($order->items as $item) {
                array_push($trackids, $item->item_number);
            }

            // check validity order items
            $tracklist = new TrackList();
            $et = $conn->loadEList($tracklist, array(
                'id_user' => $user->getID(),
                'id_track' => $trackids
            ));

            if ($et instanceof DBError || $et instanceof NTError) {
                log_e($et->message);
                return;
            };

            // check that payment_amount/payment_currency are correct

            // create order
            $eo = $conn->saveEntity($order);

            if ($eo instanceof DBError || $eo instanceof NTError) {

                if ($eo instanceof DBError || preg_match('/txn_id_unique/', $eo->message)) {
                    // order has been previously processed
                    return;
                }

                log_e($eo->message);
                return;
            } else {

                // list of soundcloud track ids
                $track_sc_ids = array();

                // create soundcloud connection
                $soundcloud = Soundcloud::getInstance($user->soundcloud_oauth_token);

                foreach ($tracklist as $track) {

                    array_push($track_sc_ids, $track->id_soundcloud);

                    try {

                        $soundcloud->put('tracks/' . $track->id_soundcloud, array(
                            "track[downloadable]" => true,
                            "track[sharing]" => "private",
                            "track[purchase_url]" => ""
                        ));

                    } catch (Exception $e) {

                        log_e($e->getMessage());
                        return;
                    }
                }

                // getting alternated tracks from soundcloud
                // we need secret_tokens in order to build download links

                $sc_tracks = null;

                try {

                    $sc_tracks_json = $soundcloud->get('tracks/', array('ids' => @implode($track_sc_ids, ',')));
                    $sc_tracks = json_decode($sc_tracks_json);

                } catch (Exception $e) {

                    log_e($e->getMessage());
                    return;
                }

                //building links to download tracks
                $links = array();
                $index = 1;
                foreach ($sc_tracks as $sc_track) {

                    $link = $sc_track->download_url . '?' . http_build_query(array(
                                'client_id' => Config::_('client-id'),
                                'secret_token' => $sc_track->secret_token
                    ));

                    // push title
                    array_push($links, sprintf('%s. %s:', $index++, $sc_track->title));
                    // push link
                    array_push($links, $link . PHP_EOL);
                }

                //building link to download invoice
                $invoice_link = Config::_('host') . '/download.php?' . http_build_query(array(
                            'id_order' => $order->getID(),
                            'secret_token' => $order->secret_token
                ));

                // sending email
                include('lib/mail/Mail.php');

                $mail = @Mail::factory("mail");

                $header = array(
                    "From" => Config::_('mail-from'),
                    "Bcc" => Config::_('mail-copy'),
                    "Subject" => Order::EMAIL_SUBJECT
                );

                $em = $mail->send($_POST['payer_email'], $header, sprintf(Order::EMAIL_BODY, @implode($links, PHP_EOL), $invoice_link));

                if ($em !== true) {
                    log_e($em);
                    return;
                }
            }

            return;

        } else if (stripos($res, "INVALID") !== false) {
            // log for manual investigation
            log_e('INVALID');
        }
    }

    fclose($fp);
}
?>
