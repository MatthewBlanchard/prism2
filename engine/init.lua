--- We export a global namespace.
--- @module "prism"
prism = {}
prism.path = ...

function prism.require(p) return require(table.concat({ prism.path, p }, ".")) end

prism.json = prism.require "lib.json"

--- @type boolean
prism._initialized = false

prism._defaultDistance = "8way"
prism._defaultRangeType = "8way"

-- Root object

--- @module "engine.core.object"
prism.Object = prism.require "core.object"

-- Colors
--- @module "engine.math.color"
prism.Color4 = prism.require "math.color"

-- Math
--- @module 'engine.math.vector'
prism.Vector2 = prism.require "math.vector"

--- @module "engine.math.bounding_box"
prism.BoundingBox = prism.require "math.bounding_box"

--- @module "engine.math.bresenham"
prism.Bresenham = prism.require "math.bresenham"

--- @module "engine.algorithms.ellipse"
prism.Ellipse = prism.require "algorithms.ellipse"

--- @module "engine.algorithms.bfs"
prism.BreadthFirstSearch = prism.require "algorithms.bfs"

prism.neighborhood = prism.Vector2.neighborhood8

--- @param neighborhood Neighborhood
function prism.setDefaultNeighborhood(neighborhood)
   prism.neighborhood = neighborhood
end

-- Structures
--- @module "engine.structures.sparsemap"
prism.SparseMap = prism.require "structures.sparsemap"

--- @module "engine.structures.sparsegrid"
prism.SparseGrid = prism.require "structures.sparsegrid"

--- @module "engine.structures.sparsearray"
prism.SparseArray = prism.require "structures.sparsearray"

--- @module "engine.structures.grid"
prism.Grid = prism.require "structures.grid"

--- @module "engine.structures.booleanbuffer"
prism.BooleanBuffer = prism.require "structures.booleanbuffer"

--- @module "engine.structures.bitmaskbuffer"
prism.BitmaskBuffer = prism.require "structures.bitmaskbuffer"

--- @module "engine.structures.queue"
prism.Queue = prism.require "structures.queue"

--- @module "engine.structures.priority_queue"
prism.PriorityQueue = prism.require "structures.priority_queue"

-- Algorithms
prism.fov = {}
--- @module "engine.algorithms.fov.row"
prism.fov.Row = prism.require "algorithms.fov.row"
--- @module "engine.algorithms.fov.quadrant"
prism.fov.Quadrant = prism.require "algorithms.fov.quadrant"
--- @module "engine.algorithms.fov.fraction"
prism.fov.Fraction = prism.require "algorithms.fov.fraction"
--- @module "engine.algorithms.fov.fov"
prism.computeFOV = prism.require "algorithms.fov.fov"

--- @module "engine.algorithms.astar.path"
prism.Path = prism.require "algorithms.astar.path"

--- @module "engine.algorithms.astar.astar"
prism.astar = prism.require "algorithms.astar.astar"

-- Core
--- @module "engine.core.scheduler.scheduler"
prism.Scheduler = prism.require "core.scheduler.scheduler"
--- @module "engine.core.scheduler.simple_scheduler"
prism.SimpleScheduler = prism.require "core.scheduler.simple_scheduler"
--- @module "engine.core.action"
prism.Action = prism.require "core.action"
--- @module "engine.core.component" 
prism.Component = prism.require "core.component"
--- @module "engine.core.actor"
prism.Actor = prism.require "core.actor"
--- @module "engine.core.actorstorage" 
prism.ActorStorage = prism.require "core.actorstorage"
--- @module "engine.core.cell"
prism.Cell = prism.require "core.cell"
--- @module "engine.core.rng"
prism.RNG = prism.require "core.rng"
--- @module "engine.core.system"
prism.System = prism.require "core.system"
--- @module "engine.core.system_manager"
prism.SystemManager = prism.require "core.system_manager"
--- @module "engine.core.map_builder"
prism.MapBuilder = prism.require "core.map_builder"
--- @module "engine.core.map"
prism.Map = prism.require "core.map"
--- @module "engine.core.message"
prism.Message = prism.require "core.message"
--- @module "engine.core.decision"
prism.Decision = prism.require "core.decision"
--- @module "engine.core.target"
prism.Target = prism.require "core.target"
--- @module "engine.core.level"
prism.Level = prism.require "core.level"
--- @module "engine.core.collision"
prism.Collision = prism.require "core.collision"
-- Behavior Tree

prism.BehaviorTree = {}

--- @module "engine.core.behavior_tree.btnode"
prism.BehaviorTree.Node = prism.require "core.behavior_tree.btnode"
--- @module "engine.core.behavior_tree.btroot"
prism.BehaviorTree.Root = prism.require "core.behavior_tree.btroot"
--- @module "engine.core.behavior_tree.btselector"
prism.BehaviorTree.Selector = prism.require "core.behavior_tree.btselector"
--- @module "engine.core.behavior_tree.btsequence"
prism.BehaviorTree.Sequence = prism.require "core.behavior_tree.btsequence"
--- @module "engine.core.behavior_tree.btsucceeder"
prism.BehaviorTree.Succeeder = prism.require "core.behavior_tree.btsucceeder"


