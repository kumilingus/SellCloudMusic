//track form
function Track(id) {
    this.id = id;
    this.name = 'track';
    this.anchor = '#track-edit';
}
Track.inherits(Form);

Track.prototype.shown = function() {
  
    $('#slider-range-min').slider({
        range: 'min',
        value: $('#track-price').val(),
        min: 0,
        max: 200,
        slide: function(event,ui) {
            $('#track-price').val(ui.value);
        }
    });
    $('#track-price').val( $('#slider-range-min').slider('value'));
    $('#exclusive-radio').buttonset();

    var anchor = this.anchor;
    var container = $('.track-label.on'); 
    
    $('#track-form').ajaxForm({
        data: {
            id_soundcloud: container.data('track-id'),
            id_user: container.data('import-user-id')
        },
        dataType: 'xml',
        beforeSubmit: function() {
            $(anchor).fadeOut();
        },
        success: function(response) {

            var id = $(response).find('id_track').text();

            if ($(response).find('status').text() === 'insert') {
                container.addClass('track-imported');
                container.data('import-track-id',id);
            }

            var t = new Track(id);
            t.show({
                xml: response,
                complete: function() {
                    $(anchor).fadeIn();
                }
            });
        } 
    });
    
    $('#remove-track-button').click(function() {

        var t = new Track(container.data('import-track-id'));
        $.ajax({
            type: 'DELETE',
            url: t.source(),
            beforeSend: function() {
                $(anchor).fadeOut();
            },
            success: function(response) {
                t.show({
                    xml: response,
                    complete: function(xml) {
                        if ($(xml).find('status').text() === "delete") {
                            container.data('import-track-id', NaN);
                            container.removeClass('track-imported');
                        }
                        $(anchor).fadeIn();
                    }
                });
            }
        });
        
        return false;
    });

    $('#display-orders').click(function() {
        var o = new OrderList($('#id-user').val());
        o.trackID = $('.track-label.on').data('import-track-id');
        o.show({
            anchor: '#display-orders',
            complete: OrderList.active
        });
    });
        
};    
    
    
    
