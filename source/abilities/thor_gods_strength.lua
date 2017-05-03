LinkLuaModifier ("modifier_thor_gods_strength", "abilities/thor_gods_strength.lua", LUA_MODIFIER_MOTION_NONE)

if thor_gods_strength == nil then thor_gods_strength = class({}) end

function thor_gods_strength:GetIntrinsicModifierName()
	return "modifier_thor_gods_strength"
end

if modifier_thor_gods_strength == nil then modifier_thor_gods_strength = class({}) end

function modifier_thor_gods_strength:IsHidden()
	return true
end

function modifier_thor_gods_strength:IsPurgable()
    return false
end

function modifier_thor_gods_strength:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,
        MODIFIER_EVENT_ON_ATTACK_START
    }

    return funcs
end

function modifier_thor_gods_strength:GetModifierProcAttack_BonusDamage_Pure (params)
 	if self.bonus_damage == nil then
 		self.bonus_damage = 0
 	end
    return self.bonus_damage
end


function modifier_thor_gods_strength:OnAttackStart (params)
    if IsServer () then
        if params.attacker == self:GetParent () then
            local target = params.target
            self.bonus_damage = (target:GetMaxHealth()*(self:GetAbility():GetSpecialValueFor("damage_percent")/100) + self:GetAbility():GetSpecialValueFor("base_damage"))
            if self:GetCaster():HasTalent("special_bonus_unique_thor") then
                self.bonus_damage = self.bonus_damage + (target:GetMaxHealth()*(self:GetCaster():FindTalentValue("special_bonus_unique_thor")/100))
            end
						if target:GetUnitName() == "npc_dota_warlock_golem_1" or target:GetUnitName() == "npc_mega_greevil" or target:GetUnitName() == "npc_dota_lich_king" then
               self.bonus_damage = 0
            end
            if target:IsBuilding() then
            	self.bonus_damage = 0
            end
        end
    end

    return 0
end
