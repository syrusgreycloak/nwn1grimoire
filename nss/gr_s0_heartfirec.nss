//*:**************************************************************************
//*:*  GR_S0_HEARTFIREC.NSS
//*:**************************************************************************
//*:* Heartfire (OnHeartbeat)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 24, 2008
//*:* Spell Compendium (p. 112)
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
//#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_LIGHTDARK"

#include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    int     iDieType          = 4;
    int     iNumDice          = 1;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = GetLocalInt(spInfo.oTarget, "GR_HF_DUR_"+ObjectToString(oCaster));
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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     bSaveMade           = GetLocalInt(spInfo.oTarget, "GR_HF_SAVE_"+ObjectToString(oCaster));
    int     iSaveType           = GRGetEnergySaveType(iEnergyType);
    int     iDmgVis             = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster);
    if(bSaveMade) iDamage = MaxInt(iDamage/2, 1);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eDmgVis  = EffectVisualEffect(iDmgVis);
    effect eDmg     = EffectDamage(iDamage, iEnergyType);
    effect eLink    = EffectLinkEffects(eDmgVis, eDmg);

    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    effect eOutline = EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eLight   = EffectVisualEffect(VFX_DUR_LIGHT_RED_10);
    effect eVisLink = EffectLinkEffects(eOutline, eLight);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_GR_HEARTFIRE));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
    }
    iDurAmount--;
    SetLocalInt(spInfo.oTarget, "GR_HF_DUR_"+ObjectToString(oCaster), iDurAmount);
    SetLocalInt(spInfo.oTarget, "GR_HF_DMG", iDamage + iSecDamage);

    if(!GRGetHasEffectTypeFromSpell(EFFECT_TYPE_VISUALEFFECT, spInfo.oTarget, SPELL_GR_HEARTFIRE)) {
        if(!GRGetHigherLvlDarknessEffectsInArea(SPELL_GR_HEARTFIRE, GetLocation(spInfo.oTarget))) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVisLink, spInfo.oTarget, RoundsToSeconds(iDurAmount));
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
