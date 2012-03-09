//*:**************************************************************************
//*:*  GR_S0_CHLIGHTN.NSS
//*:**************************************************************************
//*:*
//*:* Chain Lightning NW_S0_ChLightn Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 208)
//*:*
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

    int     iDieType        = 6;
    int     iNumDice        = MinInt(20, spInfo.iCasterLevel);
    int     iBonus          = 0;
    int     iDamage         = 0;
    int     iSecDamage      = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    float   fDmgPercent     = 1.0;
    int     bIllusion       = FALSE;

    if(spInfo.iSpellID==SPELL_GR_GSE2_CHAIN_LIGHTNING) {
        fDmgPercent = 0.6;
        bIllusion   = TRUE;
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(30.0);

    int     iVisualType;
    iVisualType = GRGetEnergyVisualType(VFX_IMP_LIGHTNING_S, iEnergyType);
    int     iBeamType       = GRGetEnergyBeamType(iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iNumSubTargets  = MinInt(20, spInfo.iCasterLevel);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    //*:* iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    iDamage = GRGetMetamagicAdjustedDamage(spInfo.iDmgDieType, spInfo.iDmgNumDice, spInfo.iMetamagic, spInfo.iDmgBonus);
    int iSubDamage = iDamage / 2;
    iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    if(bIllusion) {
        if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster)) {
            iDamage = FloatToInt(iDamage * fDmgPercent);
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eLightning   = EffectBeam(iBeamType, oCaster, BODY_NODE_HAND);
    effect eVis         = EffectVisualEffect(iVisualType);
    effect eDamage      = EffectDamage(iDamage, iEnergyType);

    if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    effect eLink        = EffectLinkEffects(eVis, eDamage);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_CHAIN_LIGHTNING));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, spInfo.oTarget, 1.7f);
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(iDamage>0) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
        }
    }

    spInfo.lTarget = GetLocation(spInfo.oTarget);
    eLightning = EffectBeam(iBeamType, spInfo.oTarget, BODY_NODE_CHEST);

    object oNextTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

    while(GetIsObjectValid(oNextTarget) && iNumSubTargets>0) {
        if(GRGetIsSpellTarget(oNextTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(oNextTarget, EventSpellCastAt(oCaster, SPELL_CHAIN_LIGHTNING));
            fDelay = GetDistanceBetween(spInfo.oTarget, oNextTarget)/20.0f;
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, oNextTarget, fDelay+1.7));
            if(!GRGetSpellResisted(oCaster, oNextTarget)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, oNextTarget);
                iDamage = GRGetReflexAdjustedDamage(iSubDamage, oNextTarget, spInfo.iDC, iSaveType, oCaster);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                if(iDamage>0) {
                    if(bIllusion) {
                        if(GRGetSaveResult(SAVING_THROW_WILL, oNextTarget, spInfo.iDC, iSaveType, oCaster)) {
                            iDamage = FloatToInt(iDamage * fDmgPercent);
                        }
                    }

                    eDamage = EffectDamage(iDamage, iEnergyType);
                    if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    eLink = EffectLinkEffects(eDamage, eVis);
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oNextTarget));
                }
            }
            iNumSubTargets--;
        }
        oNextTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
