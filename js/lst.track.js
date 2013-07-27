$(function() {
    $('.track-label').click(function() {
        
        if (!$(this).hasClass('on')) {
            
            $('.track-label').removeClass('on');
            $(this).addClass('on');
            
            $('#track-panel').children().empty();
            $('#track-info').append($(this).next().clone().children()).show();
            $('#track-edit').hide();
            
            var t = new Track($(this).data('import-track-id'));
            t.show({
                complete: function() {
                    $('#track-edit').fadeIn();
                }
            });
        } 
    });

    $('.track-label').mouseover(function() {
        $(this).addClass('over');
		

    }).mouseout(function() {
        $(this).removeClass('over');										
    });

    $('.track-body').hide();
    $('.track-label').first().click();
});