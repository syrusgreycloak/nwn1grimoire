//*:**************************************************************************
//*:*  GR_S0_STINGRAY.NSS
//*:**************************************************************************
//*:* Sting Ray
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 29, 2008
//*:* Spell Compendium (p. 206)
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
#include "GR_IC_MESSAGES"

//*:* #include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void GRDoWillSaveRoundCheck(object oTarget, object oCaster) {
    int iDC = GetLocalInt(oTarget, "GR_STINGRAY_DC");

    if(GetHasSpellEffect(SPELL_GR_STING_RAY, oTarget)) {
        if(!GRGetSaveResult(SAVING_THROW_WILL, oTarget, iDC, SAVING_THROW_TYPE_MIND_SPELLS, oCaster, 0.0f, FALSE, FALSE)) {
            DelayCommand(RoundsToSeconds(1), GRDoWillSaveRoundCheck(oTarget, oCaster));
        } else {
            GRRemoveSpellEffects(SPELL_GR_STING_RAY, oTarget, oCaster);
            DeleteLocalInt(oTarget, "GR_STINGRAY_DC");
        }
    } else {
        DeleteLocalInt(oTarget, "GR_STINGRAY_DC");
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iAttackResult   = TouchAttackRanged(spInfo.oTarget);
    int     bHasRayDeflection = GetHasSpellEffect(SPELL_GR_RAY_DEFLECTION, spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
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
    effect eRay     = EffectBeam(VFX_BEAM_SILENT_FIRE, oCaster, BODY_NODE_HAND, (iAttackResult==0) || bHasRayDeflection);
    effect eAC      = EffectACDecrease(2);
    effect eDelay   = EffectMovementSpeedDecrease(30);
    effect eDur     = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);

    effect eLink    = EffectLinkEffects(eAC, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spInfo.oTarget, 1.7f);
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_STING_RAY));
    if(iAttackResult>0) {
        if(!bHasRayDeflection) {
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, oCaster, 0.0f, FALSE, FALSE)) {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDelay, spInfo.oTarget, fDuration);
                    SetLocalInt(spInfo.oTarget, "GR_STINGRAY_DC", spInfo.iDC);
                }
                DelayCommand(RoundsToSeconds(1), GRDoWillSaveRoundCheck(spInfo.oTarget, oCaster));
            }
        } else {
            if(GetIsPC(oCaster)) {
                SetLocalObject(GetModule(), "GR_RAYDEFLECT_CASTER", oCaster);
                SignalEvent(GetModule(), EventUserDefined(GR_MESSAGE_RAYDEFLECT_CASTER));
            }
            if(GetIsPC(spInfo.oTarget)) {
                SetLocalObject(GetModule(), "GR_RAYDEFLECT_TARGET", spInfo.oTarget);
                SignalEvent(GetModule(), EventUserDefined(GR_MESSAGE_RAYDEFLECT_TARGET));
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
