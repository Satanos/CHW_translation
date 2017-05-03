LinkLuaModifier ("modifier_outsider_mark", "abilities/outsider_mark.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_outsider_mark_enemy", "abilities/outsider_mark.lua", LUA_MODIFIER_MOTION_NONE)
outsider_mark = class({})

function outsider_mark:IsStealable()
	return false
end

function outsider_mark:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end
	if hTarget:GetUnitName() == "npc_dota_hero_crystal_maiden" or hTarget:GetUnitName() == "npc_dota_hero_rubick" then
		return UF_FAIL_CUSTOM
	end
	local nResult = UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, self:GetCaster():GetTeamNumber() )
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

--------------------------------------------------------------------------------

function outsider_mark:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	if hTarget:GetUnitName() == "npc_dota_hero_crystal_maiden" or hTarget:GetUnitName() == "npc_dota_hero_rubick" then
		return "#dota_hud_error_too_many_skills"
	end

	return ""
end

function outsider_mark:OnSpellStart()
	local info = {
			EffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
			Ability = self,
			iMoveSpeed = 1600,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
		}

	ProjectileManager:CreateTrackingProjectile( info )
	EmitSoundOn( "Hero_Oracle.PurifyingFlames", self:GetCaster() )
end

function outsider_mark:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
		local duration = self:GetSpecialValueFor("duration_tooltip")
		if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			EmitSoundOn( "Hero_Oracle.FalsePromise.Damaged", hTarget )
			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_outsider_mark_enemy", { duration = duration } )
		else
			EmitSoundOn( "Hero_Oracle.FalsePromise.Healed", hTarget )
			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_outsider_mark", { duration = duration } )
		end
	end

	return true
end


modifier_outsider_mark = class({})

function modifier_outsider_mark:IsBuff()
	return true
end

function modifier_outsider_mark:IsPurgable()
	return false
end

function modifier_outsider_mark:OnCreated()
	if IsServer() then
		local caster = self:GetParent()

		caster:AddAbility("outsider_blink"):SetLevel(self:GetAbility():GetLevel())
	end
end

function modifier_outsider_mark:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()
		if caster:HasAbility("outsider_blink") then
			local abil = caster:FindAbilityByName("outsider_blink")
			abil:RemoveSelf()
		end
	end
end

function modifier_outsider_mark:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABILITY_LAYOUT
	}

	return funcs
end

function modifier_outsider_mark:GetModifierAbilityLayout( params )
	return 6
end

modifier_outsider_mark_enemy = class({})

function modifier_outsider_mark_enemy:IsHidden()
	return false
end

function modifier_outsider_mark_enemy:IsPurgable()
	return false
end

function modifier_outsider_mark_enemy:OnCreated()
	if IsServer() then
		local target = self:GetParent()

		self.damage = self:GetAbility():GetSpecialValueFor("damage_enemy")/100
		self:StartIntervalThink(1)
	end
end

function modifier_outsider_mark_enemy:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		local hp = target:GetMaxHealth()
		local damage = hp*self.damage
		if self:GetCaster():HasTalent("special_bonus_unique_outsider") then
	        damage = ((self:GetCaster():FindTalentValue("special_bonus_unique_outsider")/100)*hp) + (hp*self.damage)
		end
		local htable = {attacker = self:GetCaster(), victim = target, ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PURE}
		ApplyDamage(htable)
	end
end
