---@class Display : Object
--- Display handles rendering the game world, including cells, actors, and perspectives.
---@field attachable SpectrumAttachable The current level being displayed.
---@field spriteAtlas SpriteAtlas The sprite atlas used for rendering graphics.
---@field camera Camera The camera used to render the display.
---@field dt number Delta time for updates.
---@field cellSize Vector2
---@field override fun(dt: integer, drawnSet: table<Actor,boolean>)|nil
local Display = prism.Object:extend("Display")

---@class SpectrumAttachable : Object
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

--- Initializes a new Display instance.
---@param spriteAtlas SpriteAtlas The sprite atlas for rendering.
---@param cellSize Vector2 Size of each cell in pixels.
---@param attachable SpectrumAttachable Object containing cells and actors to render.
function Display:__new(spriteAtlas, cellSize, attachable)
   self.cellSize = cellSize
   self.attachable = attachable
   self.spriteAtlas = spriteAtlas
   self.camera = spectrum.Camera()
   self.override = nil
   self.message = nil
   self.dt = nil
end

--- Updates the display state.
---@param dt number Delta time for updates.
function Display:update(dt)
   self.dt = dt
end

--- Renders the display.
function Display:draw()
   love.graphics.push("all")
   self.camera:push()

   for x, y, cell in self.attachable:eachCell() do
      Display.drawDrawable(cell.drawable, self.spriteAtlas, self.cellSize, x, y)
   end

   for actor in self.attachable:eachActor() do
      self:drawActor(actor)
   end

   self.camera:pop()
   love.graphics.pop()
end

---@param primary SensesComponent[] List of primary senses.
---@param secondary SensesComponent[] List of secondary senses.
function Display.buildSenseInfo(primary, secondary)
   local primaryCellSet = prism.SparseGrid()
   local secondaryCellSet = prism.SparseGrid()
   local exploredCellSet = prism.SparseGrid()

   for _, sensesComponent in pairs(primary) do
      for x, y, _ in sensesComponent.cells:each() do
         primaryCellSet:set(x, y, true)
      end

      for x, y, _ in sensesComponent.explored:each() do
         exploredCellSet:set(x, y, true)
      end
   end

   for _, sensesComponent in pairs(secondary) do
      for x, y, _ in sensesComponent.cells:each() do
         if not primaryCellSet:get(x, y) then
            secondaryCellSet:set(x, y, true)
         end
      end

      for x, y, _ in sensesComponent.explored:each() do
         exploredCellSet:set(x, y, true)
      end
   end

   local primaryActorSet = {}
   local secondaryActorSet = {}

   for _, sensesComponent in ipairs(primary) do
      for actor in sensesComponent.actors:eachActor() do
         primaryActorSet[actor] = true
      end
   end

   for _, sensesComponent in ipairs(secondary) do
      for actor in sensesComponent.actors:eachActor() do
         if not primaryActorSet[actor] then
            secondaryActorSet[actor] = true
         end
      end
   end

   return 
      primaryCellSet, secondaryCellSet,
      primaryActorSet, secondaryActorSet,
      exploredCellSet
end

--- Draws the perspective of primary and secondary senses.
---@param primary SensesComponent[] List of primary senses.
---@param secondary SensesComponent[] List of secondary senses.
function Display:drawPerspective(primary, secondary)
   local drawnSet = {}

   love.graphics.push("all")
   self.camera:push()

   local 
      primaryCellSet, secondaryCellSet,
      primaryActorSet, secondaryActorSet, 
      exploredCellsSet 
   = Display.buildSenseInfo(primary, secondary)

   self:beforeDrawCells()

   for x, y, cell in self.attachable:eachCell() do
      local alpha = 1
      if not primaryCellSet:get(x, y) then 
         alpha = 0.7
         if not secondaryCellSet:get(x, y) then alpha = 0.3 end
      end
      if primaryCellSet:get(x, y) or secondaryCellSet:get(x, y) or exploredCellsSet:get(x, y) then
         Display.drawDrawable(cell.drawable, self.spriteAtlas, self.cellSize, x, y, nil, alpha)
      end
   end

   self:beforeDrawActors()

   if self.override then
      local done = self.override(self.dt, drawnSet)
      if done then self.override = nil end
   end

   for actor in self.attachable:eachActor() do
      local alpha = 1
      if not primaryActorSet[actor] then
         alpha = 0.7
         if not secondaryActorSet[actor] then alpha = 0.3 end
      end

      if primaryActorSet[actor] or secondaryActorSet[actor] then
         self:drawActor(actor, alpha, nil, drawnSet)
      end
   end

   self.camera:pop()
   love.graphics.pop()
