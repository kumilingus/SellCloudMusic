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

    $('.pdf-generator').click(function() {
        document.location.href = 'download.php?id_order=' + $(this).data('id-order');
    });

};