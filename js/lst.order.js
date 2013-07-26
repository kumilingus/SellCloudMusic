function OrderList(userID) {
    this.userID = userID;
    this.trackID = undefined;
    this.name = 'OrderList';
    this.anchor = "#content";
    this.fromDate = null;
    this.toDate = null;
}
OrderList.inherits(Form);

OrderList.prototype.xsl = function() {
    return "xsl/lst.order.xsl";
};

OrderList.prototype.source = function() {

    var queryDate = '';

    if (this.fromDate)
        queryDate += '&timestamp@1=@g' + this.fromDate;
    if (this.toDate)
        queryDate += '&timestamp@2=@l' + this.toDate;

    return "api.php?id_user=" + this.userID + "&type=" + this.name + queryDate;
};

OrderList.prototype.processData = function(xml) {
    if (this.trackID) {
        var orders = $(xml).find('order:has(item_number:contains(' + this.trackID + '))');
        $(xml).find('orderlist').empty().append(orders);
    }
    return xml;
};

OrderList.prototype.handleErrors = function() {
};

OrderList.createFilters = function(orderList) {

    var $from = $('<input>', {
        type: 'text',
        id: 'fromDate',
        placeholder: 'From Date',
        value: orderList.fromDate
    }).addClass('datepicker');

    var $to = $('<input>', {
        type: 'text',
        id: 'toDate',
        placeholder: 'To Date',
        value: orderList.toDate
    }).addClass('datepicker');

    var $content = $('#content');

    if (orderList.toDate) {
        $content.prepend($('<input>', {
            type: 'button'
        }).addClass('cancel-button').on('click', function() {
            orderList.toDate = null;
            orderList.reload(orderList);
        }));
    }

    $content.prepend($to);

    if (orderList.fromDate) {
        $content.prepend($('<input>', {
            type: 'button'
        }).addClass('cancel-button').on('click', function() {
            orderList.fromDate = null;
            orderList.reload(orderList);
        }));
    }

    $content.prepend($from);
};

OrderList.active = function(orderList) {

    var $list = $('#order-list');
    if ($list.is(':empty')) {
        // inform user there's no order
        $list.append($('<div>', {text: 'There are no orders.'}).addClass('gray-box'));
    } else {

        $('.pdf-generator').click(function() {
            document.location.href = 'download.php?id_order=' + $(this).data('id-order');
        });
    }

    if (orderList) {

        $('.datepicker').datepicker({
            maxDate: new Date(),
            dateFormat: 'yy-mm-dd',
            showWeek: true,
            onSelect: function(date) {
                orderList[$(this).attr('id')] = date;
                orderList.reload(orderList);
            }
        });

    }
};

OrderList.prototype.reload = function(orderList) {
    this.show({
        complete: function() {
            OrderList.createFilters(orderList);
            OrderList.active(orderList);
        }
    });
};