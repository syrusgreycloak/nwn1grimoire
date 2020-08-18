//*:**************************************************************************
//*:*  GR_S0_ENEBUFFER.NSS
//*:**************************************************************************
//*:*
//*:* Energy Buffer (NW_S0_EneBuffer) Copyright (c) 2001 Bioware Corp.
//*:* Tome & Blood (p. 87)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Sept 12, 2001
//*:**************************************************************************
//*:* Updated On: November 19, 2007
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

    int     iDieType        = 6;
    int     iNumDice        = MinInt(15, spInfo.iCasterLevel);
    int     iBonus          = 0;
    int     iDamage         = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 1;
    int     iDurType          = DUR_TYPE_DAYS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eCold    = EffectDamageResistance(DAMAGE_TYPE_COLD, iDamage, iDamage);
    effect eFire    = EffectDamageResistance(DAMAGE_TYPE_FIRE, iDamage, iDamage);
    effect eAcid    = EffectDamageResistance(DAMAGE_TYPE_ACID, iDamage, iDamage);
    effect eSonic   = EffectDamageResistance(DAMAGE_TYPE_SONIC, iDamage, iDamage);
    effect eElec    = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, iDamage, iDamage);
    effect eDur     = EffectVisualEffect(VFX_DUR_PROTECTION_ELEMENTS);
    effect eVis     = EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION);
    effect eDur2    = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eCold, eFire);
    eLink = EffectLinkEffects(eLink, eAcid);
    eLink = EffectLinkEffects(eLink, eSonic);
    eLink = EffectLinkEffects(eLink, eElec);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eDur2);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(SPELL_ENERGY_BUFFER, spInfo.oTarget);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_ENERGY_BUFFER, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
