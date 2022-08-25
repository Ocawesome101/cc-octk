-- OCTK example

local gui = require("octk")

local root = gui.Root(term.current()):autovisible(false)

local l1 = { text = "This is some very long text.  Lorem ipsum dolor sit amet.  And stuff, I guess." }
local l2 = { text = "Next >" }
local l3 = { text = "An example toggle (off)" }

root:add(gui.Layout(root)
  :size(0.8, 0.8)
  :position(0.5, 0.5, true, true)
  :slots(3, 1)
  :set(1, 1, gui.Label(root)
    :position(0.1, 0.5)
    :size(0.8, 0.8)
    :text(l1)
  ):set(2, 1, gui.Layout(root)
    :slots(1, 2)
    :set(1, 1, gui.Toggle(root)
      :position(0.5, 0.5, true, true)
      :size(1, 1)
      :onFlip(function(obj)
        l3.text = "An example toggle "..(obj.state and "(on)" or "(off)")
      end)
    ):set(1, 2, gui.Label(root)
      :position(1, 0.5, false, true)
      :size(1, 1)
      :text(l3)
    )
  ):set(3, 1, gui.Clickable(root)
    :size(8, 1.01, false)
    :position(-9, -3)
    :child(
      gui.Label(root)
        :text(l2)
        :position(1.01, 0.5, false, true)
        :size(-2, 0.5)
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
