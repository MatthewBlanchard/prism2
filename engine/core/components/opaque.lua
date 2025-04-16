---@class OpaqueComponent : Component
---@overload fun(): OpaqueComponent
local Opaque = prism.Component:extend("OpaqueComponent")
Opaque.name = "Opaque"

return Opaque
