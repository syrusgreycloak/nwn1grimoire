//*:**************************************************************************
//*:*  GR_S0_ANIGROWTH.NSS
//*:**************************************************************************
//*:* Animal Growth
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 28, 2004
//*:* 3.5 Player's Handbook (p. 198)
//*:**************************************************************************
//*:* Updated On: February 28, 2008
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

#include "GR_IN_DEBUG"

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
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_TURNS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(15.0);

    int     iNumCreatures   = MaxInt(1, spInfo.iCasterLevel/2);
    int     iNumAffected    = 0;
    int     iCreatureSize   = 0;    // GetCreatureSize(spInfo.oTarget)
    int     iHitDice        = 0;    // GetHitDice(spInfo.oTarget)
    int     iHitPoints      = 0;    // GetMaxHitPoints(spInfo.oTarget)
    int     iStrIncrease    = 8;
    int     iDexDecrease    = 2;
    int     iConIncrease    = 4;
    int     iBABIncrease    = 0;    // =HD * 3/4
    int     iAttackInc      = 0;    // depends upon size
    int     iDmgInc         = 0;    // depends upon size
    int     iACInc          = 0;    // depends upon size
    int     iNatACBonus     = 2;
    int     iCount          = 1;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    AutoDebugString("Declaring Effects");
    effect eImpVis              = EffectVisualEffect(VFX_IMP_GOOD_HELP);  // Visible impact effect
    effect eHPIncrease;
    effect eStrIncrease;
    effect eDexDecrease;
    effect eConIncrease;
    effect eAttackIncrease;
    effect eDamageIncrease;
    effect eACIncrease;
    effect eRefSaveIncrease     = EffectSavingThrowIncrease(SAVING_THROW_REFLEX,1);
    effect eFortSaveIncrease    = EffectSavingThrowIncrease(SAVING_THROW_FORT,1);
    effect eNatACBonus          = EffectACIncrease(iNatACBonus, AC_NATURAL_BONUS);
    effect eLink                = EffectLinkEffects(eRefSaveIncrease, eFortSaveIncrease);

    eLink = EffectLinkEffects(eLink, eNatACBonus);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    AutoDebugString("Applying Effects");
    spInfo.oTarget = GetNearestCreatureToLocation(CREATURE_TYPE_IS_ALIVE, TRUE, spInfo.lTarget, iCount);
    AutoDebugString("Target is " + GetName(spInfo.oTarget));

    AutoDebugString("Number of creatures to affect = " + IntToString(iNumCreatures));
    while(GetIsObjectValid(spInfo.oTarget) && iNumAffected<=iNumCreatures &&
        GetDistanceBetweenLocations(spInfo.lTarget,GetLocation(spInfo.oTarget))<=fRange) {

            AutoDebugString("Is spell target = " + GRBooleanToString(!GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster)));
            AutoDebugString("Racial type is Animal = " + GRBooleanToString(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ANIMAL));

            if(!GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster) &&
                GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ANIMAL) {

                iCreatureSize = GetCreatureSize(spInfo.oTarget);
                AutoDebugString("Checking creature size");
                switch(iCreatureSize) {
                    case CREATURE_SIZE_TINY:
                        iAttackInc  = 1;
                        iDmgInc     = DAMAGE_BONUS_1;
                        break;
                    case CREATURE_SIZE_SMALL:
                        iAttackInc  = 1;
                        iDmgInc     = DAMAGE_BONUS_1;
                        break;
                    case CREATURE_SIZE_MEDIUM:
                        iAttackInc  = 1;
                        iDmgInc     = DAMAGE_BONUS_1;
                        iACInc      = 2;
                        break;
                    case CREATURE_SIZE_LARGE:
                        iACInc      = 3;
                        iAttackInc  = 1;
                        iDmgInc     = DAMAGE_BONUS_1;
                        break;
                    case CREATURE_SIZE_HUGE:
                        iACInc      = 4;
                        iAttackInc  = 2;
                        iDmgInc     = DAMAGE_BONUS_2;
                        break;
                }
                iHitDice    = GetHitDice(spInfo.oTarget);
                iHitPoints  = GetMaxHitPoints(spInfo.oTarget);
                iBABIncrease= iHitDice*3/4;
                iAttackInc  += iBABIncrease;

                AutoDebugString("Building linked effects");
                eHPIncrease = EffectTemporaryHitpoints(iHitPoints);
                eStrIncrease = EffectAbilityIncrease(ABILITY_STRENGTH, iStrIncrease);
                eDexDecrease = EffectAbilityDecrease(ABILITY_DEXTERITY, iDexDecrease);
                eConIncrease = EffectAbilityIncrease(ABILITY_CONSTITUTION, iConIncrease);
                eAttackIncrease = EffectAttackIncrease(iAttackInc);
                eDamageIncrease = EffectDamageIncrease(iDmgInc);
                eACIncrease = EffectACIncrease(iACInc);
                eLink = EffectLinkEffects(eLink, eHPIncrease);
                eLink = EffectLinkEffects(eLink, eStrIncrease);
                eLink = EffectLinkEffects(eLink, eDexDecrease);
                eLink = EffectLinkEffects(eLink, eConIncrease);
                eLink = EffectLinkEffects(eLink, eAttackIncrease);
                eLink = EffectLinkEffects(eLink, eDamageIncrease);
                if(iACInc>0)
                    eLink = EffectLinkEffects(eLink, eACIncrease);

                SignalEvent(spInfo.oTarget,EventSpellCastAt(oCaster, SPELL_GR_ANIMAL_GROWTH, FALSE));
                //*:**********************************************
                //*:* Remove size enlargement spells
                //*:**********************************************
                AutoDebugString("Calling GRRemoveMultipleSpellEffects");
                GRRemoveMultipleSpellEffects(SPELL_GR_ANIMAL_GROWTH, SPELL_ENLARGE_PERSON, spInfo.oTarget, TRUE, SPELL_GR_MASS_ENLARGE, SPELL_GR_GREATER_ENLARGE);

                AutoDebugString("Applying spell effects now....");
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                iNumAffected++;
                AutoDebugString("Number of creatures affected = " + IntToString(iNumAffected));
            }
            iCount++;
            AutoDebugString("Getting next creature");
            spInfo.oTarget = GetNearestCreatureToLocation(CREATURE_TYPE_IS_ALIVE, TRUE, spInfo.lTarget, iCount);
            AutoDebugString("Target is " + GetName(spInfo.oTarget));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
