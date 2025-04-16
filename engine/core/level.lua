--- The 'Level' holds all of the actors and systems, and runs the game loop. Through the ActorStorage and SystemManager
---
--- @class Level : Object, SpectrumAttachable
--- @field systemManager SystemManager A table containing all of the systems active in the level, set in the constructor.
--- @field actorStorage ActorStorage The main actor storage containing all of the level's actors.
--- @field scheduler Scheduler The main scheduler driving the loop of the game.
--- @field map Map The level's map.
--- @field opacityCache BooleanBuffer A cache of cell opacity || actor opacity for each cell. Used to speed up fov/lighting calculations.
--- @field passableCache BitmaskBuffer A cache of cell passability || actor passability for each cell. Used to speed up pathfinding.
--- @field decision ActionDecision Used during deserialization to resume.
--- @field RNG RNG The level's local random number generator, use this for randomness within the level like attack rolls.
--- @overload fun(map: Map, actors: [Actor], systems: [System], scheduler: Scheduler): Level
--- @type Level
local Level = prism.Object:extend("Level")

Level.serializationBlacklist = {
   opacityCache = true,
   passableCache = true
}

--- Constructor for the Level class.
--- @param map Map The map to use for the level.
--- @param actors [Actor] A list of actors to
--- @param systems [System]
function Level:__new(map, actors, systems, scheduler, seed)
   self.systemManager = prism.SystemManager(self)
   self.actorStorage = prism.ActorStorage(self:sparseMapCallback(), self:sparseMapCallback())
   self.scheduler = scheduler or prism.SimpleScheduler()
   self.map = map
   self.opacityCache = prism.BooleanBuffer(map.w, map.h)  -- holds a cache of opacity to speed up fov calcs
   self.passableCache = prism.BitmaskBuffer(map.w, map.h) -- holds a cache of passability to speed up a* calcs
   self.RNG = prism.RNG(seed or love.timer.getTime())
   self.debug = false
   
   self:initialize(actors, systems)
end

