//*:**************************************************************************
//*:*  GR_S0_BURSTS.NSS
//*:**************************************************************************
//*:* MASTER SCRIPT FOR INSTANT DAMAGING BURST-TYPE SPELLS (FIREBALL,
//*:*           FIRE STORM, ICE BURST, ETC.)
//*:**************************************************************************
//*:* Fire Storm (NW_S0_FireStm) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: April 11, 2001
//*:* 3.5 Player's Handbook (p. 231)
//*:*
//*:* Fireball (NW_S0_Fireball) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Noel Borstad  Created On: Oct 18 , 2000
//*:* 3.5 Player's Handbook (p. 231)
//*:*
//*:* Ice Storm (NW_S0_IceStorm) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Sept 12, 2001
//*:* 3.5 Player's Handbook (p. 243)
//*:*
//*:* Scintillating Sphere (X2_S0_ScntSphere) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Nov 25 , 2002
//*:* Spell Compendium (p. 181)
//*:**************************************************************************
//*:* Ice Burst  2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 23, 2003
//*:* Tome & Blood (p. 91)
//*:*
//*:* Fireburst
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 31, 2007
//*:* Spell Compendium (p. 93)
//*:*
//*:* Greater Fireburst
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 31, 2007
//*:* Spell Compendium (p. 94)
//*:*
//*:* Vitriolic Sphere
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 2, 2009
//*:* Spell Compendium (p. 231)
//*:*
//*:* Cacophonic Burst
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 5, 2009
//*:* Spell Compendium (p. 41)
//*:**************************************************************************
//*:* Updated On: January 5, 2009
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
//*:* Supporting functions
//*:**************************************************************************
void RunDelayedVitriolicSphereEffects(struct SpellStruct spInfo) {
    int iEnergyType = GetLocalInt(spInfo.oTarget, "GR_VITRIOLICSPHERE_ENERGYTYPE");
    int iVisualType = GRGetEnergyVisualType(VFX_IMP_ACID_L, iEnergyType);
    int iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, spInfo.oCaster);
    int iSecDamage = 0;
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, spInfo.oCaster);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    effect eVis = EffectVisualEffect(iVisualType);
    effect eDam = EffectDamage(iDamage, iEnergyType);
    effect eLink = EffectLinkEffects(eVis, eDam);
    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    SignalEvent(spInfo.oTarget, EventSpellCastAt(spInfo.oTarget, SPELL_VITRIOLIC_SPHERE));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
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

    int     iDieType        = 6;
    int     iNumDice        = MinInt(20, spInfo.iCasterLevel);
    int     iBonus          = 0;
    int     iDamage         = 0;
    int     iSecDamage      = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    float   fDamagePercentage = 1.0;

    switch(spInfo.iSpellID) {
        case SPELL_GR_SHAD_EVOC1_FIREBALL:
            fDamagePercentage = 0.4;
        case SPELL_FIREBALL:
        case SPELL_SCINTILLATING_SPHERE:
            iNumDice = MinInt(10, spInfo.iCasterLevel);
            break;
        case SPELL_GR_SHAD_EVOC1_FIREBURST:
            fDamagePercentage = 0.4;
        case SPELL_FIREBURST:
            iDieType = 8;
            iNumDice = MinInt(5, spInfo.iCasterLevel);
            break;
        case SPELL_GR_GSE2_GREATER_FIREBURST:
            fDamagePercentage = 0.6;
        case SPELL_GREATER_FIREBURST:
            iDieType = 10;
            iNumDice = MinInt(15, spInfo.iCasterLevel);
            break;
        case SPELL_GR_SHAD_EVOC2_ICE_BURST:
            fDamagePercentage = 0.4;
        case SPELL_GR_ICE_BURST:
            iDieType = 4;
            iNumDice = MinInt(10, spInfo.iCasterLevel);
            break;
        case SPELL_GR_SHAD_EVOC1_ICE_STORM:
        case SPELL_GR_GSE1_ICE_STORM:
            fDamagePercentage = (spInfo.iSpellID==SPELL_GR_SHAD_EVOC1_ICE_STORM ? 0.4 : 0.6);
        case SPELL_ICE_STORM:
            iNumDice = 2;
            break;
        case SPELL_GR_LSE_SNILLOCS_SNOWBALL_SWARM:
            fDamagePercentage = 0.2;
        case SPELL_GR_SNILLOC_SNOWBALL_SWARM:
            iNumDice = MinInt(5, 2+(spInfo.iCasterLevel-3)/2);
            break;
        case SPELL_CACOPHONIC_BURST:
        case SPELL_GR_OTILUKES_FREEZING_SPHERE:
            iNumDice = MinInt(15, spInfo.iCasterLevel);
            break;
        case SPELL_VITRIOLIC_SPHERE:
            iNumDice = 6;
            break;
    }

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
    int     iVisualType     = VFX_IMP_FLAME_M;
    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(15.0);
    int     iSpellShape     = SHAPE_SPHERE;
    float   fDelay          = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20;
    int     iObjectType     = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iExplodeType    = GRGetEnergyExplodeType(iEnergyType, spInfo.iSpellID);
    int     iOrigDamage, iSaveMade;
    int     iSecDieType     = 0;
    int     iSecNumDice     = 0;
    int     iSecBonus       = 0;
    int     bSecBludgeoning = FALSE;

    int     bNoSR           = FALSE;
    int     bNoSave         = FALSE;
    int     bVitriolicSave  = FALSE;
    int     bOverrideSilence    = FALSE;

    int     iSpellSaveType  = REFLEX_HALF;

    switch(spInfo.iSpellID) {
        case SPELL_FIRE_STORM:
            /*** NWN1 SPECIFIC ***/
                fRange = FeetToMeters(IntToFloat(7*spInfo.iCasterLevel));
                iSpellShape = SHAPE_CUBE;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/ fRange = RADIUS_SIZE_COLOSSAL;
            fDelay = GetRandomDelay(1.5, 2.5);
            break;
        case SPELL_GR_SHAD_EVOC1_FIREBALL:
        case SPELL_FIREBALL:
            fRange = FeetToMeters(20.0);
            break;
        case SPELL_GR_SHAD_EVOC1_FIREBURST:
        case SPELL_FIREBURST:
            fRange = FeetToMeters(10.0);
            break;
        case SPELL_GR_GSE2_GREATER_FIREBURST:
        case SPELL_GREATER_FIREBURST:
            //*** NWN2 SINGLE ***/ iVisualType = VFX_HIT_SPELL_FIRE;
            fRange = FeetToMeters(15.0);
            break;
        case SPELL_GR_SHAD_EVOC2_ICE_BURST:
        case SPELL_GR_ICE_BURST:
            fRange = FeetToMeters(30.0);
            fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/30;
            iBonus = MinInt(10, spInfo.iCasterLevel);
            spInfo = GRSetSpellSecondaryDamageInfo(spInfo, DAMAGE_TYPE_BLUDGEONING, SECDMG_TYPE_OVERRIDE, iBonus);
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_FROST_S;
            //*** NWN2 SINGLE ***/ iVisualType = VFX_HIT_SPELL_ICE;
            bSecBludgeoning = TRUE;
            break;
        case SPELL_GR_GSE1_ICE_STORM:
        case SPELL_GR_SHAD_EVOC1_ICE_STORM:
        case SPELL_ICE_STORM:
            iSecDieType = 6;
            iSecNumDice = 3;
            fRange = FeetToMeters(20.0);
            spInfo.iSecDmgType = DAMAGE_TYPE_BLUDGEONING;
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_FROST_S;
            //*** NWN2 SINGLE ***/ iVisualType = VFX_HIT_SPELL_ICE;
            bNoSave = TRUE;
            bSecBludgeoning = TRUE;
            break;
        case SPELL_GR_LSE_SNILLOCS_SNOWBALL_SWARM:
        case SPELL_GR_SNILLOC_SNOWBALL_SWARM:
            fRange = FeetToMeters(10.0);
            fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/10;
            iVisualType = VFX_IMP_FROST_S;
            break;
        case SPELL_SCINTILLATING_SPHERE:
            fRange = FeetToMeters(20.0);
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_LIGHTNING_S;
            //*** NWN2 SINGLE ***/ iVisualType = VFX_HIT_SPELL_LIGHTNING;
            break;
        case SPELL_GR_OTILUKES_FREEZING_SPHERE:
            fRange = FeetToMeters(10.0);
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_FROST_L;
            //*** NWN2 SINGLE ***/ iVisualType = VFX_HIT_SPELL_ICE;
            break;
        case SPELL_VITRIOLIC_SPHERE:
            fRange = FeetToMeters(10.0);
            iVisualType = VFX_IMP_ACID_L;
            bNoSR = TRUE;
            bNoSave = TRUE;
            break;
        case SPELL_CACOPHONIC_BURST:
            fRange = FeetToMeters(20.0);
            iVisualType = VFX_IMP_SONIC;
            break;
    }

    iVisualType = GRGetEnergyVisualType(iVisualType, iEnergyType);

    if(GRGetIsUnderwater(oCaster) && iEnergyType==DAMAGE_TYPE_SONIC) fRange *= 2;
    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;

    /*** NWN1 SINGLE ***/ if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;

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
    effect eVisual    = EffectVisualEffect(iVisualType);
    effect eExplode   = EffectVisualEffect(iExplodeType);
    effect eDamage;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);

    spInfo.oTarget = GRGetFirstObjectInShape(iSpellShape, fRange, spInfo.lTarget, iObjectType);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20.0f;
            if(bNoSR || !GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                iOrigDamage = GRGetMetamagicAdjustedDamage(spInfo.iDmgDieType, spInfo.iDmgNumDice, spInfo.iMetamagic, spInfo.iDmgBonus);
                if(!bNoSave) {
                    iDamage = GRGetReflexAdjustedDamage(iOrigDamage, spInfo.oTarget, spInfo.iDC, iSaveType);
                    iSaveMade = (iDamage==0 || (iDamage==iOrigDamage/2 && !GetHasFeat(FEAT_IMPROVED_EVASION, spInfo.oTarget)));
                } else if(spInfo.iSpellID==SPELL_VITRIOLIC_SPHERE) {
                    bVitriolicSave = GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC, iSaveType);
                    if(bVitriolicSave) iDamage = iOrigDamage/2;
                }
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                } else if(iSecDieType>0) {
                    iSecDamage = GRGetMetamagicAdjustedDamage(iSecDieType, iSecNumDice, spInfo.iMetamagic, iSecBonus);
                }
                if(!bNoSave && iSaveMade) {
                    if(GetHasFeat(FEAT_EVASION, spInfo.oTarget) || GetHasFeat(FEAT_IMPROVED_EVASION, spInfo.oTarget)) {
                        iSecDamage = 0;
                    } else {
                        iSecDamage /= 2;
                    }
                }

                //*:**********************************************
                //*:* Adjust damage for Illusions with made will save
                //*:**********************************************
                if(fDamagePercentage!=1.0) {
                    if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster, fDelay)) {
                        iDamage = FloatToInt(iDamage*fDamagePercentage);
                        if(bSecBludgeoning) {
                            iSecDamage = FloatToInt(iSecDamage*fDamagePercentage);
                        }
                    }
                }

                eDamage = EffectDamage(iDamage, iEnergyType);
                eLink = EffectLinkEffects(eDamage, eVisual);
                if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                if(iDamage > 0) {
                    if(iEnergyType!=DAMAGE_TYPE_SONIC || !GetHasEffect(EFFECT_TYPE_SILENCE, spInfo.oTarget)) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                        if(spInfo.iSpellID==SPELL_VITRIOLIC_SPHERE && !bVitriolicSave) {
                            DelayCommand(RoundsToSeconds(1), RunDelayedVitriolicSphereEffects(spInfo));
                            DelayCommand(RoundsToSeconds(2), RunDelayedVitriolicSphereEffects(spInfo));
                            SetLocalInt(spInfo.oTarget, "GR_VITRIOLICSPHERE_ENERGYTYPE", iEnergyType);
                        }
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(iSpellShape, fRange, spInfo.lTarget, iObjectType);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
