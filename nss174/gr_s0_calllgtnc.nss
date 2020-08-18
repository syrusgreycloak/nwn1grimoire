//*:**************************************************************************
//*:*  GR_S0_CALLLGHTNC.NSS
//*:**************************************************************************
//*:*
//*:* ON HEARTBEAT:
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
    object  oCaster         = GetAreaOfEffectCreator();

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
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
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    //*:* spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iVisualType;
    /*** NWN1 SINGLE ***/ iVisualType = GRGetEnergyVisualType(VFX_IMP_LIGHTNING_M, iEnergyType);
    //*** NWN2 SINGLE ***/ iVisualType = GRGetEnergyVisualType(VFX_HIT_SPELL_LIGHTNING, iEnergyType);

    int     iNumBolts       = GetLocalInt(OBJECT_SELF, "GR_CL_NUMBOLTS");
    string  sAOEType        = AOE_TYPE_CALL_LIGHTNING;
    int     iAOEEffect      = AOE_MOB_CALL_LIGHTNING;
    object  oMainTarget;
    string  sType           = GetLocalString(OBJECT_SELF, "GR_CL_TYPE");

    float   fDelay;
    float   fRange          = FeetToMeters(2.5); // half size of side of square

    if(sType=="MOB") {
        oMainTarget = spInfo.oTarget;
        spInfo.lTarget = GetLocation(oMainTarget);
    } else {
        oMainTarget = OBJECT_INVALID;
        spInfo.oTarget = OBJECT_INVALID;
    }

    //*:**********************************************
    //*:* Check weather
    //*:**********************************************
    if(GetWeather(GetArea(oCaster))==WEATHER_RAIN && GetIsAreaAboveGround(GetArea(OBJECT_SELF))) {
        spInfo.iDmgDieType = 10;
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
    //*:* Cycle through target square
    //*:**********************************************
    //*** NWN2 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eDur, spInfo.lTarget, 1.75);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_CUBE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
        OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, TRUE)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetRandomDelay(0.4, 1.75);
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType);
                eDam = EffectDamage(iDamage, iEnergyType);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                if(iDamage > 0) {
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
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

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
