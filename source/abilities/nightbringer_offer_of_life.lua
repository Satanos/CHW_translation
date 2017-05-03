nightbringer_offer_of_life = class({})

function nightbringer_offer_of_life:OnSpellStart()
  local caster = self:GetCaster()
  local mana_per_second = self:GetSpecialValueFor("mana_per_second")
  local heal_per_second = self:GetSpecialValueFor("heal_per_second")
	if caster:GetHealth() < 25 then self:ToggleAbility() caster:ForceKill(false) return nil end
	local particle_lifesteal = "particles/items3_fx/octarine_core_lifesteal.vpcf"

	local lifesteal_fx = ParticleManager:CreateParticle(particle_lifesteal, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(lifesteal_fx, 0, caster:GetAbsOrigin())

	local particle = "particles/items3_fx/mango_active.vpcf"
	local fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())

	EmitSoundOn("DOTA_Item.Maim", caster)

	caster:GiveMana(mana_per_second)
	caster:SetHealth(caster:GetHealth() - (heal_per_second))
end
