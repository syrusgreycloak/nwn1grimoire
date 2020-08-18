//*:**************************************************************************
//*:*  GR_S0_REJCOCOON.NSS
//*:**************************************************************************
//*:* Rejuvenation Cocoon
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 5, 2009
//*:* Spell Compendium (p. 171)
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
void ApplyCocoonEffects(struct SpellStruct spInfo, int iDamage) {

    if(GetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget)) {
        effect eHeal = EffectHeal(iDamage);
        effect eVis  = EffectVisualEffect(VFX_IMP_HEALING_X);
        effect eLink = EffectLinkEffects(eHeal, eVis);

        SignalEvent(spInfo.oTarget, EventSpellCastAt(spInfo.oCaster, SPELL_REJUVENATION_COCOON));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
        GRRemoveMultipleEffects(EFFECT_TYPE_DISEASE, EFFECT_TYPE_POISON, spInfo.oTarget);
    } else {
        SetCommandable(TRUE, spInfo.oTarget);
    }
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    int     iDamage           = MinInt(150, spInfo.iCasterLevel*10);
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 2;
    int     iDurType          = DUR_TYPE_ROUNDS;

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

    float   fDuration       = GRGetDuration(iDurAmount, iDurType);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iCocoonHP       = spInfo.iCasterLevel*10;

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
    effect eDur     = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MAJOR);
    effect eDR1     = EffectDamageResistance(DAMAGE_TYPE_ACID, iCocoonHP, iCocoonHP);
    effect eDR2     = EffectDamageResistance(DAMAGE_TYPE_BLUDGEONING, iCocoonHP, iCocoonHP);
    effect eDR3     = EffectDamageResistance(DAMAGE_TYPE_COLD, iCocoonHP, iCocoonHP);
    effect eDR4     = EffectDamageResistance(DAMAGE_TYPE_DIVINE, iCocoonHP, iCocoonHP);
    effect eDR5     = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, iCocoonHP, iCocoonHP);
    effect eDR6     = EffectDamageResistance(DAMAGE_TYPE_FIRE, iCocoonHP, iCocoonHP);
    effect eDR7     = EffectDamageResistance(DAMAGE_TYPE_MAGICAL, iCocoonHP, iCocoonHP);
    effect eDR8     = EffectDamageResistance(DAMAGE_TYPE_NEGATIVE, iCocoonHP, iCocoonHP);
    effect eDR9     = EffectDamageResistance(DAMAGE_TYPE_PIERCING, iCocoonHP, iCocoonHP);
    effect eDR10    = EffectDamageResistance(DAMAGE_TYPE_POSITIVE, iCocoonHP, iCocoonHP);
    effect eDR11    = EffectDamageResistance(DAMAGE_TYPE_SLASHING, iCocoonHP, iCocoonHP);
    effect eDR12    = EffectDamageResistance(DAMAGE_TYPE_SONIC, iCocoonHP, iCocoonHP);
    effect eNoMove  = EffectMovementSpeedDecrease(99);
    effect eNoSpell = EffectSpellFailure(100);

    effect eLink    = EffectLinkEffects(eDur, eDR1);
    eLink = EffectLinkEffects(eLink, eDR2);
    eLink = EffectLinkEffects(eLink, eDR3);
    eLink = EffectLinkEffects(eLink, eDR4);
    eLink = EffectLinkEffects(eLink, eDR5);
    eLink = EffectLinkEffects(eLink, eDR6);
    eLink = EffectLinkEffects(eLink, eDR7);
    eLink = EffectLinkEffects(eLink, eDR8);
    eLink = EffectLinkEffects(eLink, eDR9);
    eLink = EffectLinkEffects(eLink, eDR10);
    eLink = EffectLinkEffects(eLink, eDR11);
    eLink = EffectLinkEffects(eLink, eDR12);
    eLink = EffectLinkEffects(eLink, eNoMove);
    eLink = EffectLinkEffects(eLink, eNoSpell);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_REJUVENATION_COCOON));
    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
        SetCommandable(FALSE, spInfo.oTarget);
        DelayCommand(fDuration, SetCommandable(TRUE, spInfo.oTarget));
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
        DelayCommand(RoundsToSeconds(1), ApplyCocoonEffects(spInfo, iDamage));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
