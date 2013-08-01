function User(id) {
    this.id = id;
    this.name = "user";
    this.anchor = "#content";
}
User.inherits(Form);

function AuthToken(id) {
    this.id = id;
    this.name = 'authtoken';
    this.anchor = '#content';
}
AuthToken.inherits(Form);

User.active = function() {

    $('#user-form').ajaxForm({
        dataType: "xml",
        success: function(response) {
            var u = new User(0);

            switch ($(response).find('status').text()) {

                case 'insert':
                    $(u.anchor).empty().append("<span>User sucessfully registred.</span>");
                    break;

                default:
                    u.show({
                        xml: response,
                        complete: User.active
                    });
                    break;
            }

            $("#soundcloud-connected").text($(response).find('soundcloud_username').text());
        }
    });

    $("#soundcloud-connect").click(function() {

        SC.initialize(config.soundcloud.ini);

        SC.connect(function() {
            SC.get('/me', function(me) {
                $('#soundcloud-connected').text(me.username);
                $('#soundcloud-username').val(me.username);
            });

            $('#soundcloud-oauth-token').val(SC.accessToken());
        });
    });
};

AuthToken.prototype.shown = function() {

    $('#authtoken-form').submit(_.bind(function() {
        $.post('api.php?type=authtoken&output=json', {
            id_user: this.id
        }, function(data) {
            $('.auth-token').text(data.auth_token || data.message);
        }, 'json');
        return false;
    }, this));

};