//*:**************************************************************************
//*:*  GR_S0_CLKRIGHTC.NSS
//*:**************************************************************************
//*:*
//*:* Cloak of Righteousness: OnHeartbeat Swords & Sorcery: Relics & Rituals I
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 28, 2003
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
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    int     iDurRemaining   = GetLocalInt(oCaster, "GR_CLOAKRIGHT_DUR");
    float   fDuration       = GRGetDuration(iDurRemaining);
    //*:* float   fDelay          = 0.0f;
    float   fRange          = 10.0f;

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
    effect eImp         = EffectVisualEffect(VFX_IMP_BREACH);
    effect eTargetVis   = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    effect eTargetDmg   = EffectBlindness();
    effect eFriendVis   = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    effect eAttack      = EffectAttackIncrease(1);
    effect eSave        = EffectSavingThrowIncrease(SAVING_THROW_ALL, 1, SAVING_THROW_TYPE_FEAR);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eFriendImp   = EffectLinkEffects(eAttack, eSave);
    eFriendImp = EffectLinkEffects(eFriendImp, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    iDurRemaining--;

    if(iDurRemaining) {
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, oCaster);
        SetLocalInt(oCaster, "GR_CLOAKRIGHT_DUR", iDurRemaining);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
        while(GetIsObjectValid(spInfo.oTarget)) {
            if(GetObjectSeen(oCaster, spInfo.oTarget) && !GetHasEffect(EFFECT_TYPE_BLINDNESS, spInfo.oTarget)) {
                if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                    SignalEvent(spInfo.oTarget,EventSpellCastAt(oCaster, SPELL_GR_CLOAK_RIGHTEOUSNESS));
                    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                        spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                        if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DIVINE)) {
                            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eTargetVis, spInfo.oTarget);
                            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTargetDmg, spInfo.oTarget, fDuration);
                        }
                    }
                } else {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_CLOAK_RIGHTEOUSNESS, FALSE));
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFriendImp, spInfo.oTarget, fDuration);
                }
            }
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
        }
    } else {
        GRRemoveSpellEffects(SPELL_GR_CLOAK_RIGHTEOUSNESS, oCaster);
        DeleteLocalInt(oCaster, "GR_CLOAKRIGHT_DUR");
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
