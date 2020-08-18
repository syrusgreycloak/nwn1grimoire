//*:**************************************************************************
//*:*  GR_S0_LIFETRANS.NSS
//*:**************************************************************************
//*:* Life Force Transfer (SG_S0_LifeTrans.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 11, 2003
//*:*
//*:**************************************************************************
//*:* Updated On: February 25, 2008
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
    int     iNumDice          = MinInt(15, spInfo.iCasterLevel);
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
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iHPDmg          = GetMaxHitPoints(spInfo.oTarget)-GetCurrentHitPoints(spInfo.oTarget);
    int     iAbsorb         = MinInt(2*iNumDice, GetCurrentHitPoints(oCaster)+10);
    int     iHeal           = iAbsorb*2;

    if(iHPDmg<iHeal) {
        iAbsorb = iHPDmg/2;
        iHeal = iAbsorb*2;
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
    effect eHealVis     = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eHeal        = EffectHeal(iHeal);
    effect eBeam        = EffectBeam(VFX_BEAM_COLD, oCaster, BODY_NODE_CHEST);
    effect eDmgVis      = EffectVisualEffect(VFX_IMP_HEAD_ODD);
    effect eDamage      = EffectDamage(iAbsorb, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY);
    effect eHealLink    = EffectLinkEffects(eHealVis, eHeal);
    effect eDamageLink  = EffectLinkEffects(eDmgVis, eDamage);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_LIFE_TRANSFER, FALSE));
    if(GRGetIsLiving(spInfo.oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, spInfo.oTarget, 1.5f);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHealLink, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamageLink, oCaster);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
