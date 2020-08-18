//*:**************************************************************************
//*:*  GR_S1_HORRAPPRA.NSS
//*:**************************************************************************
//*:* Horrific Appearance:OnEnter - Sea Hag (nw_s1_HorrAppr.nss) Copyright (c) 2004 Bioware Corp.
//*:* Created By: Keith Hayward  Created On: January 9, 2004
//*:* 3.5 Monster Manual (p. 144)
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
//*:* Supporting functions
//*:**************************************************************************
void DoStrengthDrain(int iDrainAmount, object oTarget) {

    effect eSTRDrain = SupernaturalEffect(EffectAbilityDecrease(ABILITY_STRENGTH, iDrainAmount));

    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eSTRDrain, oTarget);
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    spInfo.iDC = 13;
    spInfo.oTarget = GetEnteringObject();

    //*:* Targets can only be affected once in a 24hr period by the same sea hag.  We'll cheat and use
    //*:* "same day", so there could be a minor technicality if fighting around midnight
    if(GetLocalInt(spInfo.oTarget, "GR_SEAHAG_HORRIFIC_APP_DAY"+ObjectToString(oCaster))==GetCalendarDay()) {
        return; // already affected
    } else {
        SetLocalInt(spInfo.oTarget, "GR_SEAHAG_HORRIFIC_APP_DAY"+ObjectToString(oCaster), GetCalendarDay());
    }

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
    /*if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);*/

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iStrengthRemaining      = GetAbilityScore(spInfo.oTarget, ABILITY_STRENGTH);
    int     iDrainAmount            = d6(2);
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
    effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.oTarget!=oCaster) {
        if(GetIsEnemy(spInfo.oTarget, oCaster) && !GetIsReactionTypeFriendly(spInfo.oTarget, oCaster)) {
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NONE, oCaster)) {
                if(iDrainAmount>iStrengthRemaining) {
                    iDrainAmount = iStrengthRemaining;  // only drain to 0
                }
                //*:* Since the max for EffectAbilityDecrease is 10, we'll pass split amounts if more than 10
                //*:* We will also use a delayed function to disconnect from the spell id, so
                //*:* we can stack the effects
                if(iDrainAmount>10) {
                    DelayCommand(1.0f, DoStrengthDrain(iDrainAmount/2, spInfo.oTarget));
                    DelayCommand(1.2f, DoStrengthDrain(iDrainAmount-(iDrainAmount/2), spInfo.oTarget));
                } else {
                    DelayCommand(1.0f, DoStrengthDrain(iDrainAmount, spInfo.oTarget));
                }
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
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