--- @param actors [Actor]
--- @param systems [System]
function Level:initialize(actors, systems)
   assert(#actors > 0, "A level must be initialized with at least one actor!")
   self:initializeOpacityCache()
   self:initializePassabilityCache()

   for i = 1, #systems do
      self:addSystem(systems[i])
   end

   self.systemManager:initialize(self)

   local actor = table.remove(actors)
   while actor do
      self:addActor(actor)
      actor = table.remove(actors)
   end

   self.systemManager:postInitialize(self)
end

--- Initializes the level,
--- Update is the main game loop for a level. It's a coroutine that yields
--- back to the main thread when it needs to wait for input from the player.
--- This function is the heart of the game loop.
function Level:run()
   -- TODO: Fix this
   if self.decision then
      local actor = self.decision.actor
      prism.turn(self, actor, self:getActorController(actor))
      self.systemManager:onTurnEnd(self, actor)
   end

   while not self.scheduler:empty() do
      self:step()
   end
end

function Level:step()
   local schedNext = self.scheduler:next()

   assert(
      type(schedNext) == "string" or prism.Object.is(schedNext, prism.Actor),
      "Found a scheduler entry that wasn't an actor or string."
   )

   local actor = schedNext
   ---@cast actor Actor
   self.systemManager:onTurn(self, actor)
   prism.turn(self, actor, self:getActorController(actor))
   self.systemManager:onTurnEnd(self, actor)
end

--- Yields to the main 'thread', a coroutine in this case. This is called in run, and a few systems. Any time you want
--- the interface to update you should call this. Avoid calling coroutine.yield directly,
--- as this function will call the onYield method on all systems.
--- @param message Message
--- @return Decision|nil
function Level:yield(message)
   self.systemManager:onYield(self, message)
   if message:is(prism.Decision) then
      ---@cast message ActionDecision
      self.decision = message
   end
   local _, ret = coroutine.yield(message)
   self.decision = nil
   return ret
end

function Level:debugYield(stringMessage)
   if not self.debug then return end

   self:yield(prism.messages.DebugMessage(stringMessage))
end

function Level:trigger(eventName, ...)
   self.systemManager:trigger(eventName, ...)
end

--
-- Systems
--

--- Attaches a system to the level. This function will error if the system
--- doesn't have a name or if a system with the same name already exists, or if
--- the system has a requirement that hasn't been attached yet.
--- @param system System The system to add.
function Level:addSystem(system) self.systemManager:addSystem(system) end

--- Gets a system by name.
--- @param className string The name of the system to get.
--- @return System? system The system with the given name.
function Level:getSystem(className) self.systemManager:getSystem(className) end

--
-- Actor
--

--- Retrieves the unique ID associated with the specified actor.
--- Note: IDs are unique to actors within the Level but may be reused 
--- when indices are freed.
--- @param actor Actor The actor whose ID is to be retrieved.
--- @return integer? The unique ID of the actor, or nil if the actor is not found.
function Level:getID(actor)
   return self.actorStorage:getID(actor)
end

--- Adds an actor to the level. Handles updating the component cache and
--- inserting the actor into the sparse map. It will also add the actor to the
--- scheduler if it has a controller.
--- @param actor Actor The actor to add.
function Level:addActor(actor)
   -- some sanity checks
   assert(actor:is(prism.Actor), "Attemped to add a non-actor object to the level with addActor")

   self.actorStorage:addActor(actor)
   if actor:hasComponent(prism.components.Controller) then
      self.scheduler:add(actor)
   end

   self.systemManager:onActorAdded(self, actor)

   local pos = actor:getPosition()
   self:getCell(pos.x, pos.y):onEnter(self, actor)
end

--- Removes an actor from the level. Handles updating the component cache and
--- removing the actor from the sparse map. It will also remove the actor from
--- the scheduler if it has a controller.
--- @param actor Actor The actor to remove.
function Level:removeActor(actor)
   self.actorStorage:removeActor(actor)
   self.scheduler:remove(actor)
   self.systemManager:onActorRemoved(self, actor)
end

--- Removes a component from an actor. It handles
--- updating the component cache and the opacity cache.
--- @param actor Actor The actor to remove the component from.
--- @param component Component The component to remove.
function Level:removeComponent(actor, component)
   actor:__removeComponent(component)
   self.actorStorage:updateComponentCache(actor)
   local x, y = actor:getPosition():decompose()
   self:updateCaches(x, y)
end

--- Adds a component to an actor. It handles updating
--- the component cache and the opacity cache. You can do this manually, but
--- it's easier to use this function.
--- @param actor Actor The actor to add the component to.
--- @param component Component The component to add.
function Level:addComponent(actor, component)
   -- we disable the check on actor's addComponent here because it's not ACTUALLY private, but
   -- we want to discourage it's use outside of Level
   ---@diagnostic disable-next-line
   actor:__addComponent(component)
   self.actorStorage:updateComponentCache(actor)

   local pos = actor:getPosition()
   self:updateCaches(pos.x, pos.y)
end

--- Moves an actor to the given position. This function doesn't do any checking
--- for overlaps or collisions. It's used by the moveActorChecked function, you should
--- generally not invoke this yourself using moveActorChecked instead.
--- @param actor Actor The actor to move.
--- @param pos Vector2 The position to move the actor to.
--- @param skipSparseMap boolean If true the sparse map won't be updated.
function Level:moveActor(actor, pos, skipSparseMap)
   assert(pos.is and pos:is(prism.Vector2), "Expected a Vector2 for pos in Level:moveActor.")
   assert(
      math.floor(pos.x) == pos.x and math.floor(pos.y) == pos.y,
      "Expected integer values for pos in Level:moveActor."
   )

   self.systemManager:beforeMove(self, actor, actor:getPosition(), pos)

   -- if the actor isn't in the level, we don't do anything
   if not self:hasActor(actor) then return end

   if not skipSparseMap then self.actorStorage:removeSparseMapEntries(actor) end

   local previousPosition = actor:getPosition()
   -- we copy the position here so that the caller doesn't have to worry about
   -- allocating a new table
   ---@diagnostic disable-next-line
   actor.position = pos:copy()

   if not skipSparseMap then self.actorStorage:insertSparseMapEntries(actor) end

   self:getCell(previousPosition.x, previousPosition.y):onLeave(self, actor)
   self:getCell(pos.x, pos.y):onEnter(self, actor)

   self.systemManager:onMove(self, actor, previousPosition, pos)
end

--- Executes an Action, updating the level's state and triggering any events through the systems
--- attached to the Actor or Level respectively. It also updates the 'Scheduler' if the action isn't
--- a reaction or free action. Lastly, it calls the 'onAction' method on the 'Cell' that the 'Actor' is
--- standing on.
--- @param action Action The action to perform.
--- @param silent boolean? If true this action emits no events.
function Level:performAction(action, silent)
   -- this happens sometimes if one effect kills an entity and a second effect
   -- tries to damage it for instance.
   if not self:hasActor(action.owner) then return end

   assert(action:canPerform(self))
   local owner = action.owner

   self:debugYield("Actor is about to perform " .. action.name)
   if not silent then
      self.systemManager:beforeAction(self, owner, action)
      local x, y = owner:getPosition():decompose()
      self:getCell(x, y):beforeAction(self, owner, action)
   end
   action:perform(self)
   self:yield(prism.messages.ActionMessage(action))
   if not silent then
      self.systemManager:afterAction(self, owner, action)
      local x, y = owner:getPosition():decompose()
      self:getCell(x, y):afterAction(self, owner, action)
   end
end

--- Gets the actor's controller. This is a utility function that checks the
--- actor's conditions for an override controller and returns it if it exists.
--- Otherwise it returns the actor's normal controller.
--- @param actor Actor The actor to get the controller for.
--- @return ControllerComponent controller The actor's controller.
function Level:getActorController(actor)
   --- @type ControllerComponent Cast to a Controller from the generic Controller component
   return actor:getComponent(prism.components.Controller)
end

--
-- ActorStorage Wrapper
--

--- Returns true if the level contains the given actor, false otherwise. A thin wrapper
--- over the inner ActorStorage.
--- @param actor Actor The actor to check for.
--- @return boolean hasActor True if the level contains the given actor, false otherwise.
function Level:hasActor(actor) return self.actorStorage:hasActor(actor) end

--- This method returns an iterator that will return all actors in the level
--- that have the given components. If no components are given it iterate over
--- all actors. A thin wrapper over the inner ActorStorage.
--- @param ... Component The components to filter by.
--- @return function An iterator that returns the next actor that matches the given components.
function Level:eachActor(...) return self.actorStorage:eachActor(...) end

--- Returns the first actor that extends the given prototype, or nil if no actor
--- is found. Useful for one offs like stairs in some games.
--- @param prototype Actor The prototype to check for.
--- @return Actor|nil The first actor that extends the given prototype, or nil if no actor is found.
function Level:getActorByType(prototype) return self.actorStorage:getActorByType(prototype) end

--- Returns a list of all actors at the given position. A thin wrapper over
--- the inner ActorStorage.
--- @param x number The x component of the position to check.
--- @param y number The y component of the position to check.
--- @return table A list of all actors at the given position.
function Level:getActorsAt(x, y) return self.actorStorage:getActorsAt(x, y) end

--- Returns an iterator that will return all actors at the given position.
--- @param x number The x component of the position to check.
--- @param y number The y component of the position to check.
--- @return function iter An iterator that returns the next actor at the given position.
function Level:eachActorAt(x, y) return self.actorStorage:eachActorAt(x, y) end

function Level:computeFOV(origin, maxDepth, callback)
   prism.computeFOV(self, origin, maxDepth, callback)
end

--- Sets the cell at the given position to the given cell.
--- @param x number The x component of the position to set.
--- @param y number The y component of the position to set.
--- @param cell Cell The cell to set.
function Level:setCell(x, y, cell)
   self.map:set(x, y, cell)
   self:updateCaches(x, y)
end

--- Gets the cell at the given position.
--- @param x number The x component of the position to get.
--- @param y number The y component of the position to get.
--- @return Cell The cell at the given position.
function Level:getCell(x, y) return self.map:get(x, y) end

--- Is there a cell at this x, y? Part of the interface with MapBuilder
--- @param x integer The x component to check if in bounds.
---@param y integer
function Level:inBounds(x, y)
   return
      x > 0 and x <= self.map.w and
      y > 0 and y <= self.map.h
end

function Level:eachCell()
   return self.map:each()
end

function Level:updateCaches(x, y)
   self:updateOpacityCache(x, y)
   self:updatePassabilityCache(x, y)
end

--- Returns true if the cell at the given position is passable, false otherwise. Considers
--- actors in the sparse map as well as the cell's passable property.
--- @param x number The x component of the position to check.
--- @param y number The y component of the position to check.
--- @param mask Bitmask
--- @return boolean True if the cell is passable, false otherwise.
function Level:getCellPassable(x, y, mask)
   local cellMask = self.passableCache:getMask(x, y)
   return prism.Collision.checkBitmaskOverlap(mask, cellMask)
end

--- Initialize the passable cache. This should be called after the level is
--- created and before the game loop starts. It will initialize the passable
--- cache with the cell passable cache. This is handled automatically by the
--- Level class.
function Level:initializePassabilityCache()
   for x = 1, self.map.w do
      for y = 1, self.map.h do
         self.passableCache:setMask(x, y, self.map.passableCache:getMask(x, y))
      end
   end
end

--- Updates the passability cache at the given position. This should be called
--- whenever an actor moves or a cell's passability changes. This is handled
--- automatically by the Level class.
--- @param x number The x component of the position to update.
--- @param y number The y component of the position to update.
function Level:updatePassabilityCache(x, y)
   local mask = self.map.passableCache:getMask(x, y)

   for actor, _ in self.actorStorage:eachActorAt(x, y) do
      local collider = actor:getComponent(prism.components.Collider)
      if collider then
         mask = bit.band(collider.mask, mask)
      end
   end

   self.passableCache:setMask(x, y, mask)
end

--- Returns true if the cell at the given position is opaque, false otherwise.
--- @param x number The x component of the position to check.
--- @param y number The y component of the position to check.
--- @return boolean True if the cell is opaque, false otherwise.
function Level:getCellOpaque(x, y) return self.opacityCache:get(x, y) end

--- Returns the opacity cache for the level. This generally shouldn't be used
--- outside of systems that need to know about opacity.
--- @return BooleanBuffer map The opacity cache for the level.
function Level:getOpacityCache() return self.opacityCache end

--- Initialize the opacity cache. This should be called after the level is
--- created and before the game loop starts. It will initialize the opacity
--- cache with the cell opacity cache. This is handled automatically by the
--- Level class.
function Level:initializeOpacityCache()
   for x = 1, self.map.w do
      for y = 1, self.map.h do
         local opaque = self.map.opacityCache:get(x, y)
         self.opacityCache:set(x, y, opaque)
      end
   end
end

--- Updates the opacity cache at the given position. This should be called
--- whenever an actor moves or a cell's opacity changes. This is handled
--- automatically by the Level class.
--- @param x number The x component of the position to update.
--- @param y number The y component of the position to update.
function Level:updateOpacityCache(x, y)
   local opaque = false
   for actor, _ in self.actorStorage:eachActorAt(x, y) do
      opaque = opaque or actor:hasComponent(prism.components.Opaque)
      if opaque then break end
   end

   opaque = opaque or self.map.opacityCache:get(x, y)
   self.opacityCache:set(x, y, opaque)
   self.systemManager:afterOpacityChanged(self, x, y)
end

--- Finds a path from startpos to endpos
---@param startPos Vector2
---@param goalPos Vector2
---@return Path | nil
function Level:findPath(startPos, goalPos, minDistance, mask)
   if
       startPos.x < 1 or startPos.x > self.map.w or startPos.y < 1 or startPos.y > self.map.h or
       goalPos.x < 1 or goalPos.x > self.map.w or goalPos.y < 1 or goalPos.y > self.map.h
   then
      error("Path destination is not on the map.")
   end
   -- Define the passability callback (checks if a position is walkable)
   local function passableCallback(x, y)
      return self:getCellPassable(x, y, mask) -- Assume this is a method in your Level class that checks passability
   end

   -- Use the prism.astar function to find the path
   return prism.astar(startPos, goalPos, passableCallback, nil, minDistance)
end

--- Returns a list of all actors that are within the given range of the given
--- position. The type parameter determines the type of range to use. Currently
--- only "fov" and "box" are supported. The fov type uses a field of view
--- algorithm to determine what actors are visible from the given position. The
--- box type uses a simple box around the given position.
--- @param self Level
--- @param type "box"|"fov" The type of range to use.
--- @param position Vector2 The position to check from.
--- @param range number The range to check.
--- @return table? actors
--- @return table? fov A list of actors within the given range.
function Level:getAOE(type, position, range)
   assert(position:is(prism.Vector2), "Position was not a Vector2!")
   local seenActors = {}

   if type == "fov" then
      local fov = prism.SparseGrid()

      prism.computeFOV(self, position, range, function(x, y)
         fov:set(x, y, true)
      end)

      for actorInAOE in self.actorStorage:eachActor() do
         local x, y = actorInAOE.position.x, actorInAOE.position.y
         if fov:get(x, y) then table.insert(seenActors, actorInAOE) end
      end

      return fov, seenActors
   elseif type == "box" then
      for actorInAOE in self.actorStorage:eachActor() do
         if actorInAOE:getRangeVec("box", position) <= range then table.insert(seenActors, actorInAOE) end
      end

      return nil, seenActors
   end
end

function Level:sparseMapCallback()
   return function(x, y, actor)
      self:updateCaches(x, y)
   end
end

function Level:onDeserialize()
   self.actorStorage:setCallbacks(self:sparseMapCallback(), self:sparseMapCallback())

   local w, h = self.map.w, self.map.h
   self.opacityCache = prism.BooleanBuffer(w, h)
   self.passableCache = prism.BitmaskBuffer(w, h)

   self.map:onDeserialize()
   for x, y, _ in self.map:each() do
      self:updateCaches(x, y)
   end
end

return Level
