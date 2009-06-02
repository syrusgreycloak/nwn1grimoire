//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void        AutoDebugString(string sDebugString);
string      GRBooleanToString(int i);
string      GRFeatToString(int iFeat);
string      GRSpellToString(int iSpellID);

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* AutoDebugString
//*:* 2006 Karl Nickels (Syrus Greycloak)
//*:**********************************************
/*
    Utility function: wraps send message to PC to
    automatically grab the first pc in the module
    - also writes to log file
*/
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 9, 2006
//*:**********************************************
//*:* Updated On: February 14, 2007
//*:**********************************************
void AutoDebugString(string sDebugString) {
    object oPC = OBJECT_INVALID;

    if(!GetLocalInt(GetModule(),"GR_G_DEBUGGING")) {
        return;
    }

    if(GetLocalInt(GetModule(),"GR_G_DEBUG_SENDPC")) {
        oPC  = GetFirstPC();
    }

    if(GetIsObjectValid(oPC)) {
        SendMessageToPC(oPC, sDebugString);
    }
    PrintString(sDebugString);
}

//*:**********************************************
//*:* GRBooleanToString
//*:**********************************************
//*:*
//*:* Utility function for use by debugging scripts
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 9, 2006
//*:**********************************************
//*:* Updated On: February 14, 2007
//*:**********************************************
string GRBooleanToString(int i) {

    string sTrue = "TRUE";
    string sFalse = "FALSE";

    if(i==0) return sFalse;

    return sTrue;
}



//*:**********************************************
//*:* GRFeatToString
//*:**********************************************
//*:*
//*:* Utility function: returns feat name from 2da file
//*:* good for returning names instead of values for
//*:* debugging scripts
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 9, 2006
//*:**********************************************
//*:* Updated On: February 14, 2007
//*:**********************************************
string GRFeatToString(int iFeat) {

    string sFeatName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", iFeat)));

    return sFeatName;
}

//*:**********************************************
//*:* GRSpellToString
//*:**********************************************
//*:*
//*:*    Utility function: returns feat name from 2da file
//*:*    good for returning names instead of values for
//*:*    debugging scripts
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 9, 2006
//*:**********************************************
//*:* Updated On: February 14, 2007
//*:**********************************************
string GRSpellToString(int iSpellID) {

    string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", iSpellID)));

    return sSpellName;
}

//*:**************************************************************************
//*:**************************************************************************
