nightbringer_offer_of_life = class({})

function nightbringer_offer_of_life:OnSpellStart()
  local caster = self:GetCaster()
  local target = self:GetCursorTarget()

  ApplyDamage ( { attacker = caster, victim = target, ability = self, damage = self:GetAbilityDamage(), damage_type = DAMAGE_TYPE_PURE})

	local particle = "particles/items3_fx/mango_active.vpcf"
	local fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(fx, 0, target:GetAbsOrigin())

	EmitSoundOn("DOTA_Item.Maim", target)

	caster:GiveMana(self:GetAbilityDamage() / 2 )
	caster:Heal(self:GetAbilityDamage() / 2, self)
end
