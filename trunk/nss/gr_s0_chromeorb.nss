//*:**************************************************************************
//*:*  GR_S0_CHROMEORB.NSS
//*:**************************************************************************
//*:* Chromatic Orb - 2E AD&D Complete Wizard's Handbook
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 7, 2004
//*:**************************************************************************
//*:* Updated On: February 28, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"

#include "GR_IN_DEBUG"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType            = 0;
    int     iNumDice            = 0;
    int     iBonus              = 0;
    int     iDamage             = 0;
    int     iSecDamage          = 0;
    int     iDurAmount          = spInfo.iCasterLevel;
    int     iDurType            = DUR_TYPE_ROUNDS;

    int     iRequiredLevel;
    object  oLoopTarget;
    int     iSavingThrow        = 0;  // for Special Powers that provide additional saves.
    float   fRange              = 0.0f;
    int     iVisualType;
    effect  eSpecial, eApply, eLight, eAttack, eSave, eAC, eStr, eDex;

    switch(spInfo.iSpellID) {
        case SPELL_GR_CHROMATIC_ORB_LVLS15:
        case SPELL_GR_CHROMATIC_ORB_LVLS69:
            spInfo.iSpellID    = SPELL_GR_CHROMATIC_ORB_WHITE;
        case SPELL_GR_CHROMATIC_ORB_WHITE:
            iDieType    = 4;
            iNumDice    = 1;
            iVisualType = VFX_COM_HIT_SONIC;
            eLight      = EffectVisualEffect(VFX_DUR_LIGHT_WHITE_20);
            eAttack     = EffectAttackDecrease(4);
            eSave       = EffectSavingThrowDecrease(SAVING_THROW_ALL, 4);
            eAC         = EffectACDecrease(4, AC_DEFLECTION_BONUS);
            eApply      = EffectLinkEffects(eLight, eAttack);
            eApply      = EffectLinkEffects(eApply, eSave);
            eApply      = EffectLinkEffects(eApply, eAC);
            iDurAmount  = 1;
            iRequiredLevel = 1;
            break;
        case SPELL_GR_CHROMATIC_ORB_RED:
            iDieType    = 6;
            iNumDice    = 1;
            iVisualType = VFX_COM_HIT_NEGATIVE;
            eStr        = EffectAbilityDecrease(ABILITY_STRENGTH, 1);
            eDex        = EffectAbilityDecrease(ABILITY_DEXTERITY, 1);
            eApply      = EffectLinkEffects(eStr, eDex);
            iDurAmount  = 1;
            iRequiredLevel = 2;
            break;
        case SPELL_GR_CHROMATIC_ORB_ORANGE:
            iDieType    = 8;
            iNumDice    = 1;
            iVisualType = VFX_COM_HIT_FIRE;
            fRange      = FeetToMeters(5.0);
            iRequiredLevel = 3;
            break;
        case SPELL_GR_CHROMATIC_ORB_YELLOW:
            iDieType    = 10;
            iNumDice    = 1;
            iVisualType = VFX_COM_HIT_DIVINE;
            eApply      = EffectBlindness();
            iRequiredLevel = 4;
            break;
        case SPELL_GR_CHROMATIC_ORB_GREEN:
            iDieType    = 12;
            iNumDice    = 1;
            iVisualType = VFX_COM_HIT_ACID;
            eApply      = GREffectAreaOfEffect(AOE_PER_FOGSTINKSINGLE);
            iRequiredLevel = 5;
            break;
        case SPELL_GR_CHROMATIC_ORB_TURQUOISE:
            iDieType    = 4;
            iNumDice    = 2;
            iVisualType = VFX_COM_HIT_FROST;
            fRange      = FeetToMeters(10.0);
            iRequiredLevel = 6;
            break;
        case SPELL_GR_CHROMATIC_ORB_BLUE:
            iDieType    = 8;
            iNumDice    = 2;
            iVisualType = VFX_IMP_FROST_L;
            eApply      = EffectParalyze();
            iSavingThrow   = SAVING_THROW_WILL;
            iDurAmount  = GRGetMetamagicAdjustedDamage(8, 2, spInfo.iMetamagic, 4);
            iRequiredLevel = 7;
            break;
        case SPELL_GR_CHROMATIC_ORB_VIOLET:
            iVisualType = VFX_IMP_HEAD_MIND;
            eApply      = EffectSlow();
            eSpecial    = EffectPetrify();
            iSavingThrow   = SAVING_THROW_FORT;
            iDurAmount  = GRGetMetamagicAdjustedDamage(4, 2, spInfo.iMetamagic);
            iRequiredLevel = 8;
            break;
        case SPELL_GR_CHROMATIC_ORB_BLACK:
            iVisualType = VFX_FNF_GAS_EXPLOSION_GREASE;
            eSpecial    = EffectDeath();
            eApply      = EffectParalyze();
            iSavingThrow   = SAVING_THROW_WILL;
            iDurAmount  = GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic, 1);
            iRequiredLevel = 9;
            break;
    }

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

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

    iVisualType             = GRGetEnergyVisualType(iVisualType, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iAttackResult   = GRTouchAttackRanged(spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    //*:* iDamage = GRGetSpellDamageAmount(spInfo, WILL_NEGATES, oCaster, iSaveType, fDelay)*iAttackResult;
    /*if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, WILL_NEGATES, oCaster)*iAttackResult;
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eEffectVis = EffectVisualEffect(iVisualType);
    effect eDamage;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(iRequiredLevel>spInfo.iCasterLevel) {
        FloatingTextStrRefOnCreature(16939276, oCaster, FALSE);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), oCaster);
    } else {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));

        AutoDebugString("Attack result is " + IntToString(iAttackResult));
        AutoDebugString("iDieType = " + IntToString(iDieType));
        AutoDebugString("iNumDice = " + IntToString(iNumDice));

        if(iAttackResult>0) {
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {

                AutoDebugString("Spell not resisted.");
                int iSaveResult = GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC);

                AutoDebugString("iSaveResult = " + IntToString(iSaveResult));
                GRSetSpellDmgSaveMade(spInfo.iSpellID, iSaveResult, oCaster);

                if(!GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster)) {

                    AutoDebugString("Save not made.");
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eEffectVis, spInfo.oTarget);
                    iDamage = GRGetSpellDamageAmount(spInfo);
                    AutoDebugString("GRGetSpellDamageAmount = " + IntToString(iDamage));
                    AutoDebugString("iAttackResult = " + IntToString(iAttackResult));
                    iDamage *= iAttackResult;

                    AutoDebugString("iDamage = " + IntToString(iDamage));
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo)*iAttackResult;
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }

                    if(iDamage>0) {
                        AutoDebugString("Damage > 0");
                        eDamage = EffectDamage(iDamage, iEnergyType, DAMAGE_POWER_PLUS_TWENTY);
                        if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                        AutoDebugString("Applying damage");
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget);
                    }

                    if(spInfo.iSpellID==SPELL_GR_CHROMATIC_ORB_BLACK &&
                        !GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH, oCaster)) {
                            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSpecial, spInfo.oTarget);
                    } else if(spInfo.iSpellID==SPELL_GR_CHROMATIC_ORB_VIOLET &&
                        !GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC)) {
                            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSpecial, spInfo.oTarget);
                    } else if(spInfo.iSpellID!=SPELL_GR_CHROMATIC_ORB_ORANGE && spInfo.iSpellID!=SPELL_GR_CHROMATIC_ORB_TURQUOISE) {
                        if(spInfo.iSpellID==SPELL_GR_CHROMATIC_ORB_BLUE && GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC)) {
                            fDuration*=0.5;
                        }
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eApply, spInfo.oTarget, fDuration);
                    }

                    if(spInfo.iSpellID==SPELL_GR_CHROMATIC_ORB_ORANGE || spInfo.iSpellID==SPELL_GR_CHROMATIC_ORB_TURQUOISE) {
                        spInfo.lTarget = GetLocation(spInfo.oTarget);
                        oLoopTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
                        while(GetIsObjectValid(oLoopTarget))  {
                            if(oLoopTarget==spInfo.oTarget) {
                                eApply = EffectLinkEffects(eEffectVis, eDamage);
                                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eApply, oLoopTarget);
                            } else {
                                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType);
                                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                        iDamage = iSecDamage;
                                    }
                                }

                                if(iDamage>0) {
                                    if(!GRGetSpellResisted(oCaster, oLoopTarget)) {
                                        eDamage = EffectDamage(iDamage, iEnergyType, DAMAGE_POWER_PLUS_TWENTY);
                                        if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eEffectVis, oLoopTarget);
                                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oLoopTarget);
                                    }
                                }
                            }
                            oLoopTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
                        }
                    }
                }
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
