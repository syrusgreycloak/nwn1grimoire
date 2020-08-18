//*:**************************************************************************
//*:*  GR_S0_DTHKNELL.NSS
//*:**************************************************************************
//*:* Death Knell
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 9, 2008
//*:* 3.5 Player's Handbook (p. 217)
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

    if(!GRGetIsLiving(spInfo.oTarget) || (GetIsDead(spInfo.oTarget) && !GRGetIsDying(spInfo.oTarget))) {
        // only works on dying creatures
        return;
    }

    int     iDieType          = 8;
    int     iNumDice          = 1;
    int     iBonus            = 0;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = GetHitDice(spInfo.oTarget);
    int     iDurType          = DUR_TYPE_TURNS;

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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eDeath   = EffectDeath();

    effect eCasterVis   = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eTempHP      = EffectTemporaryHitpoints(iDamage);
    effect eStrBonus    = EffectAbilityIncrease(ABILITY_STRENGTH, 2);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink        = EffectLinkEffects(eDur, eTempHP);
    eLink = EffectLinkEffects(eLink, eStrBonus);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_DEATH_KNELL));
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH, oCaster)) {
            if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_DEATH, oCaster)) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                DelayCommand(1.0f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));

                GRRemoveSpellEffects(SPELL_DEATH_KNELL, oCaster);
                SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_DEATH_KNELL, FALSE));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eCasterVis, oCaster);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);
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
