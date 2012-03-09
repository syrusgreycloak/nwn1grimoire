//*:**************************************************************************
//*:*  GR_S0_SCORCH.NSS
//*:**************************************************************************
//*:* Aganazzar's Scorcher
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 5, 2003
//*:* Scorch - Spell Compendium (p. 181)
//*:**************************************************************************
//*:* Updated On: June 21, 2007
//*:* BUGFIX:  GetFirst/NextTarget selection had wrong type of OR operators
//*:**************************************************************************
//*:* Updated On: February 21, 2008
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

    int     iDieType          = 8;
    int     iNumDice          = MinInt(5, spInfo.iCasterLevel/2);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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

    float   fDuration       = GRGetSpellDuration(spInfo, iEnergyType);
    float   fDelay          = 1.5f;
    float   fRange          = FeetToMeters(30.0);

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_S, iEnergyType);
    int     iBeamType       = GRGetEnergyBeamType(iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    int     bOutOfRange     = FALSE;
    location lCasterLoc     = GetLocation(oCaster);
    location lTargetLoc     = GetLocation(spInfo.oTarget);
    float   fAngleToTarget  = GetAngleBetweenLocations(lCasterLoc, lTargetLoc);
    float   fNear           = FeetToMeters(5.0);
    object  oApplyTo;
    object  oNextTarget;

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
    effect eVis = EffectBeam(iBeamType, oCaster, BODY_NODE_HAND);
    effect eImp = EffectVisualEffect(iVisualType);
    effect eDamage;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.lTarget = GenerateNewLocationFromLocation(lCasterLoc, fRange, fAngleToTarget, fAngleToTarget);

    //*:* Try to get an object near the location of end-of-range
    oApplyTo = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR, spInfo.lTarget);

    if(!GRGetIsUnderwater(oCaster) && iEnergyType!=DAMAGE_TYPE_ELECTRICAL) {
        if(GetDistanceToObject(spInfo.oTarget)>fRange) bOutOfRange = TRUE;

        if(GetDistanceBetweenLocations(GetLocation(oApplyTo), spInfo.lTarget)<=fNear) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oApplyTo, 1.5f);
        } else {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, 1.5f);
        }

        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_AGANAZZARS_SCORCHER));
        if(!bOutOfRange) {
            if(!GRGetSpellResisted(oCaster,spInfo.oTarget)) {
                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                if(spInfo.iSpellID==SPELL_GR_LSE_AGANAZZARS_SCORCHER) {
                    if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                        iDamage = FloatToInt(iDamage*0.2f);
                    }
                }
                if(iDamage>0) {
                    eDamage = EffectDamage(iDamage, iEnergyType);
                    if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget));
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                }
            }
        }

        oNextTarget = GRGetFirstObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
            OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        while(GetIsObjectValid(oNextTarget)) {
            if(GRGetIsSpellTarget(oNextTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster) && oNextTarget!=spInfo.oTarget) {
                SignalEvent(oNextTarget, EventSpellCastAt(oCaster, SPELL_GR_AGANAZZARS_SCORCHER));
                fDelay = 1.5 + GetDistanceBetween(oCaster, spInfo.oTarget)/20;
                if(!GRGetSpellResisted(oCaster,oNextTarget)) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, oNextTarget);
                    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    if(spInfo.iSpellID==SPELL_GR_LSE_AGANAZZARS_SCORCHER) {
                        if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                            iDamage = FloatToInt(iDamage*0.2f);
                        }
                    }
                    if(iDamage>0) {
                        eDamage = EffectDamage(iDamage, iEnergyType);
                        if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                    }
                }
            }
            oNextTarget = GRGetNextObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
                OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        }
    } else {
        eVis = EffectVisualEffect(GRGetEnergyExplodeType(iEnergyType));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(10.0), spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
            OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        while(GetIsObjectValid(spInfo.oTarget)) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, TRUE)) {
                SignalEvent(oNextTarget, EventSpellCastAt(oCaster, SPELL_GR_AGANAZZARS_SCORCHER));
                fDelay = 1.5 + GetDistanceBetween(oCaster, spInfo.oTarget)/20;
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    if(iDamage>0) {
                        eDamage = EffectDamage(iDamage, iEnergyType);
                        if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget));
                    }
                }
            }
            oNextTarget = GRGetNextObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
                OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
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
