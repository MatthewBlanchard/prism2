---@type SRDAction
local SRDAction = require "example.actions.srdaction"

---@class EndTurnAction : SRDAction
---@field name string
---@field silent boolean
---@field targets table<Target>
local EndTurn = SRDAction:extend("EndTurnAction")
EndTurn.name = "end turn"
EndTurn.silent = true
EndTurn.stripName = true

function EndTurn:perform(level)
end

return EndTurn
