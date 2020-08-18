//*:**************************************************************************
//*:*  GR_S0_SEEING.NSS
//*:**************************************************************************
//*:* See Invisibility (NW_S0_SeeInvis.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 7, 2002
//*:* 3.5 Player's Handbook (p. 275)
//*:*
//*:* True Seeing (NW_S0_TrueSee.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk Created On: Jan 7, 2002
//*:* 3.5 Player's Handbook (p. 296)
//*:**************************************************************************
//*:* Devil's Sight
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 23, 2008
//*:* Complete Arcane (p. 133)
//*:**************************************************************************
//*:* Updated On: May 1, 2008
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
    int     iDurAmount        = (spInfo.iSpellID==SPELL_SEE_INVISIBILITY ? spInfo.iCasterLevel*10 : spInfo.iCasterLevel);
    int     iDurType          = DUR_TYPE_TURNS;

    if(spInfo.iSpellID==SPELL_I_DEVILS_SIGHT) {
        iDurAmount = 24;
        iDurType = DUR_TYPE_HOURS;
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
    effect eVis         = EffectVisualEffect(VFX_DUR_MAGICAL_SIGHT);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eSeeInvis    = EffectSeeInvisible();
    effect eUltraVis    = EffectUltravision();
    //*** NWN2 SINGLE ***/ effect eDarkVis = EffectDarkVision();
    effect eTrueSee     = EffectLinkEffects(eSeeInvis, eUltraVis);
    effect eLink;

    switch(spInfo.iSpellID) {
        case SPELL_SEE_INVISIBILITY:
            //*** NWN2 SINGLE ***/ eVis = EffectVisualEffect(VFX_DUR_SPELL_SEE_INVISIBILITY);
            eLink = EffectLinkEffects(eVis, eSeeInvis);
            /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);
            //*** NWN2 SINGLE ***/ RemovePermanencySpells(spInfo.oTarget);
            break;
        case SPELL_TRUE_SEEING:
            //*** NWN2 SINGLE ***/ eVis = EffectVisualEffect(VFX_DUR_SPELL_TRUE_SEEING);
            eLink = EffectLinkEffects(eVis, eTrueSee);
            eLink = EffectLinkEffects(eLink, eDur);
            break;
        case SPELL_I_DEVILS_SIGHT:
            eLink = EffectLinkEffects(eVis, eUltraVis);
            //*** NWN2 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDarkVis);
            break;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget);
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
