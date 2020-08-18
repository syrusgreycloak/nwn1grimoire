//*:**************************************************************************
//*:*  GR_S0_ELESWARM.NSS
//*:**************************************************************************
//*:*
//*:* Elemental Swarm (NW_S0_EleSwarm.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 226)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: April 12, 2001
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
#include "GR_IN_SUMMON"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void GRDoSummonElementals(int iSpellID, object oCaster, location lTarget, float fDuration, int iDieType,
    int iNumDice, string sResRef) {

    if(GetIsObjectValid(oCaster)) {
        SetLocalInt(oCaster, "GR_ELE_SWARM_DIE", iDieType);
        SetLocalInt(oCaster, "GR_ELE_SWARM_NUMDICE", iNumDice);
        SetLocalString(oCaster, "GR_L_SUMMON_TAG", sResRef);
        GRDoMultiSummonEffect(iSpellID, oCaster, DURATION_TYPE_TEMPORARY, lTarget, fDuration);
    }
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel*10;
    int     iDurType          = DUR_TYPE_TURNS;

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

    string  sSummon1;
    string  sSummon2;
    string  sSummon3;

    switch(spInfo.iSpellID) {
        case SPELL_ELEMENTAL_SWARM: // "c_elmairgreater", "c_elmearthgreater","c_elmwatergreater","c_elmfiregreater");
            if(!GRGetIsUnderwater(oCaster)) {
                sSummon1 = (spInfo.bNWN2 ? "c_elmairgreater" : "NW_SW_AIRGREAT");
                sSummon2 = (spInfo.bNWN2 ? "c_elmwatergreater" : "NW_SW_WATERGREAT");
                sSummon3 = (spInfo.bNWN2 ? "c_elmearthgreater" : "NW_SW_EARTHGREAT");
            } else {
                sSummon1 = (spInfo.bNWN2 ? "c_elmwatergreater" : "NW_SW_WATERGREAT");
                sSummon2 = (spInfo.bNWN2 ? "c_elmwatergreater" : "NW_SW_WATERGREAT");
                sSummon3 = (spInfo.bNWN2 ? "c_elmearthgreater" : "NW_SW_EARTHGREAT");
            }
            break;
        case SPELL_GR_ELE_SWARM_AIR:
            sSummon1 = (spInfo.bNWN2 ? "c_elmair" : "GR_S_AIR");
            sSummon2 = (spInfo.bNWN2 ? "c_elmairhuge" : "NW_S_AIRHUGE");
            sSummon3 = (spInfo.bNWN2 ? "c_elmairgreater" : "NW_SW_AIRGREAT");
            break;
        case SPELL_GR_ELE_SWARM_EARTH:
            sSummon1 = (spInfo.bNWN2 ? "c_elmearth" : "GR_S_EARTH");
            sSummon2 = (spInfo.bNWN2 ? "c_elmearthhuge" : "NW_S_EARTHHUGE");
            sSummon3 = (spInfo.bNWN2 ? "c_elmearthgreater" : "NW_SW_EARTHGREAT");
            break;
        case SPELL_GR_ELE_SWARM_FIRE:
            sSummon1 = (spInfo.bNWN2 ? "c_elmfire" : "GR_S_FIRE");
            sSummon2 = (spInfo.bNWN2 ? "c_elmfirehuge" : "NW_S_FIREHUGE");
            sSummon3 = (spInfo.bNWN2 ? "c_elmfiregreater" : "NW_SW_FIREGREAT");
            break;
        case SPELL_GR_ELE_SWARM_WATER:
            sSummon1 = (spInfo.bNWN2 ? "c_elmwater" : "GR_S_WATER");
            sSummon2 = (spInfo.bNWN2 ? "c_elmwaterhuge" : "NW_S_WATERHUGE");
            sSummon3 = (spInfo.bNWN2 ? "c_elmwatergreater" : "NW_SW_WATERGREAT");
            break;
    }

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
    //*:* list effect declarations here

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(oCaster, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    GRDoSummonElementals(spInfo.iSpellID, oCaster, spInfo.lTarget, fDuration, 4, 2, sSummon1);
    DelayCommand(GRGetDuration(10, DUR_TYPE_TURNS),
        GRDoSummonElementals(spInfo.iSpellID, oCaster, spInfo.lTarget, GRGetDuration((spInfo.iCasterLevel-1)*10, DUR_TYPE_TURNS),
            4, 1, sSummon2));
    DelayCommand(GRGetDuration(20, DUR_TYPE_TURNS),
        GRDoSummonElementals(spInfo.iSpellID, oCaster, spInfo.lTarget, GRGetDuration((spInfo.iCasterLevel-2)*10, DUR_TYPE_TURNS),
            1, 1, sSummon3));

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
