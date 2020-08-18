//*:**************************************************************************
//*:*  GR_S0_ABILSPELL.NSS
//*:**************************************************************************
//*:* Combination script for all the spells that do ability increases
//*:**************************************************************************
//*:* Script for ability enhancing spells:
//*:* Bulls Strength/Cats Grace/Foxs Cunning/Owls Wisdom/
//*:* Eagle's Splendor/Bear's Endurance
//*:* also Greater versions
//*:* also Mass versions
//*:*
//*:* Owl's Insight
//*:* Splendor Of Eagles (Charm Domain Granted Power)
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2005
//*:**************************************************************************
//*:* Strength of Stone
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: September 29, 2004
//*:* Spell Compendium (p. 211)
//*:**************************************************************************
//*:* Updated On: March 6, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
#include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
int PreventStacking(int iSpellID, object oTarget) {

    int iResult = FALSE;

    switch(iSpellID) {
        //*:*  Bull's Strength
        case SPELL_GREATER_BULLS_STRENGTH:
        case SPELL_GR_STRENGTH_OF_STONE:
            GRRemoveMultipleSpellEffects(SPELL_GREATER_BULLS_STRENGTH, SPELL_GR_STRENGTH_OF_STONE, oTarget, TRUE, SPELL_MASS_BULL_STRENGTH,
                SPELL_BULLS_STRENGTH);
            GRRemoveSpellEffects(614, oTarget);
            break;
        case SPELL_MASS_BULL_STRENGTH:
        case SPELL_BULLS_STRENGTH:
        case 614:
            if(GetHasSpellEffect(SPELL_GREATER_BULLS_STRENGTH, oTarget) || GetHasSpellEffect(SPELL_GR_STRENGTH_OF_STONE, oTarget)) {
                iResult = TRUE;
            } else {
                GRRemoveMultipleSpellEffects(SPELL_MASS_BULL_STRENGTH, SPELL_BULLS_STRENGTH, oTarget, TRUE, 614);
            }
            break;
        //*:*  Cat's Grace
        case SPELL_GREATER_CATS_GRACE:
            GRRemoveMultipleSpellEffects(SPELL_GREATER_CATS_GRACE, SPELL_MASS_CAT_GRACE, oTarget, TRUE, SPELL_CATS_GRACE, 481);
            break;
        case SPELL_CATS_GRACE:
        case 481:
        case SPELL_MASS_CAT_GRACE:
            if(GetHasSpellEffect(SPELL_GREATER_CATS_GRACE, oTarget)) {
                iResult = TRUE;
            } else {
                GRRemoveMultipleSpellEffects(SPELL_MASS_CAT_GRACE, SPELL_CATS_GRACE, oTarget, TRUE, 481);
            }
            break;
        //*:*  Bear's Endurance
        case SPELL_GREATER_BEARS_ENDURANCE:
            GRRemoveMultipleSpellEffects(SPELL_GREATER_BEARS_ENDURANCE, SPELL_MASS_BEAR_ENDURANCE, oTarget, TRUE, SPELL_BEARS_ENDURANCE);
            break;
        case SPELL_BEARS_ENDURANCE:
        case SPELL_MASS_BEAR_ENDURANCE:
            if(GetHasSpellEffect(SPELL_GREATER_BEARS_ENDURANCE, oTarget)) {
                iResult = TRUE;
            } else {
                GRRemoveMultipleSpellEffects(SPELL_MASS_BEAR_ENDURANCE, SPELL_BEARS_ENDURANCE, oTarget);
            }
            break;
        //*:*  Fox's Cunning
        case SPELL_GREATER_FOXS_CUNNING:
            GRRemoveMultipleSpellEffects(SPELL_GREATER_FOXS_CUNNING, SPELL_MASS_FOX_CUNNING, oTarget, TRUE, SPELL_FOXS_CUNNING);
            break;
        case SPELL_FOXS_CUNNING:
        case SPELL_MASS_FOX_CUNNING:
            if(GetHasSpellEffect(SPELL_GREATER_FOXS_CUNNING, oTarget)) {
                iResult = TRUE;
            } else {
                GRRemoveMultipleSpellEffects(SPELL_MASS_FOX_CUNNING, SPELL_FOXS_CUNNING, oTarget);
            }
            break;
        //*:* Owl's Wisdom
        case SPELL_OWLS_INSIGHT:
            GRRemoveMultipleSpellEffects(SPELL_OWLS_INSIGHT, SPELL_GREATER_OWLS_WISDOM, oTarget, TRUE, SPELL_MASS_OWL_WISDOM, SPELL_OWLS_WISDOM);
            break;
        case SPELL_GREATER_OWLS_WISDOM:
            if(GetHasSpellEffect(SPELL_OWLS_INSIGHT, oTarget)) {
                iResult = TRUE;
            } else {
                GRRemoveMultipleSpellEffects(SPELL_GREATER_OWLS_WISDOM, SPELL_MASS_OWL_WISDOM, oTarget, TRUE, SPELL_OWLS_WISDOM);
            }
            break;
        case SPELL_OWLS_WISDOM:
        case SPELL_MASS_OWL_WISDOM:
            if(GetHasSpellEffect(SPELL_OWLS_INSIGHT, oTarget) || GetHasSpellEffect(SPELL_GREATER_OWLS_WISDOM, oTarget)) {
                iResult = TRUE;
            } else {
                GRRemoveMultipleSpellEffects(SPELL_MASS_OWL_WISDOM, SPELL_OWLS_WISDOM, oTarget);
            }
            break;
        //*:* Eagle's Splendor
        case SPELL_GREATER_EAGLE_SPLENDOR:
            GRRemoveMultipleSpellEffects(SPELL_GREATER_EAGLE_SPLENDOR, SPELL_MASS_EAGLE_SPLENDOR, oTarget, TRUE, SPELL_EAGLES_SPLENDOR,
                SPELLABILITY_GR_SPLENDOR_OF_EAGLES);
            GRRemoveSpellEffects(482, oTarget);
            break;
        case SPELL_EAGLES_SPLENDOR:
        case SPELL_MASS_EAGLE_SPLENDOR:
        case SPELLABILITY_GR_SPLENDOR_OF_EAGLES:
        case 482:
            if(GetHasSpellEffect(SPELL_GREATER_EAGLE_SPLENDOR, oTarget)) {
                iResult = TRUE;
            } else {
                GRRemoveMultipleSpellEffects(482, SPELL_MASS_EAGLE_SPLENDOR, oTarget, TRUE, SPELL_EAGLES_SPLENDOR,
                    SPELLABILITY_GR_SPLENDOR_OF_EAGLES);
            }
            break;
    }

    return iResult;
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
    int     iBonus          = 4;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;
    float   fDurOverride      = 0.0f;

    if(spInfo.iSpellID==SPELL_OWLS_INSIGHT) {
        iDurAmount = 1;
        iDurType = DUR_TYPE_HOURS;
    } else if(spInfo.iSpellID==SPELLABILITY_GR_SPLENDOR_OF_EAGLES) {
        iDurAmount = 1;
        iDurType = DUR_TYPE_TURNS;
    } else if(spInfo.iSpellID==SPELL_GR_STRENGTH_OF_STONE) {
        iDurAmount = 2;
        fDurOverride = 9.0f;
    }

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType, fDurOverride);

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
    float   fRange          = FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iAbilityType;
    int     bMultiTarget    = (spInfo.iSpellID>=SPELL_MASS_BEAR_ENDURANCE && spInfo.iSpellID<=SPELL_MASS_FOX_CUNNING);
    int     iNumCreatures   = spInfo.iCasterLevel;
    int     iIncrease;
    int     iDurVisType;
    /*** NWN1 SINGLE ***/ iDurVisType = VFX_DUR_CESSATE_POSITIVE;

    //*:**********************************************
    //*:* Determine which spell was cast and adjust
    //*:**********************************************
    switch(spInfo.iSpellID) {
        //*:*  Bull's Strength
        case SPELL_GREATER_BULLS_STRENGTH:
        case SPELL_GR_STRENGTH_OF_STONE:
            iBonus = 8;
        case SPELL_BULLS_STRENGTH:
        case 614:
        case SPELL_MASS_BULL_STRENGTH:
            iAbilityType = ABILITY_STRENGTH;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_BULL_STRENGTH;
            break;
        //*:*  Cat's Grace
        case SPELL_GREATER_CATS_GRACE:
            iBonus = 8;
        case SPELL_CATS_GRACE:
        case 481:
        case SPELL_MASS_CAT_GRACE:
            iAbilityType = ABILITY_DEXTERITY;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_CAT_GRACE;
            break;
        //*:*  Bear's Endurance
        case SPELL_GREATER_BEARS_ENDURANCE:
            iBonus = 8;
        case SPELL_BEARS_ENDURANCE:
        case SPELL_MASS_BEAR_ENDURANCE:
            iAbilityType = ABILITY_CONSTITUTION;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_BEAR_ENDURANCE;
            break;
        //*:*  Fox's Cunning
        case SPELL_GREATER_FOXS_CUNNING:
            iBonus = 8;
        case SPELL_FOXS_CUNNING:
        case SPELL_MASS_FOX_CUNNING:
            iAbilityType = ABILITY_INTELLIGENCE;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_FOX_CUNNING;
            break;
        //*:* Owl's Wisdom
        case SPELL_GREATER_OWLS_WISDOM:
            iBonus = 8;
        case SPELL_OWLS_WISDOM:
        case SPELL_MASS_OWL_WISDOM:
            iAbilityType = ABILITY_WISDOM;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_OWL_WISDOM;
            break;
        //*:* Eagle's Splendor
        case SPELL_GREATER_EAGLE_SPLENDOR:
            iBonus = 8;
        case SPELL_EAGLES_SPLENDOR:
        case SPELL_MASS_EAGLE_SPLENDOR:
        case SPELLABILITY_GR_SPLENDOR_OF_EAGLES:
        case 482:
            iAbilityType = ABILITY_CHARISMA;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_EAGLE_SPLENDOR;
            break;
        //*:* Owl's Insight (Drd 5)
        case SPELL_OWLS_INSIGHT:
            iAbilityType = ABILITY_WISDOM;
            iBonus = spInfo.iCasterLevel/2;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_OWL_INSIGHT;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration       = ApplyMetamagicDurationMods(fDuration);
        iDurationType   = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    //*:* iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eAbilInc = EffectAbilityIncrease(iAbilityType, iBonus);
    /*** NWN1 SINGLE ***/ effect eVis     = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    effect eDur     = EffectVisualEffect(iDurVisType);
    effect eLink    = EffectLinkEffects(eAbilInc, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, TRUE)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                if(!PreventStacking(spInfo.iSpellID, spInfo.oTarget)) {
                    GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
                    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                }
                iNumCreatures--;
            }

            if(bMultiTarget)
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumCreatures>0);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
