//*:**************************************************************************
//*:*  GR_S1_HURLROCK.NSS
//*:**************************************************************************
//*:* Name x2_s1_hurlrock  Copyright (c) 2001 Bioware Corp.
//*:* Created By: Keith Warner, Georg Zoeller  Created On: Sept 9/10
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
//*:* Supporting functions
//*:**************************************************************************
void RockDamage(location lImpact) {

    float fDelay;
    int iDamage;
    effect eDam;

    object oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lImpact, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    //Cycle through the targets within the spell shape until an invalid object is captured.

    int iDC;

    int bShifter = (GRGetLevelByClass(CLASS_TYPE_SHIFTER,OBJECT_SELF)>10);

    if(bShifter) {
        iDC = ShifterGetSaveDC(OBJECT_SELF,SHIFTER_DC_NORMAL);
    } else {
        iDC = GRGetSpellSaveDC(OBJECT_SELF, oTarget);
    }

    int iNumDice = MaxInt(1, GetHitDice(OBJECT_SELF)/5);

    int iDamageAdjustment = GetAbilityModifier(ABILITY_STRENGTH, OBJECT_SELF);

    while(GetIsObjectValid(oTarget)) {
        if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF)) {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
            fDelay = GetDistanceBetweenLocations(lImpact, GetLocation(oTarget))/20;
            iDamage = d6(iNumDice) + iDamageAdjustment;
            iDamage = GRGetReflexAdjustedDamage(iDamage, oTarget, iDC, SAVING_THROW_TYPE_NONE);
            eDam = EffectDamage(iDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_PLUS_ONE);
            if(iDamage > 0) {
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
            }
        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lImpact, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
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

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    //GRSetSpellInfo(spInfo, oCaster);

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
    effect eImpact = EffectVisualEffect(354);
    effect eImpac1 = EffectVisualEffect(460);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
    DelayCommand(0.2f, GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpac1, spInfo.lTarget));
    RockDamage(spInfo.lTarget);

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    //GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
