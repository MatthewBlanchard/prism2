---@class SRDAction : Action
---@field name string
---@field silent boolean
---@field targets Target[]
local SRDAction = prism.Action:extend("SRDAction")
SRDAction.name = "SRDAction"
SRDAction.silent = true
SRDAction.stripName = false

function SRDAction:movePointCost(level, actor)
   return 0
end

function SRDAction:actionSlot(level, actor)
   return "Action"
end

---@param level Level
function SRDAction:canPerform(level)
   local SRDStatsComponent = self.owner:getComponent(prism.components.SRDStats)
   ---@cast SRDStatsComponent SRDStatsComponent

   if SRDStatsComponent then
      local moveCost = self:movePointCost(level, self.owner)
      local actionSlot = self:actionSlot(level, self.owner)

      if SRDStatsComponent.curMovePoints < moveCost then
         return false
      end

      if actionSlot and not SRDStatsComponent.actionSlots[actionSlot] then
         return false
      end
   end

   return prism.Action.canPerform(self, level)
end

return SRDAction
