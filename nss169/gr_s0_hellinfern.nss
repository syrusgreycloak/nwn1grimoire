//*:**************************************************************************
//*:*  GR_S0_HELLINFERN.NSS
//*:**************************************************************************
//*:* Hellish Inferno (x0_s0_inferno.nss) Copyright (c) 2000 Bioware Corp.
//*:* Georg Z, 19-10-2003
//*:**************************************************************************
/*
    NPC only spell for yaron

    like normal inferno but lasts only 5 rounds,
    ticks twice per round, adds attack and damage
    penalty.

*/
//*:**************************************************************************
//*:* Updated On: February 15, 2008
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
//*:* Supporting functions
//*:**************************************************************************
void RunImpact(object oTarget, object oCaster, int iMetamagic) {
    //--------------------------------------------------------------------------
    // Check if the spell has expired (check also removes effects)
    //--------------------------------------------------------------------------
    if(GZGetDelayedSpellEffectsExpired(762, oTarget, oCaster)) {
        GRClearSpellInfo(762, oTarget);
        return;
    }

    struct SpellStruct spInfo = GRGetSpellInfoFromObject(762, oTarget);

    if(GetIsDead(oTarget) == FALSE) {
        //* GZ: Removed Meta magic, does not work in delayed functions
        //* SG: Re-added metamagic by passing metamagic value used when
        //* SG: spell was cast
        int iFireDamage = GRGetMetamagicAdjustedDamage(6, 2, iMetamagic, 0);
        int iDivineDamage = GRGetMetamagicAdjustedDamage(6, 1, iMetamagic, 0);
        effect eDam  = EffectDamage(iFireDamage, DAMAGE_TYPE_FIRE);
        effect eDam2 = EffectDamage(iDivineDamage, DAMAGE_TYPE_DIVINE);
        effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);
        eDam = EffectLinkEffects(eVis,eDam); // flare up
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam2, oTarget);
        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
        }
        DelayCommand(3.0f, RunImpact(oTarget, oCaster, iMetamagic));
    }
}
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
    int     iDurAmount        = spInfo.iCasterLevel/2;
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
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    if(GetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget)) {
        FloatingTextStrRefOnCreature(100775, oCaster, FALSE);
        return;
    }

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = GetDistanceBetween(spInfo.oTarget, oCaster)/13;
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

    if(fDuration>GRGetDuration(6)) fDuration = GRGetDuration(6);

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eRay         = EffectBeam(444, oCaster, BODY_NODE_CHEST);
    effect eAttackDec   = EffectAttackDecrease(4);
    effect eDamageDec   = EffectDamageDecrease(4);
    effect eLink        = EffectLinkEffects(eAttackDec, eDamageDec);
    effect eDur         = EffectVisualEffect(498);
    effect eSmoke       = EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spInfo.oTarget, 3.0f);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, fDuration));
        DelayCommand(fDelay, RunImpact(spInfo.oTarget, oCaster, spInfo.iMetamagic));
        GRSetSpellInfo(spInfo, spInfo.oTarget);
    } else {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spInfo.oTarget, 2.0f);
        DelayCommand(fDelay+0.3f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, spInfo.oTarget));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
