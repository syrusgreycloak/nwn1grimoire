//*:**************************************************************************
//*:*  GR_IN_TURNING.NSS
//*:**************************************************************************
//*:*
//*:* Functions to assist turning/rebuking/bolstering undead
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2005
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IN_SPELLS"
#include "GR_IN_DEITIES"

const string ARR_TURN = "GR_TURN";
const string CREATURE = "CREATURE";
const string DISTANCE = "DISTANCE";
const string HITDICE = "HITDICE";

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
int     GRGetRebukesUndead(object oCaster = OBJECT_SELF);
int     GRGetIsValidTurnRebukeTarget(object oTarget, int iMaxHDAffected, object oCaster = OBJECT_SELF);
int     GRGetCharismaMod(object oCaster = OBJECT_SELF);
int     GRGetMaxUndeadHDAffected(object oCaster = OBJECT_SELF);
int     GRGetNumUndeadHDAffected(object oCaster = OBJECT_SELF);
int     GRGetTurningCheck(object oCaster = OBJECT_SELF);
int     GRGetTurningLevel(object oCaster = OBJECT_SELF);
void    GRSetBaseTurningInfo(object oCaster = OBJECT_SELF);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************
int GRGetRebukesUndead(object oCaster = OBJECT_SELF) {

    int bRebuke = (GetAlignmentGoodEvil(oCaster)==ALIGNMENT_EVIL ||
                    GRGetDeityAlignGoodEvil(GetLocalInt(oCaster, "MY_DEITY"))==ALIGNMENT_EVIL ||
                    GRGetDeity(oCaster)==DEITY_WEE_JAS) &&
                    GRGetDeity(oCaster)!=DEITY_ST_CUTHBERT;

    return bRebuke;
}

//*:**********************************************
int GRGetIsValidTurnRebukeTarget(object oTarget, int iMaxHDAffected, object oCaster = OBJECT_SELF) {

    int bValid = FALSE;
    int iHD = GetHitDice(oTarget);

    int bEarthType = FindSubString(GetStringLowerCase(GetResRef(oTarget)),"ear")>=0;
    int bAirType = FindSubString(GetStringLowerCase(GetResRef(oTarget)),"air")>=0;
    int bWaterType = FindSubString(GetStringLowerCase(GetResRef(oTarget)),"wat")>=0;
    int bFireType = FindSubString(GetStringLowerCase(GetResRef(oTarget)),"fir")>=0;

    switch(GRGetRacialType(oTarget)) {
        case RACIAL_TYPE_UNDEAD:
            bValid = TRUE;
            break;
        case RACIAL_TYPE_ELEMENTAL:
            if((GRGetHasDomain(DOMAIN_AIR) || GRGetHasDomain(DOMAIN_EARTH)) &&
                (bAirType || bEarthType) ) {
                    bValid = TRUE;
            } else if((GRGetHasDomain(DOMAIN_FIRE) || GRGetHasDomain(DOMAIN_WATER)) &&
                (bFireType || bWaterType) ) {
                    bValid = TRUE;
            }
            break;
        case RACIAL_TYPE_VERMIN:
            bValid = GRGetHasDomain(DOMAIN_PLANT);
            break;
        case RACIAL_TYPE_OOZE:
            bValid = GRGetHasDomain(DOMAIN_SLIME);
            break;
        case RACIAL_TYPE_OUTSIDER:
            bValid = TRUE;
            if(GetHasFeat(854)) {
                 //Planar turning decreases spell resistance against turning by 1/2
                 iHD = GetHitDice(oTarget) + (GetSpellResistance(oTarget)/2) + GetTurnResistanceHD(oTarget);
            } else {
                iHD = GetHitDice(oTarget) + (GetSpellResistance(oTarget) + GetTurnResistanceHD(oTarget));
            }
            break;
    }
    if(!GRGetRacialType(oTarget)==RACIAL_TYPE_OUTSIDER) {
        iHD = GetHitDice(oTarget) + GetTurnResistanceHD(oTarget);
    }

    if(bValid && iHD>iMaxHDAffected) {
        bValid = FALSE;
    } else {
        SetLocalInt(oTarget, "TURN_HD", iHD); // store for access in main script
    }

    return bValid;
}

//*:**********************************************
//*:* GRGetCharismaMod
//*:**********************************************
//*:*
//*:*  Returns the charisma modifier for this caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetCharismaMod(object oCaster = OBJECT_SELF) {

    int iChaMod = GetAbilityModifier(ABILITY_CHARISMA, oCaster);

    if(GRGetHasSpellEffect(SPELL_GR_CONSECRATE, oCaster)) {
        iChaMod += 3;
    }

    return iChaMod;
}

//*:**********************************************
//*:* GRGetMaxUndeadHDAffected
//*:**********************************************
//*:*
//*:* Returns the maximum number of HD the cleric
//*:* can affect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetMaxUndeadHDAffected(object oCaster = OBJECT_SELF) {

    int iTurningCheckRoll = GetLocalInt(oCaster, "GR_L_TURN_CHECK");
    int iTurnLevel = GetLocalInt(oCaster, "GR_L_TURN_LEVEL");
    int iMaxHDAffected = iTurnLevel;

    if(iTurningCheckRoll<1) {
        iMaxHDAffected -= 4;
    } else if(iTurningCheckRoll<4) {
        iMaxHDAffected -= 3;
    } else if(iTurningCheckRoll<7) {
        iMaxHDAffected -= 2;
    } else if(iTurningCheckRoll<10) {
        iMaxHDAffected -= 1;
    } else if(iTurningCheckRoll<13) {
        // no modifier
        iMaxHDAffected = iMaxHDAffected;
    } else if(iTurningCheckRoll<16) {
        iMaxHDAffected += 1;
    } else if(iTurningCheckRoll<19) {
        iMaxHDAffected += 2;
    } else if(iTurningCheckRoll<22) {
        iMaxHDAffected += 3;
    } else {
        iMaxHDAffected += 4;
    }

    if(iMaxHDAffected<0) iMaxHDAffected=0;

    return iMaxHDAffected;
}

