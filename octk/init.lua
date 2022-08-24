-- Main file for Ocawesome101's GUI Toolkit --

local expectlib = require("cc.expect")
local expect = expectlib.expect
local field = expectlib.field
local range = expectlib.range
local wrap = require("cc.strings").wrap

local gui = {
  VERSION = {
    MAJOR = 1,
    MINOR = 0,
    PATCH = 0,
  }
}

local default_style = {
  fg = colors.gray,
  bg = colors.lightGray,
  text = colors.white,
  label = colors.black,
  layout = colors.yellow,
  clickable = colors.lightGray
}

local function mk_obj_mt(name, self)
  return {
    __index = self,
    __name = "Object(octk."..name..")",
    __tostring = function(o)
      return getmetatable(o).__name
    end,
    __call = function(t, ...)
      local new = setmetatable({}, mk_obj_mt(name, t))
      if new.init then new:init(...) end
      return new
    end
  }
end

local function base_init(self, root)
  self.x = 1
  self.y = 1
  self.posPercent = false
  self.w = 100
  self.h = 100
  self.sizePercent = true
  self.centered = false
  self.root = root
end

local function size_setter(self, w, h, p)
  expect(1, w, "number", "string")
  expect(2, h, "number", "string")
  expect(3, p, "boolean", "nil")
  self.w = w
  self.h = h
  self.sizePercent = not not p
  return self
end

local function pos_setter(self, x, y, p, c)
  expect(1, x, "number", "string")
  expect(2, y, "number", "string")
  expect(3, p, "boolean", "nil")
  expect(4, c, "boolean", "nil")
  self.x = x
  self.y = y
  self.posPercent = not not p
  self.centered = not not c
  return self
end

local function base_object(name)
  local obj = {}
  obj.size = size_setter
  obj.position = pos_setter
  local mt = mk_obj_mt(name, {})
  mt.__name = "Base" .. mt.__name
  mt.__index = nil
  return setmetatable(obj, mt)
end

local function round(val)
  return math.floor(val + 0.5)
end

local function percent_of(parent, child)
  return round(parent * (child / 100))
end

local function position_accordingly(parentX, parentY, parentW, parentH,
    childX, childY, childW, childH, cPIP, center)
  if cPIP then
    local offsetX, offsetY = 0, 0
    if center then
      offsetX = round(childW / 2)
      offsetY = round(childH / 2)
    end

    return parentX + percent_of(parentW, childX) - offsetX,
      parentY + percent_of(parentH, childY) - offsetY
  else
    if childX < 0 then childX = childX + parentW end
    if childY < 0 then childY = childY + parentH end
    return parentX + childX, parentY + childY
  end
end

local function resize_accordingly(parentW, parentH, childW, childH, cSIP)
  if cSIP then
    return percent_of(parentW, childW), percent_of(parentH, childH)
  else
    return childW, childH
  end
end

local function fill(t, x, y, w, h, c, f, b)
  local cl, fl, bl = c:rep(w), colors.toBlit(f):rep(w), colors.toBlit(b):rep(w)
  for i=1, h do
    t.setCursorPos(x, y + i - 1)
    t.blit(cl, fl, bl)
  end
end


---- gui.Root ----

gui.Root = base_object "Root"

function gui.Root:init(term)
  expect(1, term, "table")
  self.term = term
  self.timed = {}
  self.style = default_style
  self.autovis = true
  self._children = {}
  return self
end

