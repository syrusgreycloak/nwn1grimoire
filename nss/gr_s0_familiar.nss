//*:**************************************************************************
//*:*  GR_S0_FAMILIAR.NSS
//*:**************************************************************************
//*:* Enhance Familiar  (sg_s0_enhfamil.nss)   Spell Compendium (p. 82)
//*:* Fortify Familiar  (sg_s0_fortfam.nss)    Spell Compendium (p. 98)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: November 4, 2003
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = (spInfo.iSpellID==SPELL_GR_FORTIFY_FAMILIAR ? 8 : 0);
    int     iNumDice          = (spInfo.iSpellID==SPELL_GR_FORTIFY_FAMILIAR ? 2 : 0);
    int     iBonus            = 0;
    switch(spInfo.iSpellID) {
        case SPELL_ENHANCE_FAMILIAR:
            iBonus = 2;
            break;
        case SPELL_GR_AUGMENT_FAMILIAR:
            iBonus = 4;
            break;
    }

    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = (spInfo.iSpellID==SPELL_ENHANCE_FAMILIAR ? DUR_TYPE_HOURS : DUR_TYPE_ROUNDS);

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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

    object  oFamiliar       = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oCaster);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eLink, eImpLink, eTempHP;
    effect eVis         = EffectVisualEffect(VFX_IMP_HOLY_AID);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    switch(spInfo.iSpellID) {
        case SPELL_ENHANCE_FAMILIAR:
            effect eAttBonus    = EffectAttackIncrease(iBonus);
            effect eSaveBonus   = EffectSavingThrowIncrease(SAVING_THROW_ALL, iBonus);
            effect eDamageBonus = EffectDamageIncrease(GRGetDamageBonusValue(iBonus));
            effect eACBonus     = EffectACIncrease(iBonus);

            eLink = EffectLinkEffects(eAttBonus, eSaveBonus);
            eLink = EffectLinkEffects(eLink, eDamageBonus);
            eLink = EffectLinkEffects(eLink, eACBonus);
            eLink = EffectLinkEffects(eLink, eDur);
            eImpLink = eVis;
            break;
        case SPELL_GR_FORTIFY_FAMILIAR:
            effect eMissChance  = EffectConcealment(50);
            effect eACIncrease  = EffectACIncrease(2, AC_NATURAL_BONUS);
            eTempHP      = EffectTemporaryHitpoints(iDamage);
            effect eACVis       = EffectVisualEffect(VFX_IMP_AC_BONUS);
            effect eTempVis     = EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE);
            effect eVisLink     = EffectLinkEffects(eACVis, eTempVis);

            eLink = EffectLinkEffects(eMissChance, eACIncrease);
            eImpLink = eVisLink;
            break;

        case SPELL_GR_AUGMENT_FAMILIAR:
            effect eSTRBonus    = EffectAbilityIncrease(ABILITY_STRENGTH, iBonus);
            effect eDEXBonus    = EffectAbilityIncrease(ABILITY_DEXTERITY, iBonus);
            effect eCONBonus    = EffectAbilityIncrease(ABILITY_CONSTITUTION, iBonus);
            effect eDmgReduction= EffectDamageReduction(5, DAMAGE_POWER_PLUS_ONE);
            effect eAugSaveBns  = EffectSavingThrowIncrease(SAVING_THROW_ALL, 2);

            eLink = EffectLinkEffects(eSTRBonus, eDEXBonus);
            eLink = EffectLinkEffects(eLink, eCONBonus);
            eLink = EffectLinkEffects(eLink, eDmgReduction);
            eLink = EffectLinkEffects(eLink, eSaveBonus);
            eLink = EffectLinkEffects(eLink, eDur);
            eImpLink = eVis;
            break;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(spInfo.oTarget) && spInfo.oTarget==oFamiliar) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
        GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpLink, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
        if(spInfo.iSpellID==SPELL_GR_FORTIFY_FAMILIAR) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTempHP, spInfo.oTarget, GRGetDuration(1, DUR_TYPE_HOURS));
        }
    } else if(GetIsObjectValid(spInfo.oTarget) && GetDistanceBetween(oCaster,spInfo.oTarget)>FeetToMeters(120.0)) {
        FloatingTextStrRefOnCreature(16939281, oCaster, FALSE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************