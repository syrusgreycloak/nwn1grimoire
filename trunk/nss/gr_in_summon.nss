//*:**************************************************************************
//*:*  GR_IN_SUMMON.NSS
//*:**************************************************************************
//*:*
//*:* Updated to do a proper multisummon effect, centralize code, and to allow
//*:* for functioning of summoning spells per the PHB where you can instead
//*:* cast a "lower" level summon and get multiple creatures.
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
//*:**********************************************
//*:* Game Libraries

//*:**********************************************
//*:* Constant Libraries
//#include "GR_IC_FEATS" - INCLUDED IN GR_IN_LIB

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_ALIGNMENT"
#include "GR_IN_ARRLIST"
#include "GR_IN_SPELLS"

const string ARR_SUMMON = "GR_SUMMONS";
const string CREATURE = "CREA";

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void    GRDestroyPreviousSummons(object oCaster = OBJECT_SELF);
void    GRDoMultiSummonEffect(int iSpellID, object oCaster, int iDurationType, location lTarget, float fDuration);
string  GRGetRandomElementalType(string sSize);
string  GRGetRandomMephitType();
string  GRGetSummonEffect(int iSpellLevel, object oCaster=OBJECT_SELF);
int     GRGetSummonVisual(int iSpellLevel);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRGetRandomElementalType
//*:**********************************************
//*:*
//*:* Chooses a random type of Elemental
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 14, 2006
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
string GRGetRandomElementalType(string sSize) {

    int iType = d4();
    string sType;
    string sSummon;

    if(iType==1) sType = "AIR";
    else if(iType==2) sType = "EARTH";
    else if(iType==3) sType = "FIRE";
    else if(iType==4) sType = "WATER";

    if(sSize=="S") {
        sSummon = "X1_S_"+sType+"SMALL";
    } else if(sSize=="M" || sSize=="L") {
        sSummon = "GR_S_"+sType;
    } else if(sSize=="H") {
        sSummon = "NW_S_"+sType+"HUGE";
    } else {
        sSummon = "NW_S_"+sType+"GREAT";
    }

    return sSummon;
}

//*:**********************************************
//*:* GRGetRandomMephitType
//*:**********************************************
//*:*
//*:* Chooses a random type of Mephit
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 14, 2006
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
string GRGetRandomMephitType() {

    string sSummon;
    int iRoll=d10();

    switch(iRoll) {
        case 1:
            sSummon = "GR_S_MEPAIR";
            break;
        case 2:
            sSummon = "GR_S_MEPDUST";
            break;
        case 3:
            sSummon = "GR_S_MEPEARTH";
            break;
        case 4:
            sSummon = "GR_S_MEPFIRE";
            break;
        case 5:
            sSummon = "GR_S_MEPICE";
            break;
        case 6:
            sSummon = "GR_S_MEPMAGMA";
            break;
        case 7:
            sSummon = "GR_S_MEPOOZE";
            break;
        case 8:
            sSummon = "GR_S_MEPSALT";
            break;
        case 9:
            sSummon = "GR_S_MEPSTEAM";
            break;
        case 10:
            sSummon = "GR_S_MEPWATER";
            break;
    }

    return sSummon;
}

