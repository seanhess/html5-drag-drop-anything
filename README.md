
HTML5 Drag and Drop Anything
============================

This readme is meant to be read like a slide presentation. Each header is a new slide. Code accompanying the presentation is also checked in to this repo.

Discuss: TODO add discussion link

About Me
--------

* Cofounded i.TV
* Training and Consulting
* http://seanhess.github.com

References
----------

* [Drag and Drop Basics](http://www.html5rocks.com/en/tutorials/dnd/basics/)
* [The HTML5 Drag and Drop API](http://www.quirksmode.org/blog/archives/2009/09/the_html5_drag.html)
* [MDN - Drag and Drop](https://developer.mozilla.org/en-US/docs/DragDrop/Drag_and_Drop)

http://html5demos.com/drag
- trash items in a list

http://html5demos.com/drag-anything
- drag any item onto the screen and see it's file info

HTML5 Drag and Drop
-------------------

* You can do almost all of this with mouse events
* Supposed to be a higher level API
* Some quirks to worry about

Demos
-----

* [HTML5 Demos - drag to trash](http://html5demos.com/drag)
* [Cards](http://localhost:4022/#/rooms/woot)

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

TODO: ??? Have to also cancel dragenter?

Dragging Data
-------------

Demo: examples/data.html

We usually want to drag something. Think about it as data, not HTML.

Use the data transfer object

    box.addEventListener("dragenter", function(e) {
        e.dataTransfer.setData("text/plain", "hello!")
    })

Then you can read that data in the drop event

    target.addEventListener("drop", function(e) {
        var message = e.dataTransfer.getData("text/plain") 
        console.log("message:", message)
    })

The format type is arbitrary, except in IE. IE requires "Text" or "Url"

TODO: Instead, you can just put crap on the event?

TODO: You could always serialize the JSON into the thing

Accepting only certain things
-----------------------------

Put enough information onto the event to let you decide later

    source.addEventListener("dragstart", function(e) {
        e.dataTransfer.setData("application/json", {message: "hello", type: "message"})
    })

Decide whether to cancel (accept) the drag in dragover

    target.addEventListener("dragover", function(e) {
        var data = e.dataTransfer.getData("application/json")
        if (data.type == "message") {
            e.target.classList.add("draggingOver")
            e.preventDefault()
            return false
        }
    })

Remember dragover gets called a lot. You can set and check a value on the event instead of in the dataTransfer

Controlling the Drag Visual
---------------------------

TODO: Manipulate the starting item
TODO: Manipulate the indicator
TODO: Highlighting the target when it happens (listen to dragstart on document?)
TODO: pointer-events: none -- to prevent it from grabbing the 
TODO: dataTransfer.setDragImage

Moving the item instead of the indicator
----------------------------------------

Dragging URLs and Images
------------------------

Dragging Files
--------------

Browser Support
---------------

TODO: show browser support
TODO: modernizer

Mobile
------

TODO: Not supported, but have touchstart, touchmove, touchend

Sortable List
-------------

TODO: how would I even do this?
TODO: use http://farhadi.ir/projects/html5sortable/



event.dataTransfer.effectAllowed = "copy";
https://developer.mozilla.org/en-US/docs/DragDrop/Drag_Operations



Todo
----

[ ] event parameters: clientX, originalTarget, etc

Outline
-------

?? Demo cards thing? - http://localhost:4022/#/rooms/woot

draggable attribute
modernizr
dragging something over
changing something when it starts
transferring data

accepting different kinds of data on different elements

Magic: weird cancellation policies
  -- show expecations and the magic words
  -- make it fun. Expected: nope!

dragging on urls and images

making an angular widget?
making a jquery component?
making a sortable list?

So, what's my cool project at the end?

Browser Compatibility

MAYBE
Mobile dragging! (using touch start, etc)

