//*:**************************************************************************
//*:*  GR_IN_DRAGONS.NSS
//*:**************************************************************************
//*:*
//*:* Dragon-related functions, mainly for determining dragon-breath strength
//*:* and type
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IC_DRAGONS"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
int GRGetDragonAge(object oDragon=OBJECT_SELF);
int GRGetDragonBreathDC(int iDragonType, int iAgeCategory);
int GRGetDragonDieType(int iDragonType);
int GRGetDragonSize(int iDragonAge, int iDragonType);
int GRGetDragonType(int iSpellID, object oCreature=OBJECT_SELF);
int GRGetDiscipleType(object oCaster=OBJECT_SELF);
int GRGetNegDragonBreathDmg(int iDragonAge);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRGetDragonAge
//*:**********************************************
//*:*
//*:* Using dragon's HD, gets appropriate age
//*:* category of the dragon.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetDragonAge(object oDragon=OBJECT_SELF) {

    int iDragonAge = GetHitDice(OBJECT_SELF);

    if(iDragonAge<7){
        iDragonAge = GR_DRAGON_WYRMLING;
    } else if(iDragonAge<10) {
        iDragonAge = GR_DRAGON_VERY_YOUNG;
    } else if(iDragonAge<13) {
        iDragonAge = GR_DRAGON_YOUNG;
    } else if(iDragonAge<16) {
        iDragonAge = GR_DRAGON_JUVENILE;
    } else if(iDragonAge<19) {
        iDragonAge = GR_DRAGON_YOUNG_ADULT;
    } else if(iDragonAge<22) {
        iDragonAge = GR_DRAGON_ADULT;
    } else if(iDragonAge<25) {
        iDragonAge = GR_DRAGON_MATURE_ADULT;
    } else if(iDragonAge<28) {
        iDragonAge = GR_DRAGON_OLD;
    } else if(iDragonAge<31) {
        iDragonAge = GR_DRAGON_VERY_OLD;
    } else if(iDragonAge<34) {
        iDragonAge = GR_DRAGON_ANCIENT;
    } else if(iDragonAge<38) {
        iDragonAge = GR_DRAGON_WYRM;
    } else {
        iDragonAge = GR_DRAGON_GREAT_WYRM;
    }

    return iDragonAge;
}

