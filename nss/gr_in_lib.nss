//*:**************************************************************************
//*:*  GR_IN_LIB.NSS
//*:**************************************************************************
//*:*
//*:* Miscellaneous, general-use functions
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
#include "X0_I0_POSITION"
#include "X2_I0_SPELLS"

//*:**********************************************
//*:* Constant Libraries
#include "GR_IC_LIB"
#include "GR_IC_SPELLS"
#include "GR_IC_FEATS"
#include "GR_IC_NAMES"

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_STRUCTS"

//*:**************************************************************************
//*:* Constants
//*:**************************************************************************
const float UNDERWATER_SONIC_MULTIPLIER = 1.5;

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
float       GRAbsF(float fNum);
int         GRXor(int bValue1, int bValue2);
int         GRGetArmorType(object oItem);
int         GRGetHasMediumOrGreaterLoad(object oTarget=OBJECT_SELF);
int         GRGetCasterAbilityModifierByClass(object oCaster, int iSpellCastClass);
float       GRGetDuration(int iNumber, int iDurationType = DUR_TYPE_ROUNDS, int iEnergyType = DAMAGE_TYPE_MAGICAL, int iFogSpell = FALSE);
object      GRGetFirstObjectInShape(int iShape, float fSize, location lTarget, int bLineOfSight = FALSE,
                int iObjectFilter = OBJECT_TYPE_CREATURE, vector vOrigin = [0.0,0.0,0.0]);
int         GRGetHasClass(int iClassType, object oCreature=OBJECT_SELF);
int         GRGetIsArcaneCaster(object oCreature);
int         GRGetIsArcaneClass(int iClass);
int         GRGetIsImmuneToMagicalHealing(object oTarget);
void        GRSetIsImmuneToMagicalHealing(object oTarget, int bImmune = TRUE);
location    GRGetMissLocation(object oTarget);
object      GRGetNextObjectInShape(int iShape, float fSize, location lTarget, int bLineOfSight = FALSE,
                int iObjectFilter = OBJECT_TYPE_CREATURE, vector vOrigin = [0.0,0.0,0.0]);
int         GRGetSpellcastingLevelByClass(int iClassType, object oCaster=OBJECT_SELF);

float       GRMetersToFeet(float fMeters);
void        Randomize();
int         MaxInt(int Int1, int Int2, int Int3=0, int Int4=0);
int         MinInt(int Int1, int Int2, int Int3=0, int Int4=0);

int         GRDetermineBaseSaveValue(object oTarget, int iSavingThrow);
int         GRGetAbilityModifier(int iAbility, object oCreature = OBJECT_SELF, int bBaseAbilityModifier = FALSE);
struct class_info GRGetClassInfo(object oCreature);

int         GRTouchAttackRanged(object oTarget, int bDisplayFeedback = TRUE);
int         GRTouchAttackMelee(object oTarget, int bDisplayFeedback = TRUE);
int         GRGetClassByPosition(int iPosition, object oCreature =  OBJECT_SELF);
int         GRGetLevelByClass(int iClassType, object oCreature = OBJECT_SELF);

int         GRGetIsDying(object oTarget);

int         GRGetMagicBlocked(object oObject = OBJECT_SELF);
void        GRSetMagicBlocked(int bTrueFalse, object oObject = OBJECT_SELF);

string      GRGetUniqueSpellIdentifier(int iSpellID, object oCaster = OBJECT_SELF);
int         GRGetIsUnderwater(object oCaster=OBJECT_SELF);
int         GRGetAdjustedUnderwaterSonicDamage(int iDamage, int iEnergyType);
object      GRGetLastKiller(object oCreature);
int         GRGetSkillModifier(int iSkill, object oCreature);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************
//*:**********************************************
//*:* GRGetAdjustedUnderwaterSonicDamage
//*:**********************************************
//*:*
//*:* Adjusts damage using sonic mulitplier
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetAdjustedUnderwaterSonicDamage(int iDamage, int iEnergyType) {

    float fCustomMultiplier = GetLocalFloat(GetModule(), UNDERWATER_SONIC_MULTIPLIER_CUSTOM);

    if(FloatToInt(fCustomMultiplier)!=0) {
        iDamage = FloatToInt(iDamage*fCustomMultiplier);
    } else {
        iDamage = FloatToInt(iDamage*UNDERWATER_SONIC_MULTIPLIER);
    }

    return iDamage;
}

//*:**********************************************
//*:* GRGetIsUnderwater
//*:**********************************************
//*:*
//*:* Checks if caster is underwater
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetIsUnderwater(object oCaster=OBJECT_SELF) {

    if(GetLocalInt(oCaster, UNDERWATER) || GetLocalInt(GetArea(oCaster), UNDERWATER))
        return TRUE;

    return FALSE;
}


//*:**********************************************
//*:* Float Absolute Value
//*:**********************************************
//*:*
//*:* Get the Absolute Value of a float without
//*:* losing precision by using the included abs(int num)
//*:* function.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 20, 2004
//*:**********************************************
//*:* Updated On: February 14, 2007
//*:**********************************************
float GRAbsF(float fNum) {
    if(fNum<0.0) fNum = -fNum;
    return fNum;
}

int GRXor(int bValue1, int bValue2) {

    return ((bValue1 && bValue2) || (!bValue1 && !bValue2));
}

