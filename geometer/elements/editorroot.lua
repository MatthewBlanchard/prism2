local Inky = geometer.require "inky"

---@type ButtonInit
local Button = geometer.require "elements.button"
---@type FilePanelInit
local FilePanel = geometer.require "elements.filepanel"
---@type EditorGridInit
local EditorGrid = geometer.require "elements.editorgrid"
---@type ToolsInit
local Tools = geometer.require "elements.tools"
---@type SelectionPanelInit
local SelectionPanel = geometer.require "elements.selectionpanel"

---@class EditorRootProps : Inky.Props
---@field gridPosition Vector2
---@field display Display
---@field attachable SpectrumAttachable
---@field scale Vector2
---@field quit boolean
---@field editor Editor

---@class EditorRoot : Inky.Element
---@field props EditorRootProps

---@param self EditorRoot
---@param scene Inky.Scene
---@return function
local function EditorRoot(self, scene)
   self.props.gridPosition = prism.Vector2(24, 24)

   local atlas = spectrum.SpriteAtlas.fromGrid(geometer.assetPath .. "/assets/gui.png", 24, 12)
   love.graphics.setDefaultFilter("nearest", "nearest")

   local canvas = love.graphics.newCanvas(320, 200)
   local overlay = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
   local frame = love.graphics.newImage(geometer.assetPath .. "/assets/frame.png")

   local filePanel = FilePanel(scene)
   filePanel.props.scale = self.props.scale
   filePanel.props.overlay = overlay

   local fileButton = Button(scene)
   fileButton.props.tileset = atlas.image
   fileButton.props.unpressedQuad = atlas:getQuadByIndex(1)
   fileButton.props.pressedQuad = atlas:getQuadByIndex(2)
   fileButton.props.toggle = true
   fileButton.props.disabled = not self.props.editor.fileEnabled
   fileButton.props.disabledQuad = atlas:getQuadByIndex(11)
   fileButton.props.onPress = function(pointer)
      filePanel.props.open = true
      filePanel.props.editor = self.props.editor
      pointer:captureElement(filePanel, true)
   end

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
   debugButton.props.onRelease = function()
      self.props.quit = true
      self.props.attachable.debug = true
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
      grid.props.editor = self.props.editor
      grid.props.display = self.props.display
      grid.props.attachable = self.props.attachable
      tools.props.editor = self.props.editor
   end, "level", "display")

   local selectionPanel = SelectionPanel(scene)
   selectionPanel.props.display = self.props.display
   selectionPanel.props.size = prism.Vector2(self.props.scale.x * 8, self.props.scale.y * 8)
   selectionPanel.props.editor = self.props.editor
   selectionPanel.props.overlay = overlay

   self:on("closeFilePanel", function()
      fileButton.props.pressed = false
   end)

   local background = prism.Color4.fromHex(0x181425)
   return function(_, x, y, w, h, depth)
      love.graphics.push("all")
      love.graphics.setCanvas(overlay)
      love.graphics.clear()
      love.graphics.pop()

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
      selectionPanel:render(232, 0, 88, 184, depth + 1)
      if filePanel.props.open then filePanel:render(0, 200 - (8 * 10), 8 * 12, 8 * 8, depth + 1) end
      love.graphics.setCanvas()

      grid:render(
         self.props.gridPosition.x,
         self.props.gridPosition.y,
         216 * self.props.scale.x,
         168 * self.props.scale.y,
         depth + 0.5
      )

      love.graphics.scale(self.props.scale:decompose())
      --local y = (love.graphics.getHeight() - (200 * self.props.scale.y)) / 2
      love.graphics.draw(canvas, 0, 0)
      love.graphics.origin()
      love.graphics.draw(overlay, 0, 0)

      love.graphics.pop()
   end
end

---@type fun(scene: Inky.Scene): EditorRoot
local EditorRootElement = Inky.defineElement(EditorRoot)
return EditorRootElement