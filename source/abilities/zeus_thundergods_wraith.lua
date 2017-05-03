zeus_thundergods_wraith = class({})
function zeus_thundergods_wraith:GetCooldown( nLevel )
    if self:GetCaster():HasScepter() then
        return 90
    end

    return self.BaseClass.GetCooldown( self, nLevel )
end

function zeus_thundergods_wraith:OnAbilityPhaseStart()
  if IsServer() then
    EmitSoundOn("Hero_Zuus.GodsWrath.PreCast", self:GetCaster())
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
  end
  return true
end

function zeus_thundergods_wraith:OnSpellStart()
  if IsServer() then
    EmitSoundOn("Hero_Zuus.GodsWrath", self:GetCaster())
    local cooldown = self:GetCooldown(self:GetLevel() - 1)
    local abilityManaCost = self:GetManaCost(self:GetLevel() - 1 )
    self:PayManaCost()
    self:StartCooldown(cooldown)
    local particle_start = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", PATTACH_WORLDORIGIN, target)
    ParticleManager:SetParticleControl(particle_start, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_start, 1, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_start, 2, self:GetCaster():GetAbsOrigin())
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 99999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for i = 1, #targets do
      local target = targets[i]
      EmitSoundOn("Hero_Zuus.GodsWrath.Target", target)
      if not target:HasModifier("modifier_thundergods_wrath_vision") then
        target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = 3.5})
      end
      AddFOWViewer(self:GetCaster():GetTeam(), target:GetAbsOrigin(), 250, 1.5, false)
      target:AddNewModifier(self:GetCaster(), self, "modifier_truesight", {duration = 3.5})
      GridNav:DestroyTreesAroundPoint( target:GetAbsOrigin(), 250, false)
      self.damage = self:GetSpecialValueFor( "damage" )
      self.damage_pers = self:GetSpecialValueFor( "damage_pers" )/100
      if self:GetCaster():HasScepter() then
          self.damage_pers = self:GetSpecialValueFor( "damage_pers_scepter" )/100
      end
      local damage = self.damage + (target:GetMaxHealth()*self.damage_pers)
      ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
      local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf", PATTACH_WORLDORIGIN, target)
    	ParticleManager:SetParticleControl(particle, 0, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
    	ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,1000 ))
    	ParticleManager:SetParticleControl(particle, 2, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
    end
  end
end
