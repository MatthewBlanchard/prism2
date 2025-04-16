--- The `Component` class represents a component that can be attached to actors.
--- Components are used to add functionality to actors. For instance, the `Moveable` component
--- allows an actor to move around the map. Components are essentially data storage that can
--- also grant actions.
--- @class Component : Object
--- @field name string Each component prototype MUST have a unique name!
--- @field requirements table A list of component prototypes the actor must first have, before this can be applied.
--- @field owner Actor The Actor this component is composing. This is set by Actor when a component is added or removed.
--- @overload fun(): Component
--- @type Component
local Component = prism.Object:extend("Component")
Component.requirements = {}

--- Called after the actor is loaded and ready, this is where the component should do any initialization requiring
--- the actor. This would include stuff like attaching systems, etc.
--- @param owner Actor
function Component:initialize(owner) end

--- Checks whether an actor has the required components to attach this component.
--- @param actor Actor The actor to check the requirements against.
--- @return boolean meetsRequirements the actor meets all requirements, false otherwise.
function Component:checkRequirements(actor)
   local foundreqs = {}

   for _, component in pairs(actor.components) do
      for _, req in pairs(self.requirements) do
         if component:is(req) then table.insert(foundreqs, component) end
      end
   end

   if #foundreqs == #self.requirements then return true end

   return false
end

return Component
