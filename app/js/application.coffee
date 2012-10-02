#= require "vendor/jquery"
#= require "vendor/jquery-ui.min"
#= require "vendor/jquery.easing.1.3"
#= require "vendor/jquery.booklet.1.4.0"
#= require "view"
#= require "vendor/underscore"

App = {}
class jQMView extends View
  _default_events =
#    'popupbeforeposition .popup' : 'resizePopUp'
    'popupafterclose .popup'     : 'removeHash'
    'click .error'               : 'clearError'
    'click .back'                : 'goBack'
    'keypress input.numeric'     : 'filterNumericKeys'
    'input input.checkLength'    : 'maxLengthCheck'

  removeHash: ->
    location.hash = ''

  maxLengthCheck: (e)->
    object = e.target
    if (object.value.length > object.maxLength)
      object.value = object.value.slice(0, object.maxLength)

  events: {}

  options:
    'data-role': 'page'
    'data-theme': 'on'

  filterNumericKeys: (e) ->
    unless Tools.isNumericKey e.keyCode
      e.returnValue = false
      e.preventDefault()

  addError: ->
    errorHtml = JST['templates/error_message']()
    if @$(".pageTitle")[0]
      @$(".pageTitle:first").after errorHtml
    else if @$(".ui-header")[0]
      @$(".ui-header:first").after errorHtml
    else
      @$el.prepend errorHtml

  error: (errorMessage) ->
    error = @$(".error")
    unless @$(".error")[0]
      @addError()
      error = @$(".error")
    error.html errorMessage
    error.slideDown()
    null

  clearError: =>
    error = @$(".error")
    error.slideUp()
    error.html ''

  headerTemplate: (title) ->
    JST['templates/header'] title:title

  template: (header,content,footer) ->
    params =
      header: header
      content: content
      footer: footer
    JST['templates/screen'] params

  goBack: =>
    Views.navigator.navigate @options.prevPage, reverse: true

  resizePopUp:(e) ->
    $(e.target).css("width",Math.floor($(window).width() * 0.9) + 'px')

  initialize: ->
    @options['data-url'] or= @id
    @options.prevPage or= $(".ui-page-active")
    @$el.attr "data-role", @options['data-role']
    @$el.attr "data-url", @options['data-url']
    @$el.attr "data-theme", @options['data-theme']
    _.defaults @events, _default_events

  render: ->
    throw "Must override"

class Application extends jQMView
  events:
#    'click .btnContact' : 'showPopupContact'
#    'click .btnFc' : 'showPopupFc'
    'click #del' : 'delete'

  delete: ->
    $("body").html('')

  renderHashPage: =>
    hash = location.hash.replace('#','').toLowerCase()
    if hash == 'contacto'
      return @showPopupContact()
    if hash == 'facebook'
      return @showPopupFc()


  showPopupContact: =>
    $(".contactPopup").popup().popup 'open'

  showPopupFc: =>
    $(".fcPopup").popup().popup 'open'



ajaxSpinner = ->
    spinner = $(".ui-loader")
    spinner.ajaxStart -> spinner.show()
    spinner.ajaxStop -> spinner.hide()

App.onLoad = ->
  ajaxSpinner()
  App.view = new Application el: $(".mainPage")
  updateHeight  = (e, ret = true)->
    $('.ui-content').css("height","#{maxHeight = $(window).height() - 128 }px")
    $('.ui-content').css("max-height","#{maxHeight = $(window).height() - 128 }px")
    return
#    height = $("#mybook").width() * 0.76
#    $('.ui-content').css("height","#{height}px")
#    $('#mybook').css("height","#{height}px")
#    $('#mybook').css("max-height","#{height}px !important")
  updateHeight undefined,false
#  $(window).bind 'resize', updateHeight

  $('#mybook').booklet({overlays: true,arrows: true,closed: true,hovers:true,autoCenter:true,width: '75%',height: '97%'})
  $('#mybook').show()
  $('.fcFrame').html '<iframe src="//www.facebook.com/plugins/likebox.php?href=http%3A%2F%2Fwww.facebook.com%2Fdecohomelp&amp;width=420&amp;height=558&amp;colorscheme=light&amp;show_faces=true&amp;border_color&amp;stream=true&amp;header=false" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:420px; height:558px;" allowTransparency="true" style="width:100%;height:100%"></iframe>'
  App.view.renderHashPage()
  $(window).bind "hashchange", -> App.view.renderHashPage()



$(document).bind "mobileinit", ->
  $.extend $.mobile,
            defaultPageTransition: 'slidefade'
            hashListeningEnabled: false
            ajaxEnabled: false
            loadingMessageTextVisible: true
            pushStateEnabled: false
            transitionFallbacks: slidefade: "slidefade"
#Exports:
window.App = App



