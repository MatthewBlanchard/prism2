--- Senses is used by the sense system as the storage for all of the sensory information
--- from the other sense components/systems. It is required for sight. See the SensesSystem for more.
--- @class SensesComponent : Component
--- @field cells SparseGrid A sparse grid of cells representing the portion of the map the actor's senses reveal.
--- @field explored SparseGrid A sparse grid of cells the actor's senses have previously revealed.
--- @field actors ActorStorage An actor storage with the actors the player is aware of.
--- @field unknown SparseMap<Vector2> Unkown actors are things the player is aware of the location of, but not the components.
--- @overload fun(): SensesComponent
local Senses = prism.Component:extend("Senses")

function Senses:initialize(actor)
   self.explored = prism.SparseGrid()
   self.cells = prism.SparseGrid()
   self.actors = prism.ActorStorage()
   self.unknown = prism.SparseMap()
end

return Senses
