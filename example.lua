-- OCTK example

local gui = require("octk")

local root = gui.Root(term.current())

root:add(gui.Layout(root)
  :size(90, 90, true)
  :position(50, 50, true, true)
  :slots(2, 1)
  :set(1, 1, gui.Label(root)
    :text("this is some very extremely obstemiously unimaginably long text!")
  ):set(2, 1, gui.Clickable(root)
    :size(8, 1, false)
    :position(-9, -3, false, false)
    :child(
      gui.Label(root)
        :text("Next >")
        :position(60, 50, true, true)
    )
  ))

root:_draw()
term.setCursorPos(1,1)
