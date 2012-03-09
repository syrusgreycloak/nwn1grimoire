//*:**************************************************************************
//*:*  GR_S1_SHADOW.NSS
//*:**************************************************************************
//*:* Shadow Attack (x2_s1_shadow) Copyright (c) 2001 Bioware Corp.
//*:*
/*
    The shadow gets special strength drain attack, once per round.

    The shifter's spectre form can use this ability but is not as effective as a real shadow
*/
//*:**************************************************************************
//*:* Updated On: February 15, 2008
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
void ApplyShadow(int iDamage, object oTarget) {
    effect eDamage = EffectAbilityDecrease(ABILITY_STRENGTH, iDamage);

    // * Delaying the command to sever the connection between this effect and
    // * the spell, so its effects stack
    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDamage, oTarget);
}

void DoShadowHit(object oTarget) {
    int iDamage = Random(6) + 1;
    int iTargetStrength = GetAbilityScore(oTarget, ABILITY_STRENGTH);

    effect eVis;
    // * Target is slain in Hardcore mode or higher if Strength is reduced to 0
    if(GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE) == FALSE) {
        //--------------------------------------------------------------------
        // On Hardcore rules, kill target if strength would fall below 0
        //--------------------------------------------------------------------
        if(((iTargetStrength - iDamage)<=0)  && GetGameDifficulty()>=GAME_DIFFICULTY_CORE_RULES) {
            FloatingTextStrRefOnCreature(84482, oTarget,FALSE);
            int iHitPoints = GetCurrentHitPoints(oTarget);
            effect eHitDamage = EffectDamage(iHitPoints+11, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY);
            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eHitDamage, oTarget);
        } else {
            DelayCommand(0.1, ApplyShadow(iDamage, oTarget));
            FloatingTextStrRefOnCreature(84483, oTarget, FALSE);
        }
        eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY) ;
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    } else {
        eVis = EffectVisualEffect(VFX_COM_HIT_NEGATIVE);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    object oTarget = GetSpellTargetObject();
    int iAttackResult = TouchAttackMelee(oTarget, TRUE);
    if(iAttackResult>0) {
        DoShadowHit(oTarget);
    }
}
//*:**************************************************************************
//*:**************************************************************************
