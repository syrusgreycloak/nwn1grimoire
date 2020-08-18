//*:**************************************************************************
//*:*  GR_S1_DRAGBREATH.NSS
//*:**************************************************************************
//*:* Dragon Breath for Wyrmling Shape (x2_s2_dragbreath) Copyright (c) 2003Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: June, 17, 2003
//*:*
//*:* Epic Dragon Breath (NW_S1_DragLightn) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: 2003-Oct-14
//*:**************************************************************************
//*:* Updated On: January 10, 2007
//*:**************************************************************************
/*
     Creatures protected by filter spell take only
     half-damage from gas version.
*/
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
#include "GR_IN_DRAGONS"

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
    int     bWyrmlingShape  = (spInfo.iSpellID>=663 && spInfo.iSpellID<=667);
    int     bDragonDisciple = (spInfo.iSpellID>=2027);
    int     bDragonShape    = (spInfo.iSpellID>=796 && spInfo.iSpellID<=798);
    int     bShifter = (GRGetLevelByClass(CLASS_TYPE_SHIFTER, OBJECT_SELF)>=10);
    int     bPoison = FALSE;

    if(GetHasSpellEffect(SPELL_GR_SUPPRESS_BREATH_WEAPON, oCaster)) {
        return;
    }

    if(spInfo.iSpellID==690) {
        spInfo.iSpellID = SPELLABILITY_GR_DD_BREATH_FIRE;
        bDragonDisciple = TRUE;
    }


    if(bWyrmlingShape) {
        spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_SHIFTER, oCaster);
    } else if(bDragonDisciple) {
        spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oCaster);
    } else if(bDragonShape) {
        spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_DRUID, oCaster) + GRGetLevelByClass(CLASS_TYPE_SHIFTER, oCaster);
        if(spInfo.iCasterLevel==0) {
            if(GetIsPC(oCaster)) {
                spInfo.iCasterLevel = GetHitDice(oCaster)/2;
            } else {
                spInfo.iCasterLevel = GetHitDice(oCaster);
            }
        }
    } else {
        spInfo.iCasterLevel = GRGetDragonAge();
    }

    int     iDieType          = 0;
    int     iNumDice          = spInfo.iCasterLevel*2;
    if(bWyrmlingShape) {
        iNumDice = spInfo.iCasterLevel/2 + 1;
    } else if(bDragonShape) {
        iNumDice = MinInt(24, MaxInt(1, spInfo.iCasterLevel-2));
    }

    int     iBonus            = 0;
    int     iDamage           = 0;

    if(bDragonDisciple) {
        iDieType = 8;
        if(spInfo.iCasterLevel<7) {
            iNumDice = 2;
        } else if(spInfo.iCasterLevel<10) {
            iNumDice = 4;
        } else if(spInfo.iCasterLevel>9) {
            iNumDice = 6 + 2*((spInfo.iCasterLevel-10)/3);
        }
    }


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

    float   fDuration       = GRGetDuration(d6()+spInfo.iCasterLevel);
    float   fDelay          = 0.0f;

    int     iDamageType;
    int     iVisualType     = -1;
    int     iSaveType       = SAVING_THROW_TYPE_NONE;
    int     iSpell;
    int     iSpellShape     = SHAPE_SPELLCONE;
    vector  vFinalPosition;
    int     iDragonAge      = GetHitDice(oCaster);

    //:*: Dragon Info Storage
    int     iDragonType = (!bDragonDisciple ? GRGetDragonType(spInfo.iSpellID, oCaster) : GRGetDiscipleType(oCaster));
    int     iDragonSize = (bWyrmlingShape ? GR_DRAGON_SIZE_TINY : GRGetDragonSize(iDragonType, spInfo.iCasterLevel));
    if(bDragonDisciple) iDragonSize = GR_DRAGON_SIZE_MEDIUM;

    int     iSavingThrow    = -1;
    int     iObjectFilter   = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    float   fRange          = FeetToMeters(GRGetDragonBreathRange(iDragonSize));
    int     bDamagingBreath = TRUE;
    int     iDurVisualType  = -1;
    int     iDurationType   = DURATION_TYPE_TEMPORARY;
    int     bPlayDragonCry  = TRUE;
    int     bBeamType       = FALSE;
    int     iBeamVfx        = -1;


    iDieType = GRGetDragonDieType(spInfo.iCasterLevel);
    if(bWyrmlingShape || bDragonDisciple) {
        bPlayDragonCry = FALSE;
        switch(spInfo.iSpellID) {
            case 663:
            case SPELLABILITY_GR_DD_BREATH_COLD:
                spInfo.iSpellID = SPELLABILITY_DRAGON_BREATH_COLD;
                break;
            case 664:
            case SPELLABILITY_GR_DD_BREATH_ACID:
                spInfo.iSpellID = SPELLABILITY_DRAGON_BREATH_ACID;
                break;
            case 665:
            case SPELLABILITY_GR_DD_BREATH_FIRE:
                spInfo.iSpellID = SPELLABILITY_DRAGON_BREATH_FIRE;
                break;
            case 666:
            case SPELLABILITY_GR_DD_BREATH_GAS:
                spInfo.iSpellID = SPELLABILITY_DRAGON_BREATH_GAS;
                break;
            case 667:
            case SPELLABILITY_GR_DD_BREATH_LIGHTNING:
                spInfo.iSpellID = SPELLABILITY_DRAGON_BREATH_LIGHTNING;
                break;
        }
    }
    //*:**********************************************
    //*:* Decide on breath weapon type, vfx based on spell id
    //*:**********************************************
    switch(spInfo.iSpellID) {
        case SPELLABILITY_DRAGON_BREATH_ACID:
            iDamageType = DAMAGE_TYPE_ACID;
            iVisualType = VFX_IMP_ACID_S;
            iSaveType   = SAVING_THROW_TYPE_ACID;
            iSpellShape = SHAPE_SPELLCYLINDER;
            bBeamType   = TRUE;
            //*** NWN2 SINGLE ***/ iBeamVfx    = VFX_BEAM_GREEN_DRAGON_ACID;
            break;
        case 796:
            bPlayDragonCry = FALSE;
        case SPELLABILITY_DRAGON_BREATH_LIGHTNING:
            iDamageType = DAMAGE_TYPE_ELECTRICAL;
            iVisualType = VFX_IMP_LIGHTNING_S;
            iSaveType   = SAVING_THROW_TYPE_ELECTRICITY;
            iSpellShape = SHAPE_SPELLCYLINDER;
            bBeamType   = TRUE;
            iBeamVfx    = VFX_BEAM_LIGHTNING;
            break;
        case 798:
            bPlayDragonCry = FALSE;
            bPoison     = TRUE;
        case SPELLABILITY_DRAGON_BREATH_GAS:
            iDamageType = DAMAGE_TYPE_ACID;
            iVisualType = VFX_IMP_ACID_S;
            iSaveType   = SAVING_THROW_TYPE_ACID;
            break;
        case 797:
            bPlayDragonCry = FALSE;
        case SPELLABILITY_DRAGON_BREATH_FIRE:
            iDamageType = DAMAGE_TYPE_FIRE;
            iVisualType = VFX_IMP_FLAME_M;
            iSaveType   = SAVING_THROW_TYPE_FIRE;
            if(iDragonType==GR_DRAGON_BRASS) {
                iSpellShape = SHAPE_SPELLCYLINDER;
                bBeamType   = TRUE;
                //*** NWN2 SINGLE ***/ iBeamVfx    = VFX_BEAM_FIRE_W;
            }
            break;
        case SPELLABILITY_DRAGON_BREATH_COLD:
            iDamageType = DAMAGE_TYPE_COLD;
            iVisualType = VFX_IMP_FROST_S;
            iSaveType   = SAVING_THROW_TYPE_COLD;
            break;
        case SPELLABILITY_DRAGON_BREATH_FEAR:  //*:* Bronze - Repulsion Gas
            bDamagingBreath = FALSE;
            iVisualType     = VFX_IMP_FEAR_S;
            iDurVisualType  = VFX_DUR_MIND_AFFECTING_FEAR;
            iSavingThrow    = SAVING_THROW_WILL;
            iSaveType       = SAVING_THROW_TYPE_FEAR;
            iObjectFilter   = OBJECT_TYPE_CREATURE;
            break;
        case SPELLABILITY_DRAGON_BREATH_PARALYZE:
            bDamagingBreath = FALSE;
            iDurVisualType  = VFX_DUR_PARALYZED;
            iSavingThrow    = SAVING_THROW_FORT;
            iObjectFilter   = OBJECT_TYPE_CREATURE;
            break;
        case SPELLABILITY_DRAGON_BREATH_SLEEP:
            bDamagingBreath = FALSE;
            iVisualType     = VFX_IMP_SLEEP;
            iDurVisualType  = VFX_DUR_CESSATE_NEGATIVE;
            iSavingThrow    = SAVING_THROW_FORT;
            iObjectFilter   = OBJECT_TYPE_CREATURE;
            iSaveType       = SAVING_THROW_TYPE_SLEEP;
            break;
        case SPELLABILITY_DRAGON_BREATH_SLOW:
            bDamagingBreath = FALSE;
            iVisualType     = VFX_IMP_SLOW;
            iDurVisualType  = VFX_DUR_CESSATE_NEGATIVE;
            iSavingThrow    = SAVING_THROW_FORT;
            iObjectFilter   = OBJECT_TYPE_CREATURE;
            break;
        case SPELLABILITY_DRAGON_BREATH_WEAKEN:
            bDamagingBreath = FALSE;
            iVisualType     = VFX_IMP_REDUCE_ABILITY_SCORE;
            iSavingThrow    = SAVING_THROW_REFLEX;
            iObjectFilter   = OBJECT_TYPE_CREATURE;
            iDurationType   = DURATION_TYPE_PERMANENT;
            break;
        case SPELLABILITY_DRAGON_BREATH_NEGATIVE:
            bDamagingBreath = FALSE;
            iVisualType     = VFX_IMP_NEGATIVE_ENERGY;
            iBonus          = GRGetNegDragonBreathDmg(iDragonAge);
            iSavingThrow    = SAVING_THROW_REFLEX;
            iSaveType       = SAVING_THROW_TYPE_NEGATIVE;
            iObjectFilter   = OBJECT_TYPE_CREATURE;
            iDurationType   = DURATION_TYPE_PERMANENT;
            break;
    }

    if(iSpellShape==SHAPE_SPELLCYLINDER) fRange *= 2;

    if(bWyrmlingShape || bDragonShape) {
        spInfo.iDC = ShifterGetSaveDC(OBJECT_SELF, SHIFTER_DC_NORMAL, bDragonShape);
        if(bDragonShape && !bShifter) {
            iNumDice = MaxInt(1, iNumDice - 4);
            spInfo.iDC = MaxInt(1, spInfo.iDC - 4);
        }
    } else if(bDragonDisciple) {
        //*:* 10 + class level + con modifier
        spInfo.iDC = 10 + spInfo.iCasterLevel + MaxInt(0, GetAbilityModifier(ABILITY_CONSTITUTION, oCaster));
    } else {
        spInfo.iDC = GRGetDragonBreathDC(iDragonType, spInfo.iCasterLevel);
    }

    if(spInfo.lTarget==GetLocation(OBJECT_SELF)) {
        // Since the target and origin are the same, we have to determine the
        // direction of the spell from the facing of OBJECT_SELF (which is more
        // intuitive than defaulting to East everytime).

        // In order to use the direction that OBJECT_SELF is facing, we have to
        // instead we pick a point slightly in front of OBJECT_SELF as the target.
        vector lTargetPosition = GetPositionFromLocation(spInfo.lTarget);
        vFinalPosition.x = lTargetPosition.x +  cos(GetFacing(OBJECT_SELF));
        vFinalPosition.y = lTargetPosition.y +  sin(GetFacing(OBJECT_SELF));
        spInfo.lTarget = Location(GetAreaFromLocation(spInfo.lTarget), vFinalPosition, GetFacingFromLocation(spInfo.lTarget));
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis, eBeam, eBreath, ePoison, eDur;

    if(iVisualType>-1) eVis = EffectVisualEffect(iVisualType);
    //*** NWN2 SINGLE ***/ if(bBeamType && iBeamVfx!=-1) eBeam = EffectVisualEffect(iBeamVfx);

    if(!bDamagingBreath) {
        if(iDurVisualType>-1) eDur = EffectVisualEffect(iDurVisualType);
        switch(spInfo.iSpellID) {
            case SPELLABILITY_DRAGON_BREATH_FEAR:
                eBreath = EffectFrightened();
                eBreath = EffectLinkEffects(eBreath, eDur);
                break;
            case SPELLABILITY_DRAGON_BREATH_PARALYZE:
                eBreath = EffectParalyze();
                eBreath = EffectLinkEffects(eBreath, eDur);
                break;
            case SPELLABILITY_DRAGON_BREATH_SLEEP:
                eBreath = EffectSleep();
                eBreath = EffectLinkEffects(eBreath, eDur);
                break;
            case SPELLABILITY_DRAGON_BREATH_SLOW:
                eBreath = EffectSlow();
                eBreath = EffectLinkEffects(eBreath, eDur);
                break;
            case SPELLABILITY_DRAGON_BREATH_WEAKEN:
                eBreath = EffectAbilityDecrease(ABILITY_STRENGTH, spInfo.iCasterLevel);
                break;
            case SPELLABILITY_DRAGON_BREATH_NEGATIVE:
                eBreath = EffectNegativeLevel(iBonus);
                break;
        }
        eBreath = SupernaturalEffect(eBreath);
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bPlayDragonCry) PlayDragonBattleCry();
    /*** NWN2 SPECIFIC ***
    if(bBeamType) {
        PlayCustomAnimation(OBJECT_SELF, "Una_breathattack01", 0, 0.7f);

        location lNewLocation = GetAheadLocation(OBJECT_SELF, 60.0f);
        object oEndTarget = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_ipoint ", lNewLocation);

        DelayCommand(1.0f, DestroyObject(oEndTarget));

        DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oEndTarget, 4.0f));
    }
    /*** END NWN2 SPECIFIC ***/

    spInfo.oTarget = GRGetFirstObjectInShape(iSpellShape, fRange, spInfo.lTarget, TRUE, iObjectFilter);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(!GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, OBJECT_SELF, NO_CASTER)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, spInfo.iSpellID));
            fDelay = GetDistanceBetween(OBJECT_SELF, spInfo.oTarget)/20;

            if(bDamagingBreath) { //*:* instant damaging (energy) types - acid, cold, etc.
                iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, 0);
                iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster);

                if((bPoison || spInfo.iSpellID==SPELLABILITY_DRAGON_BREATH_GAS) && GetHasSpellEffect(SPELL_GR_FILTER, spInfo.oTarget)) {
                    iDamage /= 2;
                    bPoison = FALSE;
                }

                if(iDamage > 0) {
                    eBreath = EffectDamage(iDamage, iDamageType);
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBreath, spInfo.oTarget));
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iDamageType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                    if(bPoison && GetObjectType(spInfo.oTarget)==OBJECT_TYPE_CREATURE) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectPoison(44), spInfo.oTarget));
                    }
                 }
             } else {
                 //*:* other breath types - fear, paralyze, sleep, slow, weaken, energy drain
                 int bSaveResult;
                 if(spInfo.iSpellID!=SPELLABILITY_DRAGON_BREATH_NEGATIVE) {
                     if(GetHasSpellEffect(SPELL_GR_FILTER, spInfo.oTarget)) {
                         bSaveResult = GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC-2, iSaveType, oCaster, fDelay);
                     } else {
                         bSaveResult = GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster, fDelay);
                     }
                 } else {
                     int iAdjNegDmg = GRGetReflexAdjustedDamage(iBonus, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster);
                     if(iAdjNegDmg==0) {
                         bSaveResult = TRUE;
                     } else {
                         bSaveResult = FALSE;
                         eBreath = SupernaturalEffect(EffectNegativeLevel(iAdjNegDmg));
                     }
                 }

                 if(!bSaveResult) {
                     if(iVisualType>-1) DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                     DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eBreath, spInfo.oTarget, fDuration));
                 }
             }
        }
        spInfo.oTarget = GRGetNextObjectInShape(iSpellShape, fRange, spInfo.lTarget, TRUE, iObjectFilter);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
