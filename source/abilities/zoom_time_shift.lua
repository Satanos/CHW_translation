zoom_time_shift = class({})

LinkLuaModifier( "modifier_proffesor_zoom_time_shift", "abilities/zoom_time_shift.lua", LUA_MODIFIER_MOTION_NONE )

function zoom_time_shift:OnSpellStart()
	local radius = self:GetSpecialValueFor( "radius_scepter" )
	local duration = self:GetSpecialValueFor(  "duration" )
  if self:GetCaster():HasScepter() then
    duration = self:GetSpecialValueFor(  "duration_scepter" )
    local allies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
  	if #allies > 0 then
  		for _,ally in pairs(allies) do
  			ally:AddNewModifier( self:GetCaster(), self, "modifier_proffesor_zoom_time_shift", { duration = duration } )
  		end
  	end
  else
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_proffesor_zoom_time_shift", { duration = duration } )
  end

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_head", self:GetCaster():GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOn( "Hero_Sven.WarCry", self:GetCaster() )
  EmitSoundOn( "Hero_Sven.GodsStrength", self:GetCaster() )

	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_4 );
end

if modifier_proffesor_zoom_time_shift == nil then modifier_proffesor_zoom_time_shift = class({}) end

function modifier_proffesor_zoom_time_shift:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_EVASION_CONSTANT,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    MODIFIER_PROPERTY_MOVESPEED_MAX
}
	return funcs
end

function modifier_proffesor_zoom_time_shift:GetModifierPreAttack_BonusDamage()
	  return self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_proffesor_zoom_time_shift:GetModifierEvasion_Constant( params )
    return self:GetAbility():GetSpecialValueFor( "evasion" )
end

function modifier_proffesor_zoom_time_shift:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetAbility():GetSpecialValueFor( "attack_speed" )
end

function modifier_proffesor_zoom_time_shift:GetModifierMoveSpeed_Absolute()
	  return 5000
end

function modifier_proffesor_zoom_time_shift:GetModifierMoveSpeed_Limit( params )
	  return 5000
end

function modifier_proffesor_zoom_time_shift:GetModifierMoveSpeed_Max( params )
	  return 5000
end
