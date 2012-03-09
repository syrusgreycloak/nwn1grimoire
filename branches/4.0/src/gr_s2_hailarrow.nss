//*:**************************************************************************
//*:*  GR_S2_HAILARROW.NSS
//*:**************************************************************************
//*:* x1_s2_hailarrow
//*:* Copyright (c) 2001 Bioware Corp.
//*:**************************************************************************
/*
    One arrow per arcane archer level at all targets

    GZ SEPTEMBER 2003
        Added damage penetration

*/
//*:**************************************************************************
//*:* Updated On: December 20, 2007
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
void DoAttack(object oTarget) {
    int iBonus = ArcaneArcherCalculateBonus();
    int iDamage;
    // * Roll Touch Attack
    int iTouch = TouchAttackRanged(oTarget, TRUE);
    if(iTouch > 0) {
        iDamage = ArcaneArcherDamageDoneByBow(iTouch==2);
        if(iDamage > 0) {
            // * GZ: Added correct damage power
            effect ePhysical = EffectDamage(iDamage, DAMAGE_TYPE_PIERCING, IPGetDamagePowerConstantFromNumber(iBonus));
            effect eMagic = EffectDamage(iBonus, DAMAGE_TYPE_MAGICAL);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePhysical, oTarget);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eMagic, oTarget);
        }
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

    spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oCaster);

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
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    float   fDist           = 0.0f;
    int     i = 0;

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
    effect eArrow = EffectVisualEffect(357);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    for(i=1; i<=spInfo.iCasterLevel; i++) {
        spInfo.oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, i);
        if(GetIsObjectValid(spInfo.oTarget)) {
            fDist = GetDistanceBetween(OBJECT_SELF, spInfo.oTarget);
            fDelay = fDist/(3.0 * log(fDist) + 2.0);

            SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, 603));
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eArrow, spInfo.oTarget);
            DelayCommand(fDelay, DoAttack(spInfo.oTarget));
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
