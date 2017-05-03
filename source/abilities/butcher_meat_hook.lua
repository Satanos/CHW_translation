if butcher_meat_hook == nil then butcher_meat_hook = class({}) end
LinkLuaModifier("modifier_butcher_meat_hook", "abilities/butcher_meat_hook.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
--------------------------------------------------------------------------------

function butcher_meat_hook:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
	return true
end

function butcher_meat_hook:IsStealable()
	return false
end

function butcher_meat_hook:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

function butcher_meat_hook:GetCastRange (vLocation, hTarget)
    if self:GetCaster ():HasScepter () then
        return 2100
    end

    return self.BaseClass.GetCastRange (self, vLocation, hTarget)
end

function butcher_meat_hook:GetCooldown (nLevel)
    if self:GetCaster ():HasScepter () then
        return 8
    end

    return self.BaseClass.GetCooldown (self, nLevel)
end
--------------------------------------------------------------------------------

function butcher_meat_hook:OnSpellStart()
	self.bChainAttached = false
	if self.hVictim ~= nil then
		self.hVictim:InterruptMotionControllers( true )
	end

	self.hook_damage = self:GetAbilityDamage()
	self.hook_speed = 1600
	self.hook_width = 100
	self.hook_distance = self:GetSpecialValueFor( "hook_distance" )
  if self:GetCaster():HasScepter() then
      self.hook_distance = self:GetSpecialValueFor( "cast_range_scepter" )
  end

	self.vision_radius = self:GetSpecialValueFor( "vision_radius" )
	self.vision_duration = self:GetSpecialValueFor( "vision_duration" )

	if self:GetCaster() and self:GetCaster():IsHero() then
		local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
		if hHook ~= nil then
			hHook:AddEffects( EF_NODRAW )
		end
	end

	self.vStartPosition = self:GetCaster():GetOrigin()
	self.vProjectileLocation = vStartPosition

	local vDirection = self:GetCursorPosition() - self.vStartPosition
	vDirection.z = 0.0

	local vDirection = ( vDirection:Normalized() ) * self.hook_distance
	self.vTargetPosition = self.vStartPosition + vDirection

	self.vHookOffset = Vector( 0, 0, 96 )
	local vHookTarget = self.vTargetPosition + self.vHookOffset
	local vKillswitch = Vector( ( ( self.hook_distance / self.hook_speed ) * 2 ), 0, 0 )

	self.nChainParticleFXIndex = ParticleManager:CreateParticle( "particles/econ/items/pudge/pudge_ti6_immortal/pudge_ti6_witness_meathook.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleAlwaysSimulate( self.nChainParticleFXIndex )
	ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 1, vHookTarget )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 2, Vector( self.hook_speed, self.hook_distance, self.hook_width ) )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 3, vKillswitch )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )

	EmitSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )

	local info = {
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		vVelocity = vDirection:Normalized() * self.hook_speed,
		fDistance = self.hook_distance,
		fStartRadius = self.hook_width ,
		fEndRadius = self.hook_width ,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		iVisionRadius = 100,
	}

	ProjectileManager:CreateLinearProjectile( info )

	self.bRetracting = false
	self.hVictim = nil
	self.bDiedInHook = false
end

--------------------------------------------------------------------------------

