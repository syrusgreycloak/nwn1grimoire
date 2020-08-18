//*:**************************************************************************
//*:*  GR_S0_GRTTHDCLP.NSS
//*:**************************************************************************
//*:* Great Thunderclap (X2_S0_GrtThdclp) Copyright (c) 2001 Bioware Corp.
//*:* Spell Compendium (p. 107)
//*:*
//*:**************************************************************************
//*:* Created By: Andrew Nobbs
//*:* Created On: Nov 20, 2002
//*:**************************************************************************
//*:* Updated On: December 10, 2007
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDeafDuration       = GRGetDuration(1, DUR_TYPE_TURNS);
    float   fStunDuration       = 9.0f;
    float   fProneDuration      = 9.0f;
    float   fProneVisDuration   = 4.0f;
    float   fDelay              = 0.0f;
    float   fRange              = FeetToMeters(20.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) {
        fDeafDuration *= 2;
        fStunDuration *= 1.5;
        fProneDuration *= 2;
        fProneVisDuration *= 2;
    }
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eExplode = EffectVisualEffect(VFX_FNF_MYSTICAL_EXPLOSION);
    effect eVis     = EffectVisualEffect(VFX_IMP_SONIC);
    effect eVis2    = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    effect eVis3    = EffectVisualEffect(VFX_IMP_STUN);
    effect eDeaf    = EffectDeaf();
    effect eKnock   = EffectKnockdown();
    effect eStun    = EffectStunned();
    effect eShake   = EffectVisualEffect(356);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShake, oCaster, 2.0f);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20;
            spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SONIC)) {
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeaf, spInfo.oTarget, fDeafDuration));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spInfo.oTarget));
            }
            if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SONIC)) {
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, spInfo.oTarget, fStunDuration));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
            }
            if(!GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SONIC)) {
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnock, spInfo.oTarget, fProneDuration));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis3, spInfo.oTarget, fProneVisDuration));
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