//*:**********************************************
//*:* GRGetDragonBreathDC
//*:**********************************************
//*:*
//*:* Using dragon's breath type and age category,
//*:* returns DC of the dragon breath.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetDragonBreathDC(int iDragonType, int iAgeCategory) {

    int iDC = 10;

    switch(iAgeCategory) {
        case GR_DRAGON_WYRMLING:
            switch(iDragonType) {
                case GR_DRAGON_WHITE:
                    iDC = 12;
                    break;
                case GR_DRAGON_BLACK:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 13;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_SILVER:
                case GR_DRAGON_SHADOW:
                    iDC = 14;
                    break;
                case GR_DRAGON_GOLD:
                case GR_DRAGON_RED:
                    iDC = 15;
                    break;
            }
            break;
        case GR_DRAGON_VERY_YOUNG:
            switch(iDragonType) {
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 14;
                    break;
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BLUE:
                case GR_DRAGON_SHADOW:
                    iDC = 16;
                    break;
                case GR_DRAGON_SILVER:
                    iDC = 17;
                    break;
                case GR_DRAGON_GOLD:
                case GR_DRAGON_RED:
                    iDC = 18;
                    break;
            }
            break;
        case GR_DRAGON_YOUNG:
            switch(iDragonType) {
                case GR_DRAGON_WHITE:
                    iDC = 16;
                    break;
                case GR_DRAGON_BLACK:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 17;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_SILVER:
                case GR_DRAGON_SHADOW:
                    iDC = 18;
                    break;
                case GR_DRAGON_GOLD:
                case GR_DRAGON_RED:
                    iDC = 19;
                    break;
            }
            break;
        case GR_DRAGON_JUVENILE:
            switch(iDragonType) {
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 18;
                    break;
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BLUE:
                case GR_DRAGON_SHADOW:
                    iDC = 20;
                    break;
                case GR_DRAGON_SILVER:
                    iDC = 21;
                    break;
                case GR_DRAGON_GOLD:
                case GR_DRAGON_RED:
                    iDC = 22;
                    break;
            }
            break;
        case GR_DRAGON_YOUNG_ADULT:
            switch(iDragonType) {
                case GR_DRAGON_WHITE:
                    iDC = 20;
                    break;
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 21;
                    break;
                case GR_DRAGON_BLACK:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_SHADOW:
                    iDC = 22;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_SILVER:
                    iDC = 23;
                    break;
                case GR_DRAGON_GOLD:
                case GR_DRAGON_RED:
                    iDC = 24;
                    break;
            }
            break;
        case GR_DRAGON_ADULT:
            switch(iDragonType) {
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 23;
                    break;
                case GR_DRAGON_SHADOW:
                    iDC = 24;
                    break;
                case GR_DRAGON_RED:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GOLD:
                    iDC = 25;
                    break;
                case GR_DRAGON_SILVER:
                    iDC = 26;
                    break;
            }
            break;
        case GR_DRAGON_MATURE_ADULT:
            switch(iDragonType) {
                case GR_DRAGON_WHITE:
                    iDC = 25;
                    break;
                case GR_DRAGON_BLACK:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_SHADOW:
                    iDC = 26;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_SILVER:
                    iDC = 27;
                    break;
                case GR_DRAGON_GOLD:
                case GR_DRAGON_RED:
                    iDC = 28;
                    break;
            }
            break;
        case GR_DRAGON_OLD:
            switch(iDragonType) {
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 27;
                    break;
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BLUE:
                case GR_DRAGON_SHADOW:
                    iDC = 29;
                    break;
                case GR_DRAGON_RED:
                case GR_DRAGON_SILVER:
                case GR_DRAGON_GOLD:
                    iDC = 30;
                    break;
            }
            break;
        case GR_DRAGON_VERY_OLD:
            switch(iDragonType) {
                case GR_DRAGON_WHITE:
                    iDC = 29;
                    break;
                case GR_DRAGON_BLACK:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 30;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_SILVER:
                    iDC = 31;
                    break;
                case GR_DRAGON_SHADOW:
                    iDC = 32;
                    break;
                case GR_DRAGON_GOLD:
                case GR_DRAGON_RED:
                    iDC = 33;
                    break;
            }
            break;
        case GR_DRAGON_ANCIENT:
            switch(iDragonType) {
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 31;
                    break;
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BLUE:
                    iDC = 33;
                    break;
                case GR_DRAGON_SILVER:
                case GR_DRAGON_SHADOW:
                    iDC = 34;
                    break;
                case GR_DRAGON_GOLD:
                case GR_DRAGON_RED:
                    iDC = 35;
                    break;
            }
            break;
        case GR_DRAGON_WYRM:
            switch(iDragonType) {
                case GR_DRAGON_WHITE:
                    iDC = 33;
                    break;
                case GR_DRAGON_BLACK:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 34;
                    break;
                case GR_DRAGON_GREEN:
                    iDC = 35;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_SILVER:
                    iDC = 36;
                    break;
                case GR_DRAGON_SHADOW:
                    iDC = 37;
                    break;
                case GR_DRAGON_GOLD:
                case GR_DRAGON_RED:
                    iDC = 38;
                    break;
            }
            break;
        case GR_DRAGON_GREAT_WYRM:
            switch(iDragonType) {
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                    iDC = 36;
                    break;
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BLUE:
                    iDC = 37;
                    break;
                case GR_DRAGON_SILVER:
                case GR_DRAGON_SHADOW:
                    iDC = 39;
                    break;
                case GR_DRAGON_GOLD:
                case GR_DRAGON_RED:
                    iDC = 40;
                    break;
            }
            break;
    }

    return iDC;
}

