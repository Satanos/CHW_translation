if tanos_dragon_blood == nil then tanos_dragon_blood = class({}) end

LinkLuaModifier ("modifier_tanos_dragon_blood", "abilities/tanos_dragon_blood.lua", LUA_MODIFIER_MOTION_NONE)

function tanos_dragon_blood:GetIntrinsicModifierName()
	return "modifier_tanos_dragon_blood"
end

if modifier_tanos_dragon_blood == nil then modifier_tanos_dragon_blood = class({}) end

function modifier_tanos_dragon_blood:IsPurgable(  )
    return false
end

function modifier_tanos_dragon_blood:IsHidden()
    return true
end

function modifier_tanos_dragon_blood:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }

    return funcs
end

function modifier_tanos_dragon_blood:GetModifierConstantHealthRegen( params )
    self.regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
    if self:GetParent():HasScepter() then 
        self.regen = self.regen + self:GetAbility():GetSpecialValueFor("bonus_health_regen_per_min_scepter")*(GameRules:GetGameTime()/60)
    end
    return self.regen
end
