//*:**************************************************************************
//*:*  GR_S2_MINDBLAST.NSS
//*:**************************************************************************
//*:* Cone: Mindflayer Mind Blast
//*:* x2_m1_mindblast
//*:* Copyright (c) 2002 Bioware Corp.
//*:* Created By: Keith Warner
//*:* Created On: Dec 5/02
//*:**************************************************************************
//*:* Updated On: December 20, 2007
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

    spInfo.iDC = 10 +(GetHitDice(oCaster)/2) +  GetAbilityModifier(ABILITY_WISDOM, oCaster);
    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    int     iDamage           = 0;
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
    float   fDelay          = 0.0f;
    float   fRange          = 15.0f;

    int     iStunTime;
    int     iAppType        = GetAppearanceType(spInfo.oTarget);
    int     bImmune         = FALSE;
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
    effect eVis = EffectVisualEffect(VFX_IMP_SONIC);
    effect eCone = EffectStunned();

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE);
    while(GetIsObjectValid(spInfo.oTarget)) {
        iAppType = GetAppearanceType(spInfo.oTarget);
        bImmune = FALSE;
        //----------------------------------------------------------------------
        // Hack to make mind flayers immune to their psionic attacks...
        //----------------------------------------------------------------------
        if (iAppType==413 || iAppType==414 || iAppType==415) {
            bImmune = TRUE;
        }

        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER) && !bImmune) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
            if(GetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget)) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_STUN), spInfo.oTarget);
                if(GRGetLevelByClass(CLASS_TYPE_SHIFTER, oCaster)>0) {
                    iDamage = d6(GRGetLevelByClass(CLASS_TYPE_SHIFTER, oCaster)/3);
                } else {
                    iDamage = d6(GetHitDice(oCaster)/2);
                }
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(iDamage), spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BIGBYS_FORCEFUL_HAND), spInfo.oTarget);
            } else if(WillSave(spInfo.oTarget, spInfo.iDC) < 1) {
                iStunTime = d4(3);
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCone, spInfo.oTarget, GRGetDuration(iStunTime)));
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
