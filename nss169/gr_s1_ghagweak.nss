//*:**************************************************************************
//*:*  GR_S1_GHAGWEAK.NSS
//*:**************************************************************************
//*:* Greenhag weakness ability (sg_s1_ghagweak.nss) 2005 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 30, 2005
//*:* 3.5 Monster Manual (p. 143)
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    spInfo.iDC = 16;

    //*:* int     iDieType          = 4;
    //*:* int     iNumDice          = 2;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_TURNS;

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

    int     iStrengthRemaining      = GetAbilityScore(spInfo.oTarget, ABILITY_STRENGTH);
    int     iDrainAmount            = d4(2);
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
    effect eVis   = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eDeath = EffectDamage(GetCurrentHitPoints(spInfo.oTarget)+11);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.oTarget!=oCaster) {
        if(GetIsEnemy(spInfo.oTarget, oCaster) && !GetIsReactionTypeFriendly(spInfo.oTarget, oCaster)) {
            if(TouchAttackMelee(spInfo.oTarget)) {
                if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NONE, oCaster)) {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                    if(iDrainAmount>iStrengthRemaining) {
                        DelayCommand(1.2f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                    } else {
                        //*:* Since the max for EffectAbilityDecrease is 10, we'll pass split amounts if more than 10
                        //*:* We will also use a delayed function to disconnect from the spell id, so
                        //*:* we can stack the effects
                        if(iDrainAmount>10) {
                            DelayCommand(1.0f, DoStrengthDrain(iDrainAmount/2, spInfo.oTarget));
                            DelayCommand(1.2f, DoStrengthDrain(iDrainAmount-(iDrainAmount/2), spInfo.oTarget));
                        } else {
                            DelayCommand(1.0f, DoStrengthDrain(iDrainAmount, spInfo.oTarget));
                        }
                    }
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
