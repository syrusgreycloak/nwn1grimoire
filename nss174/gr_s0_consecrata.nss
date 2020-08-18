//*:**************************************************************************
//*:*  GR_S0_CONSECRATA.NSS
//*:**************************************************************************
//*:* Consecrate (OnEnter) (sg_s0_consecratA.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: September 29, 2004
//*:* 3.5 Player's Handbook (p. 212)
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = 1;
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eAttackPenalty   = EffectAttackDecrease(iBonus);
    effect eDamagePenalty   = EffectDamageDecrease(iBonus);
    effect eSavePenalty     = EffectSavingThrowDecrease(SAVING_THROW_ALL, iBonus);

    effect eUndeadLink      = EffectLinkEffects(eAttackPenalty, eDamagePenalty);
    eUndeadLink = EffectLinkEffects(eUndeadLink, eSavePenalty);

    effect eImpVis  = EffectVisualEffect(VFX_COM_HIT_DIVINE);
    effect eDur     = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MINOR);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_CONSECRATE, FALSE));
    if(GetHasSpellEffect(SPELL_GR_DESECRATE, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELL_GR_DESECRATE, spInfo.oTarget);
    } else {
        GRRemoveSpellEffects(SPELL_GR_CONSECRATE, spInfo.oTarget);
        if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eUndeadLink, spInfo.oTarget);
        } else {
            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDur, spInfo.oTarget);
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
