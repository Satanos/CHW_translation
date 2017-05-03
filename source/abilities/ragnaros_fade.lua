ragnaros_fade = class({})

local killed_heroes = 0

LinkLuaModifier( "modifier_ragnaros_fade",       "abilities/ragnaros_fade.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ragnaros_fade_bonus", "abilities/ragnaros_fade.lua", LUA_MODIFIER_MOTION_NONE )

function ragnaros_fade:GetIntrinsicModifierName()
    return "modifier_ragnaros_fade_bonus"
end

function ragnaros_fade:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	local nResult = UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, self:GetCaster():GetTeamNumber() )
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

function ragnaros_fade:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end
	return ""
end

function ragnaros_fade:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

    local damage = self:GetSpecialValueFor( "damage_pct" )/100
    local mana = self:GetSpecialValueFor( "mana_drain" )
    local duration = self:GetSpecialValueFor( "illusion_duration" )

	if hCaster == nil or hTarget == nil then
		return
	end

	local nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster )
	ParticleManager:SetParticleControlEnt( nCasterFX, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nCasterFX )

	local nTargetFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControlEnt( nTargetFX, 1, hCaster, PATTACH_ABSORIGIN_FOLLOW, nil, hCaster:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nTargetFX )

	EmitSoundOn( "Hero_Terrorblade.Sunder.Cast", hCaster )
	EmitSoundOn( "Hero_Terrorblade.Sunder.Target", hTarget )

    local health = hTarget:GetMaxHealth()*damage
    local mana = hTarget:GetMana()*mana

    if hTarget:GetHealth() > health then
        local nFXIndex = ParticleManager:CreateParticle( "particles/ragnaros/ragnaros_sunder.vpcf", PATTACH_CUSTOMORIGIN, nil );
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true );
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetOrigin(), true );
        ParticleManager:SetParticleControl( nFXIndex, 3, hTarget:GetOrigin());
        ParticleManager:SetParticleControl( nFXIndex, 4, hTarget:GetOrigin());
        ParticleManager:ReleaseParticleIndex( nFXIndex );
        ApplyDamage ( { attacker = hCaster, victim = hTarget, ability = self, damage = health, damage_type = DAMAGE_TYPE_MAGICAL})
        hCaster:SetMana(hCaster:GetMana() + mana)
        hTarget:Heal( health, hCaster )
        local player_id = hCaster:GetPlayerID()
	    local caster_team = hCaster:GetTeam()
        local illusion = CreateUnitByName(hTarget:GetUnitName(), hTarget:GetAbsOrigin(  ), true, hCaster, nil, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.
        illusion:SetPlayerID(player_id)
        illusion:SetControllableByPlayer(player_id, true)
        illusion:AddNewModifier(hCaster, self, "modifier_illusion", {duration = duration, outgoing_damage = 100, incoming_damage = 400})

    	illusion:MakeIllusion()
    else
        local nFXIndex = ParticleManager:CreateParticle( "particles/ragnaros/ragnaros_sunder_kill.vpcf", PATTACH_CUSTOMORIGIN, nil );
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetOrigin(), true );
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true );
        ParticleManager:ReleaseParticleIndex( nFXIndex );

        hTarget:Kill( self, hCaster )
        killed_heroes = killed_heroes + 1
        hCaster:CalculateStatBonus(  )
        -- Recalculate all stats after the hero gains stats.
    end
end

modifier_ragnaros_fade_bonus = class({})

function modifier_ragnaros_fade_bonus:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
}
	return funcs
end

function modifier_ragnaros_fade_bonus:IsHidden()
	return true
end

function modifier_ragnaros_fade_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_ragnaros_fade_bonus:GetModifierBonusStats_Strength( params )
    return killed_heroes
end

function modifier_ragnaros_fade_bonus:GetModifierBonusStats_Intellect( params )
    return killed_heroes
end
function modifier_ragnaros_fade_bonus:GetModifierBonusStats_Agility( params )
    return killed_heroes
end
