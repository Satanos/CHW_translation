zoom_damage_speed = class({})

function zoom_damage_speed:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	local nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster )
	ParticleManager:SetParticleControlEnt( nCasterFX, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nCasterFX )

	local nTargetFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControlEnt( nTargetFX, 1, hCaster, PATTACH_ABSORIGIN_FOLLOW, nil, hCaster:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nTargetFX )

	EmitSoundOn( "Hero_Invoker.ColdSnap", hCaster )
	EmitSoundOn( "Hero_Invoker.ColdSnap.Cast", hTarget )

  local caster_as = hCaster:GetIdealSpeed()

  local damage = caster_as * self:GetSpecialValueFor("damage")/100

  hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun")})
  local damageTable = {
      victim = hTarget,
      attacker = hCaster,
      damage = damage,
      damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
  }
  ApplyDamage(damageTable)

end
