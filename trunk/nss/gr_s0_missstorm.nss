//*:**************************************************************************
//*:*  GR_S0_MISSSTORM.NSS
//*:**************************************************************************
//*:* Isaacs Missile Storm, Firebrand, Ball Lightning, Manticore Spikes
//*:**************************************************************************
//*:* Updated On: November 26, 2007
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
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    if(spInfo.iSpellID==692) { //*:* Shifter - GWShape manticore spikes
        spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_SHIFTER, oCaster);
    }

    int     iDieType          = 6;
    int     iNumDice          = (spInfo.iSpellID==SPELL_ISAACS_GREATER_MISSILE_STORM ? 2 : 1);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

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
    float   fRange          = FeetToMeters(100.0 + 10.0*spInfo.iCasterLevel);
    int     iNumMissiles;
    float   fDist           = 0.0;
    float   fDelay2, fTime;
    float   fDmgPercent     = 1.0;

    int     bIllusion       = FALSE;

    int     iEnemies        = 0;
    int     iExtraMissiles;
    int     iRemainder;
    int     iAddRemainder   = FALSE;
    int     i               = 0;
    int     iMissileVis     = VFX_IMP_MIRV;
    int     iVisual         = VFX_IMP_MAGBLUE;
    int     iTouchAttack;
    int     iSaveType;
    int     iDamageType     = DAMAGE_TYPE_MAGICAL;

    switch(spInfo.iSpellID) {
        case SPELL_GR_SHAD_EVOC2_ISAACS_LSR_MISSILES:
            bIllusion = TRUE;
            fDmgPercent = 0.4;
        case SPELL_ISAACS_LESSER_MISSILE_STORM:
            iNumMissiles = MinInt(10, spInfo.iCasterLevel);
            break;
        case SPELL_ISAACS_GREATER_MISSILE_STORM:
            iNumMissiles = MinInt(20, spInfo.iCasterLevel);
            fRange *= 4.0;
            break;
        case 498: // Manticore Spikes
        case 692: // Shifter GWShape Manticore Spikes
            fRange = RADIUS_SIZE_GARGANTUAN;
            iMissileVis = 359;
            iVisual = VFX_COM_BLOOD_SPARK_SMALL;
            iDamageType = DAMAGE_TYPE_PIERCING;
            iNumMissiles = (spInfo.iSpellID==498 ? 6 : spInfo.iCasterLevel/2);
            break;
        case SPELL_GR_GSE2_BALL_LIGHTNING:
            bIllusion = TRUE;
            fDmgPercent = 0.6;
        case SPELL_BALL_LIGHTNING:
            iNumMissiles = MinInt(15, spInfo.iCasterLevel);
            iMissileVis = 503;
            iVisual = GRGetEnergyVisualType(VFX_IMP_LIGHTNING_S, iEnergyType);
            iSaveType = GRGetEnergySaveType(iEnergyType);
            break;
    }

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
    effect eMissile = EffectVisualEffect(iMissileVis);
    effect eVis = EffectVisualEffect(iVisual);
    effect eDam;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /* New Algorithm
        1. Count # of targets
        2. Determine number of missiles
        3. Each target gets even number of missiles
        4. Remainder starts with first target, and each
           subsequent target gets one extra until there
           is no remainder left.
   */

    //*:**********************************************
    //*:* Count Targets
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
    while (GetIsObjectValid(spInfo.oTarget) ) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster, NO_CASTER)) {
            // GZ: You can only fire missiles on visible targets
            if(GetObjectSeen(spInfo.oTarget, oCaster)) {
                iEnemies++;
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
     }

    //*:**********************************************
    //*:* Determine # of missiles per enemy
    //*:**********************************************
    if(iNumMissiles>iEnemies) {
        iExtraMissiles = iNumMissiles / iEnemies;
        iRemainder = iNumMissiles % iEnemies;
    } else {
        iExtraMissiles = 1;
        iEnemies = iNumMissiles;
    }

    //*:**********************************************
    //*:* Fire missiles at targets
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
    while(GetIsObjectValid(spInfo.oTarget) && iEnemies>0) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster, NO_CASTER) && GetObjectSeen(spInfo.oTarget, oCaster)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                fDist = GetDistanceBetween(oCaster, spInfo.oTarget);
                fDelay = fDist/(3.0 * log(fDist) + 2.0);
                // if there are still uneven left over missiles, set add to TRUE (1)
                if(iRemainder>0) iAddRemainder = TRUE;

                //*:**********************************************
                //*:* GZ: Moved SR check out of loop to have 1 check
                //*:* per target, not one check per missile, which
                //*:* would rip spell mantles apart
                //*:**********************************************
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                    for(i=1; i<=iExtraMissiles + iAddRemainder; i++) {  // can do + iAddRemainder because FALSE=0 and TRUE=1
                        spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                        if(spInfo.iSpellID!=SPELL_BALL_LIGHTNING) {
                            iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                    iDamage = iSecDamage;
                                }
                            }
                        } else {
                            iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                    iDamage = iSecDamage;
                                }
                            }
                        }

                        //*:* Shadow Evocation/Greater Shadow Evocation Will disbelief check/adjustment
                        if(iDamage>0 && bIllusion) {
                            if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                                iDamage = FloatToInt(iDamage * fDmgPercent);
                            }
                        }

                        fTime = fDelay;
                        fDelay2 += 0.1;
                        fTime += fDelay2;
                        iTouchAttack = TouchAttackRanged(spInfo.oTarget);
                        if(spInfo.iSpellID==498) {
                            iDamage *= iTouchAttack;
                        }
                        if(iDamage>0) {
                            eDam = EffectDamage(iDamage, iDamageType);
                            if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                            DelayCommand(fTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                            DelayCommand(fDelay2, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, spInfo.oTarget));
                            DelayCommand(fTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                        }
                    }  // for
                } else {  // * apply a dummy visual effect
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, spInfo.oTarget);
                }
                iEnemies--; // * increment count of missiles fired
                iRemainder--;  // decrement uneven left over missiles
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
