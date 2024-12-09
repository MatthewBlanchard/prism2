--- A map builder class that extends the SparseGrid class to handle map-specific functionalities.
--- @class MapBuilder : SparseGrid
--- @field actors Actor[] A list of actors present in the map.
--- @field initialValue Cell The initial value to fill the map with.
--- @overload fun(initialValue: Cell): MapBuilder
--- @type MapBuilder
local MapBuilder = prism.SparseGrid:extend("MapBuilder")

--- The constructor for the 'MapBuilder' class.
--- Initializes the map with an empty data table and actors list.
--- @param initialValue Cell The initial value to fill the map with.
function MapBuilder:__new(initialValue)
   prism.SparseGrid.__new(self)
   self.actors = {}
   self.initialValue = initialValue
end

--- Adds an actor to the map at the specified coordinates.
--- @param actor table The actor to add.
--- @param x number The x-coordinate.
--- @param y number The y-coordinate.
function MapBuilder:addActor(actor, x, y)
   actor.position = prism.Vector2(x, y)
   table.insert(self.actors, actor)
end

--- Removes an actor from the map.
--- @param actor table The actor to remove.
function MapBuilder:removeActor(actor)
   for i, a in ipairs(self.actors) do
      if a == actor then
         table.remove(self.actors, i)
         break
      end
   end
end

--- Draws a rectangle on the map.
--- @param x1 number The x-coordinate of the top-left corner.
--- @param y1 number The y-coordinate of the top-left corner.
--- @param x2 number The x-coordinate of the bottom-right corner.
--- @param y2 number The y-coordinate of the bottom-right corner.
--- @param cell Cell The cell to fill the rectangle with.
function MapBuilder:drawRectangle(x1, y1, x2, y2, cell)
   for x = x1, x2 do
      for y = y1, y2 do
         self:set(x, y, cell)
      end
   end
end

--- Draws an ellipse on the map.
--- @param cx number The x-coordinate of the center.
--- @param cy number The y-coordinate of the center.
--- @param rx number The radius along the x-axis.
--- @param ry number The radius along the y-axis.
--- @param cell Cell The cell to fill the ellipse with.
function MapBuilder:drawEllipse(cx, cy, rx, ry, cell)
   for x = -rx, rx do
      for y = -ry, ry do
         if (x * x) / (rx * rx) + (y * y) / (ry * ry) <= 1 then
            self:set(cx + x, cy + y, cell)
         end
      end
   end
end

--- Draws a line on the map using Bresenham's line algorithm.
--- @param x1 number The x-coordinate of the starting point.
--- @param y1 number The y-coordinate of the starting point.
--- @param x2 number The x-coordinate of the ending point.
--- @param y2 number The y-coordinate of the ending point.
--- @param cell Cell The cell to draw the line with.
function MapBuilder:drawLine(x1, y1, x2, y2, cell)
   local dx = math.abs(x2 - x1)
   local dy = math.abs(y2 - y1)
   local sx = x1 < x2 and 1 or -1
   local sy = y1 < y2 and 1 or -1
   local err = dx - dy

   while true do
      self:set(x1, y1, cell)
      if x1 == x2 and y1 == y2 then break end
      local e2 = 2 * err
      if e2 > -dy then
         err = err - dy
         x1 = x1 + sx
      end
      if e2 < dx then
         err = err + dx
         y1 = y1 + sy
      end
   end
end

--- Gets the value at the specified coordinates, or the initialValue if not set.
--- @param x number The x-coordinate.
--- @param y number The y-coordinate.
--- @return any value The value at the specified coordinates, or the initialValue if not set.
function MapBuilder:get(x, y)
   local value = prism.SparseGrid.get(self, x, y)
   if value == nil then
      value = self.initialValue
   end
   return value
end

--- Sets the value at the specified coordinates.
--- @param x number The x-coordinate.
--- @param y number The y-coordinate.
--- @param value any The value to set.
function MapBuilder:set(x, y, value)
   prism.SparseGrid.set(self, x, y, value)
end

--- Adds padding around the map with a specified width and cell value.
--- @param width number The width of the padding to add.
--- @param cell Cell The cell value to use for padding.
function MapBuilder:addPadding(width, cell)
   local minX, minY = math.huge, math.huge
   local maxX, maxY = -math.huge, -math.huge

   for x, y in self:each() do
      if x < minX then minX = x end
      if x > maxX then maxX = x end
      if y < minY then minY = y end
      if y > maxY then maxY = y end
   end

   for x = minX - width, maxX + width do
      for y = minY - width, minY - 1 do
         self:set(x, y, cell)
      end
      for y = maxY + 1, maxY + width do
         self:set(x, y, cell)
      end
   end

   for y = minY - width, maxY + width do
      for x = minX - width, minX - 1 do
         self:set(x, y, cell)
      end
      for x = maxX + 1, maxX + width do
         self:set(x, y, cell)
      end
   end
end

--- Blits the source MapBuilder onto this MapBuilder at the specified coordinates.
--- @param source MapBuilder The source MapBuilder to copy from.
--- @param destX number The x-coordinate of the top-left corner in the destination MapBuilder.
--- @param destY number The y-coordinate of the top-left corner in the destination MapBuilder.
--- @param maskFn fun(x: integer, y: integer, source: Cell, dest: Cell)|nil A callback function for masking. Should return true if the cell should be copied, false otherwise.
function MapBuilder:blit(source, destX, destY, maskFn)
   maskFn = maskFn or function() return true end

   for x, y, value in source:each() do
      if maskFn(x, y, value, self:get(x, y)) then
         self:set(destX + x, destY + y, source:get(x, y))
      end
   end

   -- Adjust actor positions
   for _, actor in ipairs(source.actors) do
      ---@diagnostic disable-next-line
      actor.position = actor.position + prism.Vector2(destX, destY)
      table.insert(self.actors, actor)
   end
end

--- Builds the map and returns the map and list of actors.
--- Converts the sparse grid to a contiguous grid.
--- @return Map, table actors map and the list of actors.
function MapBuilder:build()
   -- Determine the bounding box of the sparse grid
   local minX, minY = math.huge, math.huge
   local maxX, maxY = -math.huge, -math.huge

   for x, y in self:each() do
      if x < minX then minX = x end
      if x > maxX then maxX = x end
      if y < minY then minY = y end
      if y > maxY then maxY = y end
   end

   -- Assert that the sparse grid is not empty
   assert(minX <= maxX and minY <= maxY, "SparseGrid is empty and cannot be built into a Map.")

   local width = maxX - minX + 1
   local height = maxY - minY + 1

   -- Create a new Map and populate it with the sparse grid data
   local map = prism.Map(width, height, self.initialValue)

   for x, y, value in self:each() do
      map:setCell(x - minX + 1, y - minY + 1, self:get(x, y))
   end

   -- Adjust actor positions
   for _, actor in ipairs(self.actors) do
      ---@diagnostic disable-next-line
      actor.position = actor.position - prism.Vector2(minX - 1, minY - 1)
   end

   return map, self.actors
end

return MapBuilder