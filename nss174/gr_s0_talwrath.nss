//*:**************************************************************************
//*:*  GR_S0_TALWRATH.NSS
//*:**************************************************************************
//*:* Talos' Wrath (SG_S0_TalWrath.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 31, 2003
//*:*
//*:**************************************************************************
//*:* Updated On: February 26, 2008
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
    int     iDurAmount        = spInfo.iCasterLevel/6;
    int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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

    location lRgtLocation   = GenerateNewLocationFromLocation(spInfo.lTarget, DISTANCE_SHORT,
        GetRightDirection(GetFacing(oCaster)), GetFacing(oCaster));
    location lLftLocation   = GenerateNewLocationFromLocation(spInfo.lTarget, DISTANCE_SHORT,
        GetLeftDirection(GetFacing(oCaster)), GetFacing(oCaster));
    location lFrtLocation   = GenerateNewLocationFromLocation(spInfo.lTarget, DISTANCE_SHORT,
        GetFacing(oCaster), GetFacing(oCaster));
    location lBckLocation   = GenerateNewLocationFromLocation(spInfo.lTarget, DISTANCE_SHORT,
        GetOppositeDirection(GetFacing(oCaster)), GetFacing(oCaster));

    int     iAOEType        = AOE_PER_TALOS_WRATH;
    string  sAOEType        = AOE_TYPE_TALOS_WRATH;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        iAOEType = AOE_PER_TALOS_WRATH_WIDE;
        sAOEType = AOE_TYPE_TALOS_WRATH_WIDE;
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
    effect eAOE = GREffectAreaOfEffect(iAOEType);
    effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spInfo.lTarget);
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);

    object oAOE = GRGetAOEAtLocation(spInfo.lTarget, AOE_TYPE_TALOS_WRATH, oCaster);
    GRSetAOESpellId(spInfo.iSpellID, oAOE);
    GRSetSpellInfo(spInfo, oAOE);
    SetLocalLocation(oAOE, "MY_RGT_LOC", lRgtLocation);
    SetLocalLocation(oAOE, "MY_LFT_LOC", lLftLocation);
    SetLocalLocation(oAOE, "MY_FRT_LOC", lFrtLocation);
    SetLocalLocation(oAOE, "MY_BCK_LOC", lBckLocation);
    SetLocalLocation(oAOE, "MY_LOC", spInfo.lTarget);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
