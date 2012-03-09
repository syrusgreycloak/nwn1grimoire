//*:**************************************************************************
//*:*  GR_S0_FIREAURAA.NSS
//*:**************************************************************************
//*:*
//*:* Fire Aura : OnEnter
//*:* 2E Complete Wizard's Handbook
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 10, 2004
//*:**************************************************************************
//*:* Updated On: March 10, 2008
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
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    spInfo.oTarget          = GetEnteringObject();
    spInfo.iDC              = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

    int     iDieType          = 4;
    int     iNumDice          = 2;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;

    int     iRemainingRounds  = MinInt(10, GetLocalInt(OBJECT_SELF,"REMAINING_ROUNDS"));

    int     iDurAmount        = iRemainingRounds;
    int     iDurType          = DUR_TYPE_ROUNDS;

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eImpVis          = EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION);
    effect eAOE             = GREffectAreaOfEffect(AOE_CUSTOM_SMALL, "****", "gr_s0_fireaurad", "****");
    effect eDamage          = EffectDamage(iDamage, DAMAGE_TYPE_FIRE);
    effect eAttackPenalty   = EffectAttackDecrease(2);

    effect eLink            = EffectLinkEffects(eImpVis, eDamage);
    eLink = EffectLinkEffects(eLink, eAttackPenalty);

    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.oTarget!=oCaster) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_FIRE_AURA));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
        }
        if(!GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_FIRE, oCaster)) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, GRGetDuration(iRemainingRounds));

            object oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_CUSTOM_SMALL, oCaster);
            GRSetAOESpellId(spInfo.iSpellID, oAOE);
            GRSetSpellInfo(spInfo, oAOE);
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
