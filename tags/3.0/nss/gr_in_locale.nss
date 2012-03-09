//*:**************************************************************************
//*:*  GR_IN_LOCALE.NSS
//*:**************************************************************************
//*:*
//*:* Miscellaneous functions for locale specific features (extreme heat, frostfell
//*:* area, etc)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 8, 2009
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
//*:**********************************************
//*:* Game Libraries

//*:**********************************************
//*:* Constant Libraries

//*:**********************************************
//*:* Function Libraries

//*:**************************************************************************
//*:* Constants/Structures
//*:**************************************************************************
//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
int GRGetExtremeHeatLocale(object oTarget);
int GRGetFrostfellLocale(object oTarget);
void GRSetExtremeHeatLocale(object oTarget, int bYesNo = TRUE);
void GRSetFrostfellLocale(object oTarget, int bYesNo = TRUE);
//*:**************************************************************************
//*:* Function Implementations
//*:**************************************************************************
int GRGetExtremeHeatLocale(object oTarget) {
    return GetLocalInt(oTarget, "GR_EXTREME_HEAT");
}

int GRGetFrostfellLocale(object oTarget) {
    return GetLocalInt(oTarget, "GR_FROSTFELL");
}

void GRSetExtremeHeatLocale(object oTarget, int bYesNo = TRUE) {
    SetLocalInt(oTarget, "GR_EXTREME_HEAT", bYesNo);
}

void GRSetFrostfellLocale(object oTarget, int bYesNo = TRUE) {
    SetLocalInt(oTarget, "GR_FROSTFELL", bYesNo);
}
