//*:**************************************************************************
//*:*  GR_S2_SUMUNDEAD.NSS
//*:**************************************************************************
//*:* Summon Undead (X2_S2_SumUndead) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Feb 05, 2003
//*:* Summon Greater Undead (X2_S2_SumGrUnd) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Feb 05, 2003
//*:**************************************************************************
//*:* Updated On: December 26, 2007
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
//*:* Supporting functions
//*:**************************************************************************
void PMUpgradeSummon(object oSelf, string sScript) {

    object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oSelf);
    ExecuteScript(sScript, oSummon);

}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_PALEMASTER, oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel + 14;
    int     iDurType          = DUR_TYPE_HOURS;

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

    float   fDuration       = GRGetDuration(iDurAmount, iDurType);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iVisualType     = VFX_FNF_SUMMON_UNDEAD;

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
    effect eVis = EffectVisualEffect(VFX_FNF_LOS_EVIL_10);
    effect eSummon;

    if(spInfo.iSpellID==SPELLABILITY_PM_SUMMON_UNDEAD) {
        if(spInfo.iCasterLevel <= 5) {
            eSummon = EffectSummonCreature("NW_S_GHOUL", iVisualType);
        } else if(spInfo.iCasterLevel == 6) {
            eSummon = EffectSummonCreature("NW_S_SHADOW", iVisualType);
        } else if(spInfo.iCasterLevel == 7) {
            eSummon = EffectSummonCreature("NW_S_GHAST", iVisualType);
        } else if(spInfo.iCasterLevel == 8) {
            eSummon = EffectSummonCreature("NW_S_WIGHT", iVisualType);
        } else {
            eSummon = EffectSummonCreature("X2_S_WRAITH", iVisualType);
        }
    } else {
        if(spInfo.iCasterLevel>=30) {           // * Demi Lich
            eSummon = EffectSummonCreature("X2_S_LICH_30", 496, 0.0f, 1);
        } else if(spInfo.iCasterLevel>=28) {    // * Mega Alhoon
            eSummon = EffectSummonCreature("x2_s_lich_26", 496, 0.0f, 1);
        } else if(spInfo.iCasterLevel>=26) {    // * Alhoon
            eSummon = EffectSummonCreature("X2_S_LICH_24", 496, 0.0f, 1);
        } else if(spInfo.iCasterLevel>=24) {    // * Lich
            eSummon = EffectSummonCreature("X2_S_LICH_22", 496, 0.0f, 0);
        } else if(spInfo.iCasterLevel>=22) {    // * Lich
            eSummon = EffectSummonCreature("X2_S_LICH_20", 496, 0.0f, 0);
        } else if(spInfo.iCasterLevel>=20) {    // * Skeleton Blackguard
            eSummon = EffectSummonCreature("x2_s_bguard_18", VFX_IMP_HARM, 0.0f, 0);
        } else if(spInfo.iCasterLevel>=18) {    // * Vampire Mage
            eSummon = EffectSummonCreature("x2_s_vamp_18", VFX_FNF_SUMMON_UNDEAD, 0.0f, 1);
        } else if(spInfo.iCasterLevel>=16) {    // * Ghoul King
            eSummon = EffectSummonCreature("X2_S_GHOUL_16", VFX_IMP_HARM, 0.0f, 0);
        } else if(spInfo.iCasterLevel>=14) {    // * Greater Bodak
            eSummon = EffectSummonCreature("X2_S_BODAK_14", VFX_IMP_HARM, 0.0f, 0);
        } else if(spInfo.iCasterLevel>=12) {    // * Vampire Rogue
            eSummon = EffectSummonCreature("X2_S_VAMP_10", VFX_FNF_SUMMON_UNDEAD, 0.0f, 1);
        } else if(spInfo.iCasterLevel>=10) {
            eSummon = EffectSummonCreature("X2_S_SPECTRE_10", VFX_FNF_SUMMON_UNDEAD, 0.0f, 1);
        } else {                                // * Mummy
            eSummon = EffectSummonCreature("X2_S_MUMMY_9", VFX_IMP_HARM, 0.0f, 0);
        }
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spInfo.lTarget);
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spInfo.lTarget, fDuration);
    if(GetHasSpellEffect(SPELL_GR_DESECRATE, OBJECT_SELF)) {
        int i=1;
        object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF, i);
        while(GRGetRacialType(oSummon)!=RACIAL_TYPE_UNDEAD || (GRGetRacialType(oSummon)==RACIAL_TYPE_UNDEAD &&
            GetCurrentHitPoints(oSummon)>GetMaxHitPoints(oSummon))) {
            i++;
            oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF, i);
        }
        if(GetRacialType(oSummon)==RACIAL_TYPE_UNDEAD) {
            int iSummonHD = GetHitDice(oSummon);
            effect eTempHP = EffectTemporaryHitpoints(iSummonHD);
            SignalEvent(oSummon, EventSpellCastAt(OBJECT_SELF, spInfo.iSpellID, FALSE));
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTempHP, oSummon, fDuration);
        }
    }

    // * If the character has a special pale master item equipped (variable set via OnEquip)
    // * run a script on the summoned monster.
    string sScript = GetLocalString(OBJECT_SELF, "X2_S_PM_SPECIAL_ITEM");
    if(sScript!="") {
        object oSelf = OBJECT_SELF;
        DelayCommand(1.0, PMUpgradeSummon(oSelf, sScript));
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
