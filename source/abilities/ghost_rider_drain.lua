if ghost_rider_drain == nil then ghost_rider_drain = class({}) end
LinkLuaModifier("modifier_ghost_rider_drain", "abilities/ghost_rider_drain.lua", LUA_MODIFIER_MOTION_NONE)
function ghost_rider_drain:GetIntrinsicModifierName()
   return "modifier_ghost_rider_drain"
end

if modifier_ghost_rider_drain == nil then modifier_ghost_rider_drain = class({}) end

function modifier_ghost_rider_drain:IsHidden()
   return true
end

function modifier_ghost_rider_drain:IsPurgable()
  return false
end

function modifier_ghost_rider_drain:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_ghost_rider_drain:OnAttackLanded( params )
	if IsServer() then
		if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
  			if self:GetParent():PassivesDisabled() then
  				return 0
  			end

			  local target = params.target
        if target:IsHero() then
      			if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
        				target:SetMana(target:GetMana() - self:GetAbility():GetSpecialValueFor("mana_per_hit"))
                ApplyDamage({attacker = self:GetCaster(), victim = target, damage = self:GetAbility():GetSpecialValueFor("mana_per_hit"), damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
                local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/spectre/spectre_weapon_diffusal/spectre_desolate_diffusal.vpcf", PATTACH_CUSTOMORIGIN, target );
            		ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true );
                ParticleManager:SetParticleControlEnt( nFXIndex, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true );
                ParticleManager:ReleaseParticleIndex( nFXIndex );

            		EmitSoundOn( "Hero_Antimage.ManaBreak", target )
            end
        end
		end
	end

	return 0
end
