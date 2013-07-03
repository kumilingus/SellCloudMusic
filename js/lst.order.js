function OrderList(userID) {
    this.id = userID;
    this.name = 'OrderList';
    this.anchor = "#content";
}
OrderList.inherits(Form);

OrderList.prototype.xsl = function() {
    return "xsl/lst.order.xsl";
};

OrderList.prototype.source = function() {
    return "api.php?id_user="+ this.id +"&type=" + this.name;
};

OrderList.prototype.handleErrors = function() {};