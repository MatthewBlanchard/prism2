--- An 'Action' is a command that affects a discrete change in the game state.
--- An Action consists of an owner, a name, a list of targets, and a list of target objects.
--- See Target for more.
--- @class Action : Object
--- @field time number The time it takes to perform this action. Lower is better.
--- @field silent boolean A silent action doesn't generate messages
--- @field owner Actor The actor taking the action.
--- @field source Actor? An object granting the owner of the action this action. A wand's zap action is a good example.
--- @field targets [Target]
--- @field targetObjects [Object]
--- @field requiredComponents Component[]
--- @overload fun(owner: Actor, targets: Target[]): Action
--- @type Action
local Action = prism.Object:extend("Action")
Action.time = 100
Action.silent = false

--- Constructor for the Action class.
---@param owner Actor The actor that is performing the action.
---@param targets [Object]? An optional list of target actors. Not all actions require targets.
---@param source Actor? An optional actor indicating the source of that action, for stuff like a wand or scroll.
function Action:__new(owner, targets, source)
   self.owner = owner
   self.source = source
   self.name = self.name or "ERROR"
   self.targets = self.targets or {}
   self.targetObjects = targets or {}

   assert(Action.canPerform == self.canPerform, "Do not override canPerform! Override _canPerform instead!")
   assert(Action.perform == self.perform, "Do not override perform! Override _perform instead!")

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
         target:_validate(owner, self.targetObjects[i], self.targetObjects),
         "Invalid target " .. i .. " for action " .. self.name
      )
   end
end

--- Call this function to check if the action is valid and can be executed in
--- the given level. This calls the inner overrideable _canPerform, and
--- unpacks the target objects.
--- @param level Level
--- @return boolean canPerform
function Action:canPerform(level)
   if not self:hasRequisiteComponents(self.owner) then return false end

   return self:_canPerform(level, unpack(self.targetObjects))
end

--- This method should be overriden by subclasses. This is called to make
--- sure an action is valid for the actor. This would be useful for
--- @param level Level
--- @return boolean canPerform
function Action:_canPerform(level, ...)
   error("This is a virtual method and must be overriden on subclasses!")
end

--- @param actor Actor
--- @return boolean hasRequisiteComponents
function Action:hasRequisiteComponents(actor)
   if not self.requiredComponents then return true end

   for _, component in pairs(self.requiredComponents) do
      if not actor:hasComponent(component) then return false end
   end

   return true
end

function Action:perform(level)
   self:_perform(level, unpack(self.targetObjects))
end

--- Performs the action. This should be overriden on all subclasses
--- @param level Level The level the action is being performed in.
function Action:_perform(level, ...)
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
--- @param toValidate Actor The target actor to _validate.
--- @param targets [any] The previously selected targets.
--- @return boolean true if the specified target actor is valid for this action, false otherwise.
function Action:validateTarget(n, owner, toValidate, targets)
   return self.targets[n]:_validate(owner, toValidate, targets)
end

return Action