int GRGetDragonType(int iSpellID, object oCreature=OBJECT_SELF) {

    int iAlignment = (GetAlignmentGoodEvil(oCreature));
    int iDragonType = GR_DRAGON_UNKNOWN;

    switch(iSpellID) {
        case 236: //*:* Acid - Black, Copper
            if(iAlignment==ALIGNMENT_GOOD) {
                iDragonType = GR_DRAGON_COPPER;
            } else {
                iDragonType = GR_DRAGON_BLACK;
            }
            break;
        case 237: //*:* Cold - White, Silver
            if(iAlignment==ALIGNMENT_GOOD) {
                iDragonType = GR_DRAGON_SILVER;
            } else {
                iDragonType = GR_DRAGON_WHITE;
            }
            break;
        case 238: //*:* Fear - Bronze (repulsion gas)
            iDragonType = GR_DRAGON_BRONZE;
            break;
        case 239: //*:* Fire - Red, Gold, Brass
            if(iAlignment==ALIGNMENT_GOOD) {
                if(FindSubString(GetStringLowerCase(GetResRef(oCreature)), "brass")>-1) {
                    iDragonType = GR_DRAGON_BRASS;
                } else {
                    iDragonType = GR_DRAGON_GOLD;
                }
            } else {
                iDragonType = GR_DRAGON_RED;
            }
            break;
        case 240: //*:* Gas - Green
            iDragonType = GR_DRAGON_GREEN;
            break;
        case 241: //*:* Lightning - Blue
            if(iAlignment==ALIGNMENT_GOOD) {
                iDragonType = GR_DRAGON_BRONZE;
            } else {
                iDragonType = GR_DRAGON_BLUE;
            }
            break;
        case 242: //*:* Paralyze
            iDragonType = GR_DRAGON_SILVER;
            break;
        case 243: //*:* Sleep
            iDragonType = GR_DRAGON_BRASS;
            break;
        case 244: //*:* Slow - Copper
            iDragonType = GR_DRAGON_COPPER;
            break;
        case 245: //*:* Weaken - Gold
            iDragonType = GR_DRAGON_GOLD;
            break;
        case 663: //*:* Shifter Wyrmling Shape - White
            iDragonType = GR_DRAGON_WHITE;
            break;
        case 664: //*:* Shifter Wyrmling Shape - Black
            iDragonType = GR_DRAGON_BLACK;
            break;
        case 665:   //*:* Shifter Wyrmling Shape - Red
        case 797:   //*:* Shifter/Druid Dragon Shape - Red
            iDragonType = GR_DRAGON_RED;
            break;
        case 666:   //*:* Shifter Wyrmling Shape - Green
        case 798:   //*:* Shifter/Druid Dragon Shape - Green
            iDragonType = GR_DRAGON_GREEN;
            break;
        case 667:   //*:* Shifter Wyrmling Shape - Blue
        case 796:   //*:* Shifter/Druid Dragon Shape - Blue
            iDragonType = GR_DRAGON_BLUE;
            break;
        case 698:   //*:* Negative/Energy Drain - Shadow
            iDragonType = GR_DRAGON_SHADOW;
            break;
    }

    return iDragonType;
}


