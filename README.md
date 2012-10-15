
HTML5 Drag and Drop Anything
============================

This readme is meant to be read like a slide presentation. Each header is a new slide. Code accompanying the presentation is also checked in to this repo.

About Me
--------

* Just left i.TV
* Previously consulting and training
* http://seanhess.github.com

References
----------

* [Drag and Drop Basics](http://www.html5rocks.com/en/tutorials/dnd/basics/)
* [The HTML5 Drag and Drop API](http://www.quirksmode.org/blog/archives/2009/09/the_html5_drag.html)
* [MDN - Drag and Drop](https://developer.mozilla.org/en-US/docs/DragDrop/Drag_and_Drop)

HTML5 Drag and Drop
-------------------

* Higher level than mouse events
* Can drag any div, image or link
* Can drag files and links from your desktop

* Limitation: Some quirks and browser incompatibilities
* Limitation: Doesn't map to mobile very well

Demos
-----

* [HTML5 Demos - drag to trash](http://html5demos.com/drag)
* [HTML5 Demos - automatic upload](http://html5demos.com/dnd-upload)
* [HTML5 Demos - drag anything](http://html5demos.com/drag-anything)
* [More Complex Example: Cards](http://localhost:4022/#/rooms/woot) (will not work online)

Images, Links, and Draggable
----------------------------

Images and links are draggable by default

You can make any div draggable

    <div id="box" draggable="true" class="blue square"></div>

This leaves the item in place, and drags an indicator

Simple Drag Events
------------------

Demo: examples/simple.html

You can bind to dragstart and dragend to know when an item is dragged

    var box = document.getElementById("box")
    box.addEventListener("dragstart", function(e) {
      // e.target == box
      // inspect the event
    })

    box.addEventListener("dragend", function(e) {

    })

    box.addEventListener("drag", function(e) {
      // called constantly as you hold the drag
    })

These are important for setting data and changing the visual appearance

Simple Drop Events
------------------

Add another element to drag things on to
  
    <div id="target" class="target"></div>

dragenter and dragleave do what you'd expect

    var target = document.getElementById("target")
    target.addEventListener("dragenter", function(e) {
      // give the user visual feedback
      e.target.classList.add("draggingOver")
    })

    target.addEventListener("dragleave", function(e) {
      e.target.classList.remove("draggingOver")
    })

dragover is called continuously when over your area (even when not moving)

    target.addEventListener("dragover", function(e) {
      // this gets called a lot!
    })

Accepting a Drop
----------------

You must cancel the dragover event to indicate you accept that kind of drag

    target.addEventListener("dragover", function(e) {
      e.preventDefault()
      return false
    })

    target.addEventListener("drop", function(e) {
      // dropped! Check out e.dataTransfer
    })

Note that dragleave is not called on a drop.

Dragging Data
-------------

Demo: examples/data.html

We usually want to drag something. Think about it as data, not HTML.

Use the data transfer object to share data between events

    box.addEventListener("dragenter", function(e) {
        e.dataTransfer.setData("text/plain", "hello!")
    })

Then you can read that data in the drop event

    target.addEventListener("drop", function(e) {
        var message = e.dataTransfer.getData("text/plain") 
        console.log("message:", message)
    })

The format type is arbitrary, except in IE. IE requires "Text" or "Url".

I can't find a way to set an object, but you could serialize an object.

    e.dataTransfer.setData("something", JSON.stringify({key: "value"}))

Accepting only certain things
-----------------------------

Demo: examples/buckets.html

Put enough information onto the event to let you decide later

    source.addEventListener("dragstart", function(e) {
        e.dataTransfer.setData("text/message", "hello")
    })

Decide whether to cancel (accept) the drag in dragover. Consider using the types array

    target.addEventListener("dragenter", function(e) {
        if (e.dataTransfer.types[0] == "text/message") {
            e.target.classList.add("draggingOver")
        }
    })

    target.addEventListener("dragover", function(e) {
        if (e.dataTransfer.types[0] == "text/message") {
            e.preventDefault()
            return false
        }
    })

Remember dragover gets called a lot. You don't want to deserialize JSON every time. 

Visuals: setDragImage
---------------------

Demo: examples/visuals.html

You can change the visual indicator for the drag, and control where the pointer is

    source.addEventListener("dragstart", function(e) {
        var img = document.createElement("img")
        img.src = "img/drag-indicator.png"
        e.dataTransfer.setDragImage(img, 0, 0)
    })

You can set it to a div instead, but it only works if the div is already displayed somewhere. You can't even render it off screen. 

    // this works
    var div = document.getElementById("indicator")

    // neither of these work. this doesn't work. The cloned version isn't in the DOM.
    var div = document.getElementById("indicator").cloneNode()
    var div = document.createElement("div")

    // customize it
    div.innerHTML = "dragging stuff"

    e.dataTransfer.setDragImage(div, 0, 0)

You can also set it to a canvas


Visuals: Manipulate the dragged item 
------------------------------------

Any changes affect both the original item AND the indicator

    source.addEventListener("dragstart", function(e) {
        // updates both!
        e.target.style.opacity = 0.5
    })

If you set the drag image to another element, you can control them separately

    source.addEventListener("dragstart", function(e) {
        e.target.style.opacity = 0.5
        var img = document.getElementById("indicator")
        e.dataTransfer.setDragImage(img, 0, 0)
    })

Visuals: Highlight the drop target
----------------------------------

It can be good to show where they should put something. Listen on document because you want to show before its dragged over your item

    document.addEventListener("dragenter", function(e) {
        if (event is a name)
          document.getElementById("names").classList.add("validTarget")

        else if (event is a food)
          document.getElementById("foods").classList.add("validTarget")
    })

Visuals: Greedy sub-elements grabbing the drag
----------------------------------------------

In the data example, we lose our highlight over existing elements. `dragleave` is fired over the main element

* set `pointer-events: none` on the children
* do some kind of hit test inside your leave handler
* set a timer in dragover instead of clearing in leave
* keep track of the currently entered element and don't clear if its a descendant
 
Visuals: Moving the item instead of the indicator
-------------------------------------------------

There's no way to do this with the drag and drop API. You'll have to use mouse events instead, then manually move the item. 

You can get close by hiding the original and calling `setDragImage` with a copy

Native Dragging: URLs and Images
--------------------------------

Demo: examples/images.html

You can drag links and images across browser windows. Chrome and Safari populate `text/uri-list` (according to the spec). IE sets "url"

    target.addEventListener('drop', function(e) {
        // don't let the browser switch to an image!
        e.preventDefault()

        // read the data
        var url = e.dataTransfer.getData("url") || e.dataTransfer.getData("text/uri-list")
        var img = document.createElement("img")
        img.src = url
        target.appendChild(img)
    })

All browsers seem to populate `text/html`

You could drag a link to anything, including JSON data. You could download the data with XHR and do something with it

Native Dragging: Files
----------------------

Demo: examples/files.html

If you drag files onto something droppable it populates `dataTransfer.files`. Just stick the files into a `FormData`

    target.addEventListener('drop', function(e) {
        e.preventDefault()
        var formData = new FormData()
        formData.append('file', e.dataTransfer.files[0])
        // then POST it to your server with formData as the body
    })

You can render a preview with `FileReader`

    var reader = new FileReader()
    reader.onload = function (event) {
      var image = new Image()
      image.src = event.target.result
      target.appendChild(image)
    }
    reader.readAsDataURL(e.dataTransfer.files[0])

Browser Support
---------------

The code here should work in modern versions of all 4 major browsers. Consider using [Modernizr](http://modernizr.com/) to check for the availability of these features. 

Mobile
------

The Drag and Drop API doesn't really map cleanly on mobile devices. Some mobile browsers are working on it, but it's never going to be perfect because gestures mean something: drag means to scroll the page. 

Use touch events instead or a gesture framework to create a different mobile experience.

Sortable List
-------------

I wanted to create a sortable list, but I ran out of time. Here's a great jQuery plugin that uses the drag and drop API for reference. 

http://farhadi.ir/projects/html5sortable/


Out of Time
-----------

Drop effect/effectAllowed

