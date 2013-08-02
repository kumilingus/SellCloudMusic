(function() {

    $('#authtoken-form').submit(function() {
        $.post('api.php?type=authtoken&output=json', {
            id_user: $('#id-user').val()
        }, function(data) {
            $('.auth-token').text(data.auth_token || data.message);
        }, 'json');
        return false;
    });

})();