function gui.Root:add(obj)
  expect(1, obj, "table")
  self._children[#self._children+1] = obj
end

function gui.Root:autovisible(bool)
  expect(1, bool, "boolean")
  self.autovis = bool
  return self
end

function gui.Root:style(style)
  expect(1, style, "table")
  field(style, "fg", "number")
  field(style, "bg", "number")
  field(style, "text", "number")
  field(style, "image", "number")
  field(style, "label", "number")
  field(style, "layout", "number")
  field(style, "clickable", "number")
  return self
end

function gui.Root:timedCallback(interval, callback)
  expect(1, interval, "number")
  expect(2, callback, "function")
  self.timed[#self.timed+1] = {
    interval = interval,
    callback = callback
  }
  return self
end

function gui.Root:main()
  self:_draw()
  while true do
    local sig = table.pack(os.pullEvent())
    self:_draw(nil, nil, nil, nil, sig)
  end
end

function gui.Root:exit()
  self.term.setBackgroundColor(colors.black)
  self.term.clear()
  self.term.setCursorPos(1,1)
  error()
end

function gui.Root:_draw(dx, dy, dw, dh, event)
  local w, h = self.term.getSize()
  dx, dy, dw, dh = dx or 1, dy or 1, dw or w, dh or h
  fill(self.term, dx, dy, dw, dh, " ", self.style.fg, self.style.bg)
  term.setBackgroundColor(self.style.bg)

  for i=1, #self._children do
    local child = self._children[i]
    local drawW, drawH = resize_accordingly(dw, dh, child.w, child.h,
      child.sizePercent)
    local drawX, drawY = position_accordingly(dx, dy, dw, dh, child.x, child.y,
      drawW, drawH, child.posPercent, child.centered)

    child:_draw(drawX, drawY, drawW, drawH, event or {})
  end
end


---- gui.Layout ----

gui.Layout = base_object "Layout"

function gui.Layout:init(root)
  expect(1, root, "table")
  base_init(self, root)
  self.rows = 1
  self.cols = 1
  self._slots = {{}}
end


function gui.Layout:slots(rows, cols)
  expect(1, rows, "number")
  expect(2, cols, "number")

  self.rows = range(rows, 1, math.huge)
  self.cols = range(cols, 1, math.huge)

  self._slots = {}
  for row=1, rows do
    self._slots[row] = {}
  end

  return self
end

function gui.Layout:get(row, col)
  expect(1, row, "number")
  expect(2, col, "number")
  range(row, 1, self.rows)
  range(col, 1, self.cols)

  return self._slots[row][col]
end

function gui.Layout:set(row, col, object)
  expect(1, row, "number")
  expect(2, col, "number")
  range(row, 1, self.rows)
  range(col, 1, self.cols)

  self._slots[row][col] = object
  return self
end

function gui.Layout:_draw(dx, dy, dw, dh, event)
  fill(self.root.term, dx, dy, dw, dh, " ",
    self.root.style.fg, self.root.style.layout)

  local boxW, boxH = round(dw / self.cols), round(dh / self.rows)

  term.setBackgroundColor(self.root.style.layout)
  for row=1, self.rows do
    for col=1, self.cols do
      local box = self._slots[row][col]
      if box then
        local boxX, boxY = dx + boxW * (col-1), dy + boxH * (row-1)
        local drawW, drawH = resize_accordingly(boxW, boxH, box.w, box.h,
          box.sizePercent)
        local drawX, drawY = position_accordingly(boxX, boxY, boxW, boxH,
          box.x, box.y, drawW, drawH, box.posPercent, box.centered)

        box:_draw(drawX, drawY, drawW, drawH, event)
      end
    end
  end
end


---- gui.Label ----

gui.Label = base_object "Label"

function gui.Label:init(root)
  base_init(self, root)
  self._text = { text = "" }
end

function gui.Label:text(text)
  expect(1, text, "string", "table")

  if type(text) == "table" then
    field(text, "text", "string")
    self._text = text

  else
    self._text = { text = text }
  end

  return self
end

function gui.Label:_draw(dx, dy, dw, dh)
  self.root.term.setTextColor(self.root.style.label)
  local lines = wrap(self._text.text, dw)
  for i=1, math.min(#lines, dh) do
    self.root.term.setCursorPos(dx, dy+i-1)
    self.root.term.write(lines[i])
  end
end


---- gui.Image ----

gui.Image = base_object "Image"

function gui.Image:init()
  error("do not use octk.Image yet", 0)
end


---- gui.Clickable ----

gui.Clickable = base_object "Clickable"

function gui.Clickable:init(root)
  base_init(self, root)
  self.callback = function(_,_) end
  self._child = {}
end

function gui.Clickable:onClick(func)
  expect(1, func, "function")
  self.callback = func
  return self
end

function gui.Clickable:child(obj)
  expect(1, obj, "table")
  self._child = obj
  return self
end

function gui.Clickable:_draw(dx, dy, dw, dh, event)
  fill(self.root.term, dx, dy, dw, dh, " ", self.root.style.fg,
    self.root.style.clickable)

  term.setBackgroundColor(self.root.style.clickable)

  if self._child._draw then
    local drawW, drawH = resize_accordingly(dw, dh, self._child.w,
      self._child.h, self._child.sizePercent)
    local drawX, drawY = position_accordingly(dx, dy, dw, dh, self._child.x,
      self._child.y, drawW, drawH, self._child.posPercent, self._child.centered)
    self._child:_draw(drawX, drawY, drawW, drawH)
  end

  if event[1] == "mouse_click" then
    local x, y = event[3], event[4]
    if x >= dx and x <= (dx+dw-1) and y >= dy and y <= (dy+dh-1) then
      self:callback(event[2])
    end
  end
end


---- gui.Toggle ----

gui.Toggle = base_object "Toggle"

function gui.Toggle:init(root)
  base_init(self, root)
  self.state = false
  self._text = { text = "" }
end

function gui.Toggle:get()
  return self.state
end

function gui.Toggle:set(bool)
  expect(1, bool, "boolean")
  self.state = bool
  return self
end

function gui.Toggle:onFlip(func)
  expect(1, func, "function")
  self.flip = func
  return self
end

function gui.Toggle:text(text)
  gui.Label.text(self, text)
  return self
end

function gui.Toggle:_draw(dx, dy, dw, dh, event)
  gui.Label._draw(self, dx + 4, dy, dw, dh)
  self.root.term.setCursorPos(dx, dy)
  self.root.term.setTextColor(colors.black)
  self.root.term.setBackgroundColor(colors.white)
  self.root.term.write("   ")
  self.root.term.setBackgroundColor(self.state and colors.green or colors.gray)
  self.root.term.setCursorPos(dx + (self.state and 0 or 1), dy)
  self.root.term.write("  ")
  if event[1] == "mouse_click" then
    local x, y = event[3], event[4]
    if x >= dx and x <= (dx+dw-1) and y >= dy and y <= (dy+dh-1) then
      self.state = not self.state
      if self.flip then
        self:flip()
      end
    end
  end
end

return gui
