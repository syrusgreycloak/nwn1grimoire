//*:**************************************************************************
//*:*  GR_S0_BIONATBAL.NSS
//*:**************************************************************************
//*:*
//*:* Natures Balance (NW_S0_NatureBal.nss) Copyright (c) 2001 Bioware Corp.
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: June 22, 2001
//*:**************************************************************************
//*:* Updated On: November 2, 2007
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
    int     iNumDice          = spInfo.iCasterLevel;
    //*:* int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = MaxInt(2, spInfo.iCasterLevel/3);
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

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
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
    effect eHeal;
    effect eVis     = EffectVisualEffect(VFX_IMP_HEALING_L);
    effect eSR;
    /*** NWN1 SPECIFIC ***/
        effect eVis2    = EffectVisualEffect(VFX_IMP_BREACH);
        effect eNature  = EffectVisualEffect(VFX_FNF_NATURES_BALANCE);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    /*** END NWN1 SPECIFIC ***/

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eNature, spInfo.lTarget);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, spInfo.lTarget, FALSE);
    while(GetIsObjectValid(spInfo.oTarget)) {
        fDelay = GetRandomDelay();
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster) && !GRGetIsImmuneToMagicalHealing(spInfo.oTarget)) {
              SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_NATURES_BALANCE, FALSE));
              iDamage = GRGetMetamagicAdjustedDamage(8, 3, spInfo.iMetamagic, spInfo.iCasterLevel);
              eHeal = EffectHeal(iDamage);
              DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spInfo.oTarget));
              DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
        } else if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_NATURES_BALANCE));
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                    iNumDice = MaxInt(1, iNumDice/5);
                    iDamage = GRGetMetamagicAdjustedDamage(4, iNumDice, spInfo.iMetamagic);
                    eSR = EffectSpellResistanceDecrease(iDamage);
                    /*** NWN1 SINGLE ***/ effect eLink = EffectLinkEffects(eSR, eDur);
                    //*** NWN2 SINGLE ***/ effect eLink = eSR;
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration));
                    /*** NWN1 SINGLE ***/ DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spInfo.oTarget));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, spInfo.lTarget, FALSE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
