//*:**************************************************************************
//*:*  GR_S2_DIVWRATH.NSS
//*:**************************************************************************
//*:* Divine Wrath (x2_s2_DivWrath) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Feb 05, 2003
//*:* Updated On: Jul 21, 2003 Georg Zoeller -  Epic Level progession
//*:**************************************************************************
//*:* Updated On: December 26, 2007
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

    spInfo.iCasterLevel     = GRGetLevelByClass(CLASS_TYPE_DIVINECHAMPION, oCaster);
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

    int     iDuration       = MaxInt(1, GetAbilityModifier(ABILITY_CHARISMA, oCaster));
    float   fDuration       = GRGetDuration(iDuration);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAttBonus           = 3;
    int     iDmgBonus           = DAMAGE_BONUS_3;
    int     iSaveBonus          = 3 ;
    int     iDmgReductionBonus  = 5;
    int     iDmgReductionPower  = DAMAGE_POWER_ENERGY;

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
    effect eAttack      = EffectAttackIncrease(iAttBonus, ATTACK_BONUS_MISC);
    effect eDamage      = EffectDamageIncrease(iDmgBonus, DAMAGE_TYPE_DIVINE);
    effect eSaving      = EffectSavingThrowIncrease(SAVING_THROW_ALL, iSaveBonus, SAVING_THROW_TYPE_ALL);
    effect eReduction   = EffectDamageReduction(iDmgReductionBonus, iDmgReductionPower);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eVis         = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    eVis = EffectLinkEffects(EffectVisualEffect(VFX_IMP_GOOD_HELP),eVis);

    effect eLink = EffectLinkEffects(eAttack, eDamage);
    eLink = EffectLinkEffects(eSaving,eLink);
    eLink = EffectLinkEffects(eReduction,eLink);
    eLink = EffectLinkEffects(eDur,eLink);
    eLink = SupernaturalEffect(eLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, 621, FALSE));
    GRRemoveSpellEffects(621, spInfo.oTarget);

    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
