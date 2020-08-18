//*:**************************************************************************
//*:*  GR_S0_SHADSTORM.NSS
//*:**************************************************************************
//*:* Shadow Storm (SG_S0_ShadStorm.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 18, 2003
//*:*
//*:**************************************************************************
//*:* Updated On: February 26, 2008
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
//*:* Supporting functions
//*:**************************************************************************
void DoAbilityDamage(object oTarget, int iAbility, int iDamage, float fDuration=0.0f) {

    int iTempDamage = MinInt(10, iDamage);
    int iDurationType = (fDuration==0.0f ? DURATION_TYPE_PERMANENT : DURATION_TYPE_TEMPORARY);

    effect eAbilityDamage = EffectAbilityDecrease(iAbility, iTempDamage);
    GRApplyEffectToObject(iDurationType, eAbilityDamage, oTarget, fDuration);
    if(iTempDamage!=iDamage) DelayCommand(1.0, DoAbilityDamage(oTarget, iAbility, iDamage-10, fDuration));
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = 12;
    int     iNumDice          = 4;
    int     iBonus            = MinInt(25, spInfo.iCasterLevel);
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel/2;
    int     iDurType          = DUR_TYPE_ROUNDS;

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
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(spInfo.iCasterLevel*2.0f);

    int     iAbilityDmg     = MinInt(12, spInfo.iCasterLevel/2);
    int     iSTRDamage      = iAbilityDmg;
    int     iCONDamage      = iAbilityDmg;

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
    effect eVis1    = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_GREASE);
    effect eVis2    = EffectVisualEffect(VFX_FNF_PWSTUN);
    effect eVis3    = EffectVisualEffect(VFX_IMP_LIGHTNING_M);
    effect eVisLink = EffectLinkEffects(eVis1,eVis2);
    eVisLink        = EffectLinkEffects(eVis3,eVisLink);
    effect eImp1    = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1);
    effect eHPVis   = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eSTRDamage;
    effect eCONDamage;
    effect eAbilDmg;
    effect eHPDamage;
    effect eHPDamLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisLink, spInfo.lTarget);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_SHADOW_STORM));
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp1, spInfo.oTarget);
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NEGATIVE)) {
                    iSTRDamage /= 2;
                    iCONDamage /= 2;
                }
                DelayCommand(1.5f, DoAbilityDamage(spInfo.oTarget, ABILITY_STRENGTH, iSTRDamage, fDuration));
                DelayCommand(1.7f, DoAbilityDamage(spInfo.oTarget, ABILITY_CONSTITUTION, iCONDamage, fDuration));

                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, SAVING_THROW_TYPE_NEGATIVE);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                if(iDamage>0) {
                    eHPDamage = EffectDamage(iDamage, DAMAGE_TYPE_NEGATIVE);
                    if(iSecDamage>0) eHPDamage = EffectLinkEffects(eHPDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    eHPDamLink = EffectLinkEffects(eHPVis, eHPDamage);
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHPDamLink, spInfo.oTarget);
                }
            }
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
