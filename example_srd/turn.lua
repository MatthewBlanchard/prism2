--- This is the core turn logic, and if you need to use a different scheduler or want a different turn structure you should override this.
---@param level Level
---@param actor Actor
---@param controller ControllerComponent
---@diagnostic disable-next-line
function prism.turn(level, actor, controller)
   local SRDStatsComponent = actor:getComponent(prism.components.SRDStats)
   if not level.decision then
      SRDStatsComponent:resetOnTurn()
   end

   while true do -- no brakes baby
      if not level:hasActor(actor) then break end

      local action = controller:act(level, actor)
      ---@cast action SRDAction

      if action:is(prism.actions.EndTurn) then break end
      -- we make sure we got an action back from the controller for sanity's sake
      assert(action, "Actor " .. actor.name .. " returned nil from act()")
      print(action.name, action.owner.name)
      assert(action:canPerform(level))

      SRDStatsComponent.curMovePoints = SRDStatsComponent.curMovePoints - action:movePointCost(level, actor)

      local slot = action:actionSlot(level, actor)
      if slot then
         SRDStatsComponent.actionSlots[slot] = false
      end

      level:performAction(action)
   end
end
