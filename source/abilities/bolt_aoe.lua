bolt_aoe = class({})


function bolt_aoe:OnSpellStart()
	local radius = self:GetSpecialValueFor( "radius" )
	local duration = self:GetSpecialValueFor(  "dur" )

	local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	if #targets > 0 then
  		for _,target in pairs(targets) do
					 ApplyDamage({attacker = self:GetCaster(), victim = target, damage = self:GetAbilityDamage(), ability = self, damage_type = DAMAGE_TYPE_MAGICAL})
  			   target:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = duration } )
  		end
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
  ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius, radius, 0) )
  ParticleManager:SetParticleControl( nFXIndex, 2, Vector(255, 255, 255) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOn( "chw.bolt_aoe", self:GetCaster() )

	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_2 );
end
