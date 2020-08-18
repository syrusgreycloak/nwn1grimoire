//*:**************************************************************************
//*:*  GR_S0_LGHTNBOLT.NSS
//*:**************************************************************************
//*:* Lightning Bolt NW_S0_LightnBolt Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 248)
//*:**************************************************************************
//*:* Updated On: October 25, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

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
    int     iNumDice        = spInfo.iCasterLevel;
    int     iBonus          = 0;
    int     iDamage         = 0;
    int     iSecDamage      = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    int     iCnt = 1;
    float   fDmgPercent     = 1.0;
    int     bIllusion       = FALSE;

    switch(spInfo.iSpellID) {
        case SPELL_GR_SHAD_EVOC2_LIGHTNING_BOLT:
            fDmgPercent = 0.4;
            bIllusion   = TRUE;
        case SPELL_LIGHTNING_BOLT:
            iNumDice = (spInfo.iCasterLevel>10 ? 10 : spInfo.iCasterLevel);
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(120.0);

    int     iVisualType;
    /*** NWN1 SINGLE ***/ iVisualType = GRGetEnergyVisualType(VFX_IMP_LIGHTNING_S, iEnergyType);
    //*** NWN2 SINGLE ***/ iVisualType = GRGetEnergyVisualType(VFX_HIT_SPELL_LIGHTNING, iEnergyType);
    int     iBeamType       = GRGetEnergyBeamType(iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration         = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType     = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    //*:* iDamage = GRGetSpellDamageAmount(spInfo);
    /*if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }/**/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eLightning   = EffectBeam(iBeamType, oCaster, BODY_NODE_HAND);
    effect eVis         = EffectVisualEffect(iVisualType);
    effect eDamage;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GRGetIsUnderwater(oCaster) || iEnergyType!=DAMAGE_TYPE_ELECTRICAL) {
        /*** NWN2 SPECIFIC ***
            if(GetIsObjectValid(spInfo.oTarget) && GetDistanceBetween(spInfo.oTarget, oCaster)!=fRange) {
                location lEndLocation = GenerateNewLocationFromLocation(GetLocation(oCaster), fRange, GetFacing(oCaster), GetFacing(oCaster));
                object oPoint = CreateObject(OBJECT_TYPE_CREATURE, "c_attachspellnode" , lEndLocation);
                SetScriptHidden(oPoint, TRUE);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, oPoint, 1.0);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPoint);
                DestroyObject(oPoint, 2.0);
            }
        /*** END NWN2 SPECIFIC ***/

        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, GetPosition(oCaster));
        while(GetIsObjectValid(spInfo.oTarget)) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20.0;
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    if(iDamage>0 && bIllusion) {
                        if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                            iDamage = FloatToInt(iDamage * fDmgPercent);
                        }
                    }
                    eDamage = EffectDamage(iDamage, iEnergyType);
                    eLink = EffectLinkEffects(eVis, eDamage);
                    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    if(iDamage > 0) {
                        //fDelay = GetSpellEffectDelay(GetLocation(spInfo.oTarget), spInfo.oTarget);
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                    }
                }
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, spInfo.oTarget, 1.0);
                eLightning = EffectBeam(iBeamType, spInfo.oTarget, BODY_NODE_CHEST);
            }
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
                OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, GetPosition(oCaster));
        }
    } else {
        effect eExplode = EffectVisualEffect(GRGetEnergyExplodeType(iEnergyType));
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        while(GetIsObjectValid(spInfo.oTarget)) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20;
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    iDamage = GRGetMetamagicAdjustedDamage(iDieType,  iNumDice, spInfo.iMetamagic, iBonus);
                    iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, iSaveType);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    eDamage = EffectDamage(iDamage, iEnergyType);
                    eLink = EffectLinkEffects(eVis, eDamage);
                    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    if(iDamage > 0) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                    }
                }
            }
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
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
