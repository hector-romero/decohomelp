#= require "vendor/underscore"

_.subMap = (obj, props, context) ->
  result = {}
  if obj? and _.isArray props
    _.each props, (key) ->
      result[key] = obj[key]
  result

Tools = {}

Tools.centsToCurrencyString = (number) ->
  number #or= 0
  '$' + (number / 100).toFixed(2)

Tools.stringCurrencyToCents = (string ) ->
  result = (parseFloat string.replace /\$/,'') * 100
  result or 0

Tools.toTitleCase= (str)->
  str.replace /\w\S*/g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

Tools.isNumericKey = (keyCode) ->
  key = String.fromCharCode keyCode
  regex = /[0-9]/
  regex.test(key)

Tools.isNumber = (string)->
  /^[0-9]*$/.test string


# NAVIGATOR
# Object to controll page navigation.
# Is here to solve crss dependecy problems.
Tools.getNavigationControler = (pages,noLoggedPages,User) ->
  lastPage = ''
  renderHashPage= ->
    hash  = location.hash.replace('#','').toLowerCase()
    if User.isLoggedIn()
      if pages[hash]
        goToPage hash
      else if hash == 'logout'
        User.logOut()
      else
        goToPage defaultPage
    else
      if noLoggedPages[hash]
        goToPage hash
      else
        showLogin hash

  goToPage = (pageName, changeHash = true, options) ->
    console.log "Going to page #{pageName}, #{(if changeHash then '' else 'not ')}changing hash"
    if pages[pageName] or noLoggedPages[pageName]
      $page = $("##{pageName}")
      unless $page[0]
        view = new (pages[pageName] or noLoggedPages[pageName])
          id: pageName
        view.render()
        $page = view.$el
    unless $page.hasClass 'ui-page-active'
      lastPage = pageName
      navigate $page, options
    location.hash = lastPage if changeHash

  navigate = ($page, options = {}) =>
      params = _.extend changeHash: false, options
      $("body").append $($page)
      $.mobile.changePage $page, params

  showLogin = (nextPage, options = {}) ->
      options.reverse or= true
      if pages[nextPage] == undefined
        nextPage = defaultPage
      view = new noLoggedPages['login']
          nextPage: nextPage
      view.render()
      $("body").append view.$el
      goToPage 'login',true, options

  renderFirstPage = ->
    renderHashPage()
    $(window).bind "hashchange", -> renderHashPage()

  navigateToHash = (hash,options) ->
    location.hash =  hash

  User.onLogOut = showLogin
  return {renderHashPage,goToPage,navigate,showLogin,renderFirstPage,navigateToHash}

window.Tools = Tools