end

--- Sets an override rendering function.
---@param functionFactory fun(display: Display, message: any): fun(dt: number): boolean A factory for override functions.
---@param message any Optional message to pass to the function.
function Display:setOverride(functionFactory, message)
   self.override = functionFactory(self, message)
end

--- Draws an actor.
---@param actor Actor The actor to draw.
---@param alpha number? Optional alpha transparency.
---@param color Color4? Optional color tint.
---@param drawnSet table? Optional set to track drawn actors.
function Display:drawActor(actor, alpha, color, drawnSet, x, y)
   if drawnSet and drawnSet[actor] then
      return
   end

   local drawable = actor:getComponent(prism.components.Drawable)
   if not drawable then return end
   ---@cast drawable DrawableComponent

   local position = actor:getPosition()
   x, y = x or position.x, y or position.y
   Display.drawDrawable(drawable, self.spriteAtlas, self.cellSize, x, y, color, alpha)

   if drawnSet then
      drawnSet[actor] = true
   end
end

--- Hook for custom behavior before drawing cells.
function Display:beforeDrawCells()
   -- override this method in your subclass!
end

--- Hook for custom behavior before drawing actors.
function Display:beforeDrawActors()
   -- override this method in your subclass!
end

--- Hook for custom behavior after drawing actors.
function Display:afterDrawActors()
   -- override this method in your subclass!
end

--- Retrieves the quad for a drawable.
---@param spriteAtlas SpriteAtlas The sprite atlas.
---@param drawable DrawableComponent The drawable component.
---@return love.Quad|nil The quad used for rendering.
function Display.getQuad(spriteAtlas, drawable)
   if type(drawable.index) == "number" then
      ---@diagnostic disable-next-line
      return spriteAtlas:getQuadByIndex(drawable.index)
   else
      ---@diagnostic disable-next-line
      return spriteAtlas:getQuadByName(drawable.index)
   end
end

--- Draws a drawable object.
---@param drawable DrawableComponent Drawable to render.
---@param spriteAtlas SpriteAtlas Sprite atlas to use.
---@param cellSize Vector2 Size of each cell.
---@param x integer X-coordinate.
---@param y integer Y-coordinate.
---@param color Color4? Optional color tint.
---@param alpha number? Optional alpha transparency.
function Display.drawDrawable(drawable, spriteAtlas, cellSize, x, y, color, alpha)
   alpha = alpha or 1
   local quad = Display.getQuad(spriteAtlas, drawable)
   color = color or drawable.color
   local r, g, b, a = color:decompose()
   local cSx, cSy = cellSize.x, cellSize.y

   if drawable.background then
      love.graphics.setColor(drawable.background:decompose())
      love.graphics.rectangle("fill", x * cSx, y * cSy, cSx, cSy)
   end

   love.graphics.setColor(r, g, b, a * alpha)
   love.graphics.draw(spriteAtlas.image, quad, x * cSx, y * cSy)
   love.graphics.setColor(1, 1, 1, 1)
end

--- Gets the cell under the mouse cursor.
---@return integer, integer The X and Y coordinates of the cell.
function Display:getCellUnderMouse()
   local cSx, cSy = self.cellSize.x, self.cellSize.y
   local mx, my = love.mouse.getPosition()
   local wx, wy = self.camera:toWorldSpace(mx, my)
   return math.floor(wx / cSx), math.floor(wy / cSy)
end

return Display
