//*:**************************************************************************
//*:*  GR_S2_GWDRAIN.NSS
//*:**************************************************************************
//*:* Shifter Shadow drain attack (x2_s1_shadow) Copyright (c) 2001 Bioware Corp.
//*:*
//*:*
//*:**************************************************************************
//*:* Updated On: February 15, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
#include "X2_INC_SHIFTER"

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Supporting function
//*:**************************************************************************
void DoDrain(object oTarget, int iDrain) {

    effect eDrain = EffectNegativeLevel(iDrain);
    eDrain = SupernaturalEffect(eDrain);
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

    spInfo.iDC = ShifterGetSaveDC(oCaster, SHIFTER_DC_EASY_MEDIUM);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    int     iDamage           = d2();
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

        int iAttackResult = TouchAttackMelee(spInfo.oTarget);
        iDamage *= iAttackResult;   // SG: We can do this because if we miss, iAttackResult is 0, and multiplying by 0 is 0.
                                    // SG: If we hit normally, iAttackResult is 1, and multiplying by 1 gives the same number.
                                    // SG: If we crit, iAttackResult is 2, which results in double damage (ie multiplying by 2).
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        if(iDamage>0) {     // if we missed, iDamage will be 0 from the multiplication step above
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NEGATIVE)) {
                if(GetHitDice(spInfo.oTarget)-iDamage<1) {
                    if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_DEATH, oCaster)) {
                        effect eDeath = EffectDeath(TRUE);
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget);
                    } else {
                        effect eDam = EffectDamage(GetCurrentHitPoints(spInfo.oTarget)+11, DAMAGE_TYPE_MAGICAL);
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget);
                    }
                } else {
                    DelayCommand(0.1f, DoDrain(spInfo.oTarget, iDamage));
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                }
            }
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
