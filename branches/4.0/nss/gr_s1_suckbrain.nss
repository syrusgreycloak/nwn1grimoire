//*:**************************************************************************
//*:*  GR_S1_SUCKBRAIN.NSS
//*:**************************************************************************
//*:* Mindflayer Extract Brain (x2_s1_suckbrain) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: 2003-09-01
//*:**************************************************************************
/*
    The Mindflayer's Extract Brain ability

    Since we can not simulate the When All 4 tentacles
    hit condition reliably, we use this approach for
    extract brain

    It is only triggered through the specialized
    mindflayer AI if the player is helpless.
    (see x2_ai_mflayer for details)

    If the player is helpless, the mindflayer will
    walk up and cast this spell, which has the Suck Brain
    special creature animation tied to it through spells.2da

    The spell first performs a melee touch attack. If that succeeds
    in <Hardcore difficulty, the player is awarded a Fortitude Save
    against DC 10+(HD/2).

    If the save fails, or the player is on a hardcore+ difficulty
    setting, the mindflayer will do d3()+2 points of permanent
    intelligence damage. Once a character's intelligence drops
    below 5, his enough of her brain has been extracted to kill her.

    As a little special condition, if the player is either diseased
    or poisoned, the mindflayer will also become disases or poisoned
    if by sucking the brain.


*/
//*:**************************************************************************
//*:* Updated On: January 28, 2008
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
void DoSuckBrain(object oTarget,int iDamage) {

    effect eDrain = EffectAbilityDecrease(ABILITY_INTELLIGENCE, iDamage);
    eDrain = ExtraordinaryEffect(eDrain);
    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDrain, oTarget);
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
    int     iDamage           = 0;
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    spInfo.iDC = 10+(GetHitDice(OBJECT_SELF)/2);
    int     bHardcore           = (GetGameDifficulty()>=GAME_DIFFICULTY_NORMAL);

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
    effect eBlood = EffectVisualEffect(493);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(TouchAttackMelee(spInfo.oTarget, TRUE)>0) {
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBlood, spInfo.oTarget);
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        //*:* if we failed the save (or never got one)
        if(bHardcore || (!bHardcore && !GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC))) {
            //*:* int below 5? We are braindead
            FloatingTextStrRefOnCreature(85566, spInfo.oTarget);
            if(GetAbilityScore(spInfo.oTarget, ABILITY_INTELLIGENCE)<5) {
                effect eDeath = EffectDamage(GetCurrentHitPoints(spInfo.oTarget)+11);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBlood, spInfo.oTarget);
                DelayCommand(1.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
            } else {
                iDamage = d3()+2;
                //*:* Ok, since the engine prevents ability score damage from the same spell to stack,
                //*:* we are using another "quirk" in the engine to make it stack:
                //*:* by DelayCommanding the spell function below the effect loses its SpellID information and stacks...
                DelayCommand(0.01f, DoSuckBrain(spInfo.oTarget, iDamage));
                //*:* if our target was poisoned or diseased, we inherit that
                if(GetHasEffect(EFFECT_TYPE_POISON, spInfo.oTarget)) {
                    effect ePoison = EffectPoison(POISON_PHASE_SPIDER_VENOM);
                    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoison, OBJECT_SELF);
                }

                if(GetHasEffect(EFFECT_TYPE_DISEASE, spInfo.oTarget)) {
                    effect eDisease =  EffectDisease(DISEASE_SOLDIER_SHAKES);
                    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDisease, OBJECT_SELF);
                }
            }
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
