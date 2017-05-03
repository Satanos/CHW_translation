if tribunal_justice_void == nil then tribunal_justice_void = class({ }) end

LinkLuaModifier( "modifier_tribunal_justice_void", "abilities/tribunal_justice_void.lua", LUA_MODIFIER_MOTION_NONE )

function tribunal_justice_void:OnSpellStart ()
    local hTarget = self:GetCursorTarget ()
    if hTarget ~= nil then
        if ( not hTarget:TriggerSpellAbsorb (self) ) then
            local info = {
                EffectName = "particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf",
                Ability = self,
                iMoveSpeed = 2500,
                Source = self:GetCaster (),
                Target = self:GetCursorTarget (),
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
            }

            ProjectileManager:CreateTrackingProjectile (info)
            EmitSoundOn ("Hero_ArcWarden.Flux.Cast", self:GetCaster () )
        end
    end
end

function tribunal_justice_void:OnProjectileHit (hTarget, vLocation)
    if IsServer() then
	    local duration = self:GetSpecialValueFor ("duration")
	    hTarget:AddNewModifier (self:GetCaster (), self, "modifier_tribunal_justice_void", { duration = duration } )
	    EmitSoundOn ("DOTA_Item.Bloodthorn.Activate", hTarget)
    	EmitSoundOn ("Hero_ArcWarden.SparkWraith.Damage", hTarget)
	end
    return true
end

if modifier_tribunal_justice_void == nil then modifier_tribunal_justice_void = class({}) end

function modifier_tribunal_justice_void:IsPurgable()
    return false
end

function modifier_tribunal_justice_void:GetStatusEffectName()
    return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_tribunal_justice_void:StatusEffectPriority()
    return 1
end

function modifier_tribunal_justice_void:GetEffectName()
    return "particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf"
end

function modifier_tribunal_justice_void:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tribunal_justice_void:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_tribunal_justice_void:CheckState ()
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_PASSIVES_DISABLED] = true,
        [MODIFIER_STATE_EVADE_DISABLED] = true,
    }

    return state
end

function modifier_tribunal_justice_void:GetModifierIncomingDamage_Percentage (params)
    return 50
end

function modifier_tribunal_justice_void:GetModifierMoveSpeedBonus_Percentage( params )
	return -10000
end

function modifier_tribunal_justice_void:OnDestroy()
	if IsServer() then
      local hTarget = self:GetParent()
      EmitSoundOn ("Hero_ArcWarden.SparkWraith.Activate", hTarget)
      EmitSoundOn ("Hero_ArcWarden.SparkWraith.Damage", hTarget)
      EmitSoundOn ("Hero_ArcWarden.SparkWraith.Activate", self:GetAbility():GetCaster())
      EmitSoundOn ("Hero_ArcWarden.SparkWraith.Damage", self:GetAbility():GetCaster())
      local pop_pfx = ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_OVERHEAD_FOLLOW, hTarget)
      ParticleManager:SetParticleControl(pop_pfx, 0, hTarget:GetAbsOrigin())
      ParticleManager:SetParticleControl(pop_pfx, 1, Vector(100, 0, 0))
      ParticleManager:ReleaseParticleIndex(pop_pfx)
	end
end
