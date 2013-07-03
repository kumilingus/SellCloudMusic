$(function() {

$.get("api.php",{ type: 'trackviewlist', id_user: $('.more-tracks').data('id-user'), json: true }, function(data) {
    _.each(data, function(trackview){
        $('.more-tracks').append( $('<a>',{
            href: "index.php?track=" + trackview.id_track,
            text: trackview.s1.title
        })).fadeIn();
    });
        
}, "json");

$('.more-tracks').hide();
});