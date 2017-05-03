if collector_passive == nil then collector_passive = class({}) end
LinkLuaModifier("collector_passive_aura", "abilities/collector_passive.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("collector_passive_modifier", "abilities/collector_passive.lua", LUA_MODIFIER_MOTION_NONE)

function collector_passive:GetIntrinsicModifierName()
	return "collector_passive_aura"
end

collector_passive_aura = class({})

function collector_passive_aura:IsAura()
	return true
end

function collector_passive_aura:GetAuraRadius()
	if self:GetCaster():HasScepter() then
		return 999999
	else
		return self:GetAbility():GetSpecialValueFor("radius")
	end
end

function collector_passive_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function collector_passive_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function collector_passive_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function collector_passive_aura:GetModifierAura()
	return "collector_passive_modifier"
end


collector_passive_modifier = class({})

function collector_passive_modifier:IsBuff()
	return true
end

function collector_passive_modifier:IsPurgable()
	return false
end

function collector_passive_modifier:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function collector_passive_modifier:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end
