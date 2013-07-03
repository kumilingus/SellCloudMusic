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
    $('#track-info').text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut nisl elit, convallis laoreet velit at, tristique auctor est. Proin ligula nibh, eleifend in tempus non, fermentum nec risus. Duis consectetur eleifend pretium. Sed et ligula dictum, sollicitudin arcu vitae, mattis eros. Sed aliquet massa dapibus tortor ullamcorper, eget lobortis elit lacinia. Sed ante eros, fringilla at lorem ut, tristique tempor neque. Phasellus pretium congue arcu, in tincidunt tortor posuere ut. Donec arcu nunc, mattis in neque quis, mollis iaculis tortor. In dui diam, tincidunt eu enim eu, consectetur semper magna.");
    $('#track-edit').text("Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec imperdiet at urna ac cursus. Nullam sagittis id enim ut gravida. Donec quis auctor neque. Ut lobortis lacus a enim semper, sit amet hendrerit enim porttitor. Phasellus fringilla eu nibh sit amet rutrum. Proin porta accumsan turpis vitae interdum. Cras rutrum accumsan massa, nec fringilla ante malesuada quis. Sed aliquet vestibulum ante eget consectetur. Maecenas auctor, velit in semper molestie, libero enim iaculis urna, sit amet porta nunc lorem vitae odio. Vivamus magna ipsum, adipiscing in dolor sed, lacinia scelerisque sem. Mauris imperdiet, orci eu ultricies faucibus, felis nisi condimentum turpis, rhoncus pellentesque velit lectus vel nisl. In hac habitasse platea dictumst. Suspendisse mollis nulla sit amet dui aliquet vulputate. Quisque metus diam, aliquet id ornare id, dictum vitae quam.");
});