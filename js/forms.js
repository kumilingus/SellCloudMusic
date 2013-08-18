Function.prototype.inherits = function( param ){ 
    if ( param.constructor == Function ) 
    { 
        this.prototype = new param;
        this.prototype.constructor = this;
        this.prototype.parent = param.prototype;
    } 
    else 
    { 
        this.prototype = param;
        this.prototype.constructor = this;
        this.prototype.parent = param;
    } 
    return this;
};

//form
function Form() {
    
    this.id = null;
    this.name = null;
    this.anchor = "#form";
    this.shown = null;
    
}

Form.prototype.handleErrors = function(xml) {
    var prefix = '#' + this.name + '-';
    $(xml).find('errors').children().each(function(index,value) {
        $(prefix + $(value)[0].tagName.replace('_','-'))
        .addClass('input-error')
        .focus(function() {
            $(this).removeClass('input-error');
        })
        .attr('alt',$(value).text());
    });
};

Form.prototype.source = function() {
    return "api.php?id="+ this.id +"&type=" + this.name + '&formwrap';
};

Form.prototype.xsl = function() {
    return "xsl/frm."+ this.name +".xsl";
};

Form.prototype.startLoading = function() {
  $('.loader').addClass('active');
};

Form.prototype.stopLoading = function() {
   $('.loader').removeClass('active');
};

Form.prototype.processData = function(data) {
   return data;
};

Form.prototype.show = function(args) {

    this.startLoading();

    var defs = {
        xml : null,
        anchor : this.anchor,
        complete : null,
        form : this
    };
    
    args = args || {};

    for(var i in defs) {
        if(!args[i]) args[i] = defs[i];
    }
    
    this.anchor = args.anchor;

    var calls = new Array();

    //main stylesheet
    calls['xsl'] = $.ajax({
        url: this.xsl(),
        dataType: "xml",
        async: false,
        cache: true
    });
    //xml
    if (!args['xml']) {
        calls['xml'] = $.ajax({
            url: this.source(),
            dataType: "xml",
            async: false,
            cache: false
        });
    }
    $.when(calls).done(function(data) {
        xml = null;
        xsl = data['xsl'].responseXML;

        if (!args.xml) {
            xml = args.form.processData(data['xml'].responseXML);
        } else {
            xml = args.xml;
        }
	setTimeout(function() { args.form.stopLoading() }, 10);
        $(args.anchor).empty();
        var callback = function() {
            if (args.form.shown) args.form.shown();
            if (args.complete) args.complete(xml);
            if (args.form.handleErrors) args.form.handleErrors(xml);
        };

        $(args.anchor).transform({
            xmlobj: xml,
            xslobj: xsl,
            complete : callback
        });
    });
};