//*:**********************************************
//*:* SGGetSummonEffect
//*:**********************************************
//*:*
//*:* Master script that gets the type of summons
//*:* based upon class/alignment etc.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 28, 2004
//*:* Rewritten On: July 14, 2006
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
string GRGetSummonEffect(int iSpellLevel, object oCaster=OBJECT_SELF) {

    int iRoll;
    string sSummon;
    int iDruidOrRanger      = (GetLastSpellCastClass()==CLASS_TYPE_DRUID || GetLastSpellCastClass()==CLASS_TYPE_RANGER);
    int iHasAnimalDomain    = (GRGetHasDomain(DOMAIN_ANIMAL, oCaster) && GetLastSpellCastClass()==CLASS_TYPE_CLERIC);
    string sSpellColumn;
    int iNumSummonsAvailable;

    //*:**********************************************
    //*:* Since we use random numbers, try to change where
    //*:* we start in the random number list each time
    //*:**********************************************
    Randomize();


    //*:**********************************************
    //*:* Treat clerics with Animal domain as druid or ranger for summons
    //*:* unless they have an alignment domain
    //*:* then do 50% chance for which type
    //*:**********************************************
    if(iHasAnimalDomain) {
        if(GRGetHasDomain(DOMAIN_CHAOS, oCaster) || GRGetHasDomain(DOMAIN_EVIL, oCaster) ||
           GRGetHasDomain(DOMAIN_GOOD, oCaster) || GRGetHasDomain(DOMAIN_LAW, oCaster)) {

            if(d100()<51) {
                iDruidOrRanger = TRUE;
            }

        } else {
            iDruidOrRanger = TRUE;
        }
    }

    //*:**********************************************
    //*:* Get appropriate table column
    //*:**********************************************
    if(iDruidOrRanger) {
        sSpellColumn = "Sna"+IntToString(iSpellLevel);
    } else {
        sSpellColumn = "Sm"+IntToString(iSpellLevel);
    }

    if(iDruidOrRanger) {
        //*:**********************************************
        //*:* Summon Nature's Ally
        //*:**********************************************
        iNumSummonsAvailable = StringToInt(Get2DAString("gr_sum_alnum",sSpellColumn,9));
        sSummon = Get2DAString("gr_summons",sSpellColumn,Random(iNumSummonsAvailable));
    } else if(GetLastSpellCastClass()==CLASS_TYPE_CLERIC) {

        //*:**********************************************
        //*:* Summon Monster x controlled by alignment for Clerics
        //*:**********************************************
        int iAlignment = GRGetCreatureAlignment(oCaster);

        switch(GetSpellId()) {
            case SPELL_GR_SUMMON_CREATURE_IX_CHAOS:
                iAlignment = ALIGNMENT_CN;
                break;
            case SPELL_GR_SUMMON_CREATURE_IX_EVIL:
                iAlignment = ALIGNMENT_NE;
                break;
            case SPELL_GR_SUMMON_CREATURE_IX_GOOD:
                iAlignment = ALIGNMENT_NG;
                break;
            case SPELL_GR_SUMMON_CREATURE_IX_LAW:
                iAlignment = ALIGNMENT_LN;
                break;
        }

        int iStartingAlignment = iAlignment;
        int iFirstTest = TRUE;

        iNumSummonsAvailable = StringToInt(Get2DAString("gr_sum_alnum",sSpellColumn,iAlignment));

        if(!iNumSummonsAvailable) {
            while(!iNumSummonsAvailable) {
                switch(iStartingAlignment) {
                    case ALIGNMENT_LG:
                        //*:**********************************************
                        // one step
                        //*:**********************************************
                        if(iAlignment==iStartingAlignment) iAlignment = ALIGNMENT_LN;
                        else if(iAlignment==ALIGNMENT_LN) iAlignment = ALIGNMENT_NG;
                        //*:**********************************************
                        // two steps
                        //*:**********************************************
                        else if(iAlignment==ALIGNMENT_NG) iAlignment = ALIGNMENT_CG;
                        else if(iAlignment==ALIGNMENT_CG) iAlignment = ALIGNMENT_LE;
                        //*:**********************************************
                        // default to neutral
                        //*:**********************************************
                        else {
                            iAlignment = ALIGNMENT_N;
                            iStartingAlignment = iAlignment;
                        }
                    break;
                    case ALIGNMENT_LN:
                        //*:**********************************************
                        // one step
                        //*:**********************************************
                        if(iAlignment==iStartingAlignment) iAlignment = ALIGNMENT_LG;
                        else if(iAlignment==ALIGNMENT_LG) iAlignment = ALIGNMENT_LE;
                        else {
                            iAlignment = ALIGNMENT_N;
                            iStartingAlignment = iAlignment;
                        }
                    break;
                    case ALIGNMENT_LE:
                        //*:**********************************************
                        // one step
                        //*:**********************************************
                        if(iAlignment==iStartingAlignment) iAlignment = ALIGNMENT_LN;
                        else if(iAlignment==ALIGNMENT_LN) iAlignment = ALIGNMENT_NE;
                        //*:**********************************************
                        // two steps
                        //*:**********************************************
                        else if(iAlignment==ALIGNMENT_NE) iAlignment = ALIGNMENT_CE;
                        else if(iAlignment==ALIGNMENT_CE) iAlignment = ALIGNMENT_LG;
                        //*:**********************************************
                        // default to neutral
                        //*:**********************************************
                        else {
                            iAlignment = ALIGNMENT_N;
                            iStartingAlignment = iAlignment;
                        }
                    break;
                    case ALIGNMENT_NG:
                        //*:**********************************************
                        // one step
                        //*:**********************************************
                        if(iAlignment==iStartingAlignment) iAlignment = ALIGNMENT_LG;
                        else if(iAlignment==ALIGNMENT_LG) iAlignment = ALIGNMENT_CG;
                        else {
                            iAlignment = ALIGNMENT_N;
                            iStartingAlignment = iAlignment;
                        }
                    break;
                    case ALIGNMENT_N:
                        //*:**********************************************
                        // one step
                        //*:**********************************************
                        if(iAlignment==iStartingAlignment) iAlignment = ALIGNMENT_LN;
                        else if(iAlignment==ALIGNMENT_LN) iAlignment = ALIGNMENT_CN;
                        else if(iAlignment==ALIGNMENT_CN) iAlignment = ALIGNMENT_NG;
                        else if(iAlignment==ALIGNMENT_NG) iAlignment = ALIGNMENT_NE;
                        //*:**********************************************
                        // two steps
                        //*:**********************************************
                        else if(iAlignment==ALIGNMENT_NE) iAlignment = ALIGNMENT_LG;
                        else if(iAlignment==ALIGNMENT_LG) iAlignment = ALIGNMENT_CG;
                        else if(iAlignment==ALIGNMENT_CG) iAlignment = ALIGNMENT_LE;
                        else iAlignment==ALIGNMENT_CE;
                    break;
                    case ALIGNMENT_NE:
                        //*:**********************************************
                        // one step
                        //*:**********************************************
                        if(iAlignment==iStartingAlignment) iAlignment = ALIGNMENT_LE;
                        else if(iAlignment==ALIGNMENT_LE) iAlignment = ALIGNMENT_CE;
                        else {
                            iAlignment = ALIGNMENT_N;
                            iStartingAlignment = iAlignment;
                        }
                    break;
                    case ALIGNMENT_CG:
                        //*:**********************************************
                        // one step
                        //*:**********************************************
                        if(iAlignment==iStartingAlignment) iAlignment = ALIGNMENT_CN;
                        else if(iAlignment==ALIGNMENT_CN) iAlignment = ALIGNMENT_NG;
                        //*:**********************************************
                        // two steps
                        //*:**********************************************
                        else if(iAlignment==ALIGNMENT_NG) iAlignment = ALIGNMENT_LG;
                        else if(iAlignment==ALIGNMENT_LG) iAlignment = ALIGNMENT_CE;
                        //*:**********************************************
                        // default to neutral
                        //*:**********************************************
                        else {
                            iAlignment = ALIGNMENT_N;
                            iStartingAlignment = iAlignment;
                        }
                    break;
                    case ALIGNMENT_CN:
                        //*:**********************************************
                        // one step
                        //*:**********************************************
                        if(iAlignment==iStartingAlignment) iAlignment = ALIGNMENT_CG;
                        else if(iAlignment==ALIGNMENT_CG) iAlignment = ALIGNMENT_CE;
                        else {
                            iAlignment = ALIGNMENT_N;
                            iStartingAlignment = iAlignment;
                        }
                    break;
                    case ALIGNMENT_CE:
                        //*:**********************************************
                        // one step
                        //*:**********************************************
                        if(iAlignment==iStartingAlignment) iAlignment = ALIGNMENT_NE;
                        else if(iAlignment==ALIGNMENT_NE) iAlignment = ALIGNMENT_CN;
                        //*:**********************************************
                        // two steps
                        //*:**********************************************
                        else if(iAlignment==ALIGNMENT_CN) iAlignment = ALIGNMENT_LE;
                        else if(iAlignment==ALIGNMENT_LE) iAlignment = ALIGNMENT_CG;
                        //*:**********************************************
                        // default to neutral
                        //*:**********************************************
                        else {
                            iAlignment = ALIGNMENT_N;
                            iStartingAlignment = iAlignment;
                        }
                    break;
                }
                iNumSummonsAvailable = StringToInt(Get2DAString("gr_sum_alnum",sSpellColumn,iAlignment));
            }

            int iIndexLine = StringToInt(Get2DAString("gr_sum_alnum","Start",iAlignment))+Random(iNumSummonsAvailable);
            sSummon = Get2DAString("gr_summons",sSpellColumn,iIndexLine);
        }
    }
    //*:**********************************************
    // everyone else
    //*:**********************************************
    else {
        //*:**********************************************
        //*:* Summon Monster x random
        //*:**********************************************
        iNumSummonsAvailable = StringToInt(Get2DAString("gr_sum_alnum",sSpellColumn,9));
        iRoll = Random(iNumSummonsAvailable)+1;
        string sIndexColumn = "Sm";

        if(iRoll>=10) {
            sIndexColumn = "Sna";
            iRoll-=9; // only subtract 9 as there is no Sna0 column
        }

        sIndexColumn = sIndexColumn+IntToString(iRoll);

        int iIndexLine = StringToInt(Get2DAString("gr_sum_alnum",sIndexColumn, 10+iSpellLevel));
        sSummon = Get2DAString("gr_summons", sSpellColumn, iIndexLine);
    }

    //  special creature code - Elementals/Mephits
    if(sSummon=="MEPHIT") {
        sSummon = GRGetRandomMephitType();
    } else if(GetStringLeft(sSummon, 6)=="ELEMEN") {
        sSummon = GRGetRandomElementalType(GetStringRight(sSummon, 1));
    }

    //effect eSummonedMonster = EffectSummonCreature(sSummon, iFNF_Effect);
    SetLocalString(oCaster,"GR_L_SUMMON_TAG",sSummon);

    return sSummon; //eSummonedMonster;
}

