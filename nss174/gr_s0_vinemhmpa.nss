//*:**************************************************************************
//*:* GR_S0_VINEMHMPA.NSS
//*:**************************************************************************
//:: Vine Mine, Hamper Movement: On Enter (X2_S0_VineMHmpA) Copyright (c) 2001 Bioware Corp.
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//*:* Spell Compendium (p. 230)
//*:* 3.5 DMG p. 87 for rules on heavy undergrowth
//*:**************************************************************************
//*:* Updated On: December 19, 2007
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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = GetRandomDelay(1.0, 2.2);
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eVis         = EffectVisualEffect(VFX_IMP_SLOW);
    effect eSlow        = EffectMovementSpeedDecrease(75);
    effect eTumbleDec   = EffectSkillDecrease(SKILL_TUMBLE, 5);
    effect eMoveSilDec  = EffectSkillDecrease(SKILL_MOVE_SILENTLY, 5);
    effect eHideInc     = EffectSkillIncrease(SKILL_HIDE, 5);
    effect eConceal     = EffectConcealment(30);
    /*** NWN1 SINGLE ***/ effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eLink    = EffectLinkEffects(eSlow, eConceal);
    eLink = EffectLinkEffects(eLink, eTumbleDec);
    eLink = EffectLinkEffects(eLink, eMoveSilDec);
    eLink = EffectLinkEffects(eLink, eHideInc);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GRGetIsIncorporeal(spInfo.oTarget) &&
        !GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT, spInfo.oTarget) && !GetHasSpellEffect(SPELLABILITY_GR_FREEDOM_OF_MOVEMENT, spInfo.oTarget)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
