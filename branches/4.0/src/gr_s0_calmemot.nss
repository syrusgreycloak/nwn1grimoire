//*:**************************************************************************
//*:*  GR_S0_CALMEMOT.NSS
//*:**************************************************************************
//*:*
//*:* Calm Emotions
//*:*
//*:* 3.5 Player's Handbook (p. 207)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 7, 2003
//*:**************************************************************************
//*:* Updated On: October 25, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

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
    float   fRange          = FeetToMeters(20.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iCreaturesAffected  = 0;
    int     iCreaturesTotal     = GRGetMetamagicAdjustedDamage(6, 1, spInfo.iMetamagic) * spInfo.iCasterLevel;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration       = ApplyMetamagicDurationMods(fDuration);
        iDurationType   = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
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
    effect eVis     = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDaze    = EffectDazed();
    /*** NWN1 SINGLE ***/ effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);

    while(GetIsObjectValid(spInfo.oTarget) && (iCreaturesAffected<iCreaturesTotal)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_CALM_EMOTIONS));
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
            if(WillSave(spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS)==0) {

                GRRemoveMultipleSpellEffects(SPELL_CONFUSION, SPELL_BLESS, spInfo.oTarget, FALSE, SPELL_FEAR, SPELL_TASHAS_HIDEOUS_LAUGHTER);
                GRRemoveMultipleSpellEffects(SPELL_BANE, SPELL_BLOOD_FRENZY, spInfo.oTarget, FALSE, 311, 642);
                GRRemoveMultipleSpellEffects(307, SPELL_CRUSHING_DESPAIR, spInfo.oTarget, FALSE, SPELL_LESSER_CONFUSION, SPELL_GR_GOOD_HOPE);
                GRRemoveSpellEffects(SPELL_RAGE, spInfo.oTarget);

                if(GetHasEffect(EFFECT_TYPE_CONFUSED, spInfo.oTarget))
                    RemoveSpecificEffect(EFFECT_TYPE_CONFUSED, spInfo.oTarget);
                if(GetHasEffect(EFFECT_TYPE_FRIGHTENED, spInfo.oTarget))
                    RemoveSpecificEffect(EFFECT_TYPE_FRIGHTENED, spInfo.oTarget);

                GRApplyEffectToObject(iDurationType, eDaze, spInfo.oTarget, fDuration);
                SetIsTemporaryNeutral(spInfo.oTarget, oCaster, FALSE, fDuration);
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
