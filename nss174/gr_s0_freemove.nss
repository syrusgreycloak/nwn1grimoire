//*:**************************************************************************
//*:*  GR_S0_FREEMOVE.NSS
//*:**************************************************************************
//*:* Freedom of Movement (NW_S0_FreeMove.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Oct 29, 2001
//*:* 3.5 Player's Handbook (p. 233)
//*:**************************************************************************
//*:* Freedom of Movement (Travel Domain Power)
//*:*
//*:**************************************************************************
//*:* Updated On: October 25, 2007
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
    int     iDurAmount        = (spInfo.iSpellID==SPELL_FREEDOM_OF_MOVEMENT ? spInfo.iCasterLevel : GRGetLevelByClass(CLASS_TYPE_CLERIC, oCaster));
    int     iDurType          = (spInfo.iSpellID==SPELL_FREEDOM_OF_MOVEMENT ? DUR_TYPE_TURNS : DUR_TYPE_ROUNDS);

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
    effect eParal       = EffectImmunity(IMMUNITY_TYPE_PARALYSIS);
    effect eEntangle    = EffectImmunity(IMMUNITY_TYPE_ENTANGLE);
    effect eSlow        = EffectImmunity(IMMUNITY_TYPE_SLOW);
    effect eMove        = EffectImmunity(IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE);
    effect eVis         = EffectVisualEffect(VFX_DUR_FREEDOM_OF_MOVEMENT);
    /*** NWN1 SINGLE ***/ effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //*:* Link effects
    effect eLink = EffectLinkEffects(eParal, eEntangle);
    eLink = EffectLinkEffects(eLink, eSlow);
    eLink = EffectLinkEffects(eLink, eVis);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eMove);

    if(spInfo.iSpellID==SPELLABILITY_GR_FREEDOM_OF_MOVEMENT) {
        eLink = SupernaturalEffect(eLink);
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));

    //*:**********************************************
    //*:* We need to do the loop here instead of using
    //*:* the GRRemoveMultipleEffects function so that
    //*:* we do not remove effects from certains spells
    //*:**********************************************
    effect eEff = GetFirstEffect(spInfo.oTarget);
    while(GetIsEffectValid(eEff)) {
        if((GetEffectType(eEff) == EFFECT_TYPE_PARALYZE ||
            GetEffectType(eEff) == EFFECT_TYPE_ENTANGLE ||
            GetEffectType(eEff) == EFFECT_TYPE_SLOW ||
            GetEffectType(eEff) == EFFECT_TYPE_MOVEMENT_SPEED_DECREASE) &&
            GetEffectSpellId(eEff) != SPELL_IRON_BODY
            /*** NWN2 SPECIFIC ***
            && GetEffectSpellId(eEff) != SPELL_FOUNDATION_OF_STONE &&
            GetEffectSpellId(eEff) != SPELL_TORTOISE_SHELL &&
            GetEffectSpellId(eEff) != SPELL_STONE_BODY
            /*** END NWN2 SPECIFIC ***/
            ) {

            GRRemoveEffect(eEff, spInfo.oTarget);
        }
        eEff = GetNextEffect(spInfo.oTarget);
    }

    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
