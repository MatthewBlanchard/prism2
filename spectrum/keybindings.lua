---@class Keybinding : Object
local Keybinding = prism.Object:extend("Keybinding")

--- Constructor for the Keybinding class.
--- Initializes the keymap and modes with a predefined schema and defaults.
--- @param schema table A list of predefined keybindings with their schema and defaults.
function Keybinding:__new(schema)
   self.schema = {} -- Holds the schema for all modes, including "default"
   self.keymap = {} -- Stores modifications

   -- Populate the schema with the provided schema entries
   for _, entry in ipairs(schema) do
      assert(type(entry.key) == "string", "Schema entry must include a 'key' field of type string.")
      assert(type(entry.action) == "string", "Schema entry must include an 'action' field of type string.")
      assert(entry.description == nil or type(entry.description) == "string",
             "Description must be a string or nil.")

      local mode = entry.mode or "default"
      self.schema[mode] = self.schema[mode] or {}
      self.schema[mode][entry.key] = {
         action = entry.action,
         description = entry.description or "No description provided."
      }
   end
end

--- Sets or updates a keybinding, validating it exists in the schema.
--- @param key string The key to bind.
--- @param action string The new action to associate with the key.
--- @param mode string|nil An optional mode for the binding (defaults to "default").
function Keybinding:set(key, action, mode)
   mode = mode or "default"
   assert(type(key) == "string", "Key must be a string.")
   assert(type(action) == "string", "Action must be a string.")

   -- Validate that the key exists in the schema
   local binding = self.schema[mode] and self.schema[mode][key]
   assert(binding, ("Key '%s' is not a predefined schema entry in mode '%s'."):format(key, mode))

   -- Update the keymap modification
   self.keymap[mode] = self.keymap[mode] or {}
   self.keymap[mode][key] = {
      action = action,
      description = binding.description -- Retain the original description
   }
end

--- Handles key press events and retrieves the associated action if a binding exists.
--- Falls back to the schema if no modification is found.
--- @param key string The key that was pressed.
--- @param mode string|nil The mode to use for the keybinding.
--- @return string|nil The action associated with the key, or nil if no binding exists.
function Keybinding:keypressed(key, mode)
   mode = mode or "default"  -- Default mode if none provided
   local binding = self.keymap[mode] and self.keymap[mode][key] or self.schema[mode] and self.schema[mode][key]
   return binding and binding.action
end

--- Resets keybindings for a specific mode or all modes to their defaults.
--- @param mode string|nil The mode to reset. If nil, resets all modes.
function Keybinding:clear(mode)
   if mode then
      self.keymap[mode] = nil
   else
      self.keymap = {}
   end
end

return Keybinding
