//*:**************************************************************************
//*:*  GR_S0_BLADEBROS.NSS
//*:**************************************************************************
//*:* Blade Brothers
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 23, 2008
//*:* Player's Handbook II (p. 103)
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
#include "GR_IN_SPELLS"
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
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_TURNS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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
    effect eVis     = EffectBeam(VFX_BEAM_ODD, oCaster, BODY_NODE_CHEST);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eAOE     = EffectAreaOfEffect(AOE_MOB_BLADE_BROTHERS);

    effect eLink    = EffectLinkEffects(eDur, eAOE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_BLADE_BROTHERS, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELL_GR_BLADE_BROTHERS, GetLocalObject(spInfo.oTarget, "GR_BLADEBROTHERS_OBJ"));
        GRRemoveSpellEffects(SPELL_GR_BLADE_BROTHERS, spInfo.oTarget);
    }
    if(GetHasSpellEffect(SPELL_GR_BLADE_BROTHERS, oCaster)) {
        GRRemoveSpellEffects(SPELL_GR_BLADE_BROTHERS, GetLocalObject(oCaster, "GR_BLADEBROTHERS_OBJ"));
        GRRemoveSpellEffects(SPELL_GR_BLADE_BROTHERS, oCaster);
    }

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_BLADE_BROTHERS, FALSE));
    SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_BLADE_BROTHERS, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, 1.7f);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);

    object oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_BLADE_BROTHERS, oCaster);
    GRSetAOESpellId(spInfo.iSpellID, oAOE);
    GRSetSpellInfo(spInfo, oAOE);
    SetLocalObject(spInfo.oTarget, "GR_BLADEBROTHERS_OBJ", oCaster);

    oAOE = GRGetAOEOnObject(oCaster, AOE_TYPE_BLADE_BROTHERS, oCaster);
    GRSetAOESpellId(spInfo.iSpellID, oAOE);
    GRSetSpellInfo(spInfo, oAOE);
    SetLocalObject(oCaster, "GR_BLADEBROTHERS_OBJ", spInfo.oTarget);


    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