//*:**********************************************
//*:* GRGetArmorType
//*:**********************************************
// Returns the base armor type as a number, of oItem
// -1 if invalid, or not armor, or just plain not found.
// 0 to 8 as the value of AC got from the armor - 0 for none, 8 for Full plate.
//*:**********************************************
//*:* Copied from NWN Lexicon
//*:**********************************************
int GRGetArmorType(object oItem) {
    //*:**********************************************
    //*:* Make sure the item is valid and is an armor.
    //*:**********************************************
    if (!GetIsObjectValid(oItem))
        return -1;
    if (GetBaseItemType(oItem) != BASE_ITEM_ARMOR)
        return -1;

    //*:**********************************************
    //*:* Get the identified flag for safe keeping.
    //*:**********************************************
    int bIdentified = GetIdentified(oItem);
    SetIdentified(oItem,FALSE);

    int nType = -1;
    switch (GetGoldPieceValue(oItem))
    {
        case    1: nType = 0; break; // None
        case    5: nType = 1; break; // Padded
        case   10: nType = 2; break; // Leather
        case   15: nType = 3; break; // Studded Leather / Hide
        case  100: nType = 4; break; // Chain Shirt / Scale Mail
        case  150: nType = 5; break; // Chainmail / Breastplate
        case  200: nType = 6; break; // Splint Mail / Banded Mail
        case  600: nType = 7; break; // Half-Plate
        case 1500: nType = 8; break; // Full Plate
    }
    //*:**********************************************
    //*:* Restore the identified flag, and return armor type.
    //*:**********************************************
    SetIdentified(oItem,bIdentified);

    return nType;
}

//*:**********************************************
//*:* GRGetHasMediumOrGreaterLoad
//*:**********************************************
//*:*
//*:* Checks a character's weight being carried.  For use
//*:* with whether evasion/improved evasion applies
//*:* to reflex-half saving throws.
//*:*
//*:**********************************************
//*:* Created by: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 31, 2006
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetHasMediumOrGreaterLoad(object oTarget=OBJECT_SELF) {

    int iSTR = GetAbilityScore(oTarget, ABILITY_STRENGTH);
    int iWeight = GetWeight(oTarget)/10;
    int iLoad = FALSE;

    switch(iSTR) {
        case 1:
            if(iWeight>3) iLoad = TRUE;
            break;
        case 2:
            if(iWeight>6) iLoad = TRUE;
            break;
        case 3:
            if(iWeight>10) iLoad = TRUE;
            break;
        case 4:
            if(iWeight>13) iLoad = TRUE;
            break;
        case 5:
            if(iWeight>16) iLoad = TRUE;
            break;
        case 6:
            if(iWeight>20) iLoad = TRUE;
            break;
        case 7:
            if(iWeight>23) iLoad = TRUE;
            break;
        case 8:
            if(iWeight>26) iLoad = TRUE;
            break;
        case 9:
            if(iWeight>30) iLoad = TRUE;
            break;
        case 10:
            if(iWeight>33) iLoad = TRUE;
            break;
        case 11:
            if(iWeight>38) iLoad = TRUE;
            break;
        case 12:
            if(iWeight>43) iLoad = TRUE;
            break;
        case 13:
            if(iWeight>50) iLoad = TRUE;
            break;
        case 14:
            if(iWeight>58) iLoad = TRUE;
            break;
        case 15:
            if(iWeight>66) iLoad = TRUE;
            break;
        case 16:
            if(iWeight>76) iLoad = TRUE;
            break;
        case 17:
            if(iWeight>86) iLoad = TRUE;
            break;
        case 18:
            if(iWeight>100) iLoad = TRUE;
            break;
        case 19:
            if(iWeight>116) iLoad = TRUE;
            break;
        case 20:
            if(iWeight>133) iLoad = TRUE;
            break;
        case 21:
            if(iWeight>153) iLoad = TRUE;
            break;
        case 22:
            if(iWeight>173) iLoad = TRUE;
            break;
        case 23:
            if(iWeight>200) iLoad = TRUE;
            break;
        case 24:
            if(iWeight>233) iLoad = TRUE;
            break;
        case 25:
            if(iWeight>266) iLoad = TRUE;
            break;
        case 26:
            if(iWeight>306) iLoad = TRUE;
            break;
        case 27:
            if(iWeight>346) iLoad = TRUE;
            break;
        case 28:
            if(iWeight>400) iLoad = TRUE;
            break;
        case 29:
            if(iWeight>466) iLoad = TRUE;
            break;
        case 30:
            if(iWeight>133*4) iLoad = TRUE;
            break;
        case 31:
            if(iWeight>153*4) iLoad = TRUE;
            break;
        case 32:
            if(iWeight>173*4) iLoad = TRUE;
            break;
        case 33:
            if(iWeight>200*4) iLoad = TRUE;
            break;
        case 34:
            if(iWeight>233*4) iLoad = TRUE;
            break;
        case 35:
            if(iWeight>266*4) iLoad = TRUE;
            break;
        case 36:
            if(iWeight>306*4) iLoad = TRUE;
            break;
        case 37:
            if(iWeight>346*4) iLoad = TRUE;
            break;
        case 38:
            if(iWeight>400*4) iLoad = TRUE;
            break;
        case 39:
            if(iWeight>466*4) iLoad = TRUE;
            break;
        case 40:
            if(iWeight>133*8) iLoad = TRUE;
            break;
        case 41:
            if(iWeight>153*8) iLoad = TRUE;
            break;
        case 42:
            if(iWeight>173*8) iLoad = TRUE;
            break;
        case 43:
            if(iWeight>200*8) iLoad = TRUE;
            break;
        case 44:
            if(iWeight>233*8) iLoad = TRUE;
            break;
        case 45:
            if(iWeight>266*8) iLoad = TRUE;
            break;
        case 46:
            if(iWeight>306*8) iLoad = TRUE;
            break;
        case 47:
            if(iWeight>346*8) iLoad = TRUE;
            break;
        case 48:
            if(iWeight>400*8) iLoad = TRUE;
            break;
        case 49:
            if(iWeight>466*8) iLoad = TRUE;
            break;
        case 50:
            if(iWeight>133*12) iLoad = TRUE;
            break;
        case 51:
            if(iWeight>153*12) iLoad = TRUE;
            break;
        case 52:
            if(iWeight>173*12) iLoad = TRUE;
            break;
        case 53:
            if(iWeight>200*12) iLoad = TRUE;
            break;
        case 54:
            if(iWeight>233*12) iLoad = TRUE;
            break;
        case 55:
            if(iWeight>266*12) iLoad = TRUE;
            break;
        case 56:
            if(iWeight>306*12) iLoad = TRUE;
            break;
        case 57:
            if(iWeight>346*12) iLoad = TRUE;
            break;
        case 58:
            if(iWeight>400*12) iLoad = TRUE;
            break;
        case 59:
            if(iWeight>466*12) iLoad = TRUE;
            break;
        case 60:
            if(iWeight>133*16) iLoad = TRUE;
            break;
    }

    return iLoad;
}

