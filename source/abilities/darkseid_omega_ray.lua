darkseid_omega_ray = class({})
function darkseid_omega_ray:GetCooldown (nLevel)
    if self:GetCaster ():HasScepter () then
        return self:GetSpecialValueFor ("cooldown_scepter")
    end

    return self.BaseClass.GetCooldown (self, nLevel)
end

function darkseid_omega_ray:OnSpellStart ()
    local info = {
        EffectName = "particles/items_fx/desolator_projectile.vpcf",
        Ability = self,
        iMoveSpeed = 1400,
        Source = self:GetCaster (),
        Target = self:GetCursorTarget (),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
        bDrawsOnMinimap = true,              
        bDodgeable = false,
    }
    local hTarget = self:GetCursorTarget ()
    ProjectileManager:CreateTrackingProjectile (info)
    local hCaster = self:GetCaster()

    EmitSoundOn ("Hero_Omniknight.Purification.Wingfall", hCaster)
    EmitSoundOn ("Hero_Omniknight.Purification.Wingfall.Layer", hTarget)
end

--------------------------------------------------------------------------------

function darkseid_omega_ray:OnProjectileHit (hTarget, vLocation)
    if hTarget ~= nil and ( not hTarget:IsInvulnerable () ) and ( not hTarget:TriggerSpellAbsorb (self) ) then
        EmitSoundOn ("Hero_VengefulSpirit.MagicMissileImpact", hTarget)
        local stun = self:GetSpecialValueFor ("stun")
        local damage = self:GetSpecialValueFor ("damage")
        if self:GetCaster():HasScepter() then
            damage = (hTarget:GetMaxHealth () * (self:GetSpecialValueFor ("damage_scepter")/100) + self:GetSpecialValueFor ("damage"))
        end
        local damage_table = {
            victim = hTarget,
            attacker = self:GetCaster (),
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }

        ApplyDamage (damage_table)
        hTarget:AddNewModifier (self:GetCaster (), self, "modifier_stunned", { duration = stun} )
    end

    return true
end


--------------------------------------------------------------------------------
