--- @class PlayerControllerComponent : ControllerComponent
--- @overload fun(): PlayerControllerComponent
--- @type PlayerControllerComponent
local PlayerController = prism.components.Controller:extend("PlayerController")

---@param level Level
---@param actor Actor
function PlayerController:act(level, actor)
   local actionDecision = level:yield(prism.decisions.ActionDecision(actor))
   --- @cast actionDecision ActionDecision

   return actionDecision.action
end

return PlayerController
