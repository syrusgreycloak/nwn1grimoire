//*:**************************************************************************
//*:*  GR_S0_PROTNEGPOS.NSS
//*:**************************************************************************
//*:*
//*:* Protection from Negative Energy
//*:* Protection from Positive Energy
//*:* Spell Compendium (p. 163)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: August 6, 2007
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
    int     iBonus            = 10;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel*10;
    int     iDurType          = DUR_TYPE_TURNS;

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

    int     iVisual;
    int     bHostile        = GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster);

    switch(spInfo.iSpellID) {
        case SPELL_NEGATIVE_ENERGY_PROTECTION:
            iDamage = DAMAGE_TYPE_NEGATIVE;
            /*** NWN1 SINGLE ***/ iVisual = VFX_DUR_PROTECTION_GOOD_MINOR;
            //*** NWN2 SINGLE ***/ iVisual = VFX_DUR_GLOW_YELLOW;
            break;
        case SPELL_GR_POSITIVE_ENERGY_PROTECTION:
            iDamage = DAMAGE_TYPE_POSITIVE;
            /*** NWN1 SINGLE ***/ iVisual = VFX_DUR_PROTECTION_EVIL_MINOR;
            //*** NWN2 SINGLE ***/ iVisual = VFX_DUR_GLOW_RED;
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
    effect eVis     = EffectVisualEffect(iVisual);
    /*** NWN1 SINGLE ***/ effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eDR      = EffectDamageResistance(iDamage, iBonus);
    /*** NWN1 SINGLE ***/ effect eLink    = EffectLinkEffects(eDR, eDur);
    //*** NWN2 SINGLE ***/ effect eLink    = eDR;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, bHostile));
    if(!bHostile || !GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(!bHostile || !GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, 1.0f);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
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
