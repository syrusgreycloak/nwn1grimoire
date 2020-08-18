//*:**************************************************************************
//*:*  GR_S0_PRSPELLS.NSS
//*:**************************************************************************
//*:* Protection  from Spells (NW_S0_PrChaos.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: June 27, 2001
//*:* 3.5 Player's Handbook (p. 266)
//*:**************************************************************************
//*:* Updated On: November 6, 2007
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
    int     iDurAmount        = spInfo.iCasterLevel*10;
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
    float   fRange          = FeetToMeters(15.0);
    float   fDelay;
    int     iNumTargets     = MaxInt(1, spInfo.iCasterLevel/4);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    /*** NWN1 SPECIFIC ***/
        effect eVis     = EffectVisualEffect(VFX_IMP_MAGIC_PROTECTION);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
        effect eDur2    = EffectVisualEffect(VFX_DUR_MAGIC_RESISTANCE);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eDur = EffectVisualEffect(VFX_DUR_SPELL_PROTECTION_FROM_SPELLS);
    effect eSave    = EffectSavingThrowIncrease(SAVING_THROW_ALL, 8, SAVING_THROW_TYPE_SPELL);
    effect eLink    = EffectLinkEffects(eSave, eDur);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur2);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);

    while(GetIsObjectValid(spInfo.oTarget) && iNumTargets>0) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, FALSE)) {
            fDelay = GetRandomDelay();
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_PROTECTION_FROM_SPELLS, FALSE));
            /*** NWN1 SINGLE ***/ DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration));
            iNumTargets--;
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
    }
    /*** NWN1 SINGLE ***/ DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster));
    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration));

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
