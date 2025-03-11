---@class Camera : Object
---@field position Vector2
---@field scale Vector2
---@field rotation number
---@overload fun(x?: number, y?: number): Camera
local Camera = prism.Object:extend("Camera")

function Camera:__new(x, y)
   self.position = prism.Vector2(x or 0, y or 0)
   self.scale = prism.Vector2(1, 1)
   self.rotation = 0
end

---@return number x The x position.
---@return number y The y position.
function Camera:getPosition()
   return self.position.x, self.position.y
end

---@param x number
---@param y number
function Camera:setPosition(x, y)
   self.position.x = x or self.position.x
   self.position.y = y or self.position.y
end

---@param dx number
---@param dy number
function Camera:move(dx, dy)
   self.position = self.position + prism.Vector2(dx or 0, dy or 0)
end

---@param scaleX number
---@param scaleY number
function Camera:setScale(scaleX, scaleY)
   if scaleX and not scaleY then scaleY = scaleX end
   self.scale.x = scaleX or self.scale.x
   self.scale.y = scaleY or self.scale.y

   self.scale.x = math.max(self.scale.x, 0.1)
   self.scale.y = math.max(self.scale.y, 0.1)
end

---@param factorX number
---@param factorY number
---@param pointX number
---@param pointY number
function Camera:scaleAroundPoint(factorX, factorY, pointX, pointY)
   factorY = factorY or factorX 

   local scale = self.scale:copy()
   scale.x = math.max(0.1, scale.x + factorX)
   scale.y = math.max(0.1, scale.y + factorY)

   local delta = self.scale - scale
   self:setScale(scale.x, scale.y)

   local offsetX = pointX  * delta.x
   local offsetY = pointY * delta.y

   self.position.x = self.position.x + offsetX
   self.position.y = self.position.y + offsetY
end

---@param rotation number
function Camera:setRotation(rotation)
   self.rotation = rotation or self.rotation
end

---@param x number
---@param y number
function Camera:toWorldSpace(x, y)
   -- Reverse the translation (subtract position)
   local tx = x * self.scale.x + self.position.x
   local ty = y * self.scale.y + self.position.y

   return tx, ty
end

--- Pushes the camera's transform. Call this before drawing.
function Camera:push()
   love.graphics.push()
   love.graphics.rotate(-self.rotation)
   love.graphics.scale(1 / self.scale.x, 1 / self.scale.y)
   love.graphics.translate(-math.floor(self.position.x), -math.floor(self.position.y))
end

--- Pops the camera's transform. Call this after drawing.
function Camera:pop()
   love.graphics.pop()
end

return Camera
