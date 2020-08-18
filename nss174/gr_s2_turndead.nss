//*:**************************************************************************
//*:*  GR_S2_TURNDEAD.NSS
//*:**************************************************************************
//*:* Turning Power Script (Undead, etc)
//*:* Edited version of Bioware's script  Copyright Bioware
//*:* Edited By: Karl Nickels (Syrus Greycloak)  Edited On: April 20, 2004
//*:**************************************************************************
//*:* Now includes Rebuke/Command instead of Turn/Destroy for evil clerics and
//*:* neutral clerics with evil deities
//*:*
//*:* Dispel Turning Power
//*:* Bolster Undead Power
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: November 13, 2007
//*:**************************************************************************
//*:* Updated On: November 13, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"       - INCLUDED IN GR_IN_TURNING
#include "GR_IN_SPELLHOOK"
#include "GR_IN_TURNING"
#include "GR_IN_ARRLIST"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************


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
    int     iDurAmount        = 1;
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
    float   fDelay;
    float   fRange          = FeetToMeters(60.0);
    int     bRebuke         = GRGetRebukesUndead(oCaster);
    int     bBolsterDispel  = (spInfo.iSpellID==SPELLABILITY_GR_DISPEL_TURNING || spInfo.iSpellID==SPELLABILITY_GR_BOLSTER_UNDEAD) && bRebuke;
    int     bCanUsePower    = TRUE;

    GRSetBaseTurningInfo(oCaster);

    int     iTurningLevel   = GetLocalInt(oCaster, "GR_L_TURN_LEVEL");
    int     iTurnMaxHD      = GetLocalInt(oCaster, "GR_L_TURN_MAX_HD");
    int     iTurnHD         = GetLocalInt(oCaster, "GR_L_TURN_NUM_HD");
    int     iTurnCheck      = GetLocalInt(oCaster, "GR_L_TURN_CHECK");

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
    effect eVis     = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eVisTurn = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eNegVis  = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);

    effect eTurned  = EffectTurned();
    effect eCower   = EffectDazed();
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eCommand = EffectCutsceneDominated();
    effect eDeath   = SupernaturalEffect(EffectDeath(TRUE));

    effect eImpactVis = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));

    effect eTurnLink = EffectLinkEffects(eVisTurn, eTurned);
    eTurnLink = SupernaturalEffect(EffectLinkEffects(eTurnLink, eDur));

    effect eRebukeLink = EffectLinkEffects(eVisTurn, eCower);
    eRebukeLink = SupernaturalEffect(EffectLinkEffects(eRebukeLink, eDur));

    effect eFind;

    //*:**********************************************
    //*:* Check if able to use power
    //*:**********************************************
    if(spInfo.iSpellID!=SPELLABILITY_TURN_UNDEAD) {
        //*:* all other powers require a use of turn undead
        if(!GetHasFeat(FEAT_TURN_UNDEAD)) {
            if(GetIsPC(oCaster)) {
                SendMessageToPC(oCaster, GetStringByStrRef(16939271));
            }
            return;     //bCanUsePower = FALSE;
        }
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpactVis, spInfo.lTarget);

    if(iTurnMaxHD>0 && bCanUsePower) {  // check if turning anything at all - otherwise skip loop

        //*:**********************************************
        //*:* Loop is supposed to affect nearest creatures first
        //*:* must build list first
        //*:**********************************************
        GRCreateArrayList(ARR_TURN, HITDICE, VALUE_TYPE_INT, oCaster, DISTANCE, VALUE_TYPE_FLOAT, CREATURE, VALUE_TYPE_OBJECT);

        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);

        while(GetIsObjectValid(spInfo.oTarget)) {
            if(!bBolsterDispel) {
                if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER) &&
                    GRGetIsValidTurnRebukeTarget(spInfo.oTarget, iTurnMaxHD, oCaster) &&
                    !GetHasSpellEffect(SPELLABILITY_TURN_UNDEAD, spInfo.oTarget)) {

                    GRObjectAdd(ARR_TURN, CREATURE, spInfo.oTarget);
                    GRFloatAdd(ARR_TURN, DISTANCE, GetDistanceBetween(oCaster, spInfo.oTarget));
                    GRIntAdd(ARR_TURN, HITDICE, GetLocalInt(spInfo.oTarget, "TURN_HD"));
                }
            } else {
                if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
                    GRObjectAdd(ARR_TURN, CREATURE, spInfo.oTarget);
                    GRFloatAdd(ARR_TURN, DISTANCE, GetDistanceBetween(oCaster, spInfo.oTarget));
                    GRIntAdd(ARR_TURN, HITDICE, GetLocalInt(spInfo.oTarget, "TURN_HD"));
                }
            }
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
        }
        //*:**********************************************
        //*:* If we affected any creatures, sort list and
        //*:* apply effects
        //*:**********************************************
        if(GRGetDimSize(ARR_TURN, CREATURE)>0) {
            int i, j;
            float fDist;
            object oCreature;

            //*:* Sort
            GRQuickSort(ARR_TURN, DISTANCE, 1, GRGetDimSize(ARR_TURN, DISTANCE), oCaster);

            //*:* Apply Effects
            for(i=1; i<=GRGetDimSize(ARR_TURN, CREATURE); i++) {
                spInfo.oTarget = GRObjectGetValueAt(ARR_TURN, CREATURE, i);
                int iHD = GRIntGetValueAt(ARR_TURN, HITDICE, i);
                bRebuke = GRGetRebukesUndead(oCaster); // just in case value changed due to elemental/vermin/outsider

                if(iHD<=iTurnHD) {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                    fDelay = GRFloatGetValueAt(ARR_TURN, DISTANCE, i)/20.0;

                    if(!bBolsterDispel) {
                        //*:* Figure out rebuke/turn for elementals
                        if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ELEMENTAL) {
                            int bEarthType = FindSubString(GetStringLowerCase(GetResRef(spInfo.oTarget)),"ear")>=0;
                            int bAirType = FindSubString(GetStringLowerCase(GetResRef(spInfo.oTarget)),"air")>=0;
                            int bWaterType = FindSubString(GetStringLowerCase(GetResRef(spInfo.oTarget)),"wat")>=0;
                            int bFireType = FindSubString(GetStringLowerCase(GetResRef(spInfo.oTarget)),"fir")>=0;

                            bRebuke = (GRGetHasDomain(DOMAIN_AIR) && bAirType) || (GRGetHasDomain(DOMAIN_EARTH) && bEarthType) ||
                                        (GRGetHasDomain(DOMAIN_FIRE) && bFireType) || (GRGetHasDomain(DOMAIN_WATER) && bWaterType);

                        //*:* Figure out rebuke/turn for vermin (plant domain)
                        } else if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_VERMIN && GRGetHasDomain(DOMAIN_PLANT)) {
                            bRebuke = TRUE;
                        }

                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));

                        if(iHD*2<iTurningLevel || (GRGetHasDomain(DOMAIN_SUN) && spInfo.iSpellID==SPELLABILITY_GR_GREATER_TURNING
                            && GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD)) {
                            //*:* Destroy/command object
                            if(GetHasFeat(854) && GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_OUTSIDER) {
                                effect ePlane2 = EffectVisualEffect(VFX_IMP_UNSUMMON);
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePlane2, spInfo.oTarget));
                                if((!bRebuke && GetAlignmentGoodEvil(spInfo.oTarget)==ALIGNMENT_EVIL) ||
                                    (bRebuke && GetAlignmentGoodEvil(spInfo.oTarget)!=ALIGNMENT_EVIL)) {
                                    DelayCommand(fDelay+0.1f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                                } else {
                                    DelayCommand(fDelay+0.1f, GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eCommand, spInfo.oTarget));
                                }
                            } else if(!bRebuke) {
                                DelayCommand(fDelay+0.1f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                            } else {
                                DelayCommand(fDelay+0.1f, GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eCommand, spInfo.oTarget));
                            }
                        } else {
                            //*:* Turn/rebuke object
                            if(GetHasFeat(854) && GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_OUTSIDER) {
                                effect ePlane = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_HOLY);
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePlane, spInfo.oTarget));
                                if((!bRebuke && GetAlignmentGoodEvil(spInfo.oTarget)==ALIGNMENT_EVIL) ||
                                    (bRebuke && GetAlignmentGoodEvil(spInfo.oTarget)!=ALIGNMENT_EVIL)) {
                                    AssignCommand(spInfo.oTarget, ActionMoveAwayFromObject(oCaster, TRUE));
                                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTurnLink, spInfo.oTarget, fDuration));
                                    SetLocalInt(spInfo.oTarget, "GR_TURNING_CHECK_VALUE", iTurnCheck); //*:* Need this for dispel turning attempts
                                } else {
                                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRebukeLink, spInfo.oTarget, fDuration));
                                }
                            } else if(!bRebuke) {
                                AssignCommand(spInfo.oTarget, ActionMoveAwayFromObject(oCaster, TRUE));
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTurnLink, spInfo.oTarget, fDuration));
                                SetLocalInt(spInfo.oTarget, "GR_TURNING_CHECK_VALUE", iTurnCheck); //*:* Need this for dispel turning attempts
                            } else {
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRebukeLink, spInfo.oTarget, fDuration));
                            }
                        }
                        iTurnHD -= iHD;
                    } else {
                        if(spInfo.iSpellID==SPELLABILITY_GR_DISPEL_TURNING) {
                            if(GetHasEffect(EFFECT_TYPE_TURNED, spInfo.oTarget)) {
                                if(iTurnCheck >= GetLocalInt(spInfo.oTarget, "GR_TURNING_CHECK_VALUE")) {
                                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eNegVis, spInfo.oTarget));
                                    DelayCommand(fDelay, GRRemoveSpellEffects(SPELLABILITY_TURN_UNDEAD, spInfo.oTarget));
                                    iTurnHD -= iHD;
                                }
                            }
                        } else {
                            effect eTurnIncrease;
                            if(iHD<iTurnMaxHD) {
                                eTurnIncrease = EffectTurnResistanceIncrease(iTurnMaxHD-iHD);
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eNegVis, spInfo.oTarget));
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTurnIncrease, spInfo.oTarget, fDuration));
                            }
                        }
                    }
                }
            }
            //*:* Delete list
            GRDeleteArrayList(ARR_TURN);
        }
    }

    //*:* Check/set remaining uses of Greater Turning for Sun Domain
    //*:* Check/set remaining uses of Bolster/Dispel Turning
    switch(spInfo.iSpellID) {
        case SPELLABILITY_GR_GREATER_TURNING:
            DecrementRemainingFeatUses(oCaster, FEAT_TURN_UNDEAD);
        case SPELLABILITY_TURN_UNDEAD:
            DecrementRemainingFeatUses(oCaster, FEAT_GR_DISPEL_TURNING);
            DecrementRemainingFeatUses(oCaster, FEAT_GR_BOLSTER_UNDEAD);
            break;
        case SPELLABILITY_GR_DISPEL_TURNING:
            DecrementRemainingFeatUses(oCaster, FEAT_TURN_UNDEAD);
            DecrementRemainingFeatUses(oCaster, FEAT_GR_BOLSTER_UNDEAD);
            break;
        case SPELLABILITY_GR_BOLSTER_UNDEAD:
            DecrementRemainingFeatUses(oCaster, FEAT_TURN_UNDEAD);
            DecrementRemainingFeatUses(oCaster, FEAT_GR_DISPEL_TURNING);
            break;
    }

    if(!GetHasFeat(FEAT_TURN_UNDEAD)) {
        if(GetHasFeat(FEAT_GR_GREATER_TURNING)) {
            DecrementRemainingFeatUses(oCaster, FEAT_GR_GREATER_TURNING);
        }
        if(GetHasFeat(FEAT_GR_DISPEL_TURNING)) {
            while(GetHasFeat(FEAT_GR_DISPEL_TURNING)) {
                DecrementRemainingFeatUses(oCaster, FEAT_GR_DISPEL_TURNING);
            }
        }
        if(GetHasFeat(FEAT_GR_BOLSTER_UNDEAD)) {
            while(GetHasFeat(FEAT_GR_BOLSTER_UNDEAD)) {
                DecrementRemainingFeatUses(oCaster, FEAT_GR_BOLSTER_UNDEAD);
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