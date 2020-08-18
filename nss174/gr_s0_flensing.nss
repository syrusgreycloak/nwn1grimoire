//*:**************************************************************************
//*:*  GR_S0_FLENSING.NSS
//*:**************************************************************************
//*:*
//*:* Flensing
//*:* Spell Compendium (p. 95)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 5, 2003
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

    int     iDieType          = 6;
    int     iNumDice          = 2;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 4;
    int     iDurType          = DUR_TYPE_ROUNDS;

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
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iChaDmg;
    int     iConDmg;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    iChaDmg = GRGetMetamagicAdjustedDamage(iDieType, 1, spInfo.iMetamagic, iBonus);
    iConDmg = GRGetMetamagicAdjustedDamage(iDieType, 1, spInfo.iMetamagic, iBonus);
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, FORTITUDE_HALF, oCaster);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eAOE         = GREffectAreaOfEffect(AOE_MOB_FLENSING);
    effect eImp         = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eVis         = EffectVisualEffect(VFX_COM_CHUNK_RED_MEDIUM);
    effect eDamage;
    effect eLink;
    effect eCha         = EffectAbilityDecrease(ABILITY_CHARISMA, iChaDmg);
    effect eCon         = EffectAbilityDecrease(ABILITY_CONSTITUTION, iConDmg);
    effect eAbilityLink = EffectLinkEffects(eCha, eCon);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_FLENSING));
    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster) && !GRGetIsIncorporeal(spInfo.oTarget)) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);

            object oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_FLENSING, oCaster);
            GRSetAOESpellId(spInfo.iSpellID, oAOE);
            GRSetSpellInfo(spInfo, oAOE);

            if(iDamage>0) {
                eDamage = EffectDamage(iDamage);
                eLink = EffectLinkEffects(eDamage, eVis);
                if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                if(!GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster)) {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget);
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAbilityLink, spInfo.oTarget, fDuration);
                }
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
