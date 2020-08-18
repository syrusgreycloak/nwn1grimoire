//*:**************************************************************************
//*:*  GR_S0_CALLLGHTN.NSS
//*:**************************************************************************
//*:*
//*:* Call Lightning - 3.5 Player's Handbook (p. 207)
//*:*
//*:* Call Lightning Storm  - 3.5 Player's Handbook (p. 207)
//*:*
//*:* I totally rewrote Call Lightning to work more similarly to the Player's
//*:* Handbook and added Call Lightning Storm code as well.
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
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
    int     iNumDice        = (spInfo.iSpellID==SPELL_CALL_LIGHTNING ? 3 : 5);
    int     iBonus          = 0;
    int     iDamage         = 0;
    int     iSecDamage      = 0;
    int     iDurAmount      = spInfo.iCasterLevel;
    int     iDurType        = DUR_TYPE_TURNS;

    //*:**********************************************
    //*:* Check weather
    //*:**********************************************
    if(GetWeather(GetArea(oCaster))==WEATHER_RAIN && GetIsAreaAboveGround(GetArea(oCaster))) {
        iDieType = 10;
    }

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

    float   fDuration       = GRGetSpellDuration(spInfo);

    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iVisualType;
    /*** NWN1 SINGLE ***/ iVisualType = GRGetEnergyVisualType(VFX_IMP_LIGHTNING_M, iEnergyType);
    //*** NWN2 SINGLE ***/ iVisualType = GRGetEnergyVisualType(VFX_HIT_SPELL_LIGHTNING, iEnergyType);

    string  sAOEType        = AOE_TYPE_CALL_LIGHTNING;
    int     iAOEEffect      = AOE_MOB_CALL_LIGHTNING;
    object  oMainTarget;
    object  oAOE;
    int     iNumBolts       = MinInt(10, spInfo.iCasterLevel);

    float   fDelay;
    float   fRange          = FeetToMeters(2.5); // half size of side of square

    //*:**********************************************
    //*:* Adjustments for Call Lightning Storm
    //*:**********************************************
    if(spInfo.iSpellID==SPELL_CALL_LIGHTNING_STORM) {
        iNumBolts = MinInt(15, spInfo.iCasterLevel);
        sAOEType = AOE_TYPE_CALL_LIGHTNING_STORM;
        iAOEEffect = AOE_MOB_CALL_LIGHTNING_STORM;
    }

    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);
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
    effect eAOE     = GREffectAreaOfEffect(iAOEEffect, "", "", "", sAOEType);
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDam;
    effect eLink    = eVis;
    /*** NWN2 SPECIFIC ***
        effect eVis2 = EffectVisualEffect(916);  //VFX_SPELL_HIT_CALL_LIGHTNING
        effect eDur = EffectVisualEffect(915); //VFX_SPELL_DUR_CALL_LIGHTNING
        eLink = EffectLinkEffects(eVis, eVis2);
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:**********************************************
    //*:* Check if target or location selected
    //*:**********************************************
    if(!GetIsObjectValid(spInfo.oTarget)) {
        spInfo.lTarget = GetSpellTargetLocation();
    } else {
        oMainTarget = spInfo.oTarget;
        spInfo.lTarget = GetLocation(spInfo.oTarget);
    }


    //*:**********************************************
    //*:* Cycle through target square
    //*:**********************************************
    //*** NWN2 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eDur, spInfo.lTarget, 1.75);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_CUBE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
        OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

    while (GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, TRUE)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetRandomDelay(0.4, 1.75);
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                eDam = EffectDamage(iDamage, iEnergyType);
                eLink = EffectLinkEffects(eLink, eDam);
                if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                if(iDamage > 0) {
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                }
             }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_CUBE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
            OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
    //*:**********************************************
    //*:* Apply AOE and tracking info
    //*:**********************************************
    iNumBolts--;

    //*** NWN2 SINGLE ***/ oAOE = GetObjectByTag(sAOEType);
    if(GetIsObjectValid(oMainTarget)) {
        spInfo.oTarget = oMainTarget;
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, oMainTarget, fDuration);
        /*** NWN1 SINGLE ***/ oAOE = GRGetAOEOnObject(oMainTarget, sAOEType, oCaster);
        SetLocalString(oAOE, "GR_CL_TYPE", "MOB");
    } else {
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);
        /*** NWN1 SINGLE ***/ oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
        SetLocalString(oAOE, "GR_CL_TYPE", "LOC");
    }

    GRSetSpellInfo(spInfo, oAOE);
    GRSetAOESpellId(spInfo.iSpellID, oAOE);
    SetLocalInt(oAOE, "GR_CL_NUMBOLTS", iNumBolts);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
