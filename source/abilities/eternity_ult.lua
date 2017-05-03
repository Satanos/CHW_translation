eternity_ult = class({})
LinkLuaModifier( "modifier_eternity_ult", "abilities/eternity_ult.lua",LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function eternity_ult:OnSpellStart()
	local duration = self:GetSpecialValueFor(  "tooltip_duration" )
  if self:GetCaster():HasScepter() then
      duration = self:GetSpecialValueFor(  "duration_scepter" )
  end

	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), 999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	if #units > 0 then
		for _,target in pairs(units) do
			target:AddNewModifier( self:GetCaster(), self, "modifier_eternity_ult", { duration = duration } )
      EmitSoundOn( "Hero_Oracle.FalsePromise.Cast", self:GetCaster() )
		end
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_head", self:GetCaster():GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOn( "Hero_Silencer.GlobalSilence.Cast", self:GetCaster() )
  --	EmitSoundOn( "Hero_Oracle.FalsePromise.Cast", self:GetCaster() )

	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_3 );
end

if modifier_eternity_ult == nil then modifier_eternity_ult = class({}) end

function modifier_eternity_ult:IsDebuff()
	return true
end

function modifier_eternity_ult:IsPurgable()
	return false
end

function modifier_eternity_ult:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_false_promise.vpcf"
end

function modifier_eternity_ult:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_eternity_ult:OnDestroy()
	if IsServer() then
      ApplyDamage({attacker = self:GetCaster(), victim = self:GetParent(), damage = self:GetAbility():GetSpecialValueFor("damage"), ability = self:GetAbility(), damage_type = DAMAGE_TYPE_MAGICAL})
  end
end

function modifier_eternity_ult:CheckState()
  if self:GetCaster():HasScepter() then
    return {
  	[MODIFIER_STATE_SILENCED] = true,
    [MODIFIER_STATE_MUTED] = true,
    [MODIFIER_STATE_DISARMED] = true
  	}
  end
	return {
	[MODIFIER_STATE_SILENCED] = true,
	}
end
