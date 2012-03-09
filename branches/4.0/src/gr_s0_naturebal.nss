//*:**************************************************************************
//*:*  GR_S0_NATUREBAL.NSS
//*:**************************************************************************
//*:* Nature's Balance (sg_s0_naturebal.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: November 10, 2004
//*:* Spell Compendium (p. 145)
//*:**************************************************************************
//*:* Updated On: March 10, 2008
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
    int     iBonus            = 4;
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int iAbilityAffected;

    switch(spInfo.iSpellID) {
        case SPELL_GR_NAT_BALANCE:
        case SPELL_GR_NAT_BALANCE_STR:
            iAbilityAffected=ABILITY_STRENGTH;
            break;
        case SPELL_GR_NAT_BALANCE_DEX:
            iAbilityAffected=ABILITY_DEXTERITY;
            break;
        case SPELL_GR_NAT_BALANCE_CON:
            iAbilityAffected=ABILITY_CONSTITUTION;
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
    effect eImpVis          = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    effect eScoreImprove    = EffectAbilityIncrease(iAbilityAffected, iBonus);
    effect eDurImprove      = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eImproveLink     = EffectLinkEffects(eScoreImprove, eDurImprove);

    effect eCasterVis       = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eScoreDecrease   = EffectAbilityDecrease(iAbilityAffected, iBonus);
    effect eDurDecrease     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDecreaseLink    = EffectLinkEffects(eScoreDecrease, eDurDecrease);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GetHasSpellEffect(SPELL_GR_NAT_BALANCE, oCaster)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_NAT_BALANCE, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eImproveLink, spInfo.oTarget, fDuration);

        SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_NAT_BALANCE, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eCasterVis, oCaster);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDecreaseLink, oCaster);

        if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    }
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
