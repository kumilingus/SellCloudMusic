<?php
require_once('kernel/db/class.dbcommon.php');
require_once('kernel/class.entity.php');
require_once('kernel/class.form.php');
require_once('src/ent.global.php');
require_once('src/soundcloud.php');
include_once('./cfg/configuration.php');
session_start();
//session_destroy();
?>
<html>
    <head>
        <meta http-equiv = "Content-Type" content = "text/html; charset=utf-8">
        <link rel="stylesheet" href="css/sellcloudmusic.css" type="text/css">
        <link rel="stylesheet" href="lib/jquery/jquery-ui-1.9.2.custom.min.css" type = "text/css">        
    </head>
    <body>
        <script type="text/javascript" src="cfg/config.js"></script>
        <script type="text/javascript" src="lib/underscore/underscore-min.js"></script>         
        <script type="text/javascript" src="lib/jquery/jquery.js"></script>        
        <script type="text/javascript" src="lib/jquery/jquery-ui-1.9.2.custom.min.js"></script>
        <script type="text/javascript" src="lib/jquery/jquery.form.js"></script>
        <script type="text/javascript" src="lib/jquery/jquery.transform.js"></script>
        <script type="text/javascript" src="http://connect.soundcloud.com/sdk.js"></script>        
        <script type="text/javascript" src="js/forms.js"></script>
        <script type="text/javascript" src="js/frm.login.js"></script>        
        <script type="text/javascript" src="js/frm.user.js"></script>
        <script type="text/javascript" src="js/lst.order.js"></script>
        <header id="login">
<?php
          $login = new Form(new Login(), array("action" => "login.php"));
          $usr = User::restore();
          if ($usr->getID() > 0) {
	    $login->data()->loadObject($usr);
	    $login->data()->type = Login::OUT;
	    $login->data()->id_user = $usr->getID();
	  }
          echo $login->toHTML();
?>
        </header>
        <section id="content">
<?php
	  if (isset($_GET)) {
	    if (isset($_GET['track'])) {
	      include("scripts/track.php");
	    } if (isset($_GET['import'])) {
	      include("scripts/list.php");
	    }
	  }
?>
        </section>
        <footer>
	[testing]
        </footer>
    </body>
</html>