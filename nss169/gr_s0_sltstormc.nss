//*:**************************************************************************
//*:*  GR_S0_SLTSTORMC.NSS
//*:**************************************************************************
//*:* Sleet Storm: OnHeartbeat
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 11, 2008
//*:* 3.5 Player's Handbook (p. 280)
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

    //spInfo.oTarget = GetEnteringObject();
    spInfo.iDC = 10;

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

    float   fDuration       = GRGetDuration(1);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iSkillModifier;/* = (GetSkillRank(SKILL_CONCENTRATION, spInfo.oTarget) + GetSkillRank(SKILL_MOVE_SILENTLY, spInfo.oTarget) +
                                GetSkillRank(SKILL_TUMBLE, spInfo.oTarget)/3 + GetAbilityModifier(ABILITY_DEXTERITY, spInfo.oTarget);


    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        iAOEType = AOE_PER_SLEET_STORM_WIDE;
        sAOEType = AOE_TYPE_SLEET_STORM_WIDE;
    }
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
    effect eBlind       = EffectBlindness();
    effect eSlow        = EffectMovementSpeedDecrease(50);
    effect eNoMove      = EffectCutsceneParalyze();
    effect eKnockdown   = EffectKnockdown();

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetFirstInPersistentObject();

    while(GetIsObjectValid(spInfo.oTarget)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        if(!GetHasEffect(EFFECT_TYPE_BLINDNESS, spInfo.oTarget)) {
            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eBlind, spInfo.oTarget);
        }
        iSkillModifier = (GetSkillRank(SKILL_CONCENTRATION, spInfo.oTarget) + GetSkillRank(SKILL_MOVE_SILENTLY, spInfo.oTarget) +
                                GetSkillRank(SKILL_TUMBLE, spInfo.oTarget)/3 + GetAbilityModifier(ABILITY_DEXTERITY, spInfo.oTarget));

        int iSkillCheck = d20()+iSkillModifier;
        if(iSkillCheck<spInfo.iDC) {
            if(iSkillCheck<=spInfo.iDC-5) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, spInfo.oTarget, fDuration);
            } else {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eNoMove, spInfo.oTarget, fDuration);
            }
        }
        spInfo.oTarget = GetNextInPersistentObject();
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
