//*:**************************************************************************
//*:*  GR_S0_MOONBOLT.NSS
//*:**************************************************************************
//*:* Moon Bolt
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 5, 2009
//*:* Spell Compendium (p. 143)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void ApplyMoonBoltStrengthDamage(object oTarget, int iDamage) {
    // Apply this as a delayed function to break spell id and allow stacking
    effect eSTR = EffectAbilityDecrease(ABILITY_STRENGTH, iDamage);

    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eSTR, oTarget);
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

    int     iDieType          = 4;
    int     iNumDice          = MinInt(5, spInfo.iCasterLevel/3);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
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
    float   fRange          = GetDistanceBetween(oCaster, spInfo.oTarget);
    float   fDelay          = fRange/(3.0 * log(fRange) + 2.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    if(GRGetIsLiving(spInfo.oTarget)) {
        iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, oCaster);
        if(GRGetSpellHasSecondaryDamage(spInfo)) {
            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, FORTITUDE_HALF, oCaster);
            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                iDamage = iSecDamage;
            }
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eMissile = EffectVisualEffect(VFX_IMP_MIRV);
    effect eVis     = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    //effect eSTR     = EffectAbilityDecrease(ABILITY_STRENGTH, iDamage);
    effect eProne   = EffectKnockdown();
    effect eAttack  = EffectAttackDecrease(2);
    effect eSave    = EffectSavingThrowDecrease(SAVING_THROW_WILL, 2);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eUndLink = EffectLinkEffects(eAttack, eSave);
    eUndLink        = EffectLinkEffects(eUndLink, eDur);

    if(iSecDamage>0) eVis = EffectLinkEffects(eVis, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_MOON_BOLT));
    DelayCommand(0.1, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, spInfo.oTarget));
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(GRGetIsLiving(spInfo.oTarget)) {
            DelayCommand(fDelay+0.1, ApplyMoonBoltStrengthDamage(spInfo.oTarget, iDamage));
            DelayCommand(fDelay+0.1, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
        } else if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD)) {
            if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                fDuration = GRGetDuration(GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic, 0));
                DelayCommand(fDelay+0.1, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eProne, spInfo.oTarget, fDuration));
                DelayCommand(fDuration+fDelay+0.1, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eUndLink, spInfo.oTarget, TurnsToSeconds(1)));
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
