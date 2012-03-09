//*:**************************************************************************
//*:*  GR_S0_HANDDIV.NSS
//*:**************************************************************************
//*:* Hand of Divinity (sg_s0_handdiv.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 3, 2004
//*:* Spell Compendium (p. 109)
//*:**************************************************************************
//*:* Updated On: February 28, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_DEITIES"
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

    if(GetAlignmentGoodEvil(oCaster)==ALIGNMENT_EVIL) {
        spInfo.iSpellType1 = SPELL_TYPE_EVIL;
    } else {
        spInfo.iSpellType1 = SPELL_TYPE_GOOD;
    }

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

    int     iPatron         = GetLocalInt(oCaster, "MY_DEITY");
    int     iTargetPatron   = GetLocalInt(spInfo.oTarget, "MY_DEITY");

    if(!GetLocalInt(oCaster,"MY_DEITY")) {
        GRSetPCDeity(oCaster);
        iPatron = GetLocalInt(oCaster, "MY_DEITY");
    }
    if(!GetLocalInt(spInfo.oTarget,"MY_DEITY")) {
        GRSetPCDeity(spInfo.oTarget);
        iTargetPatron = GetLocalInt(spInfo.oTarget, "MY_DEITY");
    }

    int     iDeityGoodEvil  = GRGetDeityAlignGoodEvil(iPatron);
    int     iDeityLawChaos  = GRGetDeityAlignLawChaos(iPatron);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eGoodVis = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MAJOR);  // Visible impact effect
    effect eEvilVis = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MAJOR);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eSave    = EffectSavingThrowIncrease(SAVING_THROW_ALL, 2);
    effect eLink    = EffectLinkEffects(eDur,eSave);

    if(iDeityGoodEvil==ALIGNMENT_EVIL) {
        eLink = EffectLinkEffects(eEvilVis, eLink);
    } else {
        eLink = EffectLinkEffects(eGoodVis, eLink);
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_HAND_OF_DIVINITY, FALSE));
    if(iPatron==iTargetPatron || (iDeityGoodEvil==GetAlignmentGoodEvil(spInfo.oTarget) &&
        iDeityLawChaos==GetAlignmentLawChaos(spInfo.oTarget))) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
    } else {
        FloatingTextStrRefOnCreature(16939282, oCaster, FALSE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
