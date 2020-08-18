//*:**************************************************************************
//*:*  GR_S0_BIGBY4.NSS
//*:**************************************************************************
//*:*
//*:* Bigby's Clenched Fist [x0_s0_bigby4] Copyright (c) 2002 Bioware Corp.
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

    int     iCasterModifier = GRGetCasterAbilityModifierByClass(oCaster, spInfo.iSpellCastClass);

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
    effect eHand    = EffectVisualEffect(VFX_DUR_BIGBYS_CLENCHED_FIST);
    effect eAOE     = GREffectAreaOfEffect(AOE_PER_BIGBYS);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* This spell no longer stacks. If there is one
    //*:* hand, that's enough
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST,spInfo.oTarget) || GetHasSpellEffect(SPELL_BIGBYS_CRUSHING_HAND, spInfo.oTarget)) {
        FloatingTextStrRefOnCreature(100775, oCaster, FALSE);
        return;
    }

    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_BIGBYS_CLENCHED_FIST));
        if(GRGetSpellResisted(oCaster, spInfo.oTarget)==0) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHand, spInfo.oTarget, fDuration);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);

            oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_BIGBYS, oCaster);
            SetLocalInt(oAOE,"XP2_L_SPELL_SAVE_DC_" + IntToString(SPELL_BIGBYS_CLENCHED_FIST), spInfo.iDC);
            GRSetAOESpellId(SPELL_BIGBYS_CLENCHED_FIST, oAOE);
            GRSetSpellInfo(spInfo, oAOE);
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
