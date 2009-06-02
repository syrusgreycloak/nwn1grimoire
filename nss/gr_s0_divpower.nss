//*:**************************************************************************
//*:*  GR_S0_DIVPOWER.NSS
//*:**************************************************************************
//*:*
//*:* Divine Power (NW_S0_DivPower.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 224)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Oct 21, 2001
//*:**************************************************************************
//*:* Updated On: October 25, 2007
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
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iTotalCharacterLevel    = GetHitDice(OBJECT_SELF);
    int     iBAB                    = GetBaseAttackBonus(OBJECT_SELF);
    int     iEpicPortionOfBAB       = (iTotalCharacterLevel - 19 ) / 2;
    int     iExtraAttacks           = 0;
    int     iAttackIncrease         = 0;
    int     iStr                    = GetAbilityScore(spInfo.oTarget, ABILITY_STRENGTH);
    int     iStrengthIncrease       = 6;

    if(iEpicPortionOfBAB<0) iEpicPortionOfBAB = 0;

    if(iTotalCharacterLevel>20) {
        iAttackIncrease = 20 + iEpicPortionOfBAB;
        if(iBAB - iEpicPortionOfBAB < 11) {
            iExtraAttacks = 2;
        } else if(iBAB - iEpicPortionOfBAB > 10 && iBAB - iEpicPortionOfBAB < 16) {
            iExtraAttacks = 1;
        }
    } else {
        iAttackIncrease = iTotalCharacterLevel;
        iExtraAttacks = ( (iTotalCharacterLevel-1) / 5 ) - ( (iBAB-1) / 5 );
    }
    iAttackIncrease -= iBAB;

    if(iAttackIncrease<0) iAttackIncrease = 0;

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
    effect eLink;
    /*** NWN1 SPECIFIC ***/
        effect eVis         = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
        effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
        effect eAttack      = EffectAttackIncrease(iAttackIncrease);
        effect eAttackMod   = EffectModifyAttacks(iExtraAttacks);
        eLink       = EffectLinkEffects(eAttack, eAttackMod);
        eLink       = EffectLinkEffects(eLink, eDur);
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        effect eDur = EffectVisualEffect(VFX_DUR_SPELL_DIVINE_POWER);
        effect eBAB = EffectBABMinimum(nTotalCharacterLevel);
        eLink = EffectLinkEffects(eBAB, eDur);
    /*** END NWN2 SPECIFIC ***/

    effect eStrength    = EffectAbilityIncrease(ABILITY_STRENGTH, iStrengthIncrease);
    effect eHP          = EffectTemporaryHitpoints(spInfo.iCasterLevel);

    eLink = EffectLinkEffects(eLink, eStrength);

    /*** NWN2 SPECIFIC ***
        effect eOnDispel = EffectOnDispel(0.0f, GRRemoveSpellEffects(SPELL_DIVINE_POWER, OBJECT_SELF));
        eLink = EffectLinkEffects(eLink, eOnDispel);
        eHP = EffectLinkEffects(eHP, eOnDispel);
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget);
    GRRemoveEffects(EFFECT_TYPE_TEMPORARY_HITPOINTS, spInfo.oTarget);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_DIVINE_POWER, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHP, spInfo.oTarget, fDuration);
    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
