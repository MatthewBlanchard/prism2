if not spectrum then
   error("Geometer depends on spectrum!")
end

geometer = {}

require "geometer.tool"
require "geometer.panel"
require "geometer.modification"
require "geometer.tools.rect"
require "geometer.tools.pen"
require "geometer.tools.line"
require "geometer.tools.erase"
require "geometer.tools.ellipse"
require "geometer.tools.bucket"
require "geometer.gamestates.editorstate"
require "geometer.gamestates.mapgenerator"
require "geometer.gamestates.prefabeditor"

--- @type Keybinding
local keybinds = require "geometer.keybindingschema"

---@alias Placeable Actor|Cell

---@class GeometerAttachable : Object
---@field getCell fun(self, x:integer, y:integer): Cell
---@field setCell fun(self, x:integer, y:integer, cell: Cell|nil)
---@field addActor fun(self, actor: Actor)
---@field removeActor fun(self, actor: Actor)
---@field getActorsAt fun(self, x:integer, y:integer)
---@field inBounds fun(self, x: integer, y:integer)
---@field eachActorAt fun(self, x:integer, y:integer): fun()
---@field eachActor fun(self): fun()
---@field eachCell fun(self): fun()
---@field debug boolean

---@class Geometer : Object
---@field attachable GeometerAttachable
---@field camera Camera
---@field active boolean
---@field editor Editor
---@field undoStack Modification[]
---@field redoStack Modification[]
---@field placeable Placeable|nil
---@field tool Tool|nil -- TODO: Default to a tool!
local Geometer = prism.Object:extend("Geometer")
geometer.Geometer = Geometer

function Geometer:__new(attachable, display)
   self.attachable = attachable
   self.display = display
   self.active = false
   self.placeable = prism.cells.Wall
   self.tool = geometer.PenTool()
   print("tool", self.tool)
end

local Inky = require "geometer.inky"
local Editor = require "geometer.editorelement"

local scene
local pointer

local scaler = math.min(love.graphics.getWidth() / 320, love.graphics.getHeight() / 200)
local scale = prism.Vector2(scaler, scaler)

function Geometer:isActive()
   return self.active
end

function Geometer:startEditing()
   self.active = true
   scene = Inky.scene()
   pointer = Inky.pointer(scene)
   self.editor = Editor(scene)
   self.editor.props.display = self.display
   self.editor.props.attachable = self.attachable
   self.editor.props.scale = scale
   self.editor.props.geometer = self

   self.undoStack = {}
   self.redoStack = {}

   self.tool = getmetatable(self.tool)()

   self.attachable.debug = false
end

function Geometer:update(dt)
   local mx, my = love.mouse.getX(), love.mouse.getY()
   pointer:setPosition(mx / scale.x, my / scale.y)

   if self.editor.props.quit then
      self.active = false
      self.editor.props.quit = false
   end

   scene:raise("update", dt)

   if self.tool then -- TODO: Remove when default added.
      self.tool:update(dt, self)
   end
end

--- @param modification Modification
function Geometer:execute(modification)
   modification:execute(self.attachable)
   table.insert(self.undoStack, modification)
end

function Geometer:undo()
   if #self.undoStack == 0 then
      return
   end

   local modification = table.remove(self.undoStack, #self.undoStack)
   modification:undo(self.attachable)
   table.insert(self.redoStack, modification)
end

function Geometer:redo()
   if #self.redoStack == 0 then
      return
   end

   local modification = table.remove(self.redoStack, #self.redoStack)
   modification:execute(self.attachable)
   table.insert(self.undoStack, modification)
end

function Geometer:draw()
   scene:beginFrame()

   self.editor:render(0, 0, love.graphics.getWidth(), love.graphics.getHeight())

   scene:finishFrame()
end

function Geometer:mousereleased(x, y, button)
   if button == 1 then
      pointer:raise("release")
   end
end

function Geometer:mousepressed(x, y, button)
   if button == 1 then
      pointer:raise("press")
   end
end

function Geometer:mousemoved(x, y, dx, dy, istouch)
   if love.mouse.isDown(2) then
      pointer:setPosition(x, y)
      pointer:raise("drag", dx, dy)
   end
end

function Geometer:keypressed(key, scancode)
   local action = keybinds:keypressed(key)
   if action == "undo" then
      self:undo()
   elseif action == "redo" then
      self:redo()
   end
end

function Geometer:wheelmoved(dx, dy)
   pointer:raise("scroll", dx, dy)
end
