#= require "vendor/jquery"
#=  require "vendor/jquery-ui.min"
#= require "vendor/jquery.easing.1.3"
#= require "vendor/jquery.booklet.1.4.0"
#= require "view"
#= require "vendor/underscore"

App = {}
class jQMView extends View
  _default_events =
#    'popupbeforeposition .popup' : 'resizePopUp'
    'popupafterclose .popup'     : 'removeHash'
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

  renderHashPage: =>
    hash = location.hash.replace('#','').toLowerCase()
    if hash == 'contacto'
      return @showPopupContact()
    if hash == 'facebook'
      return @showPopupFc()
    if hash == 'promo'
      return @showPopupPromo()

  showPopupContact: =>
    $(".contactPopup").popup().popup 'open'

  showPopupFc: =>
    $(".fcPopup").popup().popup 'open'

  showPopupPromo: =>
    $(".promoPopup").popup().popup 'open'

ajaxSpinner = ->
    spinner = $(".ui-loader")
    spinner.ajaxStart -> spinner.show()
    spinner.ajaxStop -> spinner.hide()

App.onLoad = ->
  ajaxSpinner()
  App.view = new Application el: $(".mainPage")



  $('.ui-content').css("height","#{maxHeight = $(window).height() - $(".ui-header").height() - $(".ui-footer").height() - 10}px")

  updateHeight  = (e, ret = true)->
    $('.ui-content').css("height","#{maxHeight = $(window).height() - $(".ui-header").outerHeight(true) - $(".ui-footer").outerHeight(true)}px")
    cH = $(".ui-content").outerHeight(true)
    cW = $(".ui-content").width()
    # Ratio 1.375 width /height
    # w / h = r
    # r . h = w
    # h = w / r
    ratioBook = 1.37
    ratio = cW / cH
    container = $(".bookContainer")
    if ratio < ratioBook
      container.css("width","100%")
      cW = container.width()
      container.css("height","#{cW / ratioBook }px")
    else

      container.css("height","100%")
      cH = container.height()
      container.css("width","#{ratioBook * cH }px")

  updateHeight undefined,false
  $(window).bind 'resize', updateHeight

  $('#mybook').booklet({overlays: true,arrows: true,pageNumbers: false,closed:true,hovers:true,autoCenter:true,width: '100%',height: '100%%'})
  $('#mybook').show()
  $('.fcFrame').html '<iframe src="//www.facebook.com/plugins/likebox.php?href=http%3A%2F%2Fwww.facebook.com%2Fdecohomelp&amp;width=420&amp;height=558&amp;colorscheme=light&amp;show_faces=true&amp;border_color&amp;stream=true&amp;header=false" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:420px; height:458px;" allowTransparency="true" style="width:100%;height:100%"></iframe>'
  $('.fcFrame').css 'width','auto'
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


