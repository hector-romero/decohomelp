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
    'click .error'               : 'clearError'
    'click .back'                : 'goBack'
    'keypress input.numeric'     : 'filterNumericKeys'
    'input input.checkLength'     : 'maxLengthCheck'


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
    'click .btnContact' : 'showPopup'

  renderHashPage: =>
    hash = location.hash.replace('#','').toLowerCase()
    if hash == 'contacto'
      @showPopup()

  showPopup: =>
    popup = @$(".popup")
    popup.popup()
    popup.popup 'open'

ajaxSpinner = ->
    spinner = $(".ui-loader")
    spinner.ajaxStart -> spinner.show()
    spinner.ajaxStop -> spinner.hide()

App.onLoad = ->
  ajaxSpinner()
  App.view = new Application el: $(".mainPage")
  updateHeight  = (e, ret = true)->
    return if ret and location.hash.match(/1$/)
    $('.ui-content').css("max-height","#{maxHeight = $(window).height() - 128 }px")
    height = $("#mybook").width() * 0.76
    $('.ui-content').css("height","#{height}px")
    $('#mybook').css("height","#{height}px")
    $('#mybook').css("max-height","#{height}px !important")
  updateHeight undefined,false
  $(window).bind 'resize', updateHeight

  $('#mybook').booklet({overlays: true,arrows: true,closed: true,hovers:true,name: 'Catálogo',autoCenter:true,width: '75%',height: '100%',hash: true})
  $('#mybook').show()
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



