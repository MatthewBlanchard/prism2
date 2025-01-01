local Inky = require("geometer.inky")

local Button = require("geometer.button")
local EditorGrid = require("geometer.gridelement")
local Tools = require("geometer.tools")

---@class EditorProps : Inky.Props
---@field gridPosition Vector2
---@field display Display
---@field level Level
---@field scale Vector2
---@field quit boolean
---@field geometer Geometer

---@class Editor : Inky.Element
---@field props EditorProps

---@param self Editor
---@param scene Inky.Scene
---@return function
local function Editor(self, scene)
   self.props.gridPosition = prism.Vector2(24, 24)

   local atlas = spectrum.SpriteAtlas.fromGrid("geometer/gui.png", 24, 12)
   love.graphics.setDefaultFilter("nearest", "nearest")

   local canvas = love.graphics.newCanvas(320, 200)
   local frame = love.graphics.newImage("geometer/frame.png")

   local fileButton = Button(scene)
   fileButton.props.tileset = atlas.image
   fileButton.props.unpressedQuad = atlas:getQuadByIndex(1)
   fileButton.props.pressedQuad = atlas:getQuadByIndex(2)

   local playButton = Button(scene)
   playButton.props.tileset = atlas.image
   playButton.props.unpressedQuad = atlas:getQuadByIndex(3)
   playButton.props.pressedQuad = atlas:getQuadByIndex(4)
   playButton.props.onRelease = function()
      self.props.quit = true
   end

   local debugButton = Button(scene)
   debugButton.props.tileset = atlas.image
   debugButton.props.unpressedQuad = atlas:getQuadByIndex(5)
   debugButton.props.pressedQuad = atlas:getQuadByIndex(6)
   debugButton.props.onRelease = function ()
      self.props.quit = true
      self.props.level.debug = true
   end

   local cellButton = Button(scene)
   cellButton.props.tileset = atlas.image
   cellButton.props.unpressedQuad = atlas:getQuadByIndex(7)
   cellButton.props.pressedQuad = atlas:getQuadByIndex(8)

   local actorButton = Button(scene)
   actorButton.props.tileset = atlas.image
   actorButton.props.unpressedQuad = atlas:getQuadByIndex(9)
   actorButton.props.pressedQuad = atlas:getQuadByIndex(10)

   local tools = Tools(scene)

   local grid = EditorGrid(scene)
   grid.props.scale = prism.Vector2(2, 2)
   self:useEffect(function()
      grid.props.geometer = self.props.geometer
      grid.props.map = self.props.level.map
      grid.props.actors = self.props.level.actorStorage
      grid.props.display = self.props.display
      grid.props.level = self.props.level
      
      tools.props.geometer = self.props.geometer
   end, "level", "display")

   local background = prism.Color4.fromHex(0x181425)
   return function(_, x, y, w, h)
      love.graphics.setBackgroundColor(background:decompose())
      love.graphics.push("all")
      love.graphics.setColor(1, 1, 1, 1)

      love.graphics.setCanvas(canvas)
      love.graphics.clear()
      love.graphics.draw(frame)
      fileButton:render(8, 184, 24, 12)
      playButton:render(8 * 2 + 24, 184, 24, 12)
      debugButton:render(8 * 6 + 24, 184, 24, 12)
      tools:render(120, 184, 112, 12)
      love.graphics.setCanvas()

      grid:render(
         self.props.gridPosition.x,
         self.props.gridPosition.y,
         225 * self.props.scale.x,
         200 * self.props.scale.y
      )
      love.graphics.scale(self.props.scale:decompose())
      --local y = (love.graphics.getHeight() - (200 * self.props.scale.y)) / 2
      love.graphics.draw(canvas, 0, 0)

      love.graphics.pop()
   end
end

---@type fun(scene: Inky.Scene): Editor
local EditorElement = Inky.defineElement(Editor)
return EditorElement
