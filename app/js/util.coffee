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

Tools.isValidEmail = (email) ->
  mailPatern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,4})+$/
  email.search(mailPatern) == 0

Tools.toTitleCase= (str)->
  str.replace /\w\S*/g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

Tools.isNumericKey = (keyCode) ->
  key = String.fromCharCode keyCode
  regex = /[0-9]/
  regex.test(key)

Tools.isNumber = (string)->
  /^[0-9]*$/.test string

creditCard =
  VISA :       'visa'
  MASTERCARD : 'mastercard'
  DISCOVER :   'discover'
  UNKNOWN :    'unknown'
  INVALID :     null

creditCard.getType = (accountNumber = '')->
  #Mastercard: length 16, prefix 51-55
  if (/^5[1-5]/.test(accountNumber))
    return creditCard.MASTERCARD
  #Visa: length 16, prefix 4, dashes optional.
  else if (/^4/.test(accountNumber))
    return  creditCard.VISA
  #Discover: length 16, prefix 6011
  else if (/^6011/.test(accountNumber))
    return  creditCard.DISCOVER
  return creditCard.UNKNOWN

#FROM: http://www.breakingpar.com/bkp/home.nsf/0/87256B280015193F87256CC70060A01B
creditCard.isValidNumber = (accountNumber = '')->
  accountNumber = accountNumber.replace(/\-/,'').replace(/\ /,'')
  return false unless accountNumber.length == 16 #*1
  return false if creditCard.getType(accountNumber) == creditCard.UNKNOWN

  # Checksum ("Mod 10")
  # Add even digits in even length strings or odd digits in odd length strings.
  checksum = 0
  i = 1
  while i <= accountNumber.length
    checksum += parseInt(accountNumber.charAt(i))
    i += 2
  # Analyze odd digits in even length strings or even digits in odd length strings.
  i = 0
  while i < accountNumber.length
    digit = parseInt(accountNumber.charAt(i)) * 2
    if digit < 10
      checksum += digit
    else
      checksum += (digit - 9)
    i += 2
  if (checksum % 10) is 0
    true
  else
    false

  #NOTES:
  #1. Currently, all suported credit cards have 16 digits

#Expire date form: yyyy-mm
creditCard.isValidExpirationDate= (year,month) ->
  return false unless month > 0 and month < 13
  expDate = new Date()
  expDate.setFullYear year, month - 1, 1 #month - 1 cause of date starts with 0 = jan
  today = new Date()
  return expDate > today

#
#creditCard.isValid = (creditCardNumber, expireDate) ->
#  return false unless creditCard.isValidNumber creditCardNumber
#

Tools.creditCard = creditCard

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