#= require "vendor/jquery"
#= require "vendor/jquery-ui.min"
#= require "vendor/jquery.easing.1.3"
#= require "vendor/jquery.booklet.1.4.0"

#= require "vendor/underscore"

App = {}

ajaxSpinner = ->
    spinner = $(".ui-loader")
    spinner.ajaxStart -> spinner.show()
    spinner.ajaxStop -> spinner.hide()

App.onLoad = ->
  ajaxSpinner()
  #$("body").css()
  $('.ui-content').css("height","#{$(window).height() - 90}")
  $('#mybook').booklet({overlays: true,arrows: true,closed: true,hovers:true,name: 'Catalogo',autoCenter:true,width: '55%',height: '100%',hash: true})
  $('#mybook').show()

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