//*:**********************************************
//*:* GRGetCasterAbilityModifierByClass
//*:**********************************************
//*:*
//*:*    Returns the modifier from the ability
//*:*    score that matters for this caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 8, 2004
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetCasterAbilityModifierByClass(object oCaster, int iSpellCastClass) {

    int iAbility;

    switch(iSpellCastClass) {
        case CLASS_TYPE_WIZARD:
            iAbility = ABILITY_INTELLIGENCE;
            break;
        case CLASS_TYPE_CLERIC:
        case CLASS_TYPE_DRUID:
        case CLASS_TYPE_RANGER:
        case CLASS_TYPE_PALADIN:
            iAbility = ABILITY_WISDOM;
            break;
        case CLASS_TYPE_SORCERER:
        case CLASS_TYPE_BARD:
            iAbility = ABILITY_CHARISMA;
            break;
    }

    return GetAbilityModifier(iAbility, oCaster);
}

//*:**********************************************
//*:* GRGetDuration
//*:**********************************************
//*:*
//*:* Gets the duration requested
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 29, 2004
//*:**********************************************
//*:* Updated On: February 14, 2007
//*:**********************************************
float GRGetDuration(int iNumber, int iDurationType = DUR_TYPE_ROUNDS, int iEnergyType = DAMAGE_TYPE_MAGICAL, int iFogSpell = FALSE) {

    float fDuration;

    switch(iDurationType) {
        case DUR_TYPE_ROUNDS:
            fDuration = RoundsToSeconds(iNumber);
            break;
        case DUR_TYPE_TURNS:
            fDuration = TurnsToSeconds(iNumber);
            break;
        case DUR_TYPE_HOURS:
            fDuration = HoursToSeconds(iNumber);
            break;
        case DUR_TYPE_DAYS:
            fDuration = HoursToSeconds(24*iNumber);
            break;
    }

    return fDuration;
}

//*:**********************************************
//*:* GRGetFirstObjectInShape
//*:**********************************************
//*:*
//*:* Gets first object in shape specified
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
object GRGetFirstObjectInShape(int iShape, float fSize, location lTarget, int bLineOfSight = FALSE,
    int iObjectFilter = OBJECT_TYPE_CREATURE, vector vOrigin = [0.0,0.0,0.0]) {

        return GetFirstObjectInShape(iShape, fSize, lTarget, bLineOfSight, iObjectFilter, vOrigin);
}

//*:**********************************************
//*:* GRGetHasClass
//*:**********************************************
//*:*
//*:* Determines if an object has a particular class.
//*:* Wraps GRGetClassByPosition
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: December 27, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetHasClass(int iClassType, object oCreature=OBJECT_SELF) {

    int iHasClass = FALSE;
    int i;

    for(i=1; i<=3 && !iHasClass; i++) {
        if(GRGetClassByPosition(i, oCreature)==iClassType) {
            iHasClass = TRUE;
        }
    }

    return iHasClass;
}

//*:**********************************************
//*:* GRGetIsArcaneCaster
//*:**********************************************
//*:*
//*:* Checks if spellcaster is an arcane caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 17, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetIsArcaneCaster(object oCreature) {

    int bIsArcane   = FALSE;
    int i;
    
    for(i=1; i<=3 && !bIsArcane; i++) {
    	int class = GRGetClassByPosition(i, oCreature);
    	if(GRGetIsArcaneClass(class)) {
    	    bIsArcane = TRUE;
    	}
    }

    return bIsArcane;
}

//*:**********************************************
//*:* GRGetIsArcaneClass
//*:**********************************************
//*:*
//*:* Checks if class is an arcane casting class
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 17, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetIsArcaneClass(int iClass) {

    int iIsArcane = (iClass==CLASS_TYPE_WIZARD ||
                    iClass==CLASS_TYPE_SORCERER ||
                    iClass==CLASS_TYPE_BARD);

    return iIsArcane;
}

//*:**********************************************
//*:* GRGetIsImmuneToMagicalHealing
//*:**********************************************
//*:*
//*:* Returns whether target is immune to magical
//*:* healing
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: December 29, 2004
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetIsImmuneToMagicalHealing(object oTarget) {

    int bImmune = (GetHasSpellEffect(SPELL_GR_CONDEMNED, oTarget) || GetLocalInt(oTarget, "IMMUNE_TO_HEAL"));

    return bImmune;
}

//*:**********************************************
//*:* GRSetIsImmuneToMagicalHealing
//*:**********************************************
//*:*
//*:* Sets whether target is immune to magical
//*:* healing
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 18, 2008
//*:**********************************************
void GRSetIsImmuneToMagicalHealing(object oTarget, int bImmune = TRUE) {

    SetLocalInt(oTarget, IMMUNE_TO_MAGICAL_HEALING, bImmune);
}

//*:**********************************************
//*:* GRGetMissLocation
//*:**********************************************
//*:*
//*:* Determines a random location around the target
//*:* for a miss effect for beams, etc.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 29, 2004
//*:**********************************************
//*:* Updated On: February 14, 2007
//*:**********************************************
location GRGetMissLocation(object oTarget) {
    int iRandom = d6();
    location lNewLoc;

    switch(iRandom) {
        case 1:
            lNewLoc = GetForwardFlankingRightLocation(oTarget);
            break;
        case 2:
            lNewLoc = GetFlankingRightLocation(oTarget);
            break;
        case 3:
            lNewLoc = GetBehindLocation(oTarget);
            break;
        case 4:
            lNewLoc = GetFlankingLeftLocation(oTarget);
            break;
        case 5:
            lNewLoc = GetForwardFlankingLeftLocation(oTarget);
            break;
        case 6:
            lNewLoc = GetAheadLocation(oTarget);
            break;
    }

    return lNewLoc;
}