//*:**********************************************
//*:* GRGetNumUndeadHDAffected
//*:**********************************************
//*:*
//*:* Returns the number of HD the cleric affects
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetNumUndeadHDAffected(object oCaster = OBJECT_SELF) {

    int iNumAffected = d6(2) + GetLocalInt(oCaster, "GR_L_CHA_TURN_MOD") + GetLocalInt(oCaster, "GR_L_TURN_LEVEL");

    // remove the below IF statement once Greater Turning power
    // has been created for the Sun Domain
    /*if(GetHasFeat(FEAT_SUN_DOMAIN_POWER, oCaster)) {
        iNumAffected += d6();
    }*/

    return iNumAffected;
}

//*:**********************************************
//*:* GRGetTurningCheck
//*:**********************************************
//*:*
//*:* Returns the turning check result for the cleric
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetTurningCheck(object oCaster = OBJECT_SELF) {

    int iBonus = 0;  //*:* Hymn of Praise/Infernal Threnody bonus/penalty

    if(GetHasSpellEffect(SPELL_GR_HYMN_OF_PRAISE, oCaster)) {
        switch(GetAlignmentGoodEvil(oCaster)) {
            case ALIGNMENT_GOOD: iBonus = 4; break;
            case ALIGNMENT_EVIL: iBonus = -4; break;
        }
    }
    if(GetHasSpellEffect(SPELL_GR_INFERNAL_THRENODY, oCaster)) {
        switch(GetAlignmentGoodEvil(oCaster)) {
            case ALIGNMENT_GOOD: iBonus = -4; break;
            case ALIGNMENT_EVIL: iBonus = 4; break;
        }
    }

    int iTurnCheck = d20() + GetLocalInt(oCaster, "GR_L_CHA_TURN_MOD") + iBonus;

    // remove the below IF statement once Greater Turning power
    // has been created for the Sun Domain
    /*if(GetHasFeat(FEAT_SUN_DOMAIN_POWER, oCaster)) {
        iTurnCheck += d4();
    }*/

    return iTurnCheck;
}

//*:**********************************************
//*:* GRGetTurningLevel
//*:**********************************************
//*:*
//*:* Returns the turning level for the cleric
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2005
//*:**********************************************
//*:* Updated On: November 13, 2007
//*:**********************************************
int GRGetTurningLevel(object oCaster = OBJECT_SELF) {

    int     iClericLevel        = GRGetLevelByClass(CLASS_TYPE_CLERIC);
    int     iPaladinLevel       = GRGetLevelByClass(CLASS_TYPE_PALADIN);
    int     iBlackguardLevel    = GRGetLevelByClass(CLASS_TYPE_BLACKGUARD);
    int     iTotalLevel         = GetHitDice(oCaster);

    int     iTurnLevel      = iClericLevel;

    if(iPaladinLevel>0 && GRGetHasSpellEffect(SPELL_GR_SEEK_ETERNAL_REST, oCaster)) {
        iPaladinLevel += 3;  // Paladins turn as 3 lvls lower than a cleric
    }

    // GZ: Since paladin levels stack when turning, blackguard levels should stack as well
    // GZ: but not with the paladin levels (thus else if).

    // SG: Apr 05: Changed check to prevent stacking of paladin levels if char has blackguard levels
    // SG: GZ's previous check only checked if there were more blackguard levels than paladin levels
    // SG: This would fall through and paladin levels could stack if char had 1 or 2 blackguard levels
    // SG: If character has Blackguard levels, they've lost Paladin abilities
    // SG: and should no longer get Paladin level stack at all

    // SG: November 13, 2007 - 3.5 edition rules - Paladin turns as cleric 3 levels lower, not 2
    // SG: Blackguards still turn as 2 levels lower

    if((iBlackguardLevel - 2) > 0) { // removed check if blackguard levels > paladin levels
        iTurnLevel  += (iBlackguardLevel - 2);
    } else if((iPaladinLevel - 3) > 0  && iBlackguardLevel == 0) { // only if no blackguard levels
        iTurnLevel  += (iPaladinLevel - 3);
    }

    return iTurnLevel;
}

//*:**********************************************
//*:* GRSetBaseTurningInfo
//*:**********************************************
//*:*
//*:* Sets all the above info as locals on the caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRSetBaseTurningInfo(object oCaster = OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_L_CHA_TURN_MOD", GRGetCharismaMod(oCaster));
    SetLocalInt(oCaster, "GR_L_TURN_CHECK", GRGetTurningCheck(oCaster));
    SetLocalInt(oCaster, "GR_L_TURN_LEVEL", GRGetTurningLevel(oCaster));
    SetLocalInt(oCaster, "GR_L_TURN_MAX_HD", GRGetMaxUndeadHDAffected(oCaster));
    SetLocalInt(oCaster, "GR_L_TURN_NUM_HD", GRGetNumUndeadHDAffected(oCaster));

}

//*:**************************************************************************
//*:**************************************************************************
