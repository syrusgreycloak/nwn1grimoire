//*:**************************************************************************
//*:*  GR_S0_REMEFFECT.NSS
//*:**************************************************************************
//*:*
//*:* Master script for most "Remove ..." spells
//*:* Remove Disease
//*:* Neutralize Poison
//*:* Remove Paralysis
//*:* Remove Curse
//*:* Remove Blindness / Deafness
//*:* Remove Fear
//*:* Created By: Preston Watamaniuk  Created On: Jan 8, 2002
//*:*
//*:* Stone to Flesh
//*:* Created By: Brent  Created On: Oct 16 2002
//*:*
//*:* Aura of Glory
//*:* Created By: Brent Knowles  Created On: July 24, 2002
//*:**************************************************************************
//*:* Freedom
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 11, 2008
//*:* 3.5 Player's Handbook (p. 233)
//*:**************************************************************************
//*:* Updated On: April 11, 2008
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 10;
    int     iDurType          = DUR_TYPE_TURNS;

    int     iEffect1        = EFFECT_TYPE_INVALIDEFFECT;
    int     iEffect2        = EFFECT_TYPE_INVALIDEFFECT;
    int     iEffect3        = EFFECT_TYPE_INVALIDEFFECT;
    /*** NWN1 SINGLE ***/ int     iVisualType     = VFX_IMP_REMOVE_CONDITION;
    //*** NWN2 SINGLE ***/ int     iVisualType      = GRGetSpellSchoolVisual(spInfo.iSpellSchool);

    int     bMultiTarget    = (spInfo.iSpellID==SPELL_REMOVE_FEAR);
    int     iNumCreatures   = 1 + (spInfo.iCasterLevel/4);
    float   fRange          = FeetToMeters(15.0);

    switch(spInfo.iSpellID) {
        case SPELL_REMOVE_BLINDNESS_AND_DEAFNESS:
        case SPELL_GR_REMOVE_BLINDNESS:
            iEffect1 = EFFECT_TYPE_BLINDNESS;
            break;
        case SPELL_GR_REMOVE_DEAFNESS:
            iEffect1 = EFFECT_TYPE_DEAF;
            break;
        case SPELL_REMOVE_CURSE:
            iEffect1 = EFFECT_TYPE_CURSE;
            break;
        case SPELL_REMOVE_DISEASE:
        case SPELLABILITY_REMOVE_DISEASE:
            iEffect1 = EFFECT_TYPE_DISEASE;
            iEffect2 = EFFECT_TYPE_ABILITY_DECREASE;
            break;
        case SPELL_NEUTRALIZE_POISON:
            iEffect1 = EFFECT_TYPE_POISON;
            iDurAmount = spInfo.iCasterLevel*10;
            //*** NWN2 SINGLE ***/ iVisualType = VFX_IMP_HEALING_M;
            break;
        case SPELL_REMOVE_PARALYSIS:
            iEffect1 = EFFECT_TYPE_PARALYZE;
            break;
        case SPELL_AURAOFGLORY:
            iNumCreatures = spInfo.iCasterLevel;
            fRange = FeetToMeters(10.0);
            bMultiTarget = TRUE;
        case SPELL_REMOVE_FEAR:
            iEffect1 = EFFECT_TYPE_FRIGHTENED;
            iDurAmount = 10;
            break;
        case SPELL_STONE_TO_FLESH:
            iEffect1 = EFFECT_TYPE_PETRIFY;
            break;
        case SPELL_GR_FREEDOM:
            iEffect1 = EFFECT_TYPE_MOVEMENT_SPEED_DECREASE;
            iEffect2 = EFFECT_TYPE_PETRIFY;
            iEffect3 = EFFECT_TYPE_ENTANGLE;
            break;
    }

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
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iBonus          = 2;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eMassVis     = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eVis         = EffectVisualEffect(iVisualType);

    effect eFearSave    = EffectSavingThrowIncrease(SAVING_THROW_ALL, iBonus, SAVING_THROW_TYPE_FEAR);
    effect ePoisonImm   = EffectImmunity(IMMUNITY_TYPE_POISON);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink;

    switch(spInfo.iSpellID) {
        case SPELL_REMOVE_FEAR:
            eLink = EffectLinkEffects(eFearSave, eDur);
            break;
        case SPELL_NEUTRALIZE_POISON:
            eLink = EffectLinkEffects(ePoisonImm, eDur);
            break;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eMassVis, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, TRUE)) {

                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                //*:* Remove effects
                effect eAOE;
                if(GRGetHasSpellEffect(SPELL_FEEBLEMIND, spInfo.oTarget) && spInfo.iSpellID==SPELL_REMOVE_CURSE) {
                    eAOE = GetFirstEffect(spInfo.oTarget);
                    int iEffSpellID;
                    while(GetIsEffectValid(eAOE)) {
                        iEffSpellID = GetEffectSpellId(eAOE);
                        if(GetEffectType(eAOE)==EFFECT_TYPE_CURSE && iEffSpellID!=SPELL_FEEBLEMIND) {
                            if(iEffSpellID==SPELL_GR_CONDEMNED) GRSetIsImmuneToMagicalHealing(spInfo.oTarget, FALSE);
                            if(iEffSpellID!=SPELL_GR_GREATER_BESTOW_CURSE ||
                                (iEffSpellID==SPELL_GR_GREATER_BESTOW_CURSE && spInfo.iCasterLevel>=17)) {
                                // Remove curse can only remove Greater Bestow Curse if cast by
                                // a spellcaster of at least 17th level
                                GRRemoveEffect(eAOE, spInfo.oTarget);
                            }
                        }
                        eAOE = GetNextEffect(spInfo.oTarget);
                    }
                } else if(iEffect2!=0) {
                    GRRemoveMultipleEffects(iEffect1, iEffect2, spInfo.oTarget, OBJECT_INVALID, iEffect3);
                    if(spInfo.iSpellID==SPELL_GR_FREEDOM) {
                        GRRemoveMultipleEffects(EFFECT_TYPE_PARALYZE, EFFECT_TYPE_SLOW, spInfo.oTarget, OBJECT_INVALID, EFFECT_TYPE_SLEEP);
                        GRRemoveEffects(EFFECT_TYPE_STUNNED, spInfo.oTarget);
                    }
                } else {
                    if(spInfo.iSpellID!=SPELL_STONE_TO_FLESH || GetLocalInt(spInfo.oTarget, "NW_STATUE")!=1) {
                        GRRemoveEffects(iEffect1, spInfo.oTarget);
                    }
                }

                switch(spInfo.iSpellID) {
                    case SPELL_REMOVE_DISEASE:
                        GRRemoveSpellEffects(SPELL_INFESTATION_OF_MAGGOTS, spInfo.oTarget);
                        break;
                    case SPELL_REMOVE_CURSE:
                        GRRemoveMultipleSpellEffects(SPELL_CURSE_OF_BLADES, SPELL_GREATER_CURSE_OF_BLADES, spInfo.oTarget));
                    case SPELL_GR_FREEDOM:
                    case SPELL_REMOVE_PARALYSIS:
                        GRRemoveSpellEffects(SPELL_GR_TOUCH_OF_VECNA, spInfo.oTarget, OBJECT_INVALID, FALSE);
                        break;
                    case SPELL_REMOVE_FEAR:
                        iNumCreatures--;
                    case SPELL_NEUTRALIZE_POISON:
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                        break;
                    case SPELL_AURAOFGLORY:
                        iNumCreatures--;
                        break;
                }
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
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