//*:**********************************************
//*:* GRGetNextObjectInShape
//*:**********************************************
//*:*
//*:* Gets next object in shape specified.  Must first
//*:* call SGGetFirstObjectInShape
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
object GRGetNextObjectInShape(int iShape, float fSize, location lTarget, int bLineOfSight = FALSE,
    int iObjectFilter = OBJECT_TYPE_CREATURE, vector vOrigin = [0.0,0.0,0.0]) {

        return GetNextObjectInShape(iShape, fSize, lTarget, bLineOfSight, iObjectFilter, vOrigin);
}

//*:**********************************************
//*:* GRGetSpellcastingLevelByClass
//*:*   (formerly SGGetSpellcastingLevelByClass)
//*:**********************************************
//*:*
//*:* Gets class level.  Mainly used for checking
//*:* spellcaster class level.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: December 27, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetSpellcastingLevelByClass(int iClassType, object oCaster=OBJECT_SELF) {

    return GRGetLevelByClass(iClassType, oCaster);
}

//*:**********************************************
//*:* Meters To Feet
//*:**********************************************
//*:*
//*:*    Conversion function to Convert Meters To Feet
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 21, 2003
//*:**********************************************
//*:* Updated On: February 14, 2007
//*:**********************************************
float GRMetersToFeet(float fMeters) {
    return (fMeters/0.31);
}

//*:**********************************************
//*:* Randomize
//*:* 2006 Karl Nickels (Syrus Greycloak)
//*:**********************************************
/*
    Utility function: tries to make "random" sequences
    more random
*/
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: August 1, 2006
//*:**********************************************
//*:* Updated On: February 14, 2007
//*:**********************************************
void Randomize() {

    int iSeed = GetTimeHour() + GetTimeMinute() + GetTimeSecond();
    int i;
    int iDummyValue;

    for(i=0; i<iSeed; i++) {
        iDummyValue = Random(iSeed);
    }
}

//*:**********************************************
//*:* MaxInt
//*:* 2007 Karl Nickels (Syrus Greycloak)
//*:**********************************************
/*
    Utility function: returns the greater value of
    up to 4 ints
*/
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: October 19, 2007
//*:**********************************************
int MaxInt(int Int1, int Int2, int Int3=0, int Int4=0) {
    int iResult1, iResult2;

    if(Int3!=0 && Int4==0) {
        iResult1 = MaxInt(Int1, Int2);
        return (iResult1>Int3 ? iResult1 : Int3);
    } else if(Int4!=0) {
        iResult1 = MaxInt(Int1, Int2);
        iResult2 = MaxInt(Int3, Int4);
        return (iResult1>iResult2 ? iResult1 : iResult2);
    } else
        return (Int1>Int2 ? Int1 : Int2);
}

//*:**********************************************
//*:* MinInt
//*:* 2007 Karl Nickels (Syrus Greycloak)
//*:**********************************************
/*
    Utility function: returns the lesser value of
    up to 4 ints
*/
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: October 19, 2007
//*:**********************************************
int MinInt(int Int1, int Int2, int Int3=0, int Int4=0) {
    int iResult1, iResult2;

    if(Int3!=0 && Int4==0) {
        iResult1 = MinInt(Int1, Int2);
        return (iResult1<Int3 ? iResult1 : Int3);
    } else if(Int4!=0) {
        iResult1 = MinInt(Int1, Int2);
        iResult2 = MinInt(Int3, Int4);
        return (iResult1<iResult2 ? iResult1 : iResult2);
    } else
        return (Int1<Int2 ? Int1 : Int2);
}

//*:**********************************************
//*:* GRDetermineBaseSaveValue
//*:* 2008 Karl Nickels (Syrus Greycloak)
//*:**********************************************
/*
    Utility function: gets base save value without
    magic items
*/
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 30, 2008
//*:**********************************************
int GRDetermineBaseSaveValue(object oTarget, int iSavingThrow) {

    int i;
    int iClass, iLevel;
    string sSaveColumn, sTableName;
    int iSaveValue = 0;

    switch(iSavingThrow) {
        case SAVING_THROW_FORT:
            sSaveColumn = "FortSave";
            break;
        case SAVING_THROW_REFLEX:
            sSaveColumn = "RefSave";
            break;
        case SAVING_THROW_WILL:
            sSaveColumn = "WillSave";
            break;
    }

    for(i=1; i<=3; i++) {
        iClass = GRGetClassByPosition(i, oTarget);
        if(iClass!=CLASS_TYPE_INVALID) {
            iLevel = GRGetLevelByClass(iClass, oTarget);
            switch(iClass) {
                case CLASS_TYPE_BARBARIAN:
                    sTableName = "CLS_SAVTHR_BARB";
                    break;
                case CLASS_TYPE_BARD:
                case CLASS_TYPE_MONSTROUS:
                case CLASS_TYPE_FEY:
                case CLASS_TYPE_HARPER:
                    sTableName = "CLS_SAVTHR_BARD";
                    break;
                case CLASS_TYPE_CLERIC:
                case CLASS_TYPE_DWARVEN_DEFENDER:
                case CLASS_TYPE_DRAGON_DISCIPLE:
                case CLASS_TYPE_OOZE:
                    sTableName = "CLS_SAVTHR_CLER";
                    break;
                case CLASS_TYPE_DRUID:
                case CLASS_TYPE_PALEMASTER:
                    sTableName = "CLS_SAVTHR_DRU";
                    break;
                case CLASS_TYPE_FIGHTER:
                case CLASS_TYPE_HUMANOID:
                case CLASS_TYPE_GIANT:
                case CLASS_TYPE_VERMIN:
                case CLASS_TYPE_BLACKGUARD:
                case CLASS_TYPE_PURPLE_DRAGON_KNIGHT:
                    sTableName = "CLS_SAVTHR_FIGHT";
                    break;
                case CLASS_TYPE_MONK:
                case CLASS_TYPE_DRAGON:
                case CLASS_TYPE_OUTSIDER:
                case CLASS_TYPE_SHAPECHANGER:
                    sTableName = "CLS_SAVTHR_MONK";
                    break;
                case CLASS_TYPE_PALADIN:
                    sTableName = "CLS_SAVTHR_PAL";
                    break;
                case CLASS_TYPE_RANGER:
                    sTableName = "CLS_SAVTHR_RANG";
                    break;
                case CLASS_TYPE_ROGUE:
                case CLASS_TYPE_SHADOWDANCER:
                case CLASS_TYPE_ASSASSIN:
                case CLASS_TYPE_WEAPON_MASTER:
                    sTableName = "CLS_SAVTHR_ROG";
                    break;
                case CLASS_TYPE_SORCERER:
                    sTableName = "CLS_SAVTHR_SORC";
                    break;
                case CLASS_TYPE_WIZARD:
                case CLASS_TYPE_ABERRATION:
                case CLASS_TYPE_ELEMENTAL:
                case CLASS_TYPE_UNDEAD:
                    sTableName = "CLS_SAVTHR_WIZ";
                    break;
                case CLASS_TYPE_ANIMAL:
                case CLASS_TYPE_BEAST:
                case CLASS_TYPE_MAGICAL_BEAST:
                case CLASS_TYPE_ARCANE_ARCHER:
                case CLASS_TYPE_DIVINE_CHAMPION:
                case CLASS_TYPE_SHIFTER:
                    sTableName = "CLS_SAVTHR_WILD";
                    break;
                case CLASS_TYPE_CONSTRUCT:
                case CLASS_TYPE_COMMONER:
                    sTableName = "CLS_SAVTHR_CONS";
                    break;
            }

            iSaveValue += StringToInt(Get2DAString(sTableName, sSaveColumn, iLevel-1));
        }
    }

    return iSaveValue;
}

