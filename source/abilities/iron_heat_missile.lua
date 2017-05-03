iron_heat_missile = class({})

function iron_heat_missile:OnSpellStart()
	local radius = self:GetSpecialValueFor( "radius" )

	local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	if #targets > 0 then
		local count = 0
		for _,enemy in pairs(targets) do
			if count < self:GetSpecialValueFor("targets") then
				count = count + 1
				local info = {
						EffectName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf",
						Ability = self,
						iMoveSpeed = self:GetSpecialValueFor( "speed" ),
						Source = self:GetCaster(),
						Target = enemy,
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
					}

				ProjectileManager:CreateTrackingProjectile( info )
				EmitSoundOn( "Hero_Tinker.Heat-Seeking_Missile", self:GetCaster() )
			else
				break
			end
		end
	else
		EmitSoundOn( "Hero_Tinker.Heat-Seeking_Missile_Dud", self:GetCaster() )
	end
	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_3 );
end


function iron_heat_missile:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) and ( not hTarget:IsMagicImmune() ) then
		EmitSoundOn( "Hero_Tinker.Heat-Seeking_Missile.Impact", hTarget )

		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self:GetAbilityDamage(),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage( damage )
	end

	return true
end
