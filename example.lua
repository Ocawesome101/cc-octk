-- OCTK example

local gui = require("octk")

local root = gui.Root(term.current())

local l1 = { text = "This is some very long text.  Lorem ipsum dolor sit amet.  And stuff, I guess." }
local l2 = { text = "Next >" }

root:add(gui.Layout(root)
  :size(90, 90, true)
  :position(50, 50, true, true)
  :slots(2, 1)
  :set(1, 1, gui.Label(root)
    :text(l1)
  ):set(2, 1, gui.Clickable(root)
    :size(8, 1, false)
    :position(-9, -3, false, false)
    :child(
      gui.Label(root)
        :text(l2)
        :position(60, 50, true, true)
    ):onClick(function(obj, button)
      if button == 1 then
        l1.text = "other text!\n\nclick Exit to exit"
        l2.text = "Exit"
        obj:onClick(function()
          obj.root:exit()
        end)
      end
    end)
  ))

root:main()
term.setCursorPos(1,1)
