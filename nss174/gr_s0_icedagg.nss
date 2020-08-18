//*:**************************************************************************
//*:*  GR_S0_ICEDAGG.NSS
//*:**************************************************************************
//*:* Ice Dagger (X2_S0_IceDagg) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Nov 25 , 2002
//*:* Spell Compendium (p. 188)
//*:**************************************************************************
//*:* Updated On: December 20, 2007
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

    spInfo.lTarget = GetLocation(spInfo.oTarget);

    int     iDieType          = 4;
    int     iNumDice          = MinInt(5, spInfo.iCasterLevel);
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
    float   fDelay2;
    float   fRange          = FeetToMeters(5.0);

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FROST_S, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    object  oProxTarget;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, iSaveType, fDelay);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDam     = EffectDamage(iDamage, iEnergyType);
    effect eProxDmg = EffectDamage(1, iEnergyType);

    if(iSecDamage>0) {
        eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
        eProxDmg = EffectLinkEffects(eProxDmg, EffectDamage(1, spInfo.iSecDmgType));
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));

    fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
    if(!GRGetSpellResisted(OBJECT_SELF, spInfo.oTarget, fDelay)) {
        if(iDamage > 0) {
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }

            oProxTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
            while(GetIsObjectValid(oProxTarget)) {
                if(GRGetIsSpellTarget(oProxTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster) && oProxTarget!=spInfo.oTarget) {
                    fDelay2 = GetDistanceBetween(spInfo.oTarget, oProxTarget)/20;
                    DelayCommand(fDelay+fDelay2, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eProxDmg, oProxTarget));
                    DelayCommand(fDelay+fDelay2, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oProxTarget));
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                }
                oProxTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
            }
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
