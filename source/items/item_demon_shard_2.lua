LinkLuaModifier ("modifier_item_demon_shard_2", "items/item_demon_shard_2.lua", LUA_MODIFIER_MOTION_NONE)

if item_demon_shard_2 == nil then
    item_demon_shard_2 = class ( {})
end

function item_demon_shard_2:GetBehavior ()
    local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
    return behav
end

function item_demon_shard_2:GetIntrinsicModifierName ()
    return "modifier_item_demon_shard_2"
end

if modifier_item_demon_shard_2 == nil then
    modifier_item_demon_shard_2 = class ( {})
end

function modifier_item_demon_shard_2:IsHidden()
    return true
end

function modifier_item_demon_shard_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_item_demon_shard_2:GetModifierProcAttack_BonusDamage_Pure (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_damage_post_attack")
end


function modifier_item_demon_shard_2:GetModifierPreAttack_BonusDamage (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_damage")
end

function modifier_item_demon_shard_2:GetModifierBonusStats_Strength (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("all")
end

function modifier_item_demon_shard_2:GetModifierBonusStats_Intellect (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("all")
end

function modifier_item_demon_shard_2:GetModifierBonusStats_Agility (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("all")
end

function modifier_item_demon_shard_2:GetModifierAttackSpeedBonus_Constant (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("as")
end

function modifier_item_demon_shard_2:GetModifierPreAttack_CriticalStrike(params)
	if RollPercentage(self:GetAbility():GetSpecialValueFor("crit_chance")) then
		IsHasCrit = true
		return self:GetAbility():GetSpecialValueFor("crit_bonus")
	end
	IsHasCrit = false
	return
end

function modifier_item_demon_shard_2:OnAttackLanded (params)
    if params.attacker == self:GetParent() then
        if params.target ~= nil and params.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
            local cleaveDamage = ( self:GetAbility():GetSpecialValueFor("percent_cleave") * params.damage ) / 100.0
            DoCleaveAttack( self:GetParent(), params.target, self:GetAbility(), cleaveDamage, 230, 230, 230, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
        end
    	if IsHasCrit and not params.target:IsBuilding() then
        local hTarget = params.target
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
        EmitSoundOn("Hero_Winter_Wyvern.WintersCurse.Target", hTarget)
        ScreenShake(hTarget:GetOrigin(), 100, 0.1, 0.3, 500, 0, true)
    	end
    end
end

function modifier_item_demon_shard_2:GetAttributes ()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end
