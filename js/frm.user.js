function User(id) {
    this.id = id;    
    this.name = "user";
    this.anchor = "#content";
}
User.inherits(Form);

User.active = function() {

    $('#user-form').ajaxForm({
        dataType: "xml",
        success: function(response) {
            var u = new User(0);
            if (!$(response).find('status:contains("insert")').length > 0) {
                u.show({
                    xml : response,
                    complete: User.active
                });
            } else {
                $(u.anchor).empty().append("<span>User sucessfully registred.</span>");
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
}