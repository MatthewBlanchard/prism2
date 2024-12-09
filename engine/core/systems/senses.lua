local SensesComponent = prism.components.Senses

--- @class SensesSystem : System
local SensesSystem = prism.System:extend("SensesSystem")
SensesSystem.name = "Senses"

--- The message system requires the Senses system. While we don't
--- directly reference it here we do grab data off the Senses component
SensesSystem.requirements = { "SensesSystem" }

function SensesSystem:onTurn(level, actor)
   if actor:hasComponent(prism.components.PlayerController) then return end
   self:triggerRebuild(level, actor)
end

---@param level Level
---@param event any
function SensesSystem:onYield(level, event)
   for actor in level:eachActor(prism.components.Senses) do
      self:triggerRebuild(level, actor)
   end
end

function SensesSystem:triggerRebuild(level, actor)
   local sensesComponent = actor:getComponent(prism.components.Senses)
   if not sensesComponent then return end

   sensesComponent.cells = prism.SparseGrid()
   
   level:trigger("onSenses", level, actor)

   for x, y, cell in sensesComponent.cells:each() do
      sensesComponent.explored:set(x, y, cell)
   end
end

return SensesSystem