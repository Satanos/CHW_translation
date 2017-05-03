LinkLuaModifier( "modifier_iron_rearm", "abilities/iron_rearm.lua",LUA_MODIFIER_MOTION_NONE )

iron_rearm = class({})


--------------------------------------------------------------------------------

function iron_rearm:GetConceptRecipientType()
    return DOTA_SPEECH_USER_ALL
end

--------------------------------------------------------------------------------

function iron_rearm:SpeakTrigger()
    return DOTA_ABILITY_SPEAK_CAST
end
function iron_rearm:IsStealable()
    return false
end
--------------------------------------------------------------------------------

function iron_rearm:GetChannelTime()
    local cooldown_channel = self:GetSpecialValueFor( "channel_tooltip" )
    return cooldown_channel
end

--------------------------------------------------------------------------------
function iron_rearm:GetManaCost(iLevel)
    return self.BaseClass.GetManaCost( self, iLevel )
end

function iron_rearm:GetCooldown( nLevel )
    return self.BaseClass.GetCooldown( self, nLevel )
end

--------------------------------------------------------------------------------

function iron_rearm:OnSpellStart()
    local caster = self:GetCaster()
    local nFXIndex = ParticleManager:CreateParticle( "particles/refresh_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
    ParticleManager:SetParticleControl( nFXIndex, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( nFXIndex, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( nFXIndex, 2, Vector(1, 1, 1))
    caster:EmitSound("DOTA_Item.SoulRing.Activate")
    self.cooldown_channel = self:GetSpecialValueFor( "channel_tooltip" )
end


function iron_rearm:OnChannelFinish( bInterrupted )
    if not bInterrupted then 
        local caster = self:GetCaster()
        caster:EmitSound("DOTA_Item.SoulRing.Activate")
        -- Reset cooldown for abilities that is not rearm
        for i = 0, caster:GetAbilityCount() - 1 do
            local ability = caster:GetAbilityByIndex( i )
            if ability and ability ~= self then
                ability:EndCooldown()
            end
        end
    end
end

--------------------------------------------------------------------------------
modifier_iron_rearm = class ({})

--------------------------------------------------------------------------------

function modifier_iron_rearm:IsBuff()
    return true
end

--------------------------------------------------------------------------------

function modifier_iron_rearm:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_iron_rearm:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_iron_rearm:OnCreated()
    if IsServer() then
        EmitSoundOn( "DOTA_Item.SoulRing.Activate", self:GetParent() )
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_stone_gaze_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "follow_origin", self:GetParent():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "follow_origin", self:GetParent():GetOrigin(), true )
        self:AddParticle( nFXIndex, false, false, -1, false, true )
    end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
