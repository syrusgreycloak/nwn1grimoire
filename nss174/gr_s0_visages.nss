//*:**************************************************************************
//*:*  GR_S0_VISAGES.NSS
//*:**************************************************************************
//*:* Ghostly Visage (NW_S0_GhostVis.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2001
//*:* Bioware Spell
//*:*
//*:* Ethereal Visage (NW_S0_EtherVis.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 7, 2002
//*:* Bioware Spell
//*:**************************************************************************
//*:* Updated On: November 2, 2007
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
    int     iDurAmount        = (spInfo.iSpellID==SPELLABILITY_AS_GHOSTLY_VISAGE ? GetLevelByClass(CLASS_TYPE_ASSASSIN) : spInfo.iCasterLevel);
    int     iDurType          = (spInfo.iSpellID==SPELL_ETHEREAL_VISAGE ? DUR_TYPE_ROUNDS : DUR_TYPE_TURNS);

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iVisualType;
    int     iDmgReductionAmt;
    int     iDmgPowerBypass;
    int     iConcealAmt;
    int     iSpellLevelAbsorb;
    //*** NWN2 SINGLE ***/ int     iDRType;

    switch(spInfo.iSpellID) {
        case SPELL_GHOSTLY_VISAGE:
            /*** NWN1 SINGLE ***/ iVisualType = VFX_DUR_GHOSTLY_VISAGE;
            /*** NWN2 SPECIFIC ***
                iVisualType = VFX_DUR_SPELL_GHOSTLY_VISAGE;
                iDRType = DR_TYPE_MAGICBONUS;
            /*** END NWN2 SPECIFIC ***/
            iDmgReductionAmt = 5;
            iDmgPowerBypass = DAMAGE_POWER_PLUS_ONE;
            iSpellLevelAbsorb = 1;
            iConcealAmt = 10;
            break;
        case SPELL_ETHEREAL_VISAGE:
            /*** NWN1 SPECIFIC ***/
                iVisualType = VFX_DUR_ETHEREAL_VISAGE;
                iDmgPowerBypass = DAMAGE_POWER_PLUS_THREE;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iVisualType = VFX_DUR_SPELL_ETHEREAL_VISAGE;
                iDmgPowerBypass = GMATERIAL_METAL_ADAMANTINE;
                iDRType = DR_TYPE_MATERIAL;
            /*** END NWN2 SPECIFIC ***/
            iDmgReductionAmt = 20;
            iSpellLevelAbsorb = 2;
            iConcealAmt = 25;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    /*** NWN1 SINGLE ***/ effect eDam     = EffectDamageReduction(iDmgReductionAmt, iDmgPowerBypass);
    //*** NWN2 SINGLE ***/ effect eDam     = EffectDamageReduction(iDmgReductionAmt, iDmgPowerBypass, 0, iDRType);
    effect eSpell   = EffectSpellLevelAbsorption(iSpellLevelAbsorb);
    effect eConceal = EffectConcealment(iConcealAmt);
    /*** NWN1 SINGLE ***/ effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eDam, eVis);
    eLink = EffectLinkEffects(eLink, eSpell);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eConceal);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
