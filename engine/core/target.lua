--- @alias TargetType
--- | "Actor"
--- | "Cell"
--- | "Point"

--- @class Target : Object
--- @field typesAllowed table<TargetType, true>
--- @field range number The distance in tiles this actor can be away from the Action taker.
--- @field rangeType "chebyshev"|"manhattan"
--- @field distanceType DistanceType
--- @overload fun(range: integer, distanceType: DistanceType): Target
--- @type Target
local Target = prism.Object:extend("Target")
Target.range = nil
Target.rangeType = "chebyshev"
Target.typesAllowed = {
   -- Actor = true,
   -- Cell = true,
   -- Point = true,
}

--- Creates a new Target with the specified range.
function Target:__new(range, distanceType)
   self.range = range or self.range
   self.distanceType = distanceType or self.rangeType
   self.canTargetSelf = false
end

local typeValidators = {
   Actor = function(object) return object:is(prism.Actor) end,
   Cell = function(object) return object:is(prism.Cell) end,
   Point = function(object) return object:is(prism.Vector2) end,
}

---@param owner Actor
---@param targetObject any
function Target:_validate(owner, targetObject)
   assert(targetObject.className, "Target must be a prism Object!")
   local isValid
   for t, _ in pairs(self.typesAllowed) do
      if typeValidators[t](targetObject) then
         isValid = true
      end
   end
   
   local targetPosition = nil
   if typeValidators.Point(targetObject) then targetPosition = targetObject end
   if typeValidators.Actor(targetObject) then targetPosition = targetObject.position end

   local range = owner:getPosition():getRange(self.rangeType, targetPosition)
   return isValid and self:validate(owner, targetObject) and range <= self.range
end

--- The inner validate for the target. This is what you override with your own
--- custom logic.
--- @param owner Actor The actor performing the action.
--- @param targetObject Actor|Cell|Vector2 The target to validate.
function Target:validate(owner, targetObject)
    return true
end

return Target