//*:**************************************************************************
//*:*  GR_S0_STMAVATAR.NSS
//*:**************************************************************************
//*:* Storm Avatar   Copyright (c) 2006 Obsidian Entertainment
//*:* Created By: Patrick Mills  Created On: Oct 11, 2006
//*:* created by Obsidian Entertainment
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS" - included in GR_IN_HASTE
#include "GR_IN_HASTE"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    //*:* int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    //*:* int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    //*:* spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    object  oMyWeapon       = IPGetTargetedOrEquippedMeleeWeapon();
    int     iDamageType     = IP_CONST_DAMAGETYPE_ELECTRICAL;
    int     iIPDamage       = IP_CONST_DAMAGEBONUS_2d10;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    //*:* iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect  eDur1       = EffectVisualEffect(VFX_DUR_PROT_SHADOW_ARMOR);
    effect  eDur2       = EffectVisualEffect(VFX_DUR_PROT_PREMONITION);
    effect  eDur        = EffectLinkEffects(eDur1, eDur2);
    effect  eSpeed      = EffectMovementSpeedIncrease(99);
    effect  eImmuneKO   = EffectImmunity(IMMUNITY_TYPE_KNOCKDOWN);
    effect  eImmuneMi   = EffectConcealment(100, MISS_CHANCE_TYPE_VS_RANGED);

    effect  eLink       = EffectLinkEffects(eDur, eImmuneMi);
    eLink = EffectLinkEffects(eLink, eImmuneKO);
    if(!GRPreventHasteStacking(spInfo.iSpellID, oCaster)) eLink = EffectLinkEffects(eLink, eSpeed);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(SPELL_STORM_AVATAR, oCaster);
    SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_STORM_AVATAR));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);
    if(GetIsObjectValid(oMyWeapon)) {
        itemproperty ipDmgBonus = ItemPropertyDamageBonus(iDamageType, iIPDamage);
        GRIPSafeAddItemProperty(oMyWeapon, ipDmgBonus, fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE, FALSE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
