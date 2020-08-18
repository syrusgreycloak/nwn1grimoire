//*:**************************************************************************
//*:*  GR_S0_BIGBY2.NSS
//*:**************************************************************************
//*:*
//*:* Bigby's Forceful Hand [x0_s0_bigby2] Copyright (c) 2002 Bioware Corp.
//*:*
//*:**************************************************************************
//*:* Created By: Brent
//*:* Created On: September 7, 2002
//*:**************************************************************************
//*:* Updated On: December 3, 2007
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

    int     iCasterRoll = d20(1) + 14;
    int     iTargetRoll = d20(1) + GetAbilityModifier(ABILITY_STRENGTH, spInfo.oTarget) + GetSizeModifier(spInfo.oTarget);

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
    effect eImpact      = EffectVisualEffect(VFX_IMP_BIGBYS_FORCEFUL_HAND);
    /*** NWN1 SINGLE ***/ effect eVis         = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    //*** NWN2 SINGLE ***/ effect eVis          = EffectVisualEffect(VFX_DUR_SPELL_DAZE);
    effect eKnockdown   = EffectDazed();
    effect eKnockdown2  = EffectKnockdown();
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink        = EffectLinkEffects(eKnockdown, eDur);

    eLink = EffectLinkEffects(eLink, eKnockdown2);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, spInfo.oTarget);
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_BIGBYS_FORCEFUL_HAND));
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(iCasterRoll >= iTargetRoll) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, fDuration);
                //*:* Bull Rush succesful
                FloatingTextStrRefOnCreature(8966, oCaster, FALSE);
            } else {
                FloatingTextStrRefOnCreature(8967, oCaster, FALSE);
            }
        }
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
