//*:**************************************************************************
//*:*  GR_S0_RESIS.NSS
//*:**************************************************************************
//*:* Resistance (NW_S0_Resis) Copyright (c) 2000 Bioware Corp.
//*:* Created By: Aidan Scanlan  Created On: 01/12/01
//*:* 3.5 Player's Handbook (p. 272)
//*:**************************************************************************
//*:* Resistance, Greater
//*:* Resistance, Superior
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 7, 2007
//*:* Spell Compendium (p. 174)
//*:**************************************************************************
//*:* Updated On: November 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
#include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
int GRPreventStacking(int iSpellID, object oTarget) {
    int bHasGreaterEffect = FALSE;

    switch(iSpellID) {
        case SPELL_RESISTANCE:
            bHasGreaterEffect = GetHasSpellEffect(SPELL_GREATER_RESISTANCE) || GetHasSpellEffect(SPELL_SUPERIOR_RESISTANCE);
            break;
        case SPELL_GREATER_RESISTANCE:
            bHasGreaterEffect = GetHasSpellEffect(SPELL_SUPERIOR_RESISTANCE);
            if(!bHasGreaterEffect) GRRemoveSpellEffects(SPELL_RESISTANCE, oTarget);
            break;
        case SPELL_SUPERIOR_RESISTANCE:
            GRRemoveMultipleSpellEffects(SPELL_RESISTANCE, SPELL_GREATER_RESISTANCE, oTarget);
            break;
    }

    return bHasGreaterEffect;
}

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
    int     iBonus            = 1;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 1;
    int     iDurType          = DUR_TYPE_DAYS;

    /*** NWN1 SPECIFIC***/
        int     iVisual         = VFX_IMP_HEAD_HOLY;
        int     iDurVis         = VFX_DUR_CESSATE_POSITIVE;
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ int     iDurVis         = VFX_DUR_SPELL_RESISTANCE;

    switch(spInfo.iSpellID) {
        case SPELL_RESISTANCE:
            iDurAmount = 1;
            iDurType = DUR_TYPE_TURNS;
            break;
        case SPELL_GREATER_RESISTANCE:
            iBonus = 3;
            /*** NWN1 SINGLE ***/ iVisual = VFX_DUR_PROTECTION_GOOD_MINOR;
            //*** NWN2 SINGLE ***/ iDurVis = VFX_DUR_SPELL_GREATER_RESISTANCE;
            break;
        case SPELL_SUPERIOR_RESISTANCE:
            iBonus = 6;
            /*** NWN1 SINGLE ***/ iVisual = VFX_DUR_PROTECTION_GOOD_MAJOR;
            //*** NWN2 SINGLE ***/ iDurVis = VFX_DUR_SPELL_SUPERIOR_RESISTANCE;
            break;
    }

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
    //*:* float   fRange          = FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration     = ApplyMetamagicDurationMods(fDuration);
        iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
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
    effect eSave    = EffectSavingThrowIncrease(SAVING_THROW_ALL, iBonus);
    /*** NWN1 SINGLE ***/ effect eVis     = EffectVisualEffect(iVisual);
    effect eDur     = EffectVisualEffect(iDurVis);
    effect eLink    = EffectLinkEffects(eSave, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*** NWN2 SINGLE ***/ RemovePermanencySpells(spInfo.oTarget);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    if(!GRPreventStacking(spInfo.iSpellID, spInfo.oTarget)) {
        GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
        /*** NWN1 SPECIFIC ***/
        if(iVisual==VFX_IMP_HEAD_HOLY) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
        } else {
            GRApplyEffectToObject(iDurationType, eVis, spInfo.oTarget, 2.0f);
        }
        /*** END NWN1 SPECIFIC ***/
    } else {
        FloatingTextStrRefOnCreature(16939246, spInfo.oTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
