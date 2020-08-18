//*:**************************************************************************
//*:*  GR_S1_EVILEYE.NSS
//*:**************************************************************************
//*:* Sea Hag Evil Eye Ability (Su)
//*:* 3.5 Monster Manual (p. 144)
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: February 20, 2008
//*:**************************************************************************
/*    Three times per day, a sea hag can cast its dire gaze upon any single
      creature within 30 feet.  The target must succeed on a DC 13 Will save
      or be dazed for 3 days, although remove curse or dispel evil can restore
      sanity sooner.  In addition, an affected creature must succeed on a DC
      13 Fortitude save or die from fright.  Creatures with immunity to fear
      effects are not affected by a sea hag's evil eye.  The save DCs are
      Charisma based.*/
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

    spInfo.iDC = 13;

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 3;
    int     iDurType          = DUR_TYPE_DAYS;

    switch(GetGameDifficulty()) {
        case GAME_DIFFICULTY_VERY_EASY:
            iDurAmount = 2;
            iDurType = DUR_TYPE_ROUNDS;
            break;
        case GAME_DIFFICULTY_EASY:
            iDurAmount = 1;
            iDurType = DUR_TYPE_TURNS;
            break;
        case GAME_DIFFICULTY_NORMAL:
            iDurType = DUR_TYPE_TURNS;
            break;
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
    /*if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);*/

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetDuration(iDurAmount, iDurType);
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
    effect eVis     = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eSave    = EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE);
    effect eDazed   = EffectDazed();
    effect eCursed  = EffectCurse(1, 0, 0, 0, 0, 0);
    effect eLink    = SupernaturalEffect(EffectLinkEffects(eDazed, eCursed));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    if(GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_FEAR, oCaster)) {
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSave, spInfo.oTarget);
    } else {
        if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, oCaster)) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_FEAR, oCaster)) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, SupernaturalEffect(EffectDeath()), spInfo.oTarget);
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
