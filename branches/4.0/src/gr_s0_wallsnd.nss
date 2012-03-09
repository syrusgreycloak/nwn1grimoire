//*:**************************************************************************
//*:*  GR_S0_WALLSND.NSS
//*:**************************************************************************
//*:* Wall of Sound (sg_s0_wallsnd.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 5, 2004
//*:* 2E Complete Bard's Handbook
//*:**************************************************************************
//*:* Updated On: March 10, 2008
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

    location lTargetSoundBlock = GenerateNewLocationFromLocation(spInfo.lTarget, FeetToMeters(15.0), GetFacing(oCaster), GetFacing(oCaster));
    location lTargetDeafenChance = GenerateNewLocationFromLocation(spInfo.lTarget, FeetToMeters(5.0), GetFacing(oCaster), GetFacing(oCaster));

    int     iAOEType1       = AOE_PER_WALLSOUND;
    string  sAOEType1       = AOE_TYPE_WALLSOUND;
    int     iAOEType2       = AOE_PER_WALLSND_DEAF;
    string  sAOEType2       = AOE_TYPE_WALLSND_DEAF;
    int     iAOEType3       = AOE_PER_WALLSND_SNDBLK;
    string  sAOEType3       = AOE_TYPE_WALLSND_SNDBLK;


    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        iAOEType1       = AOE_PER_WALLSOUND_WIDE;
        sAOEType1       = AOE_TYPE_WALLSOUND_WIDE;
        iAOEType2       = AOE_PER_WALLSND_DEAF_WIDE;
        sAOEType2       = AOE_TYPE_WALLSND_DEAF_WIDE;
        iAOEType3       = AOE_PER_WALLSND_SNDBLK_WIDE;
        sAOEType3       = AOE_TYPE_WALLSND_SNDBLK_WIDE;
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
    effect eImpVis = EffectVisualEffect(VFX_FNF_SOUND_BURST);
    effect eAOE1 = GREffectAreaOfEffect(iAOEType1);
    effect eAOE2 = GREffectAreaOfEffect(iAOEType2);
    effect eAOE3 = GREffectAreaOfEffect(iAOEType3);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpVis, spInfo.lTarget);
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE1, spInfo.lTarget, fDuration);
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE2, lTargetDeafenChance, fDuration);
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE3, lTargetSoundBlock, fDuration);

    object oAOE1 = GRGetAOEAtLocation(spInfo.lTarget, sAOEType1, oCaster);
    GRSetAOESpellId(spInfo.iSpellID, oAOE1);
    GRSetSpellInfo(spInfo, oAOE1);
    object oAOE2 = GRGetAOEAtLocation(lTargetDeafenChance, sAOEType2, oCaster);
    GRSetAOESpellId(spInfo.iSpellID, oAOE2);
    GRSetSpellInfo(spInfo, oAOE2);
    object oAOE3 = GRGetAOEAtLocation(lTargetSoundBlock, sAOEType3, oCaster);
    GRSetAOESpellId(spInfo.iSpellID, oAOE3);
    GRSetSpellInfo(spInfo, oAOE3);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
