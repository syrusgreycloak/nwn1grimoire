//*:**************************************************************************
//*:*  GR_S0_MINDFOGB.NSS
//*:**************************************************************************
//*:*
//*:* Mind Fog (OnExit) [NW_S0_MindFogA.nss] Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 253)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Aug 1, 2001
//*:**************************************************************************
//*:* Updated On: November 2, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

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
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    int     iDieType          = 6;
    int     iNumDice          = 2;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    spInfo.oTarget          = GetExitingObject();

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetDuration(GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic));
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eSave    = EffectSavingThrowDecrease(SAVING_THROW_WILL, 10);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVis     = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eAOE;

    effect eLink    = EffectLinkEffects(eSave, eDur);
    eLink = EffectLinkEffects(eLink, eVis);


    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetHasEffectTypeFromSpell(EFFECT_TYPE_SAVING_THROW_DECREASE, spInfo.oTarget, SPELL_MIND_FOG, oCaster)) {
        GRRemoveSpellEffects(SPELL_MIND_FOG, spInfo.oTarget, oCaster);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
    } else {
        GRRemoveSpellEffects(SPELL_MIND_FOG, spInfo.oTarget, oCaster);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************