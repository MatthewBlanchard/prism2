local AttackData = require "example_srd.attackdata"

---@type SRDAction
local SRDAction = require "example_srd.actions.srdaction"

--- @class AttackDataTarget : Target
local AttackDataTarget = prism.Target:extend("AttackDataTarget")
AttackDataTarget.typesAllowed = {Any = true}

function AttackDataTarget:validate(_, targetObject, _)
   return targetObject:is(AttackData)
end

function AttackDataTarget:hint(owner, _, _)
   local stats = owner:getComponent(prism.components.SRDStats)
   return stats.attacks:bake()
end

--- @class AttackTarget : Target
local AttackTarget = prism.Target:extend("AttackTarget")
AttackTarget.typesAllowed = { Actor = true }

---@param owner Actor
---@param targetObject Actor
function AttackTarget:validate(owner, targetObject, targets)
   ---@type AttackData
   local weapon = targets[1]
   local rangeCheck = owner:getRange("chebyshev", targetObject) <= (weapon.range.long or weapon.range.short)

   local hasStats = targetObject:getComponent(prism.components.SRDStats)

   return rangeCheck and hasStats and targetObject:hasComponent(prism.components.SRDStats)
end

---@class AttackAction : SRDAction
---@field name string
---@field silent boolean
---@field targets Target[]
local Attack = SRDAction:extend("AttackAction")
Attack.name = "attack"
Attack.targets = { AttackDataTarget, AttackTarget }
Attack.stripName = true

function Attack:movePointCost(level, actor)
   return 0
end

function Attack:actionSlot()
   return "Action"
end

--- @param attackdata AttackData
function Attack:calculateAttackModifiers(attackdata)
   if attackdata.staticToHit then return attackdata.staticToHit end

   local stats = self.owner:getComponent(prism.components.SRDStats)
   local statBonus = stats:getStatBonus("STR")

   if attackdata.properties.finesse then
      if stats:getStatBonus("DEX") > statBonus then
         statBonus = stats:getStatBonus("DEX")
      end
   end

   local weaponBonus = attackdata.tohitBonus

   return weaponBonus + statBonus
end

--- @param attackdata AttackData
function Attack:calculateDamageModifiers(attackdata)
   local stats = self.owner:getComponent(prism.components.SRDStats)
   local statBonus = stats:getStatBonus("STR")

   if attackdata.properties.finesse then
      if stats:getStatBonus("DEX") > statBonus then
         statBonus = stats:getStatBonus("DEX")
      end
   end

   local damageBonus = attackdata.damageBonus
   return statBonus + damageBonus
end

--- @param baseAttackRoll integer
function Attack:determineCrit(baseAttackRoll)
   return baseAttackRoll >= 20
end

function Attack:perform(level)
   --- @type AttackData
   local attackDataTarget = self:getTarget(1)
   --- @type Actor
   local attackTarget = self:getTarget(2)

   local ownerStats = self.owner:getComponent(prism.components.SRDStats)
   local targetStats = attackTarget:getComponent(prism.components.SRDStats)

   -- base attack roll
   local baseAttackRoll = level.RNG:random(1, 20)
   -- friendly attack rerolls
   -- unfriendly attack roll rerolls
   -- determine crits
   local crit = self:determineCrit(baseAttackRoll)
   -- cancel crits
   -- add modifiers
   local attackRoll = baseAttackRoll + self:calculateAttackModifiers(attackDataTarget)
   if attackRoll >= targetStats.naturalAC or crit then
      local staticDamage = 0
      local staticDamageType
      local damageDice = {}

      for _, damageData in pairs(attackDataTarget.damage) do
         local dice = damageData.dice
         if type(dice) == "number" then
            staticDamage = staticDamage + dice
            staticDamageType = damageData.type
         else
            --- @cast dice DiceData
            local diceroll = dice:roll(level.RNG)
            for _, die in ipairs(diceroll.dice) do
               table.insert(damageDice, {die, damageData.type})
            end

            if crit then
               local critroll = dice:roll(level.RNG)
               for _, die in ipairs(critroll.dice) do
                  table.insert(damageDice, {die, damageData.type})
               end
            end
         end
      end
      -- friendly damage rerolls
      -- unfriendly damage rerolls
      -- damage reduction
      -- resistances/weaknesses

      local finalDamage = staticDamage
      for _, dieTuple in ipairs(damageDice) do
         ---@cast dieTuple { [1]: Die, [2]: DamageType}
         finalDamage = finalDamage + dieTuple[1].result
         print(dieTuple[1].sides, dieTuple[1].result)
      end

      finalDamage = finalDamage + self:calculateDamageModifiers(attackDataTarget)
      targetStats.HP = targetStats.HP - finalDamage

      if targetStats.HP < 0 then
         level:removeActor(attackTarget)
      end
   end
end

return Attack
