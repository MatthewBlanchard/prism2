local Collision = {}

--- @alias CollisionMask integer

--- Collision movetypes used for bitmasking. Each bit represents a movetype, or collision layer.
--- Each movetypes represents a different collision category.
--- @type table<string, CollisionMask>
Collision.MOVETYPES = {
   movetypes0  = 0x0001,
   movetypes1  = 0x0002,
   movetypes2  = 0x0004,
   movetypes3  = 0x0008,
   movetypes4  = 0x0010,
   movetypes5  = 0x0020,
   movetypes6  = 0x0040,
   movetypes7  = 0x0080,
   movetypes8  = 0x0100,
   movetypes9  = 0x0200,
   movetypes10 = 0x0400,
   movetypes11 = 0x0800,
   movetypes12 = 0x1000,
   movetypes13 = 0x2000,
   movetypes14 = 0x4000,
   movetypes15 = 0x8000,
}

--- Stores registered movetypes names mapped to their bitmask values.
--- @type table<string, integer>
Collision.registeredMovetypes = {}

--- Stores bitmask values mapped to their registered movetypes names.
--- @type table<integer, string>
Collision.movetypeNames = {}

--- Registers a user-defined name for a collision movetypes.
--- Prevents duplicate registrations and invalid movetypes.
--- @param name string The name to associate with the movetypes.
--- @param movetype string The movetypes key from `Collision.movetypes`.
function Collision.registerMovetype(name, movetype)
   if Collision.movetypes[movetype] == nil then
      error("Invalid movetypes: " .. tostring(movetype))
   end
   if Collision.registeredMovetypes[name] then
      error("movetypes name already registered: " .. name)
   end
   if Collision.movetypeNames[Collision.movetypes[movetype]] then
      error("movetypes already assigned to another name: " .. Collision.movetypesNames[Collision.MOVETYPES[movetype]])
   end

   Collision.registeredMovetypes[name] = Collision.movetypes[movetype]
   Collision.movetypeNames[Collision.movetypes[movetype]] = name
end

--- Retrieves the bitmask value associated with a registered movetypes name.
--- @param name string The registered movetypes name.
--- @return integer|nil value The bitmask value, or nil if not found.
function Collision.getMovetypeByName(name)
   return Collision.registeredMovetypes[name]
end

--- Retrieves the registered movetypes name associated with a bitmask value.
--- @param bitmask integer The bitmask value.
--- @return string|nil name The movetypes name, or nil if not found.
function Collision.getMovetypeName(bitmask)
   return Collision.movetypeNames[bitmask]
end

function Collision.assignNextAvailableMovetype(name)
   if Collision.registeredMovetypes[name] then
      error("movetypes name already registered: " .. name)
   end

   for _, bitmask in pairs(Collision.MOVETYPES) do
      if not Collision.movetypeNames[bitmask] then
         Collision.registeredMovetypes[name] = bitmask
         Collision.movetypeNames[bitmask] = name
         return bitmask
      end
   end

   error("No available collision movetypes remaining.")
end

--- Converts a list of collision movetypes names into a combined bitmask.
--- @param movetypesNames string[] A list of movetypes names to combine.
--- @return integer The combined bitmask.
function Collision.createBitmaskFromMovetypes(movetypesNames)
   local bitmask = 0

   for _, name in ipairs(movetypesNames) do
      local movetypesBitmask = Collision.registeredMovetypes[name]
      if not movetypesBitmask then
         error("movetypes name not found: " .. name)
      end
      bitmask = bit.bor(bitmask, movetypesBitmask)  -- bitwise OR using `bit.bor`
   end

   return bitmask
end

--- Checks if two bitmasks have any overlapping collision movetypes.
--- @param bitmaskA integer The first bitmask.
--- @param bitmaskB integer The second bitmask.
--- @return boolean True if there is an overlap, false otherwise.
function Collision.checkBitmaskOverlap(bitmaskA, bitmaskB)
   return bit.band(bitmaskA, bitmaskB) ~= 0  -- bitwise AND to check for common bits
end

return Collision
