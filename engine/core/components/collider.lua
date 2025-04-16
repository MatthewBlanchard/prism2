--- @class ColliderComponent : Component
--- @overload fun(options: ColliderOptions): ColliderComponent
--- @type ColliderComponent
local Collider = prism.Component:extend("Collider")
Collider.name = "Collideable"

--- @class ColliderOptions
--- @field allowedMovetypes string[]

Collider.mask = 0
--- @param options ColliderOptions
function Collider:__new(options)
   if not options then return end
   if not options.allowedMovetypes then return end

   self.mask = prism.Collision.createBitmaskFromMovetypes(options.allowedMovetypes)
end

return Collider
