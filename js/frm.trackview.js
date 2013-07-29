$(function() {

    var userID = $('.more-tracks').data('id-user');

    // load all tracks from currently displayed user
    $.get("api.php", {type: 'trackviewlist', id_user: userID, json: true}, function(data) {
        _.each(data, function(trackview) {
            // trackview.s0/s1 are data got from soundcloud
            if (trackview.s1) {
                $('.more-tracks').append($('<a>', {
                    href: "index.php?track=" + trackview.id_track,
                    text: trackview.s1.title
                })).fadeIn();
            }
        });

    }, "json");

    // render paypal minicart
    PAYPAL.apps.MiniCart.render({
        paypalURL: config.paypal.url,
        events: {
            onAddToCart: function(data) {

                if (this.getProductAtOffset(data.offset)) {
                    return false;
                }

                // check whether the added product is owned by current user
                if (_.find(this.products, function(p) { return p.settings.custom != userID; })) {
                    console.log("illegal: mixing products owned by different users");
                    return false;
                }
            }
        }
    });

    $('.more-tracks').hide();
});
