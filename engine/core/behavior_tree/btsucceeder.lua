--- A succeeder node in the behavior tree.
--- @class BTSucceeder : BTNode
--- @overload fun(node: BTNode): BTSucceeder
--- @type BTSucceeder
local BTSucceeder = prism.BehaviorTree.Node:extend("BTSucceeder")

--- Creates a new BTSucceeder.
--- @param node BTNode
function BTSucceeder:__new(node) 
    self.node = node 
end

--- Runs the succeeder node.
--- @param level Level
--- @param actor Actor
--- @return boolean|Action
function BTSucceeder:run(level, actor)
   local return_value = self.node:run(level, actor)
   if return_value == false then 
       return true 
   end
   return return_value
end

return BTSucceeder
