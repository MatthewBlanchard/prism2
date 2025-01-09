local Inky = require "geometer.inky"
local Button = require "geometer.button"

---@class FileProps : Inky.Props
---@field scale Vector2
---@field name string
---@field overlay love.Canvas
---@field open boolean
---@field justOpen boolean

---@class File : Inky.Element
---@field props FileProps

---@param self File
---@param scene Inky.Scene
local function File(self, scene)
   self.props.name = ""
   self.props.open = false
   self.props.justOpen = false

   self:onDisable(function()
      scene:raise("closeFile")
   end)

   local image = love.graphics.newImage("geometer/assets/filebutton.png")
   local quad = love.graphics.newQuad(0, 0, image:getWidth(), image:getHeight(), image)
   local newButton = Button(scene)
   newButton.props.tileset = image
   newButton.props.hoveredQuad = quad
   newButton.props.onPress = function()
      self.props.open = false
   end

   local saveButton = Button(scene)
   saveButton.props.tileset = image
   saveButton.props.hoveredQuad = quad

   local saveAsButton = Button(scene)
   saveAsButton.props.tileset = image
   saveAsButton.props.hoveredQuad = quad

   local quitButton = Button(scene)
   quitButton.props.tileset = image
   quitButton.props.hoveredQuad = quad
   quitButton.props.onPress = function()
      love.event.quit()
   end

   local image = love.graphics.newImage("geometer/assets/file.png")
   local font =
      love.graphics.newFont("geometer/assets/FROGBLOCK-Polyducks.ttf", 8 * (math.floor(self.props.scale.x) - 1))
   local size = 8 * self.props.scale.x
   local pad = size / 4

   return function(_, x, y, w, h)
      local tileY = y / 8
      love.graphics.draw(image, x, y)
      newButton:render(x + 8, y + 8 * 2, 80, 8)
      saveButton:render(x + 8, y + 8 * 3, 80, 8)
      saveAsButton:render(x + 8, y + 8 * 4, 80, 8)
      quitButton:render(x + 8, y + 8 * 6, 80, 8)

      love.graphics.push("all")
      love.graphics.setFont(font)
      love.graphics.setCanvas(self.props.overlay)
      love.graphics.scale(1, 1)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("NEW", x + size + pad, (tileY + 2) * size + pad)
      love.graphics.print("SAVE", x + size + pad, (tileY + 3) * size + pad)
      love.graphics.print("SAVE AS", x + size + pad, (tileY + 4) * size + pad)
      love.graphics.print(self.props.name, x + size + pad, (tileY + 5) * size + pad)
      love.graphics.print("QUIT", x + size + pad, (tileY + 6) * size + pad)
      love.graphics.pop()

      self.props.justOpen = false
   end
end

---@type fun(scene: Inky.Scene): File
local FileElement = Inky.defineElement(File)
return FileElement