//*:**********************************************
//*:* GRGetSummonVisual
//*:**********************************************
//*:*
//*:* Gets the appropriate visual for the spell level
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 14, 2006
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetSummonVisual(int iSpellLevel) {

    int iFNF_Effect;

    if(iSpellLevel<4) {
        iFNF_Effect = VFX_FNF_SUMMON_MONSTER_1;
    } else if(iSpellLevel<6) {
        iFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
    } else {
        iFNF_Effect = VFX_FNF_SUMMON_MONSTER_3;
    }

    return iFNF_Effect;
}

//*:**********************************************
//*:* GRDoMultiSummonEffect
//*:**********************************************
//*:*
//*:* Loop wrapper for GRGetSummonEffect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 28, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRDoMultiSummonEffect(int iSpellID, object oCaster, int iDurationType, location lTarget, float fDuration) {

    int iEffectSpellLevel;
    int iDieType    = 3;
    int iNumDice    = 1;
    int iBonus      = 0;
    int iNumToSummon= 1;
    int bSwarmSpell = FALSE;
    effect eSummon;

    if(iSpellID==SPELL_SUMMON_CREATURE_I) {
        iEffectSpellLevel = 1;
        iDieType = 1;
    }

    if(iSpellID>805) {
        switch(iSpellID) {
            case SPELL_GR_SUMMON_CREATURE_I_D4P1_III:
            case SPELL_GR_SUMMON_CREATURE_I_D4P1_IV:
            case SPELL_GR_SUMMON_CREATURE_I_D4P1_V:
                iDieType=4;
                iBonus=1;
            case SPELL_GR_SUMMON_CREATURE_I_D3:
                iEffectSpellLevel = 1;
                break;
            case SPELL_GR_SUMMON_CREATURE_II_D4P1_IV:
            case SPELL_GR_SUMMON_CREATURE_II_D4P1_V:
            case SPELL_GR_SUMMON_CREATURE_II_D4P1_VI:
                iDieType=4;
                iBonus=1;
            case SPELL_GR_SUMMON_CREATURE_II_D3:
                iEffectSpellLevel = 2;
                break;
            case SPELL_GR_SUMMON_CREATURE_II_NORMAL:
                iEffectSpellLevel = 2;
                iDieType=1;
                break;
            case SPELL_GR_SUMMON_CREATURE_III_D4P1_V:
            case SPELL_GR_SUMMON_CREATURE_III_D4P1_VI:
            case SPELL_GR_SUMMON_CREATURE_III_D4P1_VII:
                iDieType=4;
                iBonus=1;
            case SPELL_GR_SUMMON_CREATURE_III_D3:
                iEffectSpellLevel = 3;
                break;
            case SPELL_GR_SUMMON_CREATURE_III_NORMAL:
                iEffectSpellLevel = 3;
                iDieType=1;
                break;
            case SPELL_GR_SUMMON_CREATURE_IV_D4P1_VI:
            case SPELL_GR_SUMMON_CREATURE_IV_D4P1_VII:
            case SPELL_GR_SUMMON_CREATURE_IV_D4P1_VIII:
                iDieType=4;
                iBonus=1;
            case SPELL_GR_SUMMON_CREATURE_IV_D3:
                iEffectSpellLevel = 4;
                break;
            case SPELL_GR_SUMMON_CREATURE_IV_NORMAL:
                iEffectSpellLevel = 4;
                iDieType=1;
                break;
            case SPELL_GR_SUMMON_CREATURE_V_D4P1_VII:
            case SPELL_GR_SUMMON_CREATURE_V_D4P1_VIII:
            case SPELL_GR_SUMMON_CREATURE_V_D4P1_IX:
                iDieType=4;
                iBonus=1;
            case SPELL_GR_SUMMON_CREATURE_V_D3:
                iEffectSpellLevel = 5;
                break;
            case SPELL_GR_SUMMON_CREATURE_V_NORMAL:
                iEffectSpellLevel = 5;
                iDieType=1;
                break;
            case SPELL_GR_SUMMON_CREATURE_VI_D4P1_VIII:
            case SPELL_GR_SUMMON_CREATURE_VI_D4P1_IX:
                iDieType=4;
                iBonus=1;
            case SPELL_GR_SUMMON_CREATURE_VI_D3:
                iEffectSpellLevel = 6;
                break;
            case SPELL_GR_SUMMON_CREATURE_VI_NORMAL:
                iEffectSpellLevel = 6;
                iDieType=1;
                break;
            case SPELL_GR_SUMMON_CREATURE_VII_D4P1_IX:
                iDieType=4;
                iBonus=1;
            case SPELL_GR_SUMMON_CREATURE_VII_D3:
                iEffectSpellLevel = 7;
                break;
            case SPELL_GR_SUMMON_CREATURE_VII_NORMAL:
                iEffectSpellLevel = 7;
                iDieType=1;
                break;
            case SPELL_GR_SUMMON_CREATURE_VIII_D3:
                iEffectSpellLevel = 8;
                break;
            case SPELL_GR_SUMMON_CREATURE_VIII_NORMAL:
                iEffectSpellLevel = 8;
                iDieType=1;
                break;
            case SPELL_GR_SUMMON_CREATURE_IX_NORMAL:
                iEffectSpellLevel = 9;
                iDieType=1;
                break;
            case SPELL_ELEMENTAL_SWARM:
            case SPELL_GR_ELE_SWARM_AIR:
            case SPELL_GR_ELE_SWARM_EARTH:
            case SPELL_GR_ELE_SWARM_FIRE:
            case SPELL_GR_ELE_SWARM_WATER:
                iEffectSpellLevel = 9;
                iDieType = GetLocalInt(oCaster, "GR_ELE_SWARM_DIE");
                iNumDice = GetLocalInt(oCaster, "GR_ELE_SWARM_NUMDICE");
                bSwarmSpell = TRUE;
                break;
        }

        if(iDieType!=1)
            iNumToSummon = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, GRGetMetamagicFeat(), iBonus);
    }


    string sSummon = GetLocalString(oCaster,"GR_L_SUMMON_TAG");
    object oSummon;

    int i;
    int j;
    /*** NWN1 SINGLE ***/ int iSummonVisual = GRGetSummonVisual(iEffectSpellLevel);
    //*** NWN2 SINGLE ***/ int iSummonVisual = VFX_HIT_SPELL_SUMMON_CREATURE;

    if(!bSwarmSpell) {
        eSummon = EffectSummonCreature(GRGetSummonEffect(iEffectSpellLevel, oCaster), iSummonVisual);
        sSummon = GetLocalString(oCaster,"GR_L_SUMMON_TAG");
    } else {
        eSummon = EffectSummonCreature(sSummon, iSummonVisual);
    }

    DeleteLocalString(oCaster,"GR_L_SUMMON_TAG");


    while(GetLocalInt(oCaster, "GR_L_DESTROYING_SUMMONS")) {
        // wait
    }

    effect eStr = EffectAbilityIncrease(ABILITY_STRENGTH, 4);
    effect eCon = EffectAbilityIncrease(ABILITY_CONSTITUTION, 4);
    effect eAugmentSummons = EffectLinkEffects(eStr, eCon);
    effect eTempHP; // for Elemental Swarm - max HP per die

    if(iNumToSummon==1) {
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, lTarget, fDuration);
        if(GetHasFeat(FEAT_GR_AUGMENT_SUMMONING, oCaster)) {
            oSummon = GetNearestObjectByTag(sSummon, oCaster, 1);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAugmentSummons, oSummon, fDuration);
        }
    } else {
        for(i=1; i<=iNumToSummon; i++) {
            if(i>1) {
                eSummon = EffectSummonCreature(sSummon, VFX_NONE, i*0.1);
            }
            GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, lTarget, fDuration);
            int j = 1;
            int bFound = FALSE;

            while(!bFound && j<50) { // sanity check j<50 to drop out of loop, just in case something strange happens
                oSummon = GetNearestObjectByTag(sSummon, oCaster, j);
                if(GetMaster(oSummon)==oCaster) {
                    if(GetPlotFlag(oSummon)==FALSE) {
                        bFound = TRUE;
                        if(bSwarmSpell) {
                            eTempHP = EffectTemporaryHitpoints(GetHitDice(oSummon)*8-GetMaxHitPoints(oSummon));
                            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eTempHP), oSummon);
                        }
                        SetPlotFlag(oSummon, TRUE);
                        AssignCommand(oSummon, SetIsDestroyable(FALSE));
                        SetLocalInt(oSummon, "GR_L_AM_SUMMON", TRUE);
                        if(GetHasFeat(FEAT_GR_AUGMENT_SUMMONING, oCaster)) {
                            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAugmentSummons, oSummon, fDuration);
                        }
                        GRObjectAdd(ARR_SUMMON, CREATURE, oCaster); // add to tracking array
                    }
                }
                j++;
            }
        }
    }
}

