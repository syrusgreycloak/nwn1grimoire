//*:**************************************************************************
//*:*  GR_S2_MUMDUST.NSS
//*:**************************************************************************
//*:* Mummy Dust (X2_S2_MumDust) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Feb 07, 2003
//*:* Epic Level Handbook (p. 83)
//*:**************************************************************************
//*:* Updated On: January 10, 2007
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     i, j;
    int     iNumToSummon    = 2;
    string  sSummon         = "X2_S_MUMMYWARR";
    object  oSummon;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eSummon          = ExtraordinaryEffect(EffectSummonCreature(sSummon, 496, 1.0f));
    effect eStr             = EffectAbilityIncrease(ABILITY_STRENGTH, 4);
    effect eCon             = EffectAbilityIncrease(ABILITY_CONSTITUTION, 4);
    effect eAugmentSummons  = EffectLinkEffects(eStr, eCon);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    for(i=1; i<=iNumToSummon; i++) {
        if(i>1) {
            eSummon = ExtraordinaryEffect(EffectSummonCreature(sSummon, VFX_NONE, 1.1f));
        }
        GRApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eSummon, spInfo.lTarget);
        for(j=1;j<=i;j++) {
            oSummon = GetNearestObjectByTag(sSummon, oCaster, j);
            if(GetPlotFlag(oSummon)==FALSE) {
                SetPlotFlag(oSummon, TRUE);
                AssignCommand(oSummon, SetIsDestroyable(FALSE));
                SetLocalInt(oSummon, "GR_L_AM_SUMMON", TRUE);
            }
            if(GetHasFeat(FEAT_GR_AUGMENT_SUMMONING, oCaster)) {
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eAugmentSummons, oSummon);
            }
        }
    }
    for(i=1;i<=iNumToSummon;i++) {
        oSummon = GetNearestObjectByTag(sSummon, oCaster, i);
        SetPlotFlag(oSummon,FALSE);
        AssignCommand(oSummon, SetIsDestroyable(TRUE));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
