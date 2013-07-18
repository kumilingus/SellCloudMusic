function Login(name) {
    this.name = name;
    this.anchor = "#login";
}
Login.inherits(Form);

function Pwdreq() {
    this.name = 'pwdreq';
    this.anchor = "#content";
}
Pwdreq.inherits(Form);

Pwdreq.active = function() {

    $('#pwdreq-form').ajaxForm({
        url: "login.php",
        dataType: "xml",
        success: function(response) {
            var p = new Pwdreq();
            if ($(response).find('status').text() === 'errors') {
                p.show({
                    xml: response,
                    complete: Pwdreq.active
                });
            } else {
                $(p.anchor).empty().append('<pre>Further instuctions about resetting password has been sent to your email.</pre>');
            }
        }
    });

}


Login.active = function() {

    $('#login-form').ajaxForm({
        url: "login.php",
        dataType: "xml",
        success: function(response) {
            var l = new Login($(response).find('type:parent("login")').text());
            l.show({
                xml: response,
                complete: Login.active
            });
            $('#content').empty();
        }
    });

    $('#sign-up-button').click(function() {
        var u = new User(0);
        u.show({
            complete: User.active
        });
    });

    $('#forgotten-password-button').click(function() {
        var p = new Pwdreq();
        p.show({
            complete: Pwdreq.active
        });
    });

    $('#my-tracks-button').click(function() {
        document.location.href = "?import=0";
    });

    $('#view-orders-button').click(function() {
        var o = new OrderList($('#id-user').val());
        o.show({complete: OrderList.active});
    });

    $('#edit-account-button').click(function() {
        var u = new User($('#id-user').val());
        u.show({
            complete: User.active
        });
    });

};

$(function() {

    Login.active();

});