function butcher_meat_hook:OnProjectileHit( hTarget, vLocation )
	if self.bRetracting == false then
		if hTarget ~= nil and ( not ( hTarget:IsCreep() or hTarget:IsConsideredHero() ) ) then
			Msg( "Target was invalid")
			return false
		end

		local bTargetPulled = false
		if hTarget ~= nil then
			if hTarget == self:GetCaster() then
				return false
			end
			if hTarget:IsCommandRestricted() then
				return false
			end
			EmitSoundOn( "Hero_Pudge.AttackHookImpact", hTarget )

			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_butcher_meat_hook", nil )
			if self:GetCaster():HasScepter() then
                self.hook_damage = self:GetAbilityDamage() + ((self:GetCaster():GetStrength() + self:GetCaster():GetIntellect() + self:GetCaster():GetAgility())*(self:GetSpecialValueFor("damage_atributes_scepter")/100))
            end
			if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
				local damage = {
						victim = hTarget,
						attacker = self:GetCaster(),
						damage = self.hook_damage,
						damage_type = DAMAGE_TYPE_PHYSICAL,
						ability = self
					}

				ApplyDamage( damage )

				if not hTarget:IsAlive() then
					self.bDiedInHook = true
				end

				if not hTarget:IsMagicImmune() then
					hTarget:Interrupt()
				end

				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
				ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
			end



			AddFOWViewer( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self.vision_radius, self.vision_duration, false )
			self.hVictim = hTarget
			bTargetPulled = true
		end

		local vHookPos = self.vTargetPosition
		local flPad = self:GetCaster():GetPaddedCollisionRadius()
		if hTarget ~= nil then
			vHookPos = hTarget:GetOrigin()
			flPad = flPad + hTarget:GetPaddedCollisionRadius()
		end

		--Missing: Setting target facing angle
		local vVelocity = self.vStartPosition - vHookPos
		vVelocity.z = 0.0

		local flDistance = vVelocity:Length2D() - flPad
		vVelocity = vVelocity:Normalized() * self.hook_speed

		local info = {
			Ability = self,
			vSpawnOrigin = vHookPos,
			vVelocity = vVelocity,
			fDistance = flDistance,
			Source = self:GetCaster(),
		}

		ProjectileManager:CreateLinearProjectile( info )
		self.vProjectileLocation = vHookPos

		if hTarget ~= nil and ( not hTarget:IsInvisible() ) and bTargetPulled then
			ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin() + self.vHookOffset, true )
			ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 0, 0, 0 ) )
			ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 1, 0, 0 ) )
		else
			ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true);
		end

		EmitSoundOn( "Hero_Pudge.AttackHookRetract", hTarget )

		if self:GetCaster():IsAlive() then
			self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
			self:GetCaster():StartGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
		end

		self.bRetracting = true
	else
		if self:GetCaster() and self:GetCaster():IsHero() then
			local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
			if hHook ~= nil then
				hHook:RemoveEffects( EF_NODRAW )
			end
		end

		if self.hVictim ~= nil then
			local vFinalHookPos = vLocation
			self.hVictim:InterruptMotionControllers( true )
			self.hVictim:RemoveModifierByName( "modifier_butcher_meat_hook" )

			local vVictimPosCheck = self.hVictim:GetOrigin() - vFinalHookPos
			local flPad = self:GetCaster():GetPaddedCollisionRadius() + self.hVictim:GetPaddedCollisionRadius()
			if vVictimPosCheck:Length2D() > flPad then
				FindClearSpaceForUnit( self.hVictim, self.vStartPosition, false )
			end
		end

		self.hVictim = nil
		ParticleManager:DestroyParticle( self.nChainParticleFXIndex, true )
		EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", self:GetCaster() )
	end

	return true
end

--------------------------------------------------------------------------------

function butcher_meat_hook:OnProjectileThink( vLocation )
	self.vProjectileLocation = vLocation
  if IsServer() then
    AddFOWViewer(2, vLocation, 50, 1, true)
    AddFOWViewer(3, vLocation, 50, 1, true)
  end
end

--------------------------------------------------------------------------------

function butcher_meat_hook:OnOwnerDied()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
	self:GetCaster():RemoveGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
end

modifier_butcher_meat_hook = class({})
--------------------------------------------------------------------------------

function modifier_butcher_meat_hook:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_butcher_meat_hook:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_butcher_meat_hook:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function modifier_butcher_meat_hook:OnCreated( kv )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------

function modifier_butcher_meat_hook:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_butcher_meat_hook:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function modifier_butcher_meat_hook:CheckState()
	if IsServer() then
		if self:GetCaster() ~= nil and self:GetParent() ~= nil then
			if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and ( not self:GetParent():IsMagicImmune() ) then
				local state = {
				[MODIFIER_STATE_STUNNED] = true,
				}

				return state
			end
		end
	end

	local state = {}

	return state
end

function modifier_butcher_meat_hook:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		if self:GetAbility().hVictim ~= nil then
			self:GetAbility().hVictim:SetOrigin( self:GetAbility().vProjectileLocation )
			local vToCaster = self:GetAbility().vStartPosition - self:GetCaster():GetOrigin()
			local flDist = vToCaster:Length2D()
			if self:GetAbility().bChainAttached == false and flDist > 128.0 then
				self:GetAbility().bChainAttached = true
				ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_CUSTOMORIGIN, "attach_hitloc", self:GetCaster():GetOrigin(), true )
				ParticleManager:SetParticleControl( self:GetAbility().nChainParticleFXIndex, 0, self:GetAbility().vStartPosition + self:GetAbility().vHookOffset )
			end
		end
	end
end

function modifier_butcher_meat_hook:OnHorizontalMotionInterrupted()
	if IsServer() then
		if self:GetAbility().hVictim ~= nil then
			ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetAbsOrigin() + self:GetAbility().vHookOffset, true )
			self:Destroy()
		end
	end
end
