//*:**************************************************************************
//*:*  GR_S0_ALIGNWORD.NSS
//*:**************************************************************************
//*:*
//*:* Alignment Word Spells (Blasphemy - PHB p. 205, Dictum - PHB p. 220,
//*:*       Holy Word - PHB p. 242, Word of Chaos - PHB p. 303)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 7, 2003
//*:**************************************************************************
//*:* Updated On: February 25, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Constant Libraries
#include "GR_IC_ALIGNMENT"

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_ALIGNMENT"


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

    int     iDieType          = 0;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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

    int     iHDDiff;
    int     iSpellAlign;
    int     iAlignCheckType = ALIGNMENT_AXIS_GOODEVIL;
    int     iImpType        = GRGetAlignmentImpactVisual(oCaster, 60.0);
    int     iVisType        = VFX_DUR_PROTECTION_GOOD_MINOR;

    float   fEff1Duration   = GRGetDuration(GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic));
    float   fEff2Duration   = GRGetDuration(GRGetMetamagicAdjustedDamage(4, 2, spInfo.iMetamagic));
    float   fEff3Duration   = GRGetDuration(GRGetMetamagicAdjustedDamage(10, 1, spInfo.iMetamagic), DUR_TYPE_TURNS);
    float   fRadius         = FeetToMeters(30.0);
    float   fDelay          = 1.5f;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) {
        fEff1Duration *= 2;
        fEff2Duration *= 2;
        fEff3Duration *= 2;
    }
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
    effect eImp         = EffectVisualEffect(iImpType);
    effect eUnsummon    = EffectVisualEffect(VFX_IMP_UNSUMMON);
    effect eVis         = EffectVisualEffect(iVisType);
    effect eDeath       = SupernaturalEffect(EffectDeath());
    effect eEff1        = EffectDeaf();
    effect eEff2;
    effect eEff3        = EffectParalyze();
    effect eLink;

    //*:**********************************************
    //*:* Change effects based upon spell cast
    //*:**********************************************
    switch(spInfo.iSpellID) {
        case SPELL_GR_BLASPHEMY:
            eEff1 = EffectDazed();
            eEff2 = EffectAbilityDecrease(ABILITY_STRENGTH, iDamage);
            break;
        case SPELL_GR_HOLY_WORD:
            eEff2 = EffectBlindness();
            break;
        case SPELL_GR_DICTUM:
            eEff2 = EffectSlow();
            break;
        case SPELL_GR_WORD_OF_CHAOS:
            eEff2 = EffectStunned();
            eEff3 = EffectConfused();
            break;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, oCaster);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRadius, spInfo.lTarget);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster) &&
            !GRGetCreatureAlignmentEqual(spInfo.oTarget, iSpellAlign, iAlignCheckType)) {

            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            iHDDiff = spInfo.iCasterLevel-GetHitDice(spInfo.oTarget);
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget) && iHDDiff>=0) {
                if((GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_OUTSIDER || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ELEMENTAL) &&
                    !GetIsPC(spInfo.oTarget)) {
                    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eUnsummon, GetLocation(spInfo.oTarget));
                    DestroyObject(spInfo.oTarget, fDelay);
                } else if((GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_OUTSIDER || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ELEMENTAL) &&
                    GetIsPC(spInfo.oTarget)) {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget);
                } else if(!GetHasEffect(EFFECT_TYPE_SILENCE, spInfo.oTarget)) {
                    if(iHDDiff==0) {
                        eLink = EffectLinkEffects(eVis, eEff1);
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fEff1Duration);
                    }
                    if(iHDDiff>1) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff2, spInfo.oTarget, fEff2Duration);
                    }
                    if(iHDDiff>5) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff3, spInfo.oTarget, fEff3Duration);
                    }
                    if(iHDDiff>10) {
                        if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD && !GetIsPC(spInfo.oTarget)) {
                            DestroyObject(spInfo.oTarget, fDelay);
                        } else {
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                        }
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRadius, spInfo.lTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
