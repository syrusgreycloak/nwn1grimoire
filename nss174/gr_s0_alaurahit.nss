//*:**************************************************************************
//*:*  GR_S0_ALAURAHIT.NSS
//*:**************************************************************************
//*:* Alignment Aura spells (OnHit)
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 13, 2004
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

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oItem           = GetSpellCastItem();
    string  sMyTag          = GetTag(oItem);
    object  oCaster         = GetItemPossessor(oItem);
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    spInfo.oTarget         = GetLastAttacker(oCaster);
    spInfo.iDC             = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount          = spInfo.iCasterLevel;
    int     iDurType            = DUR_TYPE_ROUNDS;
    float   fDurOverride        = 9.0f;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType, fDurOverride);

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

    int     iVisualType;
    effect  eEffect;
    int     iSavingThrow;
    int     iSaveType;

    switch(spInfo.iSpellID) {
        case SPELL_CLOAK_OF_CHAOS:
            iVisualType = VFX_IMP_CONFUSION_S;
            eEffect = EffectConfused();
            iSavingThrow = SAVING_THROW_WILL;
            iSaveType = SAVING_THROW_TYPE_CHAOS;
            break;
        case SPELL_HOLY_AURA:
            iVisualType = VFX_IMP_BLIND_DEAF_M;
            eEffect = EffectBlindness();
            iSavingThrow = SAVING_THROW_FORT;
            iSaveType = SAVING_THROW_TYPE_GOOD;
            break;
        case SPELL_SHIELD_OF_LAW:
            iVisualType = VFX_IMP_SLOW;
            effect eSlow    = EffectSlow();
            effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
            effect eAC      = EffectACDecrease(2);
            effect eAttack  = EffectAttackDecrease(2);
            effect eDmg     = EffectDamageDecrease(2);
            effect eSave    = EffectSavingThrowDecrease(SAVING_THROW_REFLEX, 2);
            eEffect = EffectLinkEffects(eSlow, eDur);
            eEffect = EffectLinkEffects(eEffect, eAC);
            eEffect = EffectLinkEffects(eEffect, eAttack);
            eEffect = EffectLinkEffects(eEffect, eDmg);
            eEffect = EffectLinkEffects(eEffect, eSave);
            iSavingThrow = SAVING_THROW_WILL;
            iSaveType = SAVING_THROW_TYPE_LAW;
            break;
        case SPELL_UNHOLY_AURA:
            iVisualType = VFX_IMP_REDUCE_ABILITY_SCORE;
            eEffect = EffectAbilityDecrease(ABILITY_STRENGTH, GRGetMetamagicAdjustedDamage(6, 1, spInfo.iMetamagic, 0));
            iSavingThrow = SAVING_THROW_FORT;
            iSaveType = SAVING_THROW_TYPE_EVIL;
            break;
    }

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
    effect eImpVis  = EffectVisualEffect(iVisualType);  // Visible impact effect

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(!GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster)) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, spInfo.oTarget, fDuration);
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
