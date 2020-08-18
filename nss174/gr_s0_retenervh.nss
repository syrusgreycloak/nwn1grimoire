//*:**************************************************************************
//*:*  GR_S0_RETENERVH.NSS
//*:**************************************************************************
//*:* Retributive Enervation: OnHit
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 21, 2008
//*:* Complete Mage (p. 116)
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
    object  oItem           = GetSpellCastItem();
    string  sMyTag          = GetTag(oItem);
    object  oCaster         = GetItemPossessor(oItem);
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId(), oItem);

    spInfo.oTarget          = GetLastAttacker(oCaster);
    spInfo.iDC              = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

    int     iNumLevels      = GetLocalInt(oItem, "GR_"+IntToString(spInfo.iSpellID)+"_NUMLEVELS");

    if(iNumLevels<=0) return;

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
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
    //*:* int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    //*:* int     iSpellType      = GRGetEnergySpellType(iEnergyType);

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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eNegLevel = EffectNegativeLevel(1);
    effect eVis      = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eTempHP   = EffectTemporaryHitpoints(5);
    effect eVis1     = EffectVisualEffect(VFX_IMP_HEALING_M);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_UNDEAD) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_RETRIBUTIVE_ENERVATION, TRUE));
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eNegLevel, spInfo.oTarget, fDuration);
        }
        iNumLevels--;
        SetLocalInt(oItem, "GR_"+IntToString(SPELL_GR_RETRIBUTIVE_ENERVATION)+"_NUMLEVELS", iNumLevels);
    } else {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_RETRIBUTIVE_ENERVATION));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTempHP, spInfo.oTarget, GRGetDuration(1, DUR_TYPE_HOURS));
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
