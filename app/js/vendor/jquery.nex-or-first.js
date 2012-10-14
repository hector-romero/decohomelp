/********************************************************************************

*jQuery.nextOrFirst()
*
* PURPOSE:  Works like next(), except gets the first item from siblings if there is no "next" sibling to get.
********************************************************************************/
(function(jQuery){
    jQuery.fn.nextOrFirst = function(selector){
    var next = this.next(selector);
    return (next.length) ? next : this.prevAll(selector).last();
    }
})(jQuery)