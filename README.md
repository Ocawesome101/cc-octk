# Ocawesome101's GUI Toolkit

This is my attempt at a documentation-driven GUI toolkit for ComputerCraft.

It intends to make creation and layout of complex interfaces as simple as possible.

## Core Features

All GUI objects use a "builder" syntax.  This allows more streamlined usage of certain features.


## GUI Objects

  - `octk.Root(termObject)`:  Creates new a root object assigned to a given term object.
    - `Root:autovisible(boolean)`:  Set whether the toolkit should manage window visibility or leave it for another program to decide.  The default is `true`.
    - `Root:size(w, h, percent)`:  Sets the size of the object relative to the parent object.  This is available on all elements.
    - `Root:position(x, y, percent, centered)`: Sets the position of the object relative to the parent object.  This is available on all elements.
    - `Root:style(style)`:  Set the UI style.  See **Styles** below.
    - `Root:timedCallback(interval, callback)`:  Add a function `callback` that will be called every `interval` seconds.  If `interval` is `0`, the function will be called whenever the main loop receives an event.
    - `Root:main()`:  Begin the GUI's main loop.

  - `octk.Layout(RootObject)`:  Creates a new layout object.
    - `Layout:slots(rows, cols)`:  Sets how many rows and columns this layout object has.  **Every time you change this you must re-add ALL elements.**
    - `Layout:get(row, col)`:  Returns the object in a given slot.
    - `Layout:set(row, col, object)`:  Sets the object in a given slot.

  - `octk.Label(RootObject)`:  Creates a new label object.
    - `Label:text(string|table)`:  Sets the text of that label object.  If the given argument is a table, the label will read its text from the `text` field of that table to allow dynamic text updates.

  - `octk.Image(RootObject)`:  Creates a new image object.
    - `Image:image(path)`:  Sets the object's path to the specified image.  The image must be in BIMG format.
    - `Image:mode(mode)`:  Sets how a wrongly sized image should be displayed.  The default is to clip it, or display black borders around it.


  - `octk.Clickable(RootObject)`:  Creates a new clickable object.
    - `Clickable:onClick(func(obj, button))`:  Set the object's callback.
    - `Clickable:child(Object)`:  Set the child of the `Clickable`.

## Examples

```lua
local gui = require("octk")

local root = gui.Root(term.current())
```
