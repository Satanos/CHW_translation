LinkLuaModifier ("modifier_item_monarh_bow", "items/item_monarh_bow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_monarh_bow_active", "items/item_monarh_bow.lua", LUA_MODIFIER_MOTION_NONE)

if item_monarh_bow == nil then
    item_monarh_bow = class ( {})
end

function item_monarh_bow:GetIntrinsicModifierName ()
    return "modifier_item_monarh_bow"
end

function item_monarh_bow:OnSpellStart ()
    local hCaster = self:GetCaster () --We will always have Caster.
    local duration = self:GetSpecialValueFor ("active_duration")
    self:GetCaster ():AddNewModifier (self:GetCaster (), self, "modifier_item_monarh_bow_active", { duration = duration } )
    local nFXIndex = ParticleManager:CreateParticle ("particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster () )
    ParticleManager:SetParticleControlEnt (nFXIndex, 2, self:GetCaster (), PATTACH_POINT_FOLLOW, "attach_head", self:GetCaster ():GetOrigin (), true)
    ParticleManager:ReleaseParticleIndex (nFXIndex)
    EmitSoundOn ("DOTA_Item.Butterfly", self:GetCaster () )
end

if modifier_item_monarh_bow == nil then
    modifier_item_monarh_bow = class ( {})
end

function modifier_item_monarh_bow:IsHidden ()
    return true
end

function modifier_item_monarh_bow:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_item_monarh_bow:GetModifierBaseAttack_BonusDamage (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_damage")
end

function modifier_item_monarh_bow:GetModifierBonusStats_Agility (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_agility")
end

function modifier_item_monarh_bow:GetModifierHealthBonus (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_health")
end

function modifier_item_monarh_bow:GetModifierManaBonus (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_mana")
end

function modifier_item_monarh_bow:GetModifierEvasion_Constant (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_evasion")
end


if modifier_item_monarh_bow_active == nil then
    modifier_item_monarh_bow_active = class ( {})
end

function modifier_item_monarh_bow_active:IsBuff()
    return false
end

function modifier_item_monarh_bow_active:GetTexture()
    return "item_monarh_bow"
end

function modifier_item_monarh_bow_active:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }

    return funcs
end

function modifier_item_monarh_bow_active:GetStatusEffectName ()
    return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_item_monarh_bow_active:StatusEffectPriority ()
    return 1000
end

function modifier_item_monarh_bow_active:GetModifierEvasion_Constant (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("active_evasion")
end

function modifier_item_monarh_bow_active:GetModifierMoveSpeedBonus_Constant (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("active_movement_speed")
end
