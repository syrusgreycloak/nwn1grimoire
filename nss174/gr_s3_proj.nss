//*:**************************************************************************
//*:*  GR_S3_PROJ.NSS
//*:**************************************************************************
//*:*
//*:* For projectile trap scripts (arrow, bolt, dart, shuriken)
//*:*
//*:**************************************************************************
//:: Created By: Karl Nickels (Syrus Greycloak)
//:: Created On: May 16, 2005
//*:**************************************************************************
//*:* Updated On: December 10, 2007
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

    if(GetObjectType(oCaster)==OBJECT_TYPE_PLACEABLE) {
        spInfo.iCasterLevel = GetReflexSavingThrow(oCaster);
    }

    int     iDieType          = 8;
    int     iNumDice          = 1;
    int     iBonus            = 0;
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

    int     iNumTargets     = 1;
    int     iDamageBonus    = 0;
    int     iAttackBonus    = 0;
    object  oNextTarget;
    int     i;
    int     iMultiplier     = 0;
    int     bDisplayFeedback = FALSE;
    int     iTouchAttackResult;

    switch(spInfo.iSpellID) {
        case 487:  // Trap Arrow
            iDieType = 6;
            iMultiplier = 1;
            break;
        case 488:  // Trap Bolt
            iMultiplier = 2;
            break;
        case 493:  // Trap Dart
        case 494:  // Trap Shuriken
            bDisplayFeedback = TRUE;
            break;
    }

    if(spInfo.iCasterLevel < 4) {
        // no changes
    } else if(spInfo.iCasterLevel < 7) {
        iNumTargets += 1;
        iDamageBonus = 1;
        iAttackBonus = 1;
    } else if(spInfo.iCasterLevel < 11) {
        iNumTargets += 2;
        iDamageBonus = 2;
        iAttackBonus = 2;
    } else if(spInfo.iCasterLevel < 15) {
        iNumTargets += 3;
        iDamageBonus = 3;
        iAttackBonus = 3;
    } else {
        iNumTargets += 4;
        iDamageBonus = 4;
        iAttackBonus = 4;
    }

    if(spInfo.iSpellID!=487) iNumTargets=1;
    iDamageBonus *= iMultiplier;
    iAttackBonus *= iMultiplier;

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
    effect eDamage;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    // Apply the attack bonus if we should have one
    if(iAttackBonus > 0) {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAttackIncrease(iAttackBonus), oCaster, 5.0);
    }

    oNextTarget = spInfo.oTarget;
    for(i=0; i < iNumTargets && GetIsObjectValid(oNextTarget); i++) {
        ActionCastFakeSpellAtObject(spInfo.iSpellID, oNextTarget, PROJECTILE_PATH_TYPE_HOMING);
        iTouchAttackResult = GRTouchAttackRanged(spInfo.oTarget, bDisplayFeedback);
        if(iTouchAttackResult>0) {
            iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, iDamageBonus)*iTouchAttackResult;
            eDamage = EffectDamage(iDamage, DAMAGE_TYPE_PIERCING);
            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDamage, oNextTarget);
        }
        oNextTarget = GetNearestObject(OBJECT_TYPE_CREATURE, spInfo.oTarget, i+1);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
