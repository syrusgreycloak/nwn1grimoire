//*:**************************************************************************
//*:*  GR_S0_AURAVITAL.NSS
//*:**************************************************************************
//*:*
//*:* Aura of Viality (NW_S0_AuraVital) by Bioware Corp.
//*:*
//*:* Spell Compendium (p. 18)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Oct 29, 2001
//*:**************************************************************************
//*:* Updated On: November 19, 2007
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
    float   fRange          = FeetToMeters(15.0);

    int     iNumAffected    = MaxInt(1, spInfo.iCasterLevel/3);
    float   fDelay;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eVis     = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eStr     = EffectAbilityIncrease(ABILITY_STRENGTH, iBonus);
    effect eDex     = EffectAbilityIncrease(ABILITY_DEXTERITY, iBonus);
    effect eCon     = EffectAbilityIncrease(ABILITY_CONSTITUTION, iBonus);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eStr, eDex);
    eLink = EffectLinkEffects(eLink, eCon);
    eLink = EffectLinkEffects(eLink, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);

    while(GetIsObjectValid(spInfo.oTarget) && iNumAffected>0) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, TRUE)) {
            fDelay = GetRandomDelay(0.4, 1.1);
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_AURA_OF_VITALITY, FALSE));
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration));
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
            iNumAffected--;
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
