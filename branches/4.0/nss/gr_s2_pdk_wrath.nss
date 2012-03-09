//*:**************************************************************************
//*:*  GR_S2_PDK_WRATH.NSS
//*:**************************************************************************
//*:* Purple Dragon Knight - Oath of Wrath (x3_s2_pdk_wrath.nss)
//*:* Created By: Stratovarius  Created On: Sept 22, 2005
//*:*
//*:**************************************************************************
//*:* Updated On: February 20, 2008
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

    if(oCaster==spInfo.oTarget) {
         FloatingTextStrRefOnCreature(16939292, oCaster, FALSE);
         return;
    }
    if(GetIsFriend(spInfo.oTarget)) {
         FloatingTextStrRefOnCreature(16939293, oCaster, FALSE);
         return;
    }

    spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT, oCaster);
    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = 2;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel*2;
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

    float   fDuration       = GRGetDuration(iDurAmount);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iTargetRace     = GRGetRacialType(spInfo.oTarget);

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
    effect eAttack  = EffectAttackIncrease(iBonus);
    effect eDamage  = EffectDamageIncrease(DAMAGE_BONUS_2, DAMAGE_TYPE_BLUDGEONING);
    effect eSave    = EffectSavingThrowIncrease(SAVING_THROW_ALL, iBonus);
    effect eSkill   = EffectSkillIncrease(SKILL_ALL_SKILLS, iBonus);

    effect eLink    = EffectLinkEffects(eAttack, eDamage);
    eLink = EffectLinkEffects(eLink, eSave);
    eLink = EffectLinkEffects(eLink, eSkill);

    eLink = VersusRacialTypeEffect(eLink, iTargetRace);
    eLink = SupernaturalEffect(eLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(oCaster, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PDK_OATH), oCaster);
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PDK_WRATH), spInfo.oTarget);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
