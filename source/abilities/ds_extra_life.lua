LinkLuaModifier("modifier_ds_extra_life", "abilities/ds_extra_life.lua", LUA_MODIFIER_MOTION_NONE)

ds_extra_life = class({})

function ds_extra_life:GetIntrinsicModifierName()
    return "modifier_ds_extra_life"
end

function ds_extra_life:GetBehavior ()
    local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
    return behav
end

modifier_ds_extra_life = class ({})

function modifier_ds_extra_life:IsHidden()
    return true
end


function modifier_ds_extra_life:OnCreated( kv )
    self.speed = self:GetAbility ():GetSpecialValueFor ("speed" )
end

--------------------------------------------------------------------------------

function modifier_ds_extra_life:OnRefresh( kv )
    self.speed = self:GetAbility ():GetSpecialValueFor ("speed")
end

--------------------------------------------------------------------------------

function modifier_ds_extra_life:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_ds_extra_life:GetModifierAttackSpeedBonus_Constant ( params )
    return self.speed
end
