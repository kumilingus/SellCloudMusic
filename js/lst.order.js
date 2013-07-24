function OrderList(userID) {
    this.userID = userID;
    this.trackID = undefined;
    this.name = 'OrderList';
    this.anchor = "#content";
}
OrderList.inherits(Form);

OrderList.prototype.xsl = function() {
    return "xsl/lst.order.xsl";
};

OrderList.prototype.source = function() {
    return "api.php?id_user="+ this.userID +"&type=" + this.name;
};

OrderList.prototype.processData = function(xml) {
    if (this.trackID) {
        var orders = $(xml).find('order:has(item_number:contains(' + this.trackID + '))');
        $(xml).find('orderlist').empty().append(orders);
    }
    return xml;
};

OrderList.prototype.handleErrors = function() {};

OrderList.active = function() {

    var $list = $('#order-list');
    if ($list.is(':empty')) {
        // inform user there's no order
        $list.append($('<span>', { text: 'There are no orders yet' }).addClass('gray-box'));
    } else {

        $('.pdf-generator').click(function() {
            document.location.href = 'download.php?id_order=' + $(this).data('id-order');
        });
    }
};