zatana_swarm = class({})

LinkLuaModifier( "modifier_zatana_swarm", "abilities/zatana_swarm.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function zatana_swarm:OnSpellStart()
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection = vDirection:Normalized()

	self.wave_speed = 1000
	self.wave_width = 300
	self.vision_aoe = 100
	self.vision_duration = 2
	self.tooltip_duration = 4

	local info = {
		EffectName = "particles/econ/items/death_prophet/death_prophet_acherontia/death_prophet_acher_swarm.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		fStartRadius = self.wave_width,
		fEndRadius = self.wave_width,
		vVelocity = vDirection * self.wave_speed,
		fDistance = self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() ),
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		bProvidesVision = true,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		iVisionRadius = self.vision_aoe,
	}

	self.nProjID = ProjectileManager:CreateLinearProjectile( info )
	EmitSoundOn( "Hero_DeathProphet.CarrionSwarm.Mortis" , self:GetCaster() )
end

function zatana_swarm:OnProjectileHit( hTarget, vLocation )
	local damage = self:GetAbilityDamage()
	if self:GetCaster():HasTalent("special_bonus_unique_zatanna") then
        damage = self:GetCaster():FindTalentValue("special_bonus_unique_zatanna") + self:GetAbilityDamage()
	end
	if hTarget ~= nil then
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self,
		}

		ApplyDamage( damage )
		EmitSoundOn( "Hero_DeathProphet.CarrionSwarm.Damage.Mortis" , hTarget )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_zatana_swarm", { duration = self.tooltip_duration } )
	end

	return false
end

modifier_zatana_swarm = class({})

--------------------------------------------------------------------------------

function modifier_zatana_swarm:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_zatana_swarm:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_zatana_swarm:GetEffectName()
	return "particles/econ/items/bane/slumbering_terror/bane_slumber_nightmare.vpcf"
end

--------------------------------------------------------------------------------

function modifier_zatana_swarm:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------

function modifier_zatana_swarm:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_zatana_swarm:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function modifier_zatana_swarm:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end
