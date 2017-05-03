pudge_dismember_lua = class({})
LinkLuaModifier( "modifier_pudge_dismember_lua", "abilities/pudge_dismember_lua.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function pudge_dismember_lua:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:GetChannelTime()
	return 3
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:OnAbilityPhaseStart()
	if IsServer() then
		self.hVictim = self:GetCursorTarget()
	end

	return true
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:OnSpellStart()
	if self.hVictim == nil then
		return
	end

	if self.hVictim:TriggerSpellAbsorb( self ) then
		self.hVictim = nil
		self:GetCaster():Interrupt()
	else
		self.hVictim:AddNewModifier( self:GetCaster(), self, "modifier_pudge_dismember_lua", { duration = self:GetChannelTime() } )
		self.hVictim:Interrupt()
	end
end


--------------------------------------------------------------------------------

function pudge_dismember_lua:OnChannelFinish( bInterrupted )
	if self.hVictim ~= nil then
		self.hVictim:RemoveModifierByName( "modifier_pudge_dismember_lua" )
	end
end

if modifier_pudge_dismember_lua == nil then modifier_pudge_dismember_lua = class({}) end

function modifier_pudge_dismember_lua:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:OnCreated( kv )
	self.dismember_damage = self:GetAbility():GetSpecialValueFor( "dismember_damage" )
	self.tick_rate = 1
	self.strength_damage_scepter = self:GetAbility():GetSpecialValueFor( "strength_damage_scepter" )
    self.damage = self.dismember_damage

	if IsServer() then
		if self:GetCaster():HasScepter() then
	        self.damage = self.dismember_damage + (self:GetCaster():GetStrength()*self.strength_damage_scepter)
	    end
		self:GetParent():InterruptChannel()
		self:OnIntervalThink()
		self:StartIntervalThink( self.tick_rate )
	end
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:OnDestroy()
	if IsServer() then
		self:GetCaster():InterruptChannel()
	end
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:OnIntervalThink()
	if IsServer() then
		local flDamage = self.damage
		if self:GetCaster():HasScepter() then
			self:GetCaster():Heal( flDamage, self:GetAbility() )
		end

		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = flDamage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		}

		ApplyDamage( damage )
		EmitSoundOn( "Hero_Pudge.Dismember", self:GetParent() )
	end
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end
