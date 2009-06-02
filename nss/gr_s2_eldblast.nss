//*:**************************************************************************
//*:*  GR_S2_ELDBLAST.NSS
//*:**************************************************************************
//*:* Eldritch Blast
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 22, 2008
//*:* Complete Arcane (p. 7)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting struct
//*:**************************************************************************
struct BlastInfo {
    int     iEssenceType;
    int     iEssenceLevel;
    int     iEssenceEnergyType;
    int     iBlastShapeType;
    int     iBlastShapeLevel;
    int     bRangedTouch;
    int     bDamaging;
    int     bDamageSave;
    int     bSpecialEffect;
    int     bMeetsSpecialReq;
    int     bHasMobAOE;
    int     bHasPerAOE;
    string  sAOEType;
    int     bMultiTarget;
    int     bLimitNumCreatures;
    int     iNumCreatures;
    int     bLineOfSight;
    int     iObjectTypeFilter;
    int     iSpellShape;
    int     iSpellTargetType;
    int     bIncludeCaster;
    int     iImpVisualType;
    effect  eSpecial;
    int     iDurationType;
    int     iSavingThrow;
    int     iDmgSavingThrow;
    int     iVisualType2;
    int     iDurVisual;
    int     iDurCessate;
    int     bSpecialReq;
    int     iSpecialReq;
    int     iSaveType;
    int     iBeamType;
    int     iVisualType;
    int     iEnergyType;
    effect  eDmgVisLink;
    effect  eSpecialLink;
    float   fRange;
    float   fDuration;
    float   fBeamDuration;
    int     bNoResist;
};

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
struct BlastInfo GRGetNewBlastInfoStruct() {

    object oCaster              = OBJECT_SELF;
    struct BlastInfo blInfo;

    blInfo.iEssenceType         = GetLocalInt(oCaster, "GR_ESSENCE_INV_ID");
    blInfo.iEssenceLevel        = GetLocalInt(oCaster, "GR_ESSENCE_INV_LEVEL");
    blInfo.iEssenceEnergyType   = GetLocalInt(oCaster, "GR_ESSENCE_ENERGY_TYPE");
    blInfo.iBlastShapeType      = GetLocalInt(oCaster, "GR_BLAST_SHAPE_ID");
    blInfo.iBlastShapeLevel     = GetLocalInt(oCaster, "GR_BLAST_SHAPE_LEVEL");
    blInfo.bRangedTouch         = TRUE;
    blInfo.bDamaging            = TRUE;
    blInfo.bDamageSave          = FALSE;
    blInfo.bSpecialEffect       = FALSE;
    blInfo.bMeetsSpecialReq     = TRUE;
    blInfo.bHasMobAOE           = FALSE;
    blInfo.bHasPerAOE           = FALSE;
    blInfo.sAOEType             = "";
    blInfo.bMultiTarget         = FALSE;
    blInfo.bLimitNumCreatures   = FALSE;
    blInfo.iNumCreatures        = 1;
    blInfo.bLineOfSight         = TRUE;
    blInfo.iObjectTypeFilter    = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    blInfo.iSpellShape          = -1;
    blInfo.iSpellTargetType     = -1;
    blInfo.bIncludeCaster       = NO_CASTER;
    blInfo.iImpVisualType       = -1;
    blInfo.eSpecial;
    blInfo.iDurationType        = DURATION_TYPE_TEMPORARY;
    blInfo.iSavingThrow         = -1;
    blInfo.iDmgSavingThrow      = SPELL_SAVE_NONE;
    blInfo.iVisualType2         = -1;
    blInfo.iDurVisual           = -1;
    blInfo.iDurCessate          = VFX_DUR_CESSATE_NEGATIVE;
    blInfo.bSpecialReq          = FALSE;
    blInfo.iSpecialReq          = -1;
    blInfo.iSaveType            = SAVING_THROW_TYPE_NONE;
    blInfo.iBeamType            = VFX_BEAM_DISINTEGRATE;
    blInfo.iVisualType          = VFX_IMP_ACID_S;
    blInfo.fRange               = FeetToMeters(30.0);
    blInfo.fBeamDuration        = 1.7f;
    blInfo.bNoResist            = FALSE;

