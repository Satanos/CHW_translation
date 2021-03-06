LinkLuaModifier("modifier_dimm_demons_power", "abilities/dimm_demons_power.lua", LUA_MODIFIER_MOTION_NONE)

dimm_demons_power = class({})

function dimm_demons_power:GetIntrinsicModifierName()
	return "modifier_dimm_demons_power"
end

modifier_dimm_demons_power = class({})

function modifier_dimm_demons_power:IsHidden()
	return false
end

function modifier_dimm_demons_power:IsPurgable()
	return false
end

function modifier_dimm_demons_power:RemoveOnDeath()
	return false
end

function modifier_dimm_demons_power:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_HERO_KILLED
	}

	return funcs
end

function modifier_dimm_demons_power:OnHeroKilled(params)
	if params.target:GetTeam() ~= self:GetParent():GetTeam() then
		if params.attacker == self:GetParent() then
			self:SetStackCount(self:GetStackCount() + 1)
		end
	end
end

function modifier_dimm_demons_power:GetModifierPreAttack_BonusDamage( params )
	return self:GetAbility():GetSpecialValueFor("bonus_damage")*self:GetStackCount()
end

function modifier_dimm_demons_power:GetAttributes ()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end
