LinkLuaModifier ("hellspont_extermination_thinker", "abilities/hellspont_extermination.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
hellspont_extermination = class ( {})

function hellspont_extermination:GetAOERadius()
    return 450
end

function hellspont_extermination:GetBehavior ()
    return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT
end

function hellspont_extermination:OnSpellStart ()
    local caster = self:GetCaster ()
    local point = self:GetCursorPosition ()
    local team_id = caster:GetTeamNumber ()
    local thinker = CreateModifierThinker (caster, self, "hellspont_extermination_thinker", { duration = 1.7 }, point, team_id, false)
end

hellspont_extermination_thinker = class({})

function hellspont_extermination_thinker:OnCreated(event)
    if IsServer() then
        local thinker = self:GetParent()
        local ability = self:GetAbility()
        self.target = self:GetAbility():GetCaster():GetCursorPosition()
        self.radius = ability:GetSpecialValueFor("radius")
        local nFXIndex = ParticleManager:CreateParticleForTeam( "particles/hellspont/hellspont_extermination_load.vpcf", PATTACH_CUSTOMORIGIN, thinker, thinker:GetTeamNumber())
        ParticleManager:SetParticleControl( nFXIndex, 0, self.target)
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(450, 0, 0))
        ParticleManager:SetParticleControl( nFXIndex, 3, self.target)
        self:AddParticle( nFXIndex, false, false, -1, false, true )
        EmitSoundOn("Hero_Invoker.SunStrike.Charge", thinker)
        AddFOWViewer( thinker:GetTeam(), self.target, 500, 3, false)
    end
end

function hellspont_extermination_thinker:OnDestroy(event)
    if IsServer() then
        local thinker = self:GetParent()
        local ability = self:GetAbility()

        local nFXIndex1 = ParticleManager:CreateParticle( "particles/econ/items/invoker/invoker_apex/invoker_sun_strike_immortal1.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( nFXIndex1, 0, thinker:GetAbsOrigin())
        ParticleManager:SetParticleControl( nFXIndex1, 1, Vector(500, 500, 0))
        ParticleManager:SetParticleControl( nFXIndex1, 2, thinker:GetAbsOrigin())
        ParticleManager:SetParticleControl( nFXIndex1, 3, thinker:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex( nFXIndex1 );

        self.damage = ability:GetSpecialValueFor("damage")
        self.damage_percent = ability:GetSpecialValueFor("damage_percent")/100
        self.radius = ability:GetSpecialValueFor("radius")
        EmitSoundOn("Hero_Invoker.SunStrike.Ignite", thinker)
        GridNav:DestroyTreesAroundPoint(thinker:GetAbsOrigin(), 500, false)
        local thinker =  self:GetParent()
        local nearby_targets = FindUnitsInRadius(thinker:GetTeam(), thinker:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

        for i, target in ipairs(nearby_targets) do
            local health = target:GetHealth()
            local damage =  (target:GetMaxHealth()*self.damage_percent) + self.damage

            ApplyDamage({victim = target, attacker = self:GetAbility():GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
            target:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_stunned", {duration = 3})
        end
    end
end
