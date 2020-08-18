//*:**************************************************************************
//*:*  GR_S0_MINDBLK.NSS
//*:**************************************************************************
//*:*
//*:* Mind Blank (NW_S0_MindBlk.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 253)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 7, 2002
//*:**************************************************************************
//*:* Updated On: November 2, 2007
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
    int     iDurAmount        = 1;
    int     iDurType          = DUR_TYPE_DAYS;

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
    float   fDelay          = 0.0;
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
    effect eImm1    = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    /*** NWN1 SPECIFIC ***/
        effect eVis     = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eVis     = EffectVisualEffect(VFX_DUR_SPELL_MIND_BLANK);

    effect eLink = EffectLinkEffects(eImm1, eVis);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);

    effect  eSearch;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));

    eSearch  = GetFirstEffect(spInfo.oTarget);
    while(GetIsEffectValid(eSearch)) {
        int bValid = FALSE;
        //*:**********************************************
        //*:* Check to see if the effect matches a particular
        //*:* type defined below
        //*:**********************************************
        switch(GetEffectType(eSearch)) {
            case EFFECT_TYPE_DAZED:
            case EFFECT_TYPE_CHARMED:
            case EFFECT_TYPE_SLEEP:
            case EFFECT_TYPE_CONFUSED:
            case EFFECT_TYPE_STUNNED:
            case EFFECT_TYPE_DOMINATED:
                bValid = TRUE;
        }
        //*:**********************************************
        //*:* Additional March 2003
        //*:* Remove any feeblemind originating effects
        //*:**********************************************
        switch(GetEffectSpellId(eSearch)) {
            case SPELL_FEEBLEMIND:
            case SPELL_BANE:
                bValid = TRUE;
        }
        //*:**********************************************
        //*:* Remove effect if the effect is a match
        //*:**********************************************
        if(bValid == TRUE) {
            GRRemoveEffect(eSearch, spInfo.oTarget);
        }
        eSearch = GetNextEffect(spInfo.oTarget);
    }

    //*:**********************************************
    //*:* After effects are removed we apply the immunity
    //*:* to mind spells to the target
    //*:**********************************************
    DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration));

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
