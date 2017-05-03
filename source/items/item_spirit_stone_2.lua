if item_spirit_stone_2 == nil then item_spirit_stone_2 = class({}) end

LinkLuaModifier( "item_spirit_stone_2_modifier", "items/item_spirit_stone_2.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "item_spirit_stone_2_aura", "items/item_spirit_stone_2.lua", LUA_MODIFIER_MOTION_NONE )

function item_spirit_stone_2:GetBehavior()
	local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
	return behav
end

function item_spirit_stone_2:GetIntrinsicModifierName()
	return "item_spirit_stone_2_modifier"
end

if item_spirit_stone_2_modifier == nil then item_spirit_stone_2_modifier = class({}) end

function item_spirit_stone_2_modifier:IsHidden()
	return true
end

function item_spirit_stone_2_modifier:IsPurgable()
	return false
end

function item_spirit_stone_2_modifier:OnCreated(table)
	if IsServer() then
		if not self:GetParent():HasModifier("item_spirit_stone_aura") and not self:GetParent():HasModifier("item_spirit_stone_2_aura") then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "item_spirit_stone_2_aura", nil)
		end
		self:GetAbility():RemoveSelf()
	end
end

if item_spirit_stone_2_aura == nil then item_spirit_stone_2_aura = class({}) end

function item_spirit_stone_2_aura:IsHidden ()
    return false
end

function item_spirit_stone_2_aura:IsPurgable()
	return false
end

function item_spirit_stone_2_aura:RemoveOnDeath()
	return false
end

function item_spirit_stone_2_aura:OnCreated(table)
	if IsServer() then
		self.abilities_executed = 0
	end
end

function item_spirit_stone_2_aura:DeclareFunctions ()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_HERO_KILLED

    }

    return funcs
end

function item_spirit_stone_2_aura:OnHeroKilled(params)
	if params.target:GetTeam() ~= self:GetParent():GetTeam() then
		self:SetStackCount(self:GetStackCount() + 2)
	end
end

function item_spirit_stone_2_aura:GetModifierConstantManaRegen( params )
	 return self:GetStackCount()*0.5
end

function item_spirit_stone_2_aura:GetModifierConstantHealthRegen( params )
	 return self:GetStackCount()*1
end

function item_spirit_stone_2_aura:OnAbilityExecuted( params )
	 if params.unit:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		 self.abilities_executed = self.abilities_executed + 1
		 if self.abilities_executed >= 4 then
		 	self.abilities_executed = 0
		 	self:SetStackCount(self:GetStackCount() + 1)
		 end
	end
end

function item_spirit_stone_2_aura:OnTakeDamage( params )
	 if params.unit == self:GetParent() then
	 	local unit = params.unit
	 	if not unit:IsAlive() then
	 		self:SetStackCount(math.floor(self:GetStackCount()*0.6))
	 	end
	 end
end

function item_spirit_stone_2_aura:GetAttributes ()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_spirit_stone_2_aura:GetTexture()
    return "item_spirit_stone_2"
end

