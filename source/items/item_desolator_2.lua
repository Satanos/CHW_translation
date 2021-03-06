LinkLuaModifier ("modifier_item_desolator_2", "items/item_desolator_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_desolator_datadriven_corruption", "items/item_desolator_2.lua", LUA_MODIFIER_MOTION_NONE)

if item_desolator_2 == nil then
    item_desolator_2 = class ( {})
end

function item_desolator_2:GetBehavior ()
    local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
    return behav
end

function item_desolator_2:GetIntrinsicModifierName ()
    return "modifier_item_desolator_2"
end

if modifier_item_desolator_2 == nil then
    modifier_item_desolator_2 = class ( {})
end

function modifier_item_desolator_2:IsHidden()
    return true
end

function modifier_item_desolator_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_item_desolator_2:GetModifierPreAttack_BonusDamage (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_damage")
end

function modifier_item_desolator_2:OnAttackLanded (params)
    if params.attacker == self:GetParent() then
		local hTarget = params.target
		hTarget:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_item_desolator_datadriven_corruption", {duration = 7})
		EmitSoundOn("Item_Desolator.Target", hTarget)
    end
end

if modifier_item_desolator_datadriven_corruption == nil then modifier_item_desolator_datadriven_corruption = class({}) end

function modifier_item_desolator_datadriven_corruption:IsHidden()
    return false
end

function modifier_item_desolator_datadriven_corruption:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

function modifier_item_desolator_datadriven_corruption:GetModifierPhysicalArmorBonus( params )
    return self:GetAbility():GetSpecialValueFor("corruption_armor")
end
