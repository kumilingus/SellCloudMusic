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
        $(xml).find('order:has(items>item>item_number:not(:contains(' + this.trackID + ')))').remove();
    }
    return xml;
};

OrderList.prototype.handleErrors = function() {};