//*:**********************************************
//*:* GRGetAbilityModifier
//*:* 2008 Karl Nickels (Syrus Greycloak)
//*:**********************************************
/*
    Utility function: allows for getting modifiers
    without magic bonuses
*/
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 30, 2008
//*:**********************************************
int GRGetAbilityModifier(int iAbility, object oCreature = OBJECT_SELF, int bBaseAbilityModifier = FALSE) {

    int iModifier = 0;

    if(!bBaseAbilityModifier) {
        iModifier = GetAbilityModifier(iAbility, oCreature);
    } else {
        iModifier = (GetAbilityScore(oCreature, iAbility, TRUE)/2)-5;
    }

    return iModifier;
}

//*:**********************************************
struct class_info GRGetClassInfo(object oCreature) {

    struct class_info csClassInfo;
    int     bCastingLevels  = FALSE;
    int     bFightingLevels = FALSE;
    int     iFortLevels     = 0;
    int     iRefLevels      = 0;
    int     iWillLevels     = 0;

    //*:* Base Classes
    csClassInfo.bBarbarian = FALSE; csClassInfo.bBard = FALSE; csClassInfo.bCleric = FALSE; csClassInfo.bDruid = FALSE; csClassInfo.bFighter = FALSE;
    csClassInfo.bMonk = FALSE; csClassInfo.bPaladin = FALSE; csClassInfo.bRanger = FALSE; csClassInfo.bRogue = FALSE; csClassInfo.bSorcerer = FALSE;
    csClassInfo.bWizard = FALSE;

    //*:* Monster/NPC Classes
    csClassInfo.bAberration = FALSE; csClassInfo.bAnimal = FALSE; csClassInfo.bConstruct = FALSE; csClassInfo.bHumanoid = FALSE;
    csClassInfo.bMonstrous = FALSE; csClassInfo.bElemental = FALSE; csClassInfo.bFey = FALSE; csClassInfo.bDragon = FALSE; csClassInfo.bUndead = FALSE;
    csClassInfo.bCommoner = FALSE; csClassInfo.bBeast = FALSE; csClassInfo.bGiant = FALSE; csClassInfo.bMagicBeast = FALSE; csClassInfo.bOutsider = FALSE;
    csClassInfo.bShapechanger = FALSE; csClassInfo.bVermin = FALSE; csClassInfo.bOoze = FALSE;

    //*:* Prestige Classes
    csClassInfo.bShadowdancer = FALSE; csClassInfo.bHarper = FALSE; csClassInfo.bArcaneArcher = FALSE; csClassInfo.bAssassin = FALSE;
    csClassInfo.bBlackguard = FALSE; csClassInfo.bDivChamp = FALSE; csClassInfo.bWeaponmaster = FALSE; csClassInfo.bPaleMaster = FALSE;
    csClassInfo.bShifter = FALSE; csClassInfo.bDwarvenDefender = FALSE; csClassInfo.bDragonDisciple = FALSE; csClassInfo.bPurpleDragKnt = FALSE;

    csClassInfo.iBestSaveType = SAVING_THROW_NONE;

    int i, iClassType;

