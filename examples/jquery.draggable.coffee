



## DRAGGABLE ########################################

jQuery.fn.draggable = (options) ->
  options ?= {}
  options.shouldMove ?= false
  options.dragClickTolerance ?= 10
  options.dragData ?= null
  options.dragType ?= null

  element = el = this
  startDragX = startDragY = 0
  startPosition = null
  position = null


  currentTarget = null

  # dom = this.get(0)
  # dom.addEventListener "dragstart", (e) ->

  if options.shouldMove
    # requires position absolute
    el.css position: 'absolute'

  dragStart = (e) ->
    e.preventDefault()
    el.css 'pointer-events', 'none'

  enable = el.draggableEnable = ->
    el.bind "mousedown touchstart", start
    el.bind "dragstart", dragStart

  disable = el.draggableDisable = ->
    el.unbind "mousedown touchstart", start
    el.unbind "dragstart", dragStart

  start = (e) ->
    if (e.originalEvent) then e = e.originalEvent
    if (e.type is 'mousedown' and e.which != 1) then return

    # e.preventDefault() # PREVENT DEFAULT HERE - stops dragstart from firing
    # this will get weird with touch?
    # don't trigger a dragstart. it gets triggered by the browser when you start moving
    # el.trigger "dragstart", e
    el.addClass "dragging"

    startPosition = el.position()
    position = {left: startPosition.left, top: startPosition.top}

    if (e.targetTouches)
      startDragX = e.targetTouches[0].pageX
      startDragY = e.targetTouches[0].pageY

      $(window)
        .bind('touchmove', move)
        .bind('touchend touchcancel', stop)

    else
      startDragX = e.clientX
      startDragY = e.clientY
      
      $(window)
        .mousemove(move)
        .mouseup(stop)
        .mouseleave(stop)

  move = (e) ->
    if e.originalEvent then e = e.originalEvent
    x = y = changeX = changeY = null

    if e.targetTouches
      x = e.targetTouches[0].pageX
      y = e.targetTouches[0].pageY
    else
      x = e.clientX
      y = e.clientY

    # check for drops onto our cousins, droppables
    hit = document.elementFromPoint(x, y)

    if currentTarget and hit != currentTarget
      trigger currentTarget, e, "dragleave"

    if hit? and $(hit).data(Droppable)
      trigger hit, e, "dragover"
      currentTarget = hit

    changeX = x - startDragX
    changeY = y - startDragY

    # should I do this automatically?
    position.left += changeX
    position.top += changeY

    if options.shouldMove
      el.css position

    el.trigger "dragmove", {dx:changeX, dy:changeY}

    startDragX = x
    startDragY = y

  trigger = (target, e, name) ->
    event = $.Event name
    event.originalEvent = e
    event.dragData = options.dragData
    event.dragType = options.dragType
    $(target).trigger event

  squareDistance = ->
    Math.abs(startPosition.left - position.left) + Math.abs(startPosition.top - position.top)

  stop = (e) ->
    if e.originalEvent then e = e.originalEvent

    x = e.clientX
    y = e.clientY

    # e.dataTransfer?.setData("text/plain", "wooooot")

    if squareDistance() < options.dragClickTolerance
      el.trigger "dragclick"

    else
      hit = document.elementFromPoint(x, y)
      if hit? and $(hit).data(Droppable)
        trigger hit, e, "drop"

    # cleanup
    el.removeClass "dragging"
    el.trigger "dragend"
    el.css 'pointer-events', 'auto'

    $(window)
      .unbind("mousemove touchmove", move)
      .unbind("mousemove mouseup mouseleave touchend touchcancel", stop)

  # start it!
  enable()

  return this








## DROPPABLE  ################################################

Droppable = "droppable"

jQuery.fn.droppable = (options) ->
  options ?= {}
  options.onDropData ?= (data) -> throw new Error "you should specify onDropData in the options for jquery.draggable"
  options.onDropUrl ?= (url) -> throw new Error "you should specify onDropUrl in the options for jquery.draggable"
  options.dragTypes ?= []     # array of hash types we accept. empty array means you accept all

  element = el = this
  element.data Droppable, options

  # whether we should accept or not
  accepts = (e) ->

    # make this work with urls
    url = e.originalEvent?.dataTransfer?.getData "text/uri-list"
    if url? then e.dragType = "url"

    acceptsAny = options.dragTypes.length is 0
    acceptsType = e.dragType in options.dragTypes
    return acceptsAny or acceptsType

  claim = (e) ->
    e?.preventDefault?()               # required by FF + Safari
    e?.originalEvent?.dataTransfer?.dropEffect = 'copy' # tells the browser what drop effect is allowed here
    return false                       # required by IE

  onDragEnter = (e) ->
    return if not accepts e
    claim e

  onDragLeave = (e) ->
    return if not accepts e
    element.removeClass "dragover"
    claim e

  onDragOver = (e) ->
    return if not accepts e
    element.addClass "dragover"
    claim e

  onDrop = (e) ->
    return if not accepts e
    onDragLeave e

    # jquery drag and drop object! call our dropData function
    if e.dragData?
      options.onDropData e.dragData

    else
      dataTransfer = e.originalEvent.dataTransfer

      ## DRAG FILE
      files = dataTransfer.files ? []

      ## DRAG URL
      # mac chrome canary: text/html, text-uri-list
      # safari: text, text-uri-list
      url = dataTransfer.getData "text/uri-list"
      if url? then options.onDropUrl url

      # I don't know what to do with files!
      # FileReader doesn't work in safari!! Oh well, URLs work, and I'd rather do that anyway :)
      # Array.prototype.forEach.call files, (file) ->
      #   reader = new FileReader()
      #   reader.onload = (e) ->
      #     dropFile scope, {file: e.target.result}
      #   reader.readAsDataURL file
      #   reader.readAsDataURL file
      #   reader.readAsText file
      #   reader.readAsBinaryString file
      #   reader.readAsArrayBuffer file

      # dataTransfer.types.forEach (type) ->
      #   console.log type, dataTransfer.getData(type)

  noop = (e) ->

  # dom.addEventListener "dragover", onDragOver, false
  element.bind 'dragenter', onDragEnter
  element.bind 'dragover', onDragOver
  # dom.addEventListener "dragexit", onDragExit, false
  element.bind "dragleave", onDragLeave
  element.bind "drop", onDrop






