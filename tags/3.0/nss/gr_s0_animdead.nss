//*:**************************************************************************
//*:*  GR_S0_ANIMDEAD.NSS
//*:**************************************************************************
//*:* Animate Dead (NW_S0_AnimDead.nss) by Bioware Corp
//*:* Created By: Preston Watamaniuk  Created On: April 11, 2001
//*:**************************************************************************
//*:* The Dead Walk
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 23, 2008
//*:**************************************************************************
//*:* Updated On: April 23, 2008
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
    int     iDurAmount        = 1;
    int     iDurType          = DUR_TYPE_DAYS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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
    effect eSummon;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* Summon the appropriate creature based on the summoner level
    /*** NWN1 SPECIFIC ***/
        if(spInfo.iCasterLevel <= 5) {
            //*:* Tyrant Fog Zombie
            eSummon = EffectSummonCreature("NW_S_ZOMBTYRANT", VFX_FNF_SUMMON_UNDEAD);
        } else if((spInfo.iCasterLevel >= 6) && (spInfo.iCasterLevel <= 9)) {
            //*:* Skeleton Warrior
            eSummon = EffectSummonCreature("NW_S_SKELWARR", VFX_FNF_SUMMON_UNDEAD);
        } else {
            //*:* Skeleton Chieftain
            eSummon = EffectSummonCreature("NW_S_SKELCHIEF", VFX_FNF_SUMMON_UNDEAD);
        }
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        if(spInfo.iCasterLevel<= 5) {
            //*:* Skeleton
            eSummon = EffectSummonCreature("c_skeleton", VFX_FNF_SUMMON_UNDEAD);
        } else if ((spInfo.iCasterLevel >= 6) && (spInfo.iCasterLevel <= 9)) {
            //*:* Zombie
            eSummon = EffectSummonCreature("c_zombie", VFX_FNF_SUMMON_UNDEAD);
        } else {
            //*:* Skeleton Warrior
            eSummon = EffectSummonCreature("c_skeletonwarrior", VFX_FNF_SUMMON_UNDEAD);
        }
    /*** END NWN2 SPECIFIC ***/
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spInfo.lTarget, fDuration);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