    for(i=1; i<=3; i++) {
        bCastingLevels = FALSE;
        bFightingLevels = FALSE;
        iClassType = GRGetClassByPosition(i, oCreature);
        switch(iClassType) {
            case CLASS_TYPE_BARBARIAN:
                csClassInfo.bBarbarian = TRUE;
                bFightingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_BARD:
                csClassInfo.bBard = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iRefLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                iWillLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                break;
            case CLASS_TYPE_CLERIC:
                csClassInfo.bCleric = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                iWillLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                break;
            case CLASS_TYPE_DRUID:
                csClassInfo.bDruid = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                iWillLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                break;
            case CLASS_TYPE_FIGHTER:
                csClassInfo.bFighter = TRUE;
                bFightingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_MONK:
                csClassInfo.bMonk = TRUE;
                bFightingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature)/3;
                iRefLevels += GRGetLevelByClass(iClassType, oCreature)/3;
                iWillLevels += GRGetLevelByClass(iClassType, oCreature)/3;
                break;
            case CLASS_TYPE_PALADIN:
                csClassInfo.bPaladin = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_RANGER:
                csClassInfo.bRanger = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                iRefLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                break;
            case CLASS_TYPE_ROGUE:
                csClassInfo.bRogue = TRUE;
                bFightingLevels = TRUE;
                iRefLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_SORCERER:
                csClassInfo.bSorcerer = TRUE;
                bCastingLevels = TRUE;
                iWillLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_WIZARD:
                csClassInfo.bWizard = TRUE;
                bCastingLevels = TRUE;
                iWillLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_SHADOWDANCER:
                csClassInfo.bShadowdancer = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iRefLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_HARPER:
                csClassInfo.bHarper = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iRefLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                iWillLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                break;
            case CLASS_TYPE_ARCANE_ARCHER:
                csClassInfo.bArcaneArcher = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                iRefLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                break;
            case CLASS_TYPE_ASSASSIN:
                csClassInfo.bAssassin = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iRefLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_BLACKGUARD:
                csClassInfo.bBlackguard = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_DIVINE_CHAMPION:
                csClassInfo.bDivChamp = TRUE;
                bFightingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_WEAPON_MASTER:
                csClassInfo.bWeaponmaster = TRUE;
                bFightingLevels = TRUE;
                iRefLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_PALEMASTER:
                csClassInfo.bPaleMaster = TRUE;
                bCastingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                iWillLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                break;
            case CLASS_TYPE_SHIFTER:
                csClassInfo.bShifter = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                iRefLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                break;
            case CLASS_TYPE_DWARVEN_DEFENDER:
                csClassInfo.bDwarvenDefender = TRUE;
                bFightingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                iWillLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                break;
            case CLASS_TYPE_DRAGON_DISCIPLE:
                csClassInfo.bDragonDisciple = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                iWillLevels += GRGetLevelByClass(iClassType, oCreature)/2;
                break;
            case CLASS_TYPE_PURPLE_DRAGON_KNIGHT:
                csClassInfo.bPurpleDragKnt = TRUE;
                bFightingLevels = TRUE;
                iFortLevels += GRGetLevelByClass(iClassType, oCreature);
                break;
            case CLASS_TYPE_ABERRATION:
                csClassInfo.bAberration = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                break;
            case CLASS_TYPE_ANIMAL:
                csClassInfo.bAnimal = TRUE;
                bFightingLevels = TRUE;
                break;
            case CLASS_TYPE_CONSTRUCT:
                csClassInfo.bConstruct = TRUE;
                bFightingLevels = TRUE;
                break;
            case CLASS_TYPE_HUMANOID:
                csClassInfo.bHumanoid = TRUE;
                bFightingLevels = TRUE;
                break;
            case CLASS_TYPE_MONSTROUS:
                csClassInfo.bMonstrous = TRUE;
                bFightingLevels = TRUE;
                break;
            case CLASS_TYPE_ELEMENTAL:
                csClassInfo.bElemental = TRUE;
                bFightingLevels = TRUE;
                break;
            case CLASS_TYPE_FEY:
                csClassInfo.bFey = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                break;
            case CLASS_TYPE_DRAGON:
                csClassInfo.bDragon = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                break;
            case CLASS_TYPE_UNDEAD:
                csClassInfo.bUndead = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                break;
            case CLASS_TYPE_COMMONER:
                csClassInfo.bCommoner = TRUE;
                bFightingLevels = TRUE;
                break;
            case CLASS_TYPE_BEAST:
                csClassInfo.bBeast = TRUE;
                bFightingLevels = TRUE;
                break;
            case CLASS_TYPE_GIANT:
                csClassInfo.bGiant = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                break;
            case CLASS_TYPE_MAGICAL_BEAST:
                csClassInfo.bMagicBeast = TRUE;
                bFightingLevels = TRUE;
                break;
            case CLASS_TYPE_OUTSIDER:
                csClassInfo.bOutsider = TRUE;
                bFightingLevels = TRUE;
                bCastingLevels = TRUE;
                break;
            case CLASS_TYPE_SHAPECHANGER:
                csClassInfo.bShapechanger = TRUE;
                bFightingLevels = TRUE;
                break;
            case CLASS_TYPE_VERMIN:
                csClassInfo.bVermin = TRUE;
                bFightingLevels = TRUE;
                break;
            case CLASS_TYPE_OOZE:
                csClassInfo.bOoze = TRUE;
                bFightingLevels = TRUE;
                break;
        }
        if(bFightingLevels && bCastingLevels) {
            csClassInfo.iCastingLevels += GRGetLevelByClass(iClassType, oCreature)/2;
            csClassInfo.iFightingLevels += GRGetLevelByClass(iClassType, oCreature)/2;
        } else if(bCastingLevels) {
            csClassInfo.iCastingLevels += GRGetLevelByClass(iClassType, oCreature)/2;
        } else {
            csClassInfo.iFightingLevels += GRGetLevelByClass(iClassType, oCreature)/2;
        }
    }
    int iMaxSaveValue = MaxInt(iFortLevels, iRefLevels, iWillLevels);
    if(iFortLevels==iMaxSaveValue) {
        csClassInfo.iBestSaveType = SAVING_THROW_FORT;
    } else if(iRefLevels==iMaxSaveValue) {
        csClassInfo.iBestSaveType = SAVING_THROW_REFLEX;
    } else {
        csClassInfo.iBestSaveType = SAVING_THROW_WILL;
    }

    return csClassInfo;
}

int GRTouchAttackRanged(object oTarget, int bDisplayFeedback = TRUE) {
    int iAttackResult = TouchAttackRanged(oTarget, bDisplayFeedback);

    if(iAttackResult==2) {
        while(TouchAttackRanged(oTarget, bDisplayFeedback)==2) {
            iAttackResult++;
        }
    }

    return iAttackResult;
}

int GRTouchAttackMelee(object oTarget, int bDisplayFeedback = TRUE) {
    int iAttackResult = TouchAttackMelee(oTarget, bDisplayFeedback);

    if(iAttackResult==2) {
        while(TouchAttackMelee(oTarget, bDisplayFeedback)==2) {
            iAttackResult++;
        }
    }

    return iAttackResult;
}

int GRGetClassByPosition(int iPosition, object oCreature=OBJECT_SELF) {

    int iClass = GetClassByPosition(iPosition, oCreature);

    if(iClass>=51 && iClass<=59) iClass = CLASS_TYPE_DRAGON_DISCIPLE;

    return iClass;
}