int GRGetDragonSize(int iDragonAge, int iDragonType) {

    int iDragonSize;

    switch(iDragonAge) {
        case GR_DRAGON_WYRMLING:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_TINY;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SILVER:
                    iDragonSize = GR_DRAGON_SIZE_SMALL;
                    break;
                case GR_DRAGON_RED:
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_MEDIUM;
                    break;
            }
            break;
        case GR_DRAGON_VERY_YOUNG:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_SMALL;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SILVER:
                    iDragonSize = GR_DRAGON_SIZE_MEDIUM;
                    break;
                case GR_DRAGON_RED:
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_LARGE;
                    break;
            }
            break;
        case GR_DRAGON_YOUNG:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_SMALL;
                    break;
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SILVER:
                    iDragonSize = GR_DRAGON_SIZE_MEDIUM;
                    break;
                case GR_DRAGON_RED:
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_LARGE;
                    break;
            }
            break;
        case GR_DRAGON_JUVENILE:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_MEDIUM;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SILVER:
                case GR_DRAGON_RED:
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_LARGE;
                    break;
            }
            break;
        case GR_DRAGON_YOUNG_ADULT:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_MEDIUM;
                    break;
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SILVER:
                    iDragonSize = GR_DRAGON_SIZE_LARGE;
                    break;
                case GR_DRAGON_RED:
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_HUGE;
                    break;
            }
            break;
        case GR_DRAGON_ADULT:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_LARGE;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SILVER:
                case GR_DRAGON_RED:
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_HUGE;
                    break;
            }
            break;
        case GR_DRAGON_MATURE_ADULT:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_LARGE;
                    break;
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SILVER:
                case GR_DRAGON_RED:
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_HUGE;
                    break;
            }
            break;
        case GR_DRAGON_OLD:
        case GR_DRAGON_VERY_OLD:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SILVER:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_HUGE;
                    break;
                case GR_DRAGON_RED:
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_GARGANTUAN;
                    break;
            }
            break;
        case GR_DRAGON_ANCIENT:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_HUGE;
                    break;
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SILVER:
                case GR_DRAGON_RED:
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_GARGANTUAN;
                    break;
            }
            break;
        case GR_DRAGON_WYRM:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SILVER:
                case GR_DRAGON_RED:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_GARGANTUAN;
                    break;
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_COLOSSAL;
                    break;
            }
            break;
        case GR_DRAGON_GREAT_WYRM:
            switch(iDragonType) {
                case GR_DRAGON_UNKNOWN:
                case GR_DRAGON_BLACK:
                case GR_DRAGON_WHITE:
                case GR_DRAGON_BRASS:
                case GR_DRAGON_COPPER:
                case GR_DRAGON_BLUE:
                case GR_DRAGON_GREEN:
                case GR_DRAGON_BRONZE:
                case GR_DRAGON_SHADOW:
                    iDragonSize = GR_DRAGON_SIZE_GARGANTUAN;
                    break;
                case GR_DRAGON_SILVER:
                case GR_DRAGON_RED:
                case GR_DRAGON_GOLD:
                    iDragonSize = GR_DRAGON_SIZE_COLOSSAL;
                    break;
            }
            break;
    }

    return iDragonSize;
}

int GRGetDragonDieType(int iDragonType) {

    int iDieType = 8;

    switch(iDragonType) {
        case GR_DRAGON_BLACK:
        case GR_DRAGON_COPPER:
            iDieType = 4;
            break;
        case GR_DRAGON_BLUE:
        case GR_DRAGON_SILVER:
            iDieType = 8;
            break;
        case GR_DRAGON_GREEN:
        case GR_DRAGON_WHITE:
        case GR_DRAGON_BRASS:
        case GR_DRAGON_BRONZE:
            iDieType = 6;
            break;
        case GR_DRAGON_RED:
        case GR_DRAGON_GOLD:
            iDieType = 10;
            break;
    }

    return iDieType;
}

float GRGetDragonBreathRange(int iDragonSize) {

    float fFeet = 15.0;

    switch(iDragonSize) {
        case GR_DRAGON_SIZE_TINY:
            fFeet = 15.0;
            break;
        case GR_DRAGON_SIZE_SMALL:
            fFeet = 20.0;
            break;
        case GR_DRAGON_SIZE_MEDIUM:
            fFeet = 30.0;
            break;
        case GR_DRAGON_SIZE_LARGE:
            fFeet = 40.0;
            break;
        case GR_DRAGON_SIZE_HUGE:
            fFeet = 50.0;
            break;
        case GR_DRAGON_SIZE_GARGANTUAN:
            fFeet = 60.0;
            break;
        case GR_DRAGON_SIZE_COLOSSAL:
            fFeet = 70.0;
            break;
    }

    return fFeet;
}

