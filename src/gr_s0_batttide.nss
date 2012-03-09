//*:**************************************************************************
//*:*  GR_S0_BATTTIDE.NSS
//*:**************************************************************************
//*:*
//*:* Battletide (X2_S0_BattTide) Copyright (c) 2001 Bioware Corp.
//*:*
//*:* Player's Guide to Faerun (p. 99)
//*:*
//*:**************************************************************************
//*:* Created By: Andrew Nobbs
//*:* Created On: Dec 04, 2002
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(15.0);

    int     bOneAffected    = FALSE;
    int     iTargetCounter  = 1;

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
    effect eAOE     = GREffectAreaOfEffect(41);

    //*:* Bad effects link
    effect eNegSaves    = EffectSavingThrowDecrease(SAVING_THROW_ALL, 1);
    effect eNegAttack   = EffectAttackDecrease(1);
    effect eNegDamage   = EffectDamageDecrease(1);
    effect eNegDur      = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink        = EffectLinkEffects(eNegAttack, eNegDamage);
    eLink = EffectLinkEffects(eLink, eNegSaves);
    eLink = EffectLinkEffects(eLink, eNegDur);

    //*:* Good effects link
    effect eHaste   = EffectMovementSpeedIncrease(99);
    effect eAttack  = EffectAttackIncrease(1);
    effect eSave    = EffectSavingThrowIncrease(SAVING_THROW_REFLEX, 1);
    effect eAC      = EffectACIncrease(1);
    effect eVis     = EffectVisualEffect(VFX_IMP_DOOM);
    effect eVis2    = EffectVisualEffect(VFX_IMP_HOLY_AID);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink2   = EffectLinkEffects(eHaste, eDur);
    eLink2 = EffectLinkEffects(eLink2, eAttack);
    eLink2 = EffectLinkEffects(eLink2, eSave);
    eLink2 = EffectLinkEffects(eLink2, eAC);
    effect eFind;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetHasSpellEffect(SPELL_BATTLETIDE, oCaster)) {
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetStringByStrRef(16939247));
        }
        return;
    }

    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, oCaster, fDuration);

    object oAOE = GRGetAOEOnObject(oCaster, AOE_TYPE_BATTLETIDE, oCaster);
    GRSetAOESpellId(GetSpellId());
    GRSetSpellInfo(spInfo, oAOE);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster, FALSE)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                   fDelay = GetRandomDelay(0.75, 1.75);
                   DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                   DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration));
                   bOneAffected = TRUE;
                   SetLocalObject(oAOE, "GR_BATTLETIDE_TARGET" + IntToString(iTargetCounter), spInfo.oTarget);
                   SetLocalInt(oAOE, "GR_NUM_BATTLETIDE_TARGETS", iTargetCounter);
                   iTargetCounter++;
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }
    if(bOneAffected) {
        SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_BATTLETIDE, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink2, oCaster, fDuration);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oCaster);
    } else {  // no targets affected - no point in keeping the AOE going
        DestroyObject(oAOE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