int GRGetLevelByClass(int iClassType, object oCreature = OBJECT_SELF) {

    if(iClassType==CLASS_TYPE_DRAGON_DISCIPLE) {
        if(GetHasFeat(FEAT_GR_DD_BLACK, oCreature)) iClassType = 51;
        else if(GetHasFeat(FEAT_GR_DD_BLUE, oCreature)) iClassType = 52;
        else if(GetHasFeat(FEAT_GR_DD_GREEN, oCreature)) iClassType = 53;
        else if(GetHasFeat(FEAT_GR_DD_WHITE, oCreature)) iClassType = 54;
        else if(GetHasFeat(FEAT_GR_DD_BRASS, oCreature)) iClassType = 55;
        else if(GetHasFeat(FEAT_GR_DD_BRONZE, oCreature)) iClassType = 56;
        else if(GetHasFeat(FEAT_GR_DD_COPPER, oCreature)) iClassType = 57;
        else if(GetHasFeat(FEAT_GR_DD_GOLD, oCreature)) iClassType = 58;
        else if(GetHasFeat(FEAT_GR_DD_SILVER, oCreature)) iClassType = 59;
    }

    return GetLevelByClass(iClassType, oCreature);
}

int GRGetIsDying(object oTarget) {
    int bIsDying = FALSE;
    int iHP = GetCurrentHitPoints(oTarget);

    if(iHP<0 && iHP>-11) {
        bIsDying = TRUE;
    }

    return bIsDying;
}

int GRGetMagicBlocked(object oObject = OBJECT_SELF) {
    return GetLocalInt(oObject, IS_MAGIC_BLOCKED);
}

void GRSetMagicBlocked(int bTrueFalse, object oObject = OBJECT_SELF) {
    SetLocalInt(oObject, IS_MAGIC_BLOCKED, bTrueFalse);
}

object GRGetLastKiller(object oCreature) {
    ExecuteScript(MY_KILLER_SCRIPT, oCreature);
    return GetLocalObject(oCreature, MY_KILLER);
}

int GRGetSkillModifier(int iSkill, object oCreature) {

    string sKeyAbility  = Get2DAString("skills", "KeyAbility", iSkill);
    int iSkillModifier  = 0;
    int iAbility        = -1;
    int iSkillRank      = GetSkillRank(iSkill);
    int iAbilityMod     = 0;

    if(sKeyAbility!="****" && sKeyAbility!="" && iSkillRank>-1) {
        sKeyAbility = GetStringUpperCase(sKeyAbility);

        if(sKeyAbility=="STR") iAbility = ABILITY_STRENGTH;
        else if(sKeyAbility=="DEX") iAbility = ABILITY_DEXTERITY;
        else if(sKeyAbility=="CON") iAbility = ABILITY_CONSTITUTION;
        else if(sKeyAbility=="INT") iAbility = ABILITY_INTELLIGENCE;
        else if(sKeyAbility=="WIS") iAbility = ABILITY_WISDOM;
        else if(sKeyAbility=="CHA") iAbility = ABILITY_CHARISMA;

        if(iAbility>-1) iAbilityMod = GetAbilityModifier(iAbility, oCreature);

        iSkillModifier = iSkillRank + iAbilityMod;

        return iSkillModifier;
    } else {
        return -1;
    }
}

string GRGetUniqueSpellIdentifier(int iSpellID, object oCaster = OBJECT_SELF) {

    string sIdentifier = ObjectToString(oCaster)+IntToString(iSpellID)+IntToString(GetTimeHour())+IntToString(GetTimeMinute())+IntToString(GetTimeSecond());

    if(GetStringLength(sIdentifier)>32) {
        sIdentifier = GetStringLeft(sIdentifier, 32);
    }

    return sIdentifier;
}

int GRGetDamageBonusValue(int iBonus) {

    switch(iBonus) {
        case 1:
            iBonus = DAMAGE_BONUS_1;
            break;
        case 2:
            iBonus = DAMAGE_BONUS_2;
            break;
        case 3:
            iBonus = DAMAGE_BONUS_3;
            break;
        case 4:
            iBonus = DAMAGE_BONUS_4;
            break;
        case 5:
            iBonus = DAMAGE_BONUS_5;
            break;
        case 6:
            iBonus = DAMAGE_BONUS_6;
            break;
        case 7:
            iBonus = DAMAGE_BONUS_7;
            break;
        case 8:
            iBonus = DAMAGE_BONUS_8;
            break;
        case 9:
            iBonus = DAMAGE_BONUS_9;
            break;
        case 10:
            iBonus = DAMAGE_BONUS_10;
            break;
        case 11:
            iBonus = DAMAGE_BONUS_11;
            break;
        case 12:
            iBonus = DAMAGE_BONUS_12;
            break;
        case 13:
            iBonus = DAMAGE_BONUS_13;
            break;
        case 14:
            iBonus = DAMAGE_BONUS_14;
            break;
        case 15:
            iBonus = DAMAGE_BONUS_15;
            break;
        case 16:
            iBonus = DAMAGE_BONUS_16;
            break;
        case 17:
            iBonus = DAMAGE_BONUS_17;
            break;
        case 18:
            iBonus = DAMAGE_BONUS_18;
            break;
        case 19:
            iBonus = DAMAGE_BONUS_19;
            break;
        case 20:
            iBonus = DAMAGE_BONUS_20;
            break;
        /*** NWN2 SPECIFIC ***
        case 21:
            iBonus = DAMAGE_BONUS_21;
            break;
        case 22:
            iBonus = DAMAGE_BONUS_22;
            break;
        case 23:
            iBonus = DAMAGE_BONUS_23;
            break;
        case 24:
            iBonus = DAMAGE_BONUS_24;
            break;
        case 25:
            iBonus = DAMAGE_BONUS_25;
            break;
        case 26:
            iBonus = DAMAGE_BONUS_26;
            break;
        case 27:
            iBonus = DAMAGE_BONUS_27;
            break;
        case 28:
            iBonus = DAMAGE_BONUS_28;
            break;
        case 29:
            iBonus = DAMAGE_BONUS_29;
            break;
        case 30:
            iBonus = DAMAGE_BONUS_30;
            break;
        case 31:
            iBonus = DAMAGE_BONUS_31;
            break;
        case 32:
            iBonus = DAMAGE_BONUS_32;
            break;
        case 33:
            iBonus = DAMAGE_BONUS_33;
            break;
        case 34:
            iBonus = DAMAGE_BONUS_34;
            break;
        case 35:
            iBonus = DAMAGE_BONUS_35;
            break;
        case 36:
            iBonus = DAMAGE_BONUS_36;
            break;
        case 37:
            iBonus = DAMAGE_BONUS_37;
            break;
        case 38:
            iBonus = DAMAGE_BONUS_38;
            break;
        case 39:
            iBonus = DAMAGE_BONUS_39;
            break;
        case 40:
            iBonus = DAMAGE_BONUS_40;
            break;
        /*** END NWN2 SPECIFIC ***/
    }

    return iBonus;
}