prism.actors = {}
prism.actions = {}
prism.components = {}
prism.cells = {}
prism.targets = {}
prism.messages = {}
prism.systems = {}
prism.messages = {}
prism.decisions = {}
prism.behaviors = {}

--- @module "engine.core.systems.senses"
prism.systems.Senses = prism.require "core.systems.senses"

--- @module "engine.core.components.collider"
prism.components.Collider = prism.require "core.components.collider"

--- @module "engine.core.components.controller"
prism.components.Controller = prism.require "core.components.controller"

--- @module "engine.core.components.player_controller"
prism.components.PlayerController = prism.require "core.components.player_controller"

--- @module "engine.core.components.senses"
prism.components.Senses = prism.require "core.components.senses"

--- @module "engine.core.components.opaque"
prism.components.Opaque = prism.require "core.components.opaque"

--- @module "engine.core.decisions.actiondecision"
prism.decisions.ActionDecision = prism.require "core.decisions.actiondecision"

--- @module "engine.core.messages.actionmessage"
prism.messages.ActionMessage = prism.require "core.messages.actionmessage"

--- @module "engine.core.messages.debugmessage"
prism.messages.DebugMessage = prism.require "core.messages.debugmessage"

prism._items = {
   "targets",
   "cells",
   "actions",
   "components",
   --"behaviors",
   "actors",
   "messages",
   "decisions",
   "systems",
}

prism._itemPatterns = {
   components = "[cC][oO][mM][pP][oO][nN][eE][nN][tT]",
   actors = "[aA][cC][tT][oO][rR]",
   actions = "[aA][cC][tT][iI][oO][nN]",
   cells = "[cC][eE][lL][lL]",
   targets = "[tT][aA][rR][gG][eE][tT]",
   messages = "[mM][eE][sS][sS][aA][gG][eE]",
   systems = "[sS][yY][sS][tT][eE][mM]",
   decisions = "[dD][eE][cC][iI][sS][iI][oO][nN]",
   behaviors = "[bB][eE][hH][aA][vV][iI][oO][rR]",
}


local function loadItems(path, itemType, recurse, definitions)
   local info = {}
   local items = prism[itemType]

   for k, item in pairs(love.filesystem.getDirectoryItems(path)) do
      local fileName = path .. "/" .. item
      love.filesystem.getInfo(fileName, info)
      if info.type == "file" then
         fileName = string.gsub(fileName, ".lua", "")
         fileName = string.gsub(fileName, "/", ".")

         local name = string.gsub(item, ".lua", "")
         local item = require(fileName)
         local strippedClassName = string.gsub(item.className, prism._itemPatterns[itemType], "")

         if not item.stripName then
            strippedClassName = item.className
         end

         assert(strippedClassName ~= "",
            "File " .. name .. " contains type " .. itemType .. " without a valid stripped name!")
         assert(items[strippedClassName] == nil,
            "File " .. name .. " contains type " .. itemType .. " with duplicate name!")
         items[strippedClassName] = item

         table.insert(definitions, "--- @module " .. '"' .. fileName .. '"')
         table.insert(definitions, "prism." .. itemType .. "." .. strippedClassName .. " = nil")
      elseif info.type == "directory" and recurse then
         loadItems(fileName, itemType, recurse, definitions)
      end
   end
end

prism.modules = {}
function prism.loadModule(directory)
   local items = love.filesystem.getDirectoryItems(directory)
   assert(#items > 0, "The specified directory in loadModule does not exist!")
   table.insert(prism.modules, directory)

   if love.filesystem.read(directory .. "/module.lua") then
      require(directory .. "." .. "module")
   end

   local sourceDir = love.filesystem.getSource() -- Get the source directory
   local definitions = { "---@meta " .. string.lower(directory) }

   for _, item in ipairs(prism._items) do
      loadItems(directory .. "/" .. item, item, true, definitions)
   end

   local lastSubdir = directory:match("([^/\\]+)$")

   -- Define the output file path
   local outputFile = sourceDir .. "/definitions/" .. lastSubdir .. ".lua"

   -- Write the concatenated definitions to the file
   local file, err = io.open(outputFile, "w")
   if not file then
      print("Failed to open file for writing: " .. (err or "Unknown error"))
      return
   end

   file:write(table.concat(definitions, "\n"))
   file:close()
end

function prism.hotload()
end

--- This is the core turn logic, and if you need to use a different scheduler or want a different turn structure you should override this.
--- There is a version of this provided for time-based
---@param level Level
---@param actor Actor
---@param controller ControllerComponent
---@diagnostic disable-next-line
function prism.turn(level, actor, controller)
   local _, action

   action = controller:act(level, actor)

   -- we make sure we got an action back from the controller for sanity's sake
   assert(action, "Actor " .. actor.name .. " returned nil from act()")

   level:performAction(action)
end

--- Runs the level coroutine and returns the next message, or nil if the coroutine has halted.
--- @return Message|nil
function prism.advanceCoroutine(updateCoroutine, level, decision)
   local success, ret = coroutine.resume(updateCoroutine, level, decision)

   if not success then
      error(ret .. "\n" .. debug.traceback(updateCoroutine))
   end

   local coroutineStatus = coroutine.status(updateCoroutine)
   if coroutineStatus == "suspended" then
      return ret
   end
end
