--- A 'Cell' is a single tile on the map. It defines the properties of the tile and has a few callbacks.
--- Maybe cells should have components so that they can be extended with custom functionality like the grass?
--- Still working on the details there. For now, cells are just a simple way to define the properties of a tile.
--- @class Cell : Object
--- @field name string Displayed in the user interface.
--- @field passable boolean Defines whether a cell can moved through.
--- @field opaque boolean Defines whether a cell can be seen through.
--- @overload fun(): Cell
--- @type Cell
local Cell = prism.Object:extend("Cell")
Cell.name = nil
Cell.opaque = false
Cell.passable = false

--- Constructor for the Cell class.
function Cell:__new() end

--- Called when an actor enters the cell.
--- @param level Level The level where the actor entered the cell.
--- @param actor Actor The actor that entered the cell.
function Cell:onEnter(level, actor) end

--- Called when an actor leaves the cell.
--- @param level Level The level where the actor left the cell.
--- @param actor Actor The actor that left the cell.
function Cell:onLeave(level, actor) end

--- Called right before an action takes place on this cell.
--- @param level Level
--- @param actor Actor
--- @param action Action
function Cell:beforeAction(level, actor, action) end

--- Called right after an action is taken on the cell.
--- @param level Level The level where the action took place.
--- @param actor Actor The actor that took the action.
--- @param action Action The action that was taken.
function Cell:afterAction(level, actor, action) end

return Cell