    return blInfo;
}
//*:**********************************************
void DoChainEffect(object oOrigTarget, int iDamage, struct SpellStruct spInfo, struct BlastInfo blInfo) {

    blInfo.fRange = FeetToMeters(30.0);
    spInfo.lTarget = GetLocation(oOrigTarget);
    int iSubDamage;
    int iAttackResult = 1;
    effect eBeam;
    effect eDamage; //= EffectDamage(iSubDamage, blInfo.iEnergyType);
    effect eLink; //= EffectLinkEffects(blInfo.eDmgVisLink, eDamage);

    object oNextTarget = GRGetFirstObjectInShape(blInfo.iSpellShape, blInfo.fRange, spInfo.lTarget, blInfo.bLineOfSight, blInfo.iObjectTypeFilter);
    if(GetIsObjectValid(oNextTarget)) {
        do {
            if(GRGetIsSpellTarget(oNextTarget, blInfo.iSpellTargetType, spInfo.oCaster, blInfo.bIncludeCaster)) {
                SignalEvent(oNextTarget, EventSpellCastAt(spInfo.oCaster, spInfo.iSpellID));
                iAttackResult = TouchAttackRanged(oNextTarget);
                eBeam = EffectBeam(blInfo.iBeamType, oOrigTarget, BODY_NODE_CHEST, iAttackResult==0);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oNextTarget, blInfo.fBeamDuration);
                if(iAttackResult>0) {
                    if(blInfo.bNoResist || !GRGetSpellResisted(spInfo.oCaster, oNextTarget)) {
                        if(blInfo.bSpecialReq) {
                            switch(blInfo.iSpecialReq) {
                                case SPECIAL_REQ_TYPE_LIVING:
                                    if(GRGetIsLiving(oNextTarget)) blInfo.bMeetsSpecialReq = TRUE;
                                    break;
                                case SPECIAL_REQ_TYPE_SIZE:
                                    if(blInfo.iEssenceType==ELDRITCH_ESSENCE_TYPE_REPELLING_BLAST) {
                                        blInfo.bMeetsSpecialReq = TRUE;
                                        if(GRGetCreatureSize(spInfo.oTarget)>CREATURE_SIZE_MEDIUM) {
                                            blInfo.bSpecialEffect = FALSE;
                                        }
                                    }
                                    break;
                            }
                        }

                        if(blInfo.bMeetsSpecialReq) {
                            if(blInfo.bDamaging) {
                                iSubDamage = GRGetReflexAdjustedDamage(iDamage/2, oNextTarget, spInfo.iDC, blInfo.iSaveType, spInfo.oCaster);
                                if(GetObjectType(oNextTarget)!=OBJECT_TYPE_CREATURE) iSubDamage /= 2;
                                if(iSubDamage>0) {
                                    if(blInfo.iEssenceType!=ELDRITCH_ESSENCE_TYPE_UTTERDARK_BLAST || GRGetRacialType(oNextTarget)!=RACIAL_TYPE_UNDEAD) {
                                        eDamage = EffectDamage(iSubDamage * iAttackResult, blInfo.iEnergyType);
                                    } else {
                                        eDamage = EffectHeal(iSubDamage);
                                    }
                                    eLink = EffectLinkEffects(blInfo.eDmgVisLink, eDamage);
                                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oNextTarget);
                                }
                            }

                            if(blInfo.bSpecialEffect) {
                                if(blInfo.iSavingThrow==-1 || !GRGetSaveResult(blInfo.iSavingThrow, spInfo.oTarget, spInfo.iDC, blInfo.iSaveType)) {
                                    if(blInfo.iEssenceType==SPELL_I_BRIMSTONE_BLAST) {
                                        if(GetHasSpellEffect(SPELL_I_BRIMSTONE_BLAST, oNextTarget)) {
                                            GRRemoveSpellEffects(SPELL_I_BRIMSTONE_BLAST, oNextTarget);
                                        }
                                        spInfo.iDmgNumDice = 1;
                                    } else if(blInfo.iEssenceType==ELDRITCH_ESSENCE_TYPE_REPELLING_BLAST) {
                                        AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
                                        location lCaster = GetLocation(oOrigTarget);
                                        location lTarget = GetLocation(oNextTarget);
                                        location lNewTarget = GenerateNewLocationFromLocation(lTarget, blInfo.fRange, GetAngleBetweenLocations(lCaster, lTarget), GetFacing(oNextTarget));
                                        AssignCommand(spInfo.oTarget, ActionDoCommand(JumpToLocation(lNewTarget)));
                                    }

                                    if(blInfo.iEssenceType!=ELDRITCH_ESSENCE_TYPE_FRIGHTFUL_BLAST ||
                                        (blInfo.iEssenceType==ELDRITCH_ESSENCE_TYPE_FRIGHTFUL_BLAST && !GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_MIND_SPELLS) && !GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_FEAR))) {
                                        GRApplyEffectToObject(blInfo.iDurationType, blInfo.eSpecialLink, spInfo.oTarget, blInfo.fDuration);
                                        object oAOE;
                                        if(blInfo.bHasMobAOE) {
                                            oAOE = GRGetAOEOnObject(oNextTarget, blInfo.sAOEType, spInfo.oCaster);
                                        } else if(blInfo.bHasPerAOE) {
                                            oAOE = GRGetAOEAtLocation(GetLocation(oNextTarget), blInfo.sAOEType, spInfo.oCaster);
                                        }
                                        if(GetIsObjectValid(oAOE)) {
                                            GRSetAOESpellId(spInfo.iSpellID, oAOE);
                                            GRSetSpellInfo(spInfo, oAOE);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                blInfo.iNumCreatures--;
            }
            oOrigTarget = oNextTarget;
            oNextTarget = GRGetNextObjectInShape(blInfo.iSpellShape, blInfo.fRange, spInfo.lTarget, blInfo.bLineOfSight, blInfo.iObjectTypeFilter);
        } while(GetIsObjectValid(oNextTarget) && blInfo.iNumCreatures>0 && iAttackResult>0);
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

    struct  BlastInfo   blInfo = GRGetNewBlastInfoStruct();
    struct  SpellStruct spInfo;

    if(blInfo.iBlastShapeType==BLAST_SHAPE_TYPE_NONE && blInfo.iEssenceType==ELDRITCH_ESSENCE_TYPE_NONE) {
        spInfo = GRGetSpellStruct(GetSpellId(), oCaster);
    } else {
        spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId(), oCaster);
    }

    if(blInfo.iEssenceType!=ELDRITCH_ESSENCE_TYPE_NONE) spInfo.iSpellID = blInfo.iEssenceType;

    /*spInfo.iSpellLevel = MaxInt(spInfo.iSpellLevel, blInfo.iEssenceLevel, blInfo.iBlastShapeLevel);
    spInfo.iDC = 10 + spInfo.iSpellLevel + GetAbilityModifier(ABILITY_CHARISMA);*/

    int     iDieType          = 6;
    int     iNumDice          = (spInfo.iCasterLevel<=11 ? ((spInfo.iCasterLevel+1)/2) : (6+(spInfo.iCasterLevel-11)/3));
    int     iBonus            = 0;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    blInfo.iEnergyType     = (blInfo.iEssenceEnergyType>-1 ? DAMAGE_TYPE_MAGICAL : blInfo.iEssenceEnergyType);
    int     iSpellType      = GRGetEnergySpellType(blInfo.iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = 0.0f;
    //*:* float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(IntToFloat(d6()*5));
    blInfo.iSaveType       = (blInfo.iEnergyType==DAMAGE_TYPE_MAGICAL ? SAVING_THROW_TYPE_NONE : GRGetEnergySaveType(blInfo.iEnergyType));

    switch(blInfo.iEssenceType) {
        case ELDRITCH_ESSENCE_TYPE_BESHADOWED_BLAST:
            blInfo.bDamaging = FALSE;
            blInfo.fDuration = GRGetDuration(1);
            blInfo.bSpecialEffect = TRUE;
            blInfo.eSpecial = EffectBlindness();
            blInfo.iSavingThrow = SAVING_THROW_FORT;
            blInfo.iBeamType = VFX_BEAM_BLACK;
            blInfo.iVisualType2 = VFX_IMP_BLIND_DEAF_M;
            blInfo.iDurVisual = VFX_DUR_MIND_AFFECTING_DISABLED;
            blInfo.bSpecialReq = TRUE;
            blInfo.iSpecialReq = SPECIAL_REQ_TYPE_LIVING;
            blInfo.bMeetsSpecialReq = FALSE;
            break;
        case ELDRITCH_ESSENCE_TYPE_BEWITCHING_BLAST:
            blInfo.fDuration = GRGetDuration(1);
            blInfo.bSpecialEffect = TRUE;
            blInfo.eSpecial = EffectConfused();
            blInfo.iSavingThrow = SAVING_THROW_WILL;
            blInfo.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
            blInfo.iDurVisual = VFX_DUR_MIND_AFFECTING_DISABLED;
           break;
        case ELDRITCH_ESSENCE_TYPE_BRIMSTONE_BLAST:
            blInfo.fDuration = GRGetDuration(MaxInt(1, GetLevelByClass(CLASS_TYPE_WARLOCK, oCaster)/5));
            spInfo.iDmgNumDice = 2;
            blInfo.iVisualType = VFX_IMP_FLAME_M;
            blInfo.iBeamType = VFX_BEAM_FLAME;
            blInfo.bSpecialEffect = TRUE;
            blInfo.bHasMobAOE = TRUE;
            blInfo.eSpecial = GREffectAreaOfEffect(AOE_MOB_BRIMSTONE_BLAST);
            blInfo.sAOEType = AOE_TYPE_BRIMSTONE_BLAST;
            blInfo.iSavingThrow = SAVING_THROW_REFLEX;
            break;
        case ELDRITCH_ESSENCE_TYPE_FRIGHTFUL_BLAST:
            blInfo.fDuration = GRGetDuration(1, DUR_TYPE_TURNS);
            blInfo.bSpecialEffect = TRUE;
            blInfo.eSpecial = GREffectShaken();
            blInfo.iSavingThrow = SAVING_THROW_WILL;
            blInfo.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
            blInfo.iDurVisual = VFX_DUR_MIND_AFFECTING_DISABLED;
            break;
        case ELDRITCH_ESSENCE_TYPE_HELLRIME_BLAST:
            blInfo.fDuration = GRGetDuration(10, DUR_TYPE_TURNS);
            blInfo.bSpecialEffect = TRUE;
            blInfo.iBeamType = VFX_BEAM_COLD;
            blInfo.iVisualType = VFX_IMP_FROST_S;
            blInfo.iVisualType2 = VFX_IMP_REDUCE_ABILITY_SCORE;
            blInfo.eSpecial = EffectAbilityDecrease(ABILITY_DEXTERITY, 4);
            blInfo.iSavingThrow = SAVING_THROW_FORT;
            blInfo.iSaveType = GRGetEnergySaveType(blInfo.iEnergyType);
            break;
        case ELDRITCH_ESSENCE_TYPE_NOXIOUS_BLAST:
            blInfo.fDuration = GRGetDuration(1, DUR_TYPE_TURNS);
            blInfo.bSpecialEffect = TRUE;
            blInfo.iVisualType = VFX_IMP_DISEASE_S;
            blInfo.eSpecial = ExtraordinaryEffect(EffectDazed());
            blInfo.iSavingThrow = SAVING_THROW_FORT;
            blInfo.iDurVisual = VFX_DUR_MIND_AFFECTING_DISABLED;
            break;
        case ELDRITCH_ESSENCE_TYPE_REPELLING_BLAST:
            blInfo.fDuration = GRGetDuration(2);
            blInfo.bSpecialEffect = TRUE;
            blInfo.iVisualType = VFX_IMP_DEATH;
            blInfo.eSpecial = EffectKnockdown();
            blInfo.iSavingThrow = SAVING_THROW_FORT;
            blInfo.iDurVisual = VFX_DUR_MIND_AFFECTING_DISABLED;
            blInfo.bSpecialReq = TRUE;
            blInfo.iSpecialReq = SPECIAL_REQ_TYPE_SIZE;
            blInfo.bMeetsSpecialReq = FALSE;
            break;
        case ELDRITCH_ESSENCE_TYPE_SICKENING_BLAST:
            blInfo.fDuration = GRGetDuration(1, DUR_TYPE_TURNS);
            blInfo.bSpecialEffect = TRUE;
            blInfo.iVisualType = VFX_IMP_DISEASE_S;
            blInfo.eSpecial = GREffectSickened();
            blInfo.iSavingThrow = SAVING_THROW_FORT;
            blInfo.iDurVisual = VFX_DUR_PROTECTION_EVIL_MINOR;
            break;
        case ELDRITCH_ESSENCE_TYPE_UTTERDARK_BLAST:
            blInfo.fDuration = GRGetDuration(1, DUR_TYPE_HOURS);
            blInfo.iEnergyType = DAMAGE_TYPE_NEGATIVE;
            blInfo.bSpecialEffect = TRUE;
            blInfo.iVisualType = VFX_IMP_NEGATIVE_ENERGY;
                /*** NWN1 SPECIFIC ***/
            blInfo.iBeamType = VFX_BEAM_EVIL;
                /*** END NWN1 SPECIFIC ***/
            blInfo.eSpecial = EffectNegativeLevel(2);
            blInfo.iSavingThrow = SAVING_THROW_FORT;
            break;
        case ELDRITCH_ESSENCE_TYPE_VITRIOLIC_BLAST:
            blInfo.bNoResist = TRUE;
            blInfo.bHasMobAOE = TRUE;
            blInfo.iVisualType = VFX_IMP_ACID_L;
            blInfo.fDuration = GRGetDuration(MaxInt(1, GetLevelByClass(CLASS_TYPE_WARLOCK, oCaster)/5));
            blInfo.eSpecial = GREffectAreaOfEffect(AOE_MOB_VITRIOLIC_BLAST);
            blInfo.sAOEType = AOE_TYPE_VITRIOLIC_BLAST;
            break;
    }

    switch(blInfo.iBlastShapeType) {
        case BLAST_SHAPE_TYPE_NONE:
            blInfo.iSpellTargetType = -1;
            break;
        case BLAST_SHAPE_TYPE_CHAIN:
            blInfo.bLimitNumCreatures = TRUE;
            blInfo.iNumCreatures = spInfo.iCasterLevel/5;
            blInfo.iSpellTargetType = SPELL_TARGET_SELECTIVEHOSTILE;
            break;
        case BLAST_SHAPE_TYPE_CONE:
            blInfo.bDamageSave = TRUE;
            blInfo.iDmgSavingThrow = REFLEX_HALF;
            blInfo.bRangedTouch = FALSE;
            blInfo.bMultiTarget = TRUE;
            blInfo.iSpellShape = SHAPE_SPELLCONE;
            blInfo.fRange = FeetToMeters(30.0);
            blInfo.iSpellTargetType = SPELL_TARGET_STANDARDHOSTILE;
            break;
        case BLAST_SHAPE_TYPE_DOOM:
            blInfo.bDamageSave = TRUE;
            blInfo.iDmgSavingThrow = REFLEX_HALF;
            blInfo.bRangedTouch = FALSE;
            blInfo.bMultiTarget = TRUE;
            blInfo.iSpellShape = SHAPE_SPHERE;
            blInfo.fRange = FeetToMeters(20.0);
            blInfo.iSpellTargetType = SPELL_TARGET_SELECTIVEHOSTILE;
            break;
        case BLAST_SHAPE_TYPE_HIDEOUS_BLOW:
            blInfo.bRangedTouch = FALSE;
            break;
    }

    if(blInfo.iEssenceEnergyType>-1) {
        blInfo.iVisualType = GRGetEnergyVisualType(blInfo.iVisualType, blInfo.iEnergyType);
    }

    int     iAttackResult = (blInfo.bRangedTouch ? GRTouchAttackRanged(spInfo.oTarget) : 1);
    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    //*:* iDamage = GRGetSpellDamageAmount(spInfo) * iAttackResult;
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eImp;
    effect eBeam        = EffectBeam(blInfo.iBeamType, oCaster, BODY_NODE_HAND, iAttackResult==0);
    effect eDamage;      //= EffectDamage(iDamage);
    effect eVis         = EffectVisualEffect(blInfo.iVisualType);
    effect eVis2;
    blInfo.eDmgVisLink        = eVis;
    effect eDurCessate  = EffectVisualEffect(blInfo.iDurCessate);
    effect eDurVis;
    effect eLink;


    if(blInfo.iVisualType2>-1) {
        eVis2 = EffectVisualEffect(blInfo.iVisualType2);
        blInfo.eDmgVisLink = EffectLinkEffects(blInfo.eDmgVisLink, eVis2);
        eLink = blInfo.eDmgVisLink;
    }
    if(blInfo.bSpecialEffect) {
        blInfo.eSpecialLink = EffectLinkEffects(blInfo.eSpecial, eDurCessate);
        if(blInfo.iDurVisual>-1) {
            eDurVis = EffectVisualEffect(blInfo.iDurVisual);
            blInfo.eSpecialLink = EffectLinkEffects(blInfo.eSpecialLink, eDurVis);
        }
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(blInfo.bMultiTarget) {
        spInfo.oTarget = GRGetFirstObjectInShape(blInfo.iSpellShape, blInfo.fRange, spInfo.lTarget, blInfo.bLineOfSight, blInfo.iObjectTypeFilter);
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImp, spInfo.lTarget);
    } else if(blInfo.iBlastShapeType!=BLAST_SHAPE_TYPE_HIDEOUS_BLOW) {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, spInfo.oTarget, blInfo.fBeamDuration);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!blInfo.bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, blInfo.iSpellTargetType, oCaster, blInfo.bIncludeCaster)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                if(blInfo.iBlastShapeType==BLAST_SHAPE_TYPE_DOOM) {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, spInfo.oTarget, blInfo.fBeamDuration);
                }
                if(iAttackResult>0) {
                    if(blInfo.bNoResist || !GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                        if(blInfo.bSpecialReq) {
                            switch(blInfo.iSpecialReq) {
                                case SPECIAL_REQ_TYPE_LIVING:
                                    if(GRGetIsLiving(spInfo.oTarget)) blInfo.bMeetsSpecialReq = TRUE;
                                    break;
                                case SPECIAL_REQ_TYPE_SIZE:
                                    if(blInfo.iEssenceType==ELDRITCH_ESSENCE_TYPE_REPELLING_BLAST) {
                                        blInfo.bMeetsSpecialReq = TRUE;
                                        if(GRGetCreatureSize(spInfo.oTarget)<=CREATURE_SIZE_MEDIUM) {
                                            blInfo.bSpecialEffect = FALSE;
                                        }
                                    }
                                    break;
                            }
                        }

                        if(blInfo.bMeetsSpecialReq) {
                            if(blInfo.bDamaging) {
                                iDamage = GRGetSpellDamageAmount(spInfo, blInfo.iDmgSavingThrow);
                                if(GetObjectType(spInfo.oTarget)!=OBJECT_TYPE_CREATURE) iDamage /= 2;
                                if(iDamage>0) {
                                    if(blInfo.iEssenceType!=ELDRITCH_ESSENCE_TYPE_UTTERDARK_BLAST || GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_UNDEAD) {
                                        eDamage = EffectDamage(iDamage * iAttackResult, blInfo.iEnergyType);
                                    } else {
                                        eDamage = EffectHeal(iDamage);
                                    }
                                    eLink = EffectLinkEffects(eLink, eDamage);
                                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                                }
                            }

                            if(!blInfo.bDamaging || iDamage>0) {
                                if(blInfo.bSpecialEffect) {
                                    if(blInfo.iSavingThrow==-1 || !GRGetSaveResult(blInfo.iSavingThrow, spInfo.oTarget, spInfo.iDC, blInfo.iSaveType)) {
                                        if(blInfo.iEssenceType==ELDRITCH_ESSENCE_TYPE_BRIMSTONE_BLAST) {
                                            if(GetHasSpellEffect(SPELL_I_BRIMSTONE_BLAST, spInfo.oTarget)) {
                                                GRRemoveSpellEffects(SPELL_I_BRIMSTONE_BLAST, spInfo.oTarget);
                                            }
                                        } else if(blInfo.iEssenceType==ELDRITCH_ESSENCE_TYPE_REPELLING_BLAST) {
                                            AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
                                            location lCaster = GetLocation(oCaster);
                                            location lTarget = GetLocation(spInfo.oTarget);
                                            location lNewTarget = GenerateNewLocationFromLocation(lTarget, fRange, GetAngleBetweenLocations(lCaster, lTarget), GetFacing(spInfo.oTarget));
                                            AssignCommand(spInfo.oTarget, ActionDoCommand(JumpToLocation(lNewTarget)));
                                        }

                                        if(blInfo.iEssenceType!=ELDRITCH_ESSENCE_TYPE_FRIGHTFUL_BLAST ||
                                            (blInfo.iEssenceType==ELDRITCH_ESSENCE_TYPE_FRIGHTFUL_BLAST && !GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_MIND_SPELLS) && !GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_FEAR))) {

                                            GRApplyEffectToObject(blInfo.iDurationType, blInfo.eSpecialLink, spInfo.oTarget, blInfo.fDuration);
                                            object oAOE;
                                            if(blInfo.bHasMobAOE) {
                                                oAOE = GRGetAOEOnObject(spInfo.oTarget, blInfo.sAOEType, oCaster);
                                            } else if(blInfo.bHasPerAOE) {
                                                oAOE = GRGetAOEAtLocation(spInfo.lTarget, blInfo.sAOEType, oCaster);
                                            }
                                            if(GetIsObjectValid(oAOE)) {
                                                spInfo.iDmgNumDice = 2;
                                                GRSetAOESpellId(spInfo.iSpellID, oAOE);
                                                GRSetSpellInfo(spInfo, oAOE);
                                            }
                                        }
                                    }
                                }
                            }

                            if(blInfo.iBlastShapeType==BLAST_SHAPE_TYPE_CHAIN && blInfo.iNumCreatures>0) {
                                DoChainEffect(spInfo.oTarget, iDamage, spInfo, blInfo);
                            }
                        }
                    }
                }
            }
            if(blInfo.bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(blInfo.iSpellShape, blInfo.fRange, spInfo.lTarget, blInfo.bLineOfSight, blInfo.iObjectTypeFilter);
                if(blInfo.bLimitNumCreatures) blInfo.iNumCreatures--;
            }
        } while(GetIsObjectValid(spInfo.oTarget) && blInfo.bMultiTarget && blInfo.iNumCreatures>0);
    }

    if(blInfo.iBlastShapeType==BLAST_SHAPE_TYPE_HIDEOUS_BLOW) {
        object oMyWeapon = IPGetTargetedOrEquippedMeleeWeapon();
        IPRemoveMatchingItemProperties(oMyWeapon, ITEM_PROPERTY_ONHITCASTSPELL, DURATION_TYPE_TEMPORARY, SUBTYPE_MAGICAL);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster, TRUE);
}
//*:**************************************************************************
//*:**************************************************************************
