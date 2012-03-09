//*:**************************************************************************
//*:*  GR_S0_BARKSKIN.NSS
//*:**************************************************************************
//*:* Barkskin (NW_S0_BarkSkin.nss) Copyright (c) 2000 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Feb 21, 2001
//*:* 3.5 Player's Handbook (p. 203)
//*:**************************************************************************
//*:* Tortoise Shell
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: January 5, 2009
//*:* Spell Compendium (p. 221)
//*:**************************************************************************
//*:* Updated On: January 5, 2009
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
    int     iBonus            = (spInfo.iSpellID==SPELL_BARKSKIN ? 2 : MinInt(9, 6 + (spInfo.iCasterLevel-11)/3));
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
    //*:* float   fRange          = FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iExtraBonus     = MinInt(3, (spInfo.iCasterLevel>=6 ? spInfo.iCasterLevel/3-1 : 0));

    if(spInfo.iSpellID==SPELL_BARKSKIN) iBonus += iExtraBonus;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration       = ApplyMetamagicDurationMods(fDuration);
        iDurationType   = ApplyMetamagicDurationTypeMods(iDurationType);
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
    effect eVis;
    effect eLink;
    /*** NWN1 SPECIFIC ***/
        eVis = EffectVisualEffect(VFX_DUR_PROT_BARKSKIN);
        effect eHead    = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ eVis = EffectVisualEffect(VFX_DUR_SPELL_BARKSKIN);
    effect eAC      = EffectACIncrease(iBonus, AC_NATURAL_BONUS);
    effect eSlow    = EffectMovementSpeedDecrease(33);

    eLink = (spInfo.iSpellID==SPELL_BARKSKIN ? EffectLinkEffects(eVis, eAC) : EffectLinkEffects(eSlow, eAC));
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetIsLiving(spInfo.oTarget)) {
        GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget);

        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
        GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
        /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHead, spInfo.oTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
