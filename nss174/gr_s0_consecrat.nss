//*:**************************************************************************
//*:*  GR_S0_CONSECRAT.NSS
//*:**************************************************************************
//*:* Consecrate (sg_s0_consecrat.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: September 29, 2004
//*:* 3.5 Player's Handbook (p. 212)
//*:*
//*:* Desecrate (sg_s0_desecrate.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: September 29, 2004
//*:* 3.5 Player's Handbook (p. 218)
//*:**************************************************************************
//*:* Updated On: March 3, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel*2;
    int     iDurType          = DUR_TYPE_HOURS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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

    float   fDuration           = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    float   fRange              = FeetToMeters(20.0);

    int     iDispelledOpp       = FALSE;

    int     iAOEType            = AOE_PER_CONSECRATE;
    string  sAOEType            = AOE_TYPE_CONSECRATE;
    string  sOppAOEType1        = AOE_TYPE_DESECRATE;
    string  sOppAOEType2        = AOE_TYPE_DESECRATE_WIDE;
    int     iOppAOEText         = 16939278;

    if(spInfo.iSpellID==SPELL_GR_DESECRATE) {
        iAOEType = AOE_PER_DESECRATE;
        sAOEType = AOE_TYPE_DESECRATE;
        sOppAOEType1 = AOE_TYPE_CONSECRATE;
        sOppAOEType2 = AOE_TYPE_CONSECRATE_WIDE;
        iOppAOEText = 16939277;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        fRange *= 2;
        if(spInfo.iSpellID==SPELL_GR_CONSECRATE) {
            iAOEType = AOE_PER_CONSECRATE_WIDE;
            sAOEType = AOE_TYPE_CONSECRATE_WIDE;
        } else {
            iAOEType = AOE_PER_DESECRATE_WIDE;
            sAOEType = AOE_TYPE_DESECRATE_WIDE;
        }
    }
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
    effect eImpVis = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_FIRE);
    effect eAOE = GREffectAreaOfEffect(iAOEType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpVis, spInfo.lTarget);

    object oAOE = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    while(GetIsObjectValid(oAOE)) {
        if(GetTag(oAOE)==sOppAOEType1 || GetTag(oAOE)==sOppAOEType2) {
            DestroyObject(oAOE);
            iDispelledOpp = TRUE;
        }
        oAOE = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    }

    if(iDispelledOpp) {
        FloatingTextStrRefOnCreature(iOppAOEText, oCaster, FALSE);
    } else {
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);
        oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
        GRSetAOESpellId(spInfo.iSpellID, oAOE);
        GRSetSpellInfo(spInfo, oAOE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