//*:**********************************************
//*:* GRDestroyPreviousSummons
//*:**********************************************
//*:*
//*:* Although the summons duration has been reduced
//*:* to match the PHB, it may cause a lag issue if
//*:* casters spam out multitudes of creatures.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 28, 2004
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRDestroyPreviousSummons(object oCaster = OBJECT_SELF) {

    int iSize = GRGetDimSize(ARR_SUMMON, CREATURE, oCaster);
    if(iSize>0) {
        SetLocalInt(oCaster, "GR_L_DESTROYING_SUMMONS", TRUE);

        object oSummon;
        /* We use the original size of the array above to monitor
           the loop instead of waiting for GRObjectPop to hit the
           bottom of the "stack" to give us OBJECT_INVALID just in
           case a summons is killed and is no longer valid anyway */
        while(iSize>0) {
            oSummon = GRObjectPop(ARR_SUMMON, CREATURE, oCaster);
            if(GetIsObjectValid(oSummon))
                DestroyObject(oSummon);   // if valid, destroy the summons
            iSize--; // we could do the function call to get the size
                     // but it's quicker just to decrement the variable
        }

        SetLocalInt(oCaster, "GR_L_DESTROYING_SUMMONS", FALSE);
    }
}
//*:**************************************************************************
//*:**************************************************************************
