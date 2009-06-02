//*:**************************************************************************
//*:*  GR_S0_RAGEFRNZY.NSS
//*:**************************************************************************
//*:* Barbarian Rage (NW_S1_BarbRage) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Aug 13, 2001
//*:**************************************************************************
//*:* Blood Frenzy
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 28, 2003
//*:* Magic of Faerun (p. 82)
//*:**************************************************************************
//*:* Updated On: November 13, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_FEATS"

//*:* #include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void DoFatigueAfterRage(object oCaster, int iNumRounds) {

    effect eVis         = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eStrFatigue  = EffectAbilityDecrease(ABILITY_STRENGTH, 2);
    effect eDexFatigue  = EffectAbilityDecrease(ABILITY_DEXTERITY, 2);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink        = EffectLinkEffects(eStrFatigue, eDexFatigue);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = ExtraordinaryEffect(eLink);

    iNumRounds = (iNumRounds/2) - MaxInt(0, GetAbilityModifier(ABILITY_CONSTITUTION));
    SignalEvent(oCaster, EventSpellCastAt(oCaster, 307));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, GRGetDuration(iNumRounds));

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
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    if(spInfo.iSpellID!=SPELL_BLOOD_FRENZY) {
        spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_BARBARIAN);
    }

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

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int iIncrease           = 4;
    int iSave               = 2;
    int iDecrease           = 2;
    int iCon                = 0;

    if(spInfo.iSpellID==SPELL_BLOOD_FRENZY) {
        iIncrease = 2;
        iSave = 1;
        iDecrease = 1;
        fDuration = GRGetSpellDuration(spInfo);
    } else {
        if(spInfo.iCasterLevel>10) {  // 3.5 rules start Greater Rage at level 11
            iIncrease = 6;
            iSave = 3;
        }

        iCon = GetAbilityModifier(ABILITY_CONSTITUTION)+3+iIncrease/2; // divide iIncrease by 2 since modifier increases by every 2 CON pts
        fDuration = GRGetDuration(iCon);
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
    effect eVis     = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    effect eStr     = EffectAbilityIncrease(ABILITY_CONSTITUTION, iIncrease);
    effect eCon     = EffectAbilityIncrease(ABILITY_STRENGTH, iIncrease);
    effect eSave    = EffectSavingThrowIncrease(SAVING_THROW_WILL, iSave);
    effect eSave2   = EffectSavingThrowIncrease(SAVING_THROW_WILL, 4, SAVING_THROW_TYPE_MIND_SPELLS);
    effect eAC      = EffectACDecrease(iDecrease, AC_DODGE_BONUS);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink    = EffectLinkEffects(eCon, eStr);
    eLink = EffectLinkEffects(eLink, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eDur);
    if(GetHasFeat(FEAT_GR_INDOMITABLE_WILL, oCaster)) eLink = EffectLinkEffects(eLink, eSave2);

    eLink = (spInfo.iSpellID==SPELL_BLOOD_FRENZY ? MagicalEffect(eLink) : ExtraordinaryEffect(eLink));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE)) {
        GRRemoveSpellEffects(SPELL_BLOOD_FRENZY, OBJECT_SELF);
        SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, spInfo.iSpellID, FALSE));
        PlayVoiceChat(VOICE_CHAT_BATTLECRY1);

        if(spInfo.iSpellID==SPELL_BLOOD_FRENZY || iCon>0) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, OBJECT_SELF, fDuration);
            if(iCon>0) GRCheckAndApplyEpicRageFeats(iCon);
        }
        if(spInfo.iSpellID!=SPELL_BLOOD_FRENZY && !GetHasFeat(FEAT_TIRELESS_RAGE_5, OBJECT_SELF)) {
            DelayCommand(fDuration+1.0, DoFatigueAfterRage(OBJECT_SELF, iCon));
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
