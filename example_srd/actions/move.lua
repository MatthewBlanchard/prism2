---@type SRDAction
local SRDAction = require "example_srd.actions.srdaction"

local PointTarget = prism.Target:extend("PointTarget")
PointTarget.typesAllowed = { Point = true }
PointTarget.range = 1

---@class MoveAction : SRDAction
---@field name string
---@field silent boolean
---@field targets Target[]
---@field previousPosition Vector2
local Move = SRDAction:extend("MoveAction")
Move.name = "move"
Move.silent = true
Move.targets = { PointTarget }
Move.stripName = true

function Move:movePointCost(level, actor)
   return 1
end

function Move:actionSlot()
   return nil
end

function Move:canPerform(level)
   local destination = self:getTarget(1)
   return level:getCellPassable(destination.x, destination.y) and prism.actions.SRDAction.canPerform(self, level)
end

function Move:perform(level)
   --- @type Vector2
   local destination = self:getTarget(1)

   assert(self.owner:getPosition():distanceChebyshev(destination) == 1)
   assert(level:getCellPassable(destination.x, destination.y))

   self.previousPosition = self.owner:getPosition()
   level:moveActor(self.owner, destination, false)
end

return Move
