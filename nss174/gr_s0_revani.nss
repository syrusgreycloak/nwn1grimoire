//*:**************************************************************************
//*:*  GR_S0_REVANI.NSS
//*:**************************************************************************
//*:* Revitalize Animal (sg_s0_revani.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: November 10, 2004
//*:* 2E Complete Ranger's Handbook
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

    int     iDieType          = 8;
    int     iNumDice          = (spInfo.iSpellID==SPELL_GR_REVITALIZE_ANIMAL_1 ? 1 : 2);
    int     iBonus            = (spInfo.iSpellID==SPELL_GR_REVITALIZE_ANIMAL_1 ? MinInt(5, spInfo.iCasterLevel) : MinInt(10, spInfo.iCasterLevel));
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic);
    int     iDurType          = DUR_TYPE_HOURS;

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

    int     iTargetDmg      = GetMaxHitPoints(spInfo.oTarget)-GetCurrentHitPoints(spInfo.oTarget);
    int     iPossibleHealAmt = GetCurrentHitPoints(oCaster)-1;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    if(iDamage>iTargetDmg) iDamage = iTargetDmg;
    if(iDamage>iPossibleHealAmt) iDamage = iPossibleHealAmt;

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eImpVis          = EffectVisualEffect(VFX_IMP_HEALING_L);
    effect eHeal            = EffectHeal(iDamage);
    effect eTargetLink      = EffectLinkEffects(eImpVis, eHeal);
    effect eAttackPenalty   = EffectAttackDecrease(1);
    effect eDurVis          = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eCasterLink      = EffectLinkEffects(eAttackPenalty, eDurVis);
    effect eCasterDmg       = EffectDamage(iDamage);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_REVITALIZE_ANIMAL, FALSE));
    if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ANIMAL  && !GRGetIsImmuneToMagicalHealing(spInfo.oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eTargetLink, spInfo.oTarget);
        SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_REVITALIZE_ANIMAL, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCasterLink, oCaster, fDuration);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eCasterDmg, oCaster);
        DelayCommand(fDuration, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eTargetLink, oCaster));
        if(!GetIsFriend(spInfo.oTarget, oCaster)) {
            SetIsTemporaryNeutral(spInfo.oTarget, oCaster, FALSE);
            ClearPersonalReputation(oCaster, spInfo.oTarget);
        }
    } else if(!GRGetIsImmuneToMagicalHealing(spInfo.oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), spInfo.oTarget);
        FloatingTextStrRefOnCreature(16939283, oCaster, FALSE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
