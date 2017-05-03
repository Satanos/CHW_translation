night_king_flesh_hunger = class({})

function night_king_flesh_hunger:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function night_king_flesh_hunger:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster:GetAbsOrigin()
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local heal = self:GetSpecialValueFor("heal")
	local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_decay.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect, 0, target)
	ParticleManager:SetParticleControl(effect, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(effect, 2, target)
	EmitSoundOn("Hero_Undying.Decay.Target", caster)
	local nearby_allied_units = FindUnitsInRadius(caster:GetTeam(), target, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i, nearby_ally in ipairs(nearby_allied_units) do  --Restore health and play a particle effect for every found ally.
		EmitSoundOn("Hero_Undying.SoulRip.Ally", nearby_ally)
		nearby_ally:Heal(heal, caster)
	end

	local nearby_enemy_units = FindUnitsInRadius(caster:GetTeam(), target, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i, nearby_enemy in ipairs(nearby_enemy_units) do  --Restore health and play a particle effect for every found ally.
		EmitSoundOn("Hero_Undying.SoulRip.Enemy", nearby_ally)
		if self:GetCaster():HasTalent("special_bonus_unique_night_king") then
	        damage = self:GetCaster():FindTalentValue("special_bonus_unique_night_king") + damage
		end
		local table = {attacker = caster, victim = nearby_enemy, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL}
		ApplyDamage(table)
	end
end