int GRGetDiscipleType(object oCaster=OBJECT_SELF) {

    int iDragonType = GR_DRAGON_UNKNOWN;

    if(GetHasFeat(FEAT_GR_DD_BLACK, oCaster)) {
        iDragonType = GR_DRAGON_BLACK;
    } else if(GetHasFeat(FEAT_GR_DD_BLUE, oCaster)) {
        iDragonType = GR_DRAGON_BLUE;
    } else if(GetHasFeat(FEAT_GR_DD_GREEN, oCaster)) {
        iDragonType = GR_DRAGON_GREEN;
    } else if(GetHasFeat(FEAT_GR_DD_RED, oCaster)) {
        iDragonType = GR_DRAGON_RED;
    } else if(GetHasFeat(FEAT_GR_DD_WHITE, oCaster)) {
        iDragonType = GR_DRAGON_WHITE;
    } else if(GetHasFeat(FEAT_GR_DD_BRASS, oCaster)) {
        iDragonType = GR_DRAGON_BRASS;
    } else if(GetHasFeat(FEAT_GR_DD_BRONZE, oCaster)) {
        iDragonType = GR_DRAGON_BRONZE;
    } else if(GetHasFeat(FEAT_GR_DD_COPPER, oCaster)) {
        iDragonType = GR_DRAGON_COPPER;
    } else if(GetHasFeat(FEAT_GR_DD_GOLD, oCaster)) {
        iDragonType = GR_DRAGON_GOLD;
    } else if(GetHasFeat(FEAT_GR_DD_SILVER, oCaster)) {
        iDragonType = GR_DRAGON_SILVER;
    }

    return iDragonType;
}

int GRGetNegDragonBreathDmg(int iDragonAge) {

    int iDmgAmt;

    switch(iDragonAge) {
        case GR_DRAGON_WYRMLING:
        case GR_DRAGON_VERY_YOUNG:
        case GR_DRAGON_YOUNG:
            iDmgAmt = 1;
            break;
        case GR_DRAGON_JUVENILE:
        case GR_DRAGON_YOUNG_ADULT:
            iDmgAmt = 2;
            break;
        case GR_DRAGON_ADULT:
            iDmgAmt = 3;
            break;
        case GR_DRAGON_MATURE_ADULT:
            iDmgAmt = 4;
            break;
        case GR_DRAGON_OLD:
        case GR_DRAGON_VERY_OLD:
            iDmgAmt = 5;
            break;
        case GR_DRAGON_ANCIENT:
            iDmgAmt = 6;
            break;
        case GR_DRAGON_WYRM:
            iDmgAmt = 7;
            break;
        case GR_DRAGON_GREAT_WYRM:
            iDmgAmt = 8;
            break;
    }

    return iDmgAmt;
}

int GRGetDragonWingBuffetDC(int iDragonAge) {

    int iWingBuffetDC = 0;

    switch(iDragonAge) {
        case GR_DRAGON_WYRMLING:
            iWingBuffetDC = 15;
            break;
        case GR_DRAGON_VERY_YOUNG:
            iWingBuffetDC = 18;
            break;
        case GR_DRAGON_YOUNG:
            iWingBuffetDC = 19;
            break;
        case GR_DRAGON_JUVENILE:
            iWingBuffetDC = 22;
            break;
        case GR_DRAGON_YOUNG_ADULT:
            iWingBuffetDC = 24;
            break;
        case GR_DRAGON_ADULT:
            iWingBuffetDC = 25;
            break;
        case GR_DRAGON_MATURE_ADULT:
            iWingBuffetDC = 28;
            break;
        case GR_DRAGON_OLD:
            iWingBuffetDC = 30;
            break;
        case GR_DRAGON_VERY_OLD:
            iWingBuffetDC = 33;
            break;
        case GR_DRAGON_ANCIENT:
            iWingBuffetDC = 35;
            break;
        case GR_DRAGON_WYRM:
            iWingBuffetDC = 38;
            break;
        case GR_DRAGON_GREAT_WYRM:
            iWingBuffetDC = 40;
            break;
    }

    return iWingBuffetDC;
}
//*:**************************************************************************
//*:**************************************************************************
