//*:**************************************************************************
//*:*  GR_S0_RIGHTMGT.NSS
//*:**************************************************************************
//*:* Righteous Might (sg_s0_rightmgt.nss) 2006 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 7, 2006
//*:*
//*:**************************************************************************
//*:* Updated On: March 11, 2008
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
    int     iBonus            = 5;
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

    int     iAlign          = GetAlignmentGoodEvil(oCaster);

    if(iAlign==ALIGNMENT_NEUTRAL) iAlign = ALIGNMENT_GOOD;

    if(spInfo.iCasterLevel>=12 && spInfo.iCasterLevel<15) {
        iBonus = 10;
    } else if(spInfo.iCasterLevel>=15) {
        iBonus = 15;
    }

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
    effect eVis     = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect eDur     = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MAJOR);
    effect eSTR     = EffectAbilityIncrease(ABILITY_STRENGTH, 8);
    effect eCON     = EffectAbilityIncrease(ABILITY_CONSTITUTION, 4);
    effect eAC      = EffectACIncrease(3, AC_NATURAL_BONUS);  //+4, -1 for size increase
    effect eAtt     = EffectAttackDecrease(1);
    effect eDmg     = EffectDamageIncrease(GRGetDamageBonusValue(2)); // substituted for weapon size increase
    effect eDmgRed  = EffectDamageReduction(iBonus, DAMAGE_POWER_PLUS_THREE);

    effect eLink = EffectLinkEffects(eDur, eSTR);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eAtt);
    eLink = EffectLinkEffects(eLink, eDmg);
    eLink = EffectLinkEffects(eLink, eDmgRed);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveMultipleSpellEffects(SPELL_ENLARGE_PERSON, SPELL_GR_MASS_ENLARGE, spInfo.oTarget, TRUE, SPELL_GR_GREATER_ENLARGE);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_RIGHTEOUS_MIGHT));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
