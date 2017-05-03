if batman_betarang == nil then batman_betarang = class({}) end

--[[[[function batman_betarang:OnSpellStart()
	local hTarget = self:GetCursorTarget()
    local hCaster = self:GetCaster()
    EmitSoundOn( "Hero_BountyHunter.Shuriken", self:GetCaster() )
	if hTarget ~= nil then
		if ( not hTarget:TriggerSpellAbsorb( self ) ) then
            -- Add a modifier to this unit.
            local info = {
			EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
			Ability = self,
			iMoveSpeed = 1000,
			Source = hCaster,
			Target = hTarget,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
			}
			ProjectileManager:CreateTrackingProjectile( info )

            local target_teams = self:GetAbilityTargetTeam()
            local target_types = self:GetAbilityTargetType()
            local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
            local start_pos = hTarget:GetAbsOrigin(  )
            local unit_table = FindUnitsInLine(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), hCaster:GetAbsOrigin()+(hCaster:GetForwardVector():Normalized()*1200) nil, 400, target_teams, target_types, target_flags)
            for index, unit in pairs(unit_table) do
               unit.dest = ( start_pos - unit:GetAbsOrigin() ):Length2D()
            end

            table.sort(unit_table,
            function(i, j)
                if i.dest < j.dest then
                    return true
                else
                    return false
                end
            end)
            if IsServer() then
                for index, unit in pairs(unit_table) do
                    Timers:CreateTimer(index * (), function()
			            local info = {
						EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
						Ability = self,
						iMoveSpeed = 1000,
						Source = hCaster,
						Target = hTarget,
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
						}
						ProjectileManager:CreateTrackingProjectile( info )
                        -- Play named sound on Entity
                        local next_unit = unit_table[index + 1]
                        if next_unit == nil then
                            next_unit = hCaster
                        end
                    end)
                    -- Damage an npc.
                    unit.dest = nil
                end
            end
        end
    end
end]]

function batman_betarang:OnSpellStart()
	local info = {
			EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
			Ability = self,
			iMoveSpeed = 500,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
		}

	ProjectileManager:CreateTrackingProjectile( info )
	EmitSoundOn( "Hero_BountyHunter.Shuriken", self:GetCaster() )
	self.max_bounces = self:GetSpecialValueFor("max_bounce")
end

--------------------------------------------------------------------------------

function batman_betarang:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) and ( not hTarget:IsMagicImmune() ) then
		EmitSoundOn( "Hero_BountyHunter.Shuriken.Impact", hTarget )

		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self:GetAbilityDamage(),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage( damage )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = self:GetSpecialValueFor("stun_duration") } )
		if self.max_bounces == 0 then
			return nil
		end
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hTarget:GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		if #units > 0 then
			for _,target in pairs(units) do
				if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:IsInvulnerable() ) and target ~= hTarget then
					local info = {
						EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
						Ability = self,
						iMoveSpeed = 500,
						Source = hTarget,
						Target = target,
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
					}
					self.max_bounces = self.max_bounces - 1
					ProjectileManager:CreateTrackingProjectile( info )
					break
				end
			end
		end
	end

	return true
end