int GRGetDamageDieBonusValue(int iDieType, int iNumDice=1) {

    int iBonus;

    switch(iDieType) {
        case 4:
            iBonus = (iNumDice==1 ? DAMAGE_BONUS_1d4 : DAMAGE_BONUS_2d4);
            break;
        case 6:
            iBonus = (iNumDice==1 ? DAMAGE_BONUS_1d6 : DAMAGE_BONUS_2d6);
            break;
        case 8:
            iBonus = (iNumDice==1 ? DAMAGE_BONUS_1d8 : DAMAGE_BONUS_2d8);
            break;
        case 10:
            iBonus = (iNumDice==1 ? DAMAGE_BONUS_1d10 : DAMAGE_BONUS_2d10);
            break;
        case 12:
            iBonus = (iNumDice==1 ? DAMAGE_BONUS_1d12 : DAMAGE_BONUS_2d12);
            break;
    }

    return iBonus;
}


/*** NWN2 SPECIFIC ***
int GRGetSpellSchoolBeam(int iSpellSchool) {

    int iBeamType = VFX_BEAM_CURES;

    switch(iSpellSchool) {
        case SPELL_SCHOOL_ABJURATION:
            iBeamType = VFX_BEAM_ABJURATION;
            break;
        case SPELL_SCHOOL_CONJURATION:
            iBeamType = VFX_BEAM_CONJURATION;
            break;
        case SPELL_SCHOOL_DIVINATION:
            iBeamType = VFX_BEAM_DIVINATION;
            break;
        case SPELL_SCHOOL_ENCHANTMENT:
            iBeamType = VFX_BEAM_ENCHANTMENT;
            break;
        case SPELL_SCHOOL_EVOCATION:
            iBeamType = VFX_BEAM_EVOCATION;
            break;
        case SPELL_SCHOOL_ILLUSION:
            iBeamType = VFX_BEAM_ILLUSION;
            break;
        case SPELL_SCHOOL_NECROMANCY:
            iBeamType = VFX_BEAM_NECROMANCY;
            break;
        case SPELL_SCHOOL_TRANSMUTATION:
            iBeamType = VFX_BEAM_TRANSMUTATION;
            break;
    }

    return iBeamType;
}

int GRGetSpellSchoolVisual(int iSpellSchool) {

    int iVisualType = VFX_HIT_SPELL_DIVINATION;

    switch(iSpellSchool) {
        case SPELL_SCHOOL_ABJURATION:
            iVisualType = VFX_HIT_SPELL_ABJURATION;
            break;
        case SPELL_SCHOOL_CONJURATION:
            iVisualType = VFX_HIT_SPELL_CONJURATION;
            break;
        //case SPELL_SCHOOL_DIVINATION:
        //    iVisualType = VFX_HIT_SPELL_DIVINATION;
        //    break;
        case SPELL_SCHOOL_ENCHANTMENT:
            iVisualType = VFX_HIT_SPELL_ENCHANTMENT;
            break;
        case SPELL_SCHOOL_EVOCATION:
            iVisualType = VFX_HIT_SPELL_EVOCATION;
            break;
        case SPELL_SCHOOL_ILLUSION:
            iVisualType = VFX_HIT_SPELL_ILLUSION;
            break;
        case SPELL_SCHOOL_NECROMANCY:
            iVisualType = VFX_HIT_SPELL_NECROMANCY;
            break;
        case SPELL_SCHOOL_TRANSMUTATION:
            iVisualType = VFX_HIT_SPELL_TRANSMUTATION;
            break;
    }

    return iVisualType;
}

int GRGetSpellSchoolAOEVisual(int iSpellSchool) {

    int iVisualType = VFX_HIT_AOE_DIVINATION;

    switch(iSpellSchool) {
        case SPELL_SCHOOL_ABJURATION:
            iVisualType = VFX_HIT_AOE_ABJURATION;
            break;
        case SPELL_SCHOOL_CONJURATION:
            iVisualType = VFX_HIT_AOE_CONJURATION;
            break;
        //case SPELL_SCHOOL_DIVINATION:
        //    iVisualType = VFX_HIT_AOE_DIVINATION;
        //    break;
        case SPELL_SCHOOL_ENCHANTMENT:
            iVisualType = VFX_HIT_AOE_ENCHANTMENT;
            break;
        case SPELL_SCHOOL_EVOCATION:
            iVisualType = VFX_HIT_AOE_EVOCATION;
            break;
        case SPELL_SCHOOL_ILLUSION:
            iVisualType = VFX_HIT_AOE_ILLUSION;
            break;
        case SPELL_SCHOOL_NECROMANCY:
            iVisualType = VFX_HIT_AOE_NECROMANCY;
            break;
        case SPELL_SCHOOL_TRANSMUTATION:
            iVisualType = VFX_HIT_AOE_TRANSMUTATION;
            break;
    }

    return iVisualType;
}
/*** END NWN2 SPECIFIC ***/

//*:**************************************************************************
/*
void main() {} /**/
//*:**************************************************************************
