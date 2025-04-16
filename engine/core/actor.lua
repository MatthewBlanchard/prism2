--- An 'Actor' represents entities in the game, including the player, enemies, and items.
--- Actors are composed of Components that define their state and behavior.
--- For example, an actor may have a Sight component that determines their field of vision, explored tiles,
--- and other related aspects.
--- @class Actor : Object
--- @field private position Vector2 An actor's position in the game world.
--- @field name string The string name of the actor, used for display to the user.
--- @field char string The character to draw for this actor.
--- @field components Component[] A table containing all of the actor's component instances. Generated at runtime.
--- @field componentCache table This is a cache for component queries, reducing most queries to a hashmap lookup.
--- @overload fun(): Actor
--- @type Actor
local Actor = prism.Object:extend("Actor")
Actor.position = nil
Actor.name = "actor"

--- Constructor for an actor.
--- Initializes and copies the actor's fields from its prototype.
--- @param self Actor
function Actor:__new()
   self.position = prism.Vector2(1, 1)

   local components = self:initialize()
   self.components = {}
   self.componentCache = {}
   if components then
      for _, component in ipairs(components) do
         component.owner = self
         self:__addComponent(component)
      end
   end
end

--
--- Components
--

--- Creates the components for the actor. Override this.
--- @return Component[]
function Actor:initialize()
   return {}
end

--- Adds a component to the actor. This function will check if the component's
--- prerequisites are met and will throw an error if they are not.
--- @param component Component The component to add to the actor.
--- @private
function Actor:__addComponent(component)
   assert(component:is(prism.Component), "Expected argument component to be of type Component!")
   assert(component:checkRequirements(self), "Unsupported component " .. component.className .. " added to actor!")
   assert(not self:hasComponent(component), "Actor already has component " .. component.className .. "!")

   for _, v in pairs(prism.components) do
      if component:is(v) then
         if self.componentCache[v] then error("Actor already has component " .. v.className .. "!") end
         self.componentCache[v] = component
      end
   end

   component.owner = self
   table.insert(self.components, component)
   component:initialize(self)
end

--- Removes a component from the actor. This function will throw an error if the
--- component is not present on the actor.
--- @param component Component The component to remove from the actor.
function Actor:__removeComponent(component)
   assert(component:is(prism.Component), "Expected argument component to be of type Component!")

   for _, componentPrototype in pairs(prism.components) do
      if component:is(componentPrototype) then
         if not self.componentCache[componentPrototype] then
            error("Actor does not have component " .. componentPrototype.name .. "!")
         end

         for cachedComponent, _ in pairs(self.componentCache) do
            if cachedComponent:is(componentPrototype) then self.componentCache[cachedComponent] = nil end
         end
      end
   end

   for i = 1, #self.components do
      if self.components[i]:is(getmetatable(component)) then
         local component = table.remove(self.components, i)
         component.owner = nil
         return component
      end
   end
end

--- Returns a bool indicating whether the actor has a component of the given type.
--- @param prototype Component The prototype of the component to check for.
--- @return boolean hasComponent
function Actor:hasComponent(prototype)
   assert(prototype:is(prism.Component), "Expected argument type to be inherited from Component!")

   return self.componentCache[prototype] ~= nil
end

--- Searches for a component that inherits from the supplied prototype
--- @generic T
--- @param prototype T The type of the component to return.
--- @return T?
function Actor:getComponent(prototype) return self.componentCache[prototype] end


--- Expects a component, returning it or erroring on nil.
--- @generic T
--- @param prototype T The type of the component to return.
--- @return T
function Actor:expectComponent(prototype)
   return self.componentCache[prototype] or error("Expected component " .. prototype.className .. "!")
end
--
--- Actions
--

--- Get a list of actions that the actor can perform.
--- @return Action[] totalActions Returns a table of all actions.
function Actor:getActions()
   local totalActions = {}

   for _, action in pairs(prism.actions) do
      if action:hasRequisiteComponents(self) then
         table.insert(totalActions, action)
      end
   end

   return totalActions
end

--
-- Utility
--

--- Returns the current position of the actor.
--- @return Vector2 position Returns a copy of the actor's current position.
function Actor:getPosition() return self.position:copy() end

--- Get the range from this actor to another actor.
--- @param type DistanceType
--- @param actor Actor The other actor to get the range to.
--- @return number Returns the calculated range.
function Actor:getRange(type, actor)
   return self.position:getRange(type, actor.position)
end

--- Get the range from this actor to a given vector.
-- @function Actor:getRangeVec
-- @tparam string type The type of range calculation to use.
-- @tparam Vector2 vector The vector to get the range to.
-- @treturn number Returns the calculated range.
function Actor:getRangeVec(type, vector) return self.position:getRange(type, vector) end

return Actor
