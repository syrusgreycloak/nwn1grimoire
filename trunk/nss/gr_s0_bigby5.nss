//*:**************************************************************************
//*:*  GR_S0_BIGBY5.NSS
//*:**************************************************************************
//*:*
//*:* Bigby's Crushing Hand [x0_s0_bigby5] Copyright (c) 2002 Bioware Corp.
//*:*
//*:**************************************************************************
//*:* Created By: Brent
//*:* Created On: September 7, 2002
//*:**************************************************************************
//*:* Updated On: December 3, 2007
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int iCasterModifier = GRGetCasterAbilityModifierByClass(oCaster, spInfo.iSpellCastClass);
    int iCasterRoll = d20(1) + iCasterModifier + spInfo.iCasterLevel + 12 + -1;
    int iTargetRoll = GetAC(spInfo.oTarget);

    object oAOE;

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
    effect eHand        = EffectVisualEffect(VFX_DUR_BIGBYS_CRUSHING_HAND);
    effect eKnockdown   = EffectCutsceneImmobilize();
    effect eLink        = EffectLinkEffects(eKnockdown, eHand);
    effect eAOE         = GREffectAreaOfEffect(AOE_PER_BIGBYS);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* This spell no longer stacks. If there is one
    //*:* hand, that's enough
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_BIGBYS_CRUSHING_HAND, spInfo.oTarget) || GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST, spInfo.oTarget)) {
        FloatingTextStrRefOnCreature(100775, oCaster, FALSE);
        return;
    }

    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_BIGBYS_CRUSHING_HAND));
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            //*:* grapple HIT succesful,
            if(iCasterRoll >= iTargetRoll) {
                //*:* now must make a GRAPPLE check
                //*:* hold target for duration of spell
                iCasterRoll = d20(1) + iCasterModifier + spInfo.iCasterLevel + 12 + 4;
                iTargetRoll = d20(1) + GetBaseAttackBonus(spInfo.oTarget) + GetSizeModifier(spInfo.oTarget) +
                    GetAbilityModifier(ABILITY_STRENGTH, spInfo.oTarget);

                if(iCasterRoll >= iTargetRoll) {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);

                    oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_BIGBYS, oCaster);
                    GRSetAOESpellId(SPELL_BIGBYS_CRUSHING_HAND, oAOE);
                    GRSetSpellInfo(spInfo, oAOE);

                    FloatingTextStrRefOnCreature(2478, oCaster);
                } else {
                    FloatingTextStrRefOnCreature(83309, oCaster);
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
