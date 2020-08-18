//*:**************************************************************************
//*:*  GR_S0_DIVINTER.NSS
//*:**************************************************************************
//*:*
//*:* Divine Interdiction
//*:* Spell Compendium (p. 70)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 12, 2004
//*:**************************************************************************
//*:* Updated On: March 11, 2008
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAOEType        = AOE_PER_DIVINE_INTERDICTION;
    string  sAOEType        = AOE_TYPE_DIVINE_INTERDICTION;

    object  oAOE;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        iAOEType = AOE_PER_DIVINE_INTERDICTION_WIDE;
        sAOEType = AOE_TYPE_DIVINE_INTERDICTION_WIDE;
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
    effect eImpVis = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_HOLY);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eAOE = GREffectAreaOfEffect(iAOEType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(spInfo.oTarget)) {
        if(!GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster) && GetObjectType(spInfo.oTarget)==OBJECT_TYPE_CREATURE) {
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_DIVINE_INTERDICTION));
                }
            }
        } else {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_DIVINE_INTERDICTION, FALSE));
        }
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, fDuration);
        oAOE = GRGetAOEOnObject(spInfo.oTarget, sAOEType, oCaster);
    } else {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpVis, spInfo.lTarget);
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);
        oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
    }
    GRSetAOESpellId(spInfo.iSpellID, oAOE);
    GRSetSpellInfo(spInfo, oAOE);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
