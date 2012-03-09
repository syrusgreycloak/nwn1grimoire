//*:**************************************************************************
//*:*  GR_S0_FLMSTRIKE.NSS
//*:**************************************************************************
//*:* Flame Strike (NW_S0_FlmStrike) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Noel Borstad  Created On: Oct 19, 2000
//*:* 3.5 Player's Handbook (p. 231)
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

    int     iDieType          = 6;
    int     iNumDice          = MinInt(15, spInfo.iCasterLevel);
    int     iBonus            = 0;
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
    float   fRange          = FeetToMeters(10.0);

    int     iFireDamage;
    int     iHolyDamage;

    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    /*** NWN1 SINGLE ***/ int     iVisual1        = GRGetEnergyVisualType(VFX_IMP_DIVINE_STRIKE_FIRE, iEnergyType);
    //*** NWN2 SINGLE ***/ int      iVisual1        = GRGetEnergyVisualType(VFX_HIT_SPELL_FLAMESTRIKE, iEnergyType);
    int     iVisual2        = GRGetEnergyVisualType(VFX_IMP_FLAME_S, iEnergyType);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eStrike  = EffectVisualEffect(iVisual1);
    effect eVis     = EffectVisualEffect(iVisual2);
    effect eHoly;
    effect eFire;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eStrike, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE, OBJECT_TYPE_CREATURE |
        OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, TRUE)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_FLAME_STRIKE));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, 0.6)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
                 if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                iHolyDamage = GRGetReflexAdjustedDamage(iDamage/2, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DIVINE);
                iFireDamage = GRGetReflexAdjustedDamage(iDamage/2, spInfo.oTarget, spInfo.iDC, iEnergyType);
                eHoly = EffectDamage(iHolyDamage, DAMAGE_TYPE_DIVINE);
                eFire = EffectDamage(iFireDamage, iEnergyType);
                if(iSecDamage>0) eVis = EffectLinkEffects(eVis, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                if(iFireDamage > 0 || iHolyDamage > 0) {
                    DelayCommand(0.6, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    if(iFireDamage>0) DelayCommand(0.6, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eFire, spInfo.oTarget));
                    if(iHolyDamage>0) DelayCommand(0.6, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHoly, spInfo.oTarget));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE, OBJECT_TYPE_CREATURE |
            OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
