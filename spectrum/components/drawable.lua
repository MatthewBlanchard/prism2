--- @class DrawableComponent : Component
--- @field index string|integer
--- @field color Color4
--- @field background? Color4
--- @overload fun(index: string|integer, color: Color4, background?: Color4): DrawableComponent
local Drawable = prism.Component:extend "DrawableComponent"

--- Index needs to be a string associated with a sprite in the SpriteAtlas, or
--- an integer index associated with a sprite.
--- @param index string|integer
--- @param color Color4
--- @param background? Color4
function Drawable:__new(index, color, background)
   self.index = index
   self.color = color or prism.Color4(1, 1, 1, 1)
   self.background = background
end

return Drawable
