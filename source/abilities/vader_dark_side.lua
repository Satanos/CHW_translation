vader_dark_side = class({})

LinkLuaModifier( "modifier_vader_dark_side", "abilities/vader_dark_side.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vader_dark_side_leak", "abilities/vader_dark_side.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function vader_dark_side:GetIntrinsicModifierName()
	return "modifier_vader_dark_side"
end

function vader_dark_side:OnHeroDiedNearby( hVictim, hKiller, kv )
	if hVictim == nil or hKiller == nil then
		return
	end

	if hVictim:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and self:GetCaster():IsAlive() then
		local vToCaster = self:GetCaster():GetOrigin() - hVictim:GetOrigin()
		local flDistance = vToCaster:Length2D()
		if hKiller == self:GetCaster() or 400 >= flDistance then
			if self:GetCaster():HasModifier("modifier_vader") then
                local mod = self:GetCaster():FindModifierByName("modifier_vader")
                mod:SetStackCount(mod:GetStackCount() + 1)
				local mod2 = self:GetCaster():FindModifierByName("modifier_vader_dark_side")
				mod2:ForceRefresh()
            end

			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
end

modifier_vader_dark_side = class({})

function modifier_vader_dark_side:IsAura()
	return true
end

function modifier_vader_dark_side:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}

	return funcs
end

function modifier_vader_dark_side:OnCreated()
	if IsServer() then
        if self:GetCaster():HasModifier("modifier_vader") then
            local mod = self:GetCaster():FindModifierByName("modifier_vader")
            self.magic_resist = mod:GetStackCount()
        else
            self.magic_resist = 0
        end
    end
end

function modifier_vader_dark_side:GetModifierMagicalResistanceBonus( params )
	return self.magic_resist
end

function modifier_vader_dark_side:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "aura_radius" )
end

function modifier_vader_dark_side:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_vader_dark_side:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_vader_dark_side:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_vader_dark_side:GetModifierAura()
	return "modifier_vader_dark_side_leak"
end

modifier_vader_dark_side_leak = class({})

function modifier_vader_dark_side_leak:IsPurgable(  )
    return false
end

function modifier_vader_dark_side_leak:OnCreated( table )
    if IsServer(  ) then
        self:StartIntervalThink(1)
    end
end

function modifier_vader_dark_side_leak:OnIntervalThink()
    if IsServer(  ) then
        if self:GetParent():GetMana() > self:GetAbility():GetSpecialValueFor( "aura_damage" ) then

            local mana = self:GetAbility():GetSpecialValueFor( "aura_damage" )

            self:GetParent():SetMana(self:GetParent():GetMana() - mana)
            if self:GetCaster():HasTalent("special_bonus_unique_vader") then
		        mana = self:GetCaster():FindTalentValue("special_bonus_unique_vader") + mana
			end
            self:GetAbility():GetCaster():SetMana(self:GetCaster():GetMana() + mana)
            ApplyDamage({attacker = self:GetAbility():GetCaster(), victim = self:GetParent(), ability = self:GetAbility(), damage = mana, damage_type = DAMAGE_TYPE_MAGICAL})
        end
    end
end
