LinkLuaModifier ("modifier_collector_ult", "abilities/collector_ult.lua", LUA_MODIFIER_MOTION_NONE)
collector_ult = class ( {})

function collector_ult:GetCooldown (nLevel)
    return self.BaseClass.GetCooldown (self, nLevel)
end

function collector_ult:OnSpellStart ()
    local caster = self:GetCaster ()
    local duration = self:GetSpecialValueFor ("duration")
    caster:AddNewModifier (caster, self, "modifier_collector_ult", { duration = duration })
    EmitSoundOn ("Hero_Nevermore.ROS.Arcana", caster)
end

modifier_collector_ult = class ( {})

function modifier_collector_ult:OnCreated( kv )
    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_head", self:GetCaster():GetOrigin(), true )
        self:AddParticle( nFXIndex, false, false, -1, false, true )
    end
end


function modifier_collector_ult:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_collector_ult:OnAttackLanded( params )
    if params.attacker == self:GetParent() then
        if params.target:IsBuilding() then
          return nil
        end
        ApplyDamage({attacker = self:GetParent(), victim = params.target, damage = self:GetParent():GetIntellect()*5, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_MAGICAL})
        EmitSoundOn("DOTA_Item.EtherealBlade.Target", params.target)
    end
end
