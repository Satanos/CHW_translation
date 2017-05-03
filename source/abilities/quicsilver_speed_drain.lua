if quicsilver_speed_drain == nil then quicsilver_speed_drain = class({}) end

function quicsilver_speed_drain:GetCastRange( vLocation, hTarget )
	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end

function quicsilver_speed_drain:OnSpellStart()
	local hTarget = self:GetCaster():GetCursorPosition()
  local nFXIndex = ParticleManager:CreateParticle( "particles/hero_khan/khan_echo_strike_jump.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin());
  ParticleManager:SetParticleControl( nFXIndex, 1, self:GetCaster():GetOrigin());
  ParticleManager:SetParticleControl( nFXIndex, 3, self:GetCaster():GetOrigin());
	ParticleManager:ReleaseParticleIndex( nFXIndex );

	EmitSoundOn( "Hero_QueenOfPain.Blink_out", self:GetCaster() )

  self:GetCaster():SetAbsOrigin(hTarget)
  FindClearSpaceForUnit(self:GetCaster(), hTarget, true)

  local nFXIndex = ParticleManager:CreateParticle( "particles/hero_khan/khan_echo_strike_jump.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin());
  ParticleManager:SetParticleControl( nFXIndex, 1, self:GetCaster():GetOrigin());
  ParticleManager:SetParticleControl( nFXIndex, 3, self:GetCaster():GetOrigin());
	ParticleManager:ReleaseParticleIndex( nFXIndex );

  local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	if #units > 0 then
		for _,target in pairs(units) do
      EmitSoundOn( "Hero_QueenOfPain.ProjectileImpact", target )
      local damage = (self:GetCaster():GetIdealSpeed() - target:GetIdealSpeed() ) / 2
      if damage <= 0 then
          damage = self:GetAbilityDamage()
      else
          damage = self:GetAbilityDamage() + damage
      end
      ApplyDamage({attacker = self:GetCaster(), victim = target, damage = damage, ability = self, damage_type = DAMAGE_TYPE_MAGICAL})
		end
	end
end
