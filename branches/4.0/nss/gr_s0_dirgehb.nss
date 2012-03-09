//*:**************************************************************************
//*:*  GR_S0_DIRGEHB.NSS
//*:**************************************************************************
//*:*
//*:* Dirge (x0_s0_dirge.nss) Copyright (c) 2001 Bioware Corp.
//*:* Spell Compendium (p. 65)
//*:*
//*:**************************************************************************
//*:* Created By: Brent
//*:* Created On: July 2002
//*:**************************************************************************
//*:* Updated On: November 26, 2007
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
void DoDirgeImpact(object oTarget, object oCaster) {
    //------------------------------------------------------------------
    // The trick that allows this spellscript to do stacking ability
    // score damage (which is not possible to do from normal scripts)
    // is that the ability score damage is done from a delaycommanded
    // function which will sever the connection between the effect
    // and the SpellId
    //------------------------------------------------------------------

    effect eStr = EffectAbilityDecrease(ABILITY_STRENGTH, 2);
    effect eDex = EffectAbilityDecrease(ABILITY_DEXTERITY, 2);
    effect eLink = ExtraordinaryEffect(EffectLinkEffects(eStr, eDex));

    if((GetAbilityScore(oTarget, ABILITY_STRENGTH)<=2 || GetAbilityScore(oTarget, ABILITY_DEXTERITY)<=2) &&
        GetGameDifficulty()>=GAME_DIFFICULTY_CORE_RULES) {

        if(!GetImmortal(oTarget)) {
            FloatingTextStrRefOnCreature(100932, oTarget);
            effect eKill = EffectDamage(GetCurrentHitPoints(oTarget)+1);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, oTarget);
            effect eVfx = EffectVisualEffect(VFX_IMP_DEATH_L);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVfx, oTarget);
         }
    } else {
        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
    }
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 2;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = 2;
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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = GetRandomDelay(1.0, 2.0);
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eDeathVis    = EffectVisualEffect(VFX_IMP_DEATH);
    effect eDeath       = EffectDeath();
    effect eVis         = EffectVisualEffect(VFX_FNF_SOUND_BURST);
    effect eStr;
    effect eDex;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetFirstInPersistentObject();

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_DIRGE));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_ALL, oCaster)) {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                    DelayCommand(1.0, DoDirgeImpact(spInfo.oTarget, oCaster));
                }
            }
        }
        spInfo.oTarget = GetNextInPersistentObject();
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
