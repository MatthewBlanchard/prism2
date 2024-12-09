--- An 'Action' is a command that affects a discrete change in the game state.
--- An Action consists of an owner, a name, a list of targets, and a list of target objects.
--- See Target for more.
--- @class Action : Object
--- @field time number The time it takes to perform this action. Lower is better.
--- @field silent boolean A silent action doesn't generate messages
--- @field owner Actor The actor taking the action.
--- @field source Actor? An object granting the owner of the action this action. A wand's zap action is a good example.
--- @field targets table<Target>
--- @field targetObjects table<Object>
--- @overload fun(owner: Actor, targets: table<Target>): Action
--- @type Action
local Action = prism.Object:extend("Action")
Action.time = 100
Action.silent = false

--- Constructor for the Action class.
---@param owner Actor The actor that is performing the action.
---@param targets table? An optional list of target actors. Not all actions require targets.
---@param source Actor? An optional actor indicating the source of that action, for stuff like a wand or scroll.
function Action:__new(owner, targets, source)
   self.owner = owner
   self.source = source
   self.name = self.name or "ERROR"
   self.targets = self.targets or {}
   self.targetObjects = targets or {}

   assert(
      #self.targetObjects == #self.targets,
      "Invalid number of targets for action "
         .. self.name
         .. " expected "
         .. #self.targets
         .. " got "
         .. #self.targetObjects
   )
   for i, target in ipairs(self.targets) do
      assert(
         target:_validate(owner, self.targetObjects[i]),
         "Invalid target " .. i .. " for action " .. self.name
      )
   end
end

--- This method should be overriden by subclasses. This is called to make
--- sure an action is valid for the actor. This would be useful for 
--- @param actor Actor The actor trying to perform the action
--- @param source Actor? An optional second actor for things like zapping a wand.
function Action:canPerform(actor, source)
   return true
end

--- Performs the action. This should be overriden on all subclasses
--- @param level Level The level the action is being performed in.
function Action:perform(level)
    error("This is a virtual method and must be overriden on subclasses!")
end

--- Returns the target actor at the specified index.
---@param n number The index of the target actor to retrieve.
---@return any target The target actor at the specified index.
function Action:getTarget(n)
   if self.targetObjects[n] then return self.targetObjects[n] end
end

--- Returns the number of targets associated with this action.
--- @return number numTargets The number of targets associated with this action.
function Action:getNumTargets()
   if not self.targets then return 0 end
   return #self.targets
end

--- Returns a list of target actors associated with this action.
--- @return table targetList A list of target actors associated with this action.
function Action:getTargets() return self.targetObjects end

--- Returns the target object at the specified index.
--- @tparam number index The index of the target object to retrieve.
--- @return Target|nil targetObject
function Action:getTargetObject(index) return self.targets[index] end

--- Determines if the specified actor is a target of this action.
-- @tparam Actor actor The actor to check if they are a target of this action.
-- @treturn boolean true if the specified actor is a target of this action, false otherwise.
function Action:hasTarget(actor)
   for _, a in pairs(self.targetObjects) do
      if a == actor then return true end
   end
end

--- _validates the specified target for this action.
--- @param n number The index of the target object to _validate.
--- @param owner Actor The actor that is performing the action.
--- @param to_validate Actor The target actor to _validate.
--- @return boolean true if the specified target actor is valid for this action, false otherwise.
function Action:validateTarget(n, owner, to_validate)
   return self.targets[n]:_validate(owner, to_validate)
end

return Action
