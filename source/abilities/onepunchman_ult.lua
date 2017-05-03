onepunchman_ult = class({})

--------------------------------------------------------------------------------
function onepunchman_ult:GetCooldown( nLevel )
    return self.BaseClass.GetCooldown( self, nLevel )
end
--------------------------------------------------------------------------------

function onepunchman_ult:OnSpellStart()
    local hTarget = self:GetCursorTarget()
    if hTarget ~= nil then
        if ( not hTarget:TriggerSpellAbsorb( self ) ) then
              local target = hTarget
              local caster = self:GetCaster()
              local ability = self
              local explosion5 = ParticleManager:CreateParticle("particles/one_punch.vpcf", PATTACH_WORLDORIGIN, target)
              ParticleManager:SetParticleControl(explosion5, 0, target:GetAbsOrigin() + Vector(0, 0, 1))
              ParticleManager:SetParticleControl(explosion5, 1, Vector(1, 1, 1))
              ParticleManager:SetParticleControl(explosion5, 2, Vector(255, 255, 255))
              ParticleManager:SetParticleControl(explosion5, 3, target:GetAbsOrigin())
              ParticleManager:SetParticleControl(explosion5, 5, Vector(200, 200, 0))

              local explosion13 = ParticleManager:CreateParticle("particles/hero_zoom/time_crystal_activate.vpcf", PATTACH_WORLDORIGIN, target)
              ParticleManager:SetParticleControl(explosion13 , 0, target:GetAbsOrigin())


              local exception_table = {}
              table.insert(exception_table, "modifier_dazzle_shallow_grave")
              table.insert(exception_table, "modifier_shallow_grave_datadriven")
              table.insert(exception_table, "modifier_damage_reverse_caster")
              table.insert(exception_table, "modifier_item_ghost_datadriven_active_ob")
              table.insert(exception_table, "modifier_dormammu_angel")
              table.insert(exception_table, "scarlet_witch_sphere")
              table.insert(exception_table, "modifier_byond")
              table.insert(exception_table, "modifier_fate_edict_buff")

              if target:HasItemInInventory("item_aegis") then
                  for i=0, 5, 1 do
                      local current_item = target:GetItemInSlot(i)
                      if current_item ~= nil then
                          if current_item:GetName() == "item_aegis" then
                              current_item:RemoveSelf()
                          end
                      end
                  end
              end

              target:Purge(true, true, false, false, true)
              if target:HasAbility("skeleton_king_reincarnation_datadriven") then
                  local abil = target:FindAbilityByName("skeleton_king_reincarnation_datadriven")
                  abil:StartCooldown(60)
              end
              local modifier_count = target:GetModifierCount()
              for i = 0, modifier_count do
                  local modifier_name = target:GetModifierNameByIndex(i)
                  local modifier_check = false

                  -- Compare if the modifier is in the exception table
                  -- If it is then set the helper variable to true and remove it
                  for j = 0, #exception_table do
                      if exception_table[j] == modifier_name then
                          modifier_check = true
                          break
                      end
                  end

                  -- Remove the modifier depending on the helper variable
                  if modifier_check then
                      target:RemoveModifierByName(modifier_name)
                  end
              end
              target:Kill(ability, caster)
              if target:IsAlive() then
                  target:ForceKill(false)
              end
          end
          EmitSoundOn( "Hero_EarthShaker.EchoSlam", hTarget )
          EmitSoundOn( "Hero_EarthShaker.EchoSlamEcho", self:GetCaster() )
          EmitSoundOn( "Hero_EarthShaker.EchoSlamSmall", hTarget )
          EmitSoundOn( "PudgeWarsClassic.echo_slam", hTarget )
          if self:GetCaster():HasScepter() then
              local damage = self:GetSpecialValueFor("damage_scepter")*0.01
              local Scepters = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 680, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
              for i = 1, #Scepters do
                  local target = Scepters[i]
                  EmitSoundOn( "Hero_Magnataur.ReversePolarity.Stun", target )
                  ApplyDamage({victim = target, attacker = self:GetCaster(), damage = hTarget:GetMaxHealth()*damage, damage_type = DAMAGE_TYPE_PURE})
              end
          end
      end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
