#= require "vendor/underscore"
# From Backbone View

# Helper function to get a value from a Backbone object as a property
# or as a function.
getValue = (object, prop) ->
  return null  unless object and object[prop]
  (if _.isFunction(object[prop]) then object[prop]() else object[prop])

# Cached regex to split keys for `delegate`.
delegateEventSplitter =  /^(\S+)\s*(.*)$/
#List of view options to be merged as properties.
viewOptions = ['model', 'collection', 'el', 'id', 'attributes', 'className', 'tagName']

eventSplitter = /\s+/
Events =
  on: (events, callback, context) ->
    calls = undefined
    event = undefined
    node = undefined
    tail = undefined
    list = undefined
    return this  unless callback
    events = events.split(eventSplitter)
    calls = @_callbacks or (@_callbacks = {})
    while event = events.shift()
      list = calls[event]
      node = (if list then list.tail else {})
      node.next = tail = {}
      node.context = context
      node.callback = callback
      calls[event] =
        tail: tail
        next: (if list then list.next else node)
    this

  off: (events, callback, context) ->
    event = undefined
    calls = undefined
    node = undefined
    tail = undefined
    cb = undefined
    ctx = undefined
    return  unless calls = @_callbacks
    unless events or callback or context
      delete @_callbacks

      return this
    events = (if events then events.split(eventSplitter) else _.keys(calls))
    while event = events.shift()
      node = calls[event]
      delete calls[event]

      continue  if not node or not (callback or context)
      tail = node.tail
      while (node = node.next) isnt tail
        cb = node.callback
        ctx = node.context
        @.on event, cb, ctx  if (callback and cb isnt callback) or (context and ctx isnt context)
    this

  trigger: (events) ->
    event = undefined
    node = undefined
    calls = undefined
    tail = undefined
    args = undefined
    all = undefined
    rest = undefined
    return this  unless calls = @_callbacks
    all = calls.all
    events = events.split(eventSplitter)
    rest = slice.call(arguments, 1)
    while event = events.shift()
      if node = calls[event]
        tail = node.tail
        node.callback.apply node.context or this, rest  while (node = node.next) isnt tail
      if node = all
        tail = node.tail
        args = [event].concat(rest)
        node.callback.apply node.context or this, args  while (node = node.next) isnt tail
    this

Events.bind = Events.on
Events.unbind = Events.off

#View = Backbone.View = (options) ->
class View extends Events
  constructor: (options) ->
    @cid = _.uniqueId("view")
    @_configure options or {}
    @_ensureElement()
    @initialize.apply this, arguments
    @delegateEvents()

#  _.extend View::, Events,
  tagName: "div"

  $: (selector) ->
    @$el.find selector

  initialize: ->

  render: ->
    this

  remove: =>
    @$el.remove()
    this

  make: (tagName, attributes, content) ->
    el = document.createElement(tagName)
    $(el).attr attributes  if attributes
    $(el).html content  if content
    el

  setElement: (element, delegate) ->
    @undelegateEvents()  if @$el
    @$el = (if (element instanceof $) then element else $(element))
    @el = @$el[0]
    @delegateEvents()  if delegate isnt false
    this

  delegateEvents: (events) ->
    return  unless events or (events = getValue(this, "events"))
    @undelegateEvents()
    for key of events
      method = events[key]
      method = this[events[key]]  unless _.isFunction(method)
      throw new Error("Method \"" + events[key] + "\" does not exist")  unless method
      match = key.match(delegateEventSplitter)
      eventName = match[1]
      selector = match[2]
      method = _.bind(method, this)
      eventName += ".delegateEvents" + @cid
      if selector is ""
        @$el.bind eventName, method
      else
        @$el.delegate selector, eventName, method

  undelegateEvents: ->
    @$el.unbind ".delegateEvents" + @cid

  _configure: (options) ->
    options = _.extend({}, @options, options)  if @options
    i = 0
    l = viewOptions.length

    while i < l
      attr = viewOptions[i]
      this[attr] = options[attr]  if options[attr]
      i++
    @options = options

  _ensureElement: ->
    unless @el
      attrs = getValue(this, "attributes") or {}
      attrs.id = @id  if @id
      attrs["class"] = @className  if @className
      @setElement @make(@tagName, attrs), false
    else
      @setElement @el, false


#Exports:
window.View = View