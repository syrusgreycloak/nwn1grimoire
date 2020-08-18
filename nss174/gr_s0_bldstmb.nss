//*:**************************************************************************
//*:*  GR_S0_BLDSTMB.NSS
//*:**************************************************************************
//*:*
//*:* Blood Storm: On Exit
//*:* summons a whirlwind of blood that envelops the entire area of
//*:* effect and has several effects on those caught within it.
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 15, 2003
//*:**************************************************************************
//*:* Updated On: February 21, 2008
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

    spInfo.oTarget = GetExitingObject();

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

    float   fDuration       = GRGetDuration(GRGetMetamagicAdjustedDamage(6, 2, spInfo.iMetamagic));
    //*:* float   fDelay          = 0.0f;
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
    effect eVis   = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    effect eBlind = EffectBlindness();
    effect eEffect;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GetIsObjectValid(oCaster)) {
        GRRemoveSpellEffects(SPELL_GR_BLOODSTORM, spInfo.oTarget);
    } else {
        // MUST USE THE FOLLOWING LOOP AS WE DON'T WANT TO REMOVE THE FEAR EFFECTS
        // WHICH WOULD HAPPEN IF WE USED RemoveSpellEffects(iSpellId, oCaster, spInfo.oTarget)
        eEffect = GetFirstEffect(spInfo.oTarget);
        while(GetIsEffectValid(eEffect)) {
            if(GetEffectType(eEffect)==EFFECT_TYPE_BLINDNESS && GetEffectSpellId(eEffect)==SPELL_GR_BLOODSTORM &&
                GetEffectCreator(eEffect)==oCaster) {
                    GRRemoveEffect(eEffect, spInfo.oTarget);
            } else if(GetEffectType(eEffect)==EFFECT_TYPE_ATTACK_DECREASE && GetEffectSpellId(eEffect)==SPELL_GR_BLOODSTORM &&
                GetEffectCreator(eEffect)==oCaster) {
                    GRRemoveEffect(eEffect, spInfo.oTarget);
            }
            eEffect = GetNextEffect(spInfo.oTarget);
        }
        if(GetLocalInt(spInfo.oTarget, "GR_BSTM_IS_BLIND")) {
            // If already blinded, target is blinded for 2d6 rounds after leaving the Bloodstorm
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBlind, spInfo.oTarget, fDuration);
        }
    }
    DeleteLocalInt(spInfo.oTarget, "GR_BSTM_IS_BLIND");

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
