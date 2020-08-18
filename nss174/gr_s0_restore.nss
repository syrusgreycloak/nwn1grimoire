//*:**************************************************************************
//*:*  GR_S0_RESTORE.NSS
//*:**************************************************************************
//*:* Lesser Restoration (NW_S0_LsRestor.nss) Copyright (c) 2001 Bioware Corp.
//*:* Restoration (NW_S0_Restore.nss) Copyright (c) 2001 Bioware Corp.
//*:* Greater Restoration (NW_S0_GrRestore.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 272)
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 7, 2002
//*:**************************************************************************
//*:* Restoration Others (x2_s0_restother.nss) Copyright (c) 2001 Bioware Corp.
//*:**************************************************************************
//*:* Created By: Keith Warner
//*:* Created On: Jan 3/03
//*:**************************************************************************
//*:*
//*:* Mass Restoration - Spell Compendium (p. 174)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 16, 2007
//*:**************************************************************************
//*:* Updated On: October 25, 2007
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
int GetIsSupernaturalCurse(effect eEff) {
    object oCreator = GetEffectCreator(eEff);
    if(GetTag(oCreator) == "q6e_ShaorisFellTemple")
        return TRUE;
    return FALSE;
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

    int     iVisualType     = VFX_IMP_RESTORATION_LESSER;

    int     bMultiTarget    = (spInfo.iSpellID==SPELL_GR_MASS_RESTORATION);
    int     iNumAffected    = spInfo.iCasterLevel;

    int     iSignalSpellID  = spInfo.iSpellID;

    switch(spInfo.iSpellID) {
        case SPELL_GR_MASS_RESTORATION:
            iVisualType = VFX_IMP_RESTORATION;
            break;
        case 568:  // Restoration others
            iSignalSpellID = SPELL_RESTORATION;
        case SPELL_RESTORATION:
            iVisualType = VFX_IMP_RESTORATION;
            break;
        case SPELL_GREATER_RESTORATION:
            iVisualType = VFX_IMP_RESTORATION_GREATER;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eImpact = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eVisual = EffectVisualEffect(iVisualType);
    effect eBad;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, iSignalSpellID, FALSE));

                eBad = GetFirstEffect(spInfo.oTarget);

                while(GetIsEffectValid(eBad)) {
                    int iEffectSpellID = GetEffectSpellId(eBad);
                    //*:* Certain "good" spells have minor penalties.  Do not remove these
                    if(iEffectSpellID != SPELL_ENLARGE_PERSON &&
                        iEffectSpellID != SPELL_IRON_BODY &&
                        iEffectSpellID != SPELL_RIGHTEOUS_MIGHT
                        /*** NWN2 SPECIFIC ***
                            && iEffectSpellID != SPELL_STONE_BODY &&
                            iEffectSpellID != 803
                        /*** END NWN2 SPECIFIC ***/
                        ) {

                        if(spInfo.iSpellID!=568) {
                            if(GetEffectType(eBad)==EFFECT_TYPE_ABILITY_DECREASE) {
                                if(GetEffectSubType(eBad)==SUBTYPE_MAGICAL && GetEffectDurationType(eBad)==DURATION_TYPE_TEMPORARY) {
                                    if(!GetIsSupernaturalCurse(eBad)) {
                                        GRRemoveEffect(eBad, spInfo.oTarget);
                                    }
                                } else if(spInfo.iSpellID!=SPELL_LESSER_RESTORATION && GetEffectSubType(eBad)==SUBTYPE_MAGICAL &&
                                    GetEffectDurationType(eBad)==DURATION_TYPE_PERMANENT) {
                                    if(!GetIsSupernaturalCurse(eBad)) {
                                        GRRemoveEffect(eBad, spInfo.oTarget);
                                    }
                                }
                            } else if(GetEffectType(eBad)==EFFECT_TYPE_NEGATIVELEVEL && spInfo.iSpellID!=SPELL_LESSER_RESTORATION) {
                                if(!GetIsSupernaturalCurse(eBad)) {
                                    GRRemoveEffect(eBad, spInfo.oTarget);
                                }
                            } else if(spInfo.iSpellID==SPELL_GREATER_RESTORATION) {
                                switch(GetEffectType(eBad)) {
                                    case EFFECT_TYPE_BLINDNESS:
                                    case EFFECT_TYPE_DEAF:
                                    case EFFECT_TYPE_CHARMED:
                                    case EFFECT_TYPE_DOMINATED:
                                    case EFFECT_TYPE_DAZED:
                                    case EFFECT_TYPE_CONFUSED:
                                    case EFFECT_TYPE_FRIGHTENED:
                                    case EFFECT_TYPE_STUNNED:
                                        if(!GetIsSupernaturalCurse(eBad)) {
                                            GRRemoveEffect(eBad, spInfo.oTarget);
                                        }
                                        break;
                                }
                            }
                        } else {        // Restoration: Others
                            switch(GetEffectType(eBad)) {
                                case EFFECT_TYPE_ABILITY_DECREASE:
                                case EFFECT_TYPE_AC_DECREASE:
                                case EFFECT_TYPE_ATTACK_DECREASE:
                                case EFFECT_TYPE_DAMAGE_DECREASE:
                                case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
                                case EFFECT_TYPE_SAVING_THROW_DECREASE:
                                case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
                                case EFFECT_TYPE_SKILL_DECREASE:
                                case EFFECT_TYPE_BLINDNESS:
                                case EFFECT_TYPE_DEAF:
                                case EFFECT_TYPE_PARALYZE:
                                case EFFECT_TYPE_NEGATIVELEVEL:
                                    GRRemoveEffect(eBad, spInfo.oTarget);
                                    break;
                            }
                        }
                    }
                    eBad = GetNextEffect(spInfo.oTarget);
                }
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spInfo.oTarget);
                iNumAffected--;
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumAffected>0);
    }

    if(GetSpellCastItem()!=oCaster) {
        if(spInfo.iSpellID==568) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(5), oCaster);
        }
        if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    }

    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
