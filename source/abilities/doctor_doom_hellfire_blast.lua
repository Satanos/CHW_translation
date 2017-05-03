doctor_doom_hellfire_blast = class ( {})


function doctor_doom_hellfire_blast:OnSpellStart ()
    local info = {
        EffectName = "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf",
        Ability = self,
        iMoveSpeed = 1000,
        Source = self:GetCaster (),
        Target = self:GetCursorTarget (),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }

    ProjectileManager:CreateTrackingProjectile (info)
    EmitSoundOn ("Hero_SkeletonKing.Hellfire_Blast", self:GetCaster () )
end

--------------------------------------------------------------------------------

function doctor_doom_hellfire_blast:OnProjectileHit (hTarget, vLocation)
    if hTarget ~= nil and ( not hTarget:IsInvulnerable () ) and ( not hTarget:TriggerSpellAbsorb (self) ) and ( not hTarget:IsMagicImmune () ) then
        local nFXIndex = ParticleManager:CreateParticleForTeam ("particles/frostivus_gameplay/frostivus_skeletonking_hellfireblast_explosion.vpcf", PATTACH_WORLDORIGIN, self:GetCaster (), self:GetCaster ():GetTeamNumber () )
        ParticleManager:SetParticleControl (nFXIndex, 0, hTarget:GetOrigin () )
        ParticleManager:SetParticleControl (nFXIndex, 1, hTarget:GetOrigin () )
        ParticleManager:SetParticleControl (nFXIndex, 3, hTarget:GetOrigin () )
        ParticleManager:ReleaseParticleIndex (nFXIndex)
        EmitSoundOn ("Hero_SkeletonKing.Hellfire_BlastImpact", hTarget)
        local disarm_duration = self:GetSpecialValueFor ("disarm_duration")
        local damage = self:GetSpecialValueFor ("damage")

        local damage = {
            victim = hTarget,
            attacker = self:GetCaster (),
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }

        ApplyDamage (damage)
        hTarget:AddNewModifier (self:GetCaster (), self, "modifier_disarmed", { duration = disarm_duration } )
        hTarget:AddNewModifier (self:GetCaster (), self, "modifier_stunned", { duration = self:GetSpecialValueFor("stun") } )
    end

    return true
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
