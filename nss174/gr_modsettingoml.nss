//*:**************************************************************************
//*:*  GR_IN_OML.NSS
//*:**************************************************************************
//*:*
//*:* Include for the custom on module load script that runs with HCR2
//*:* This will allow for just adding the Grimoire module load script as a
//*:* variable on the module per the HCR2 instructions.  A 2da is read by the
//*:* script, which will set the rest of the script variables, plus any Grimoire
//*:* global variable settings
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2007
//*:**************************************************************************
//*:* Updated On: November 5, 2008
//*:**************************************************************************
#include "h2_core_i"

struct stVariable {
    string sVarName;
    string sVarType;
    string sVarData;
};

void GRSetModuleVariable(struct stVariable varToSet) {

    if(GetStringLowerCase(varToSet.sVarType)=="string") {
        SetLocalString(GetModule(), varToSet.sVarName, varToSet.sVarData);
    } else if(GetStringLowerCase(varToSet.sVarType)=="int") {
        SetLocalInt(GetModule(), varToSet.sVarName, StringToInt(varToSet.sVarData));
    } else if(GetStringLowerCase(varToSet.sVarType)=="float") {
        SetLocalFloat(GetModule(), varToSet.sVarName, StringToFloat(varToSet.sVarData));
    }
}


void GRLoadModuleSettings() {

    struct  stVariable stVtoSet;
    int     iCounter = 0;

    while(stVtoSet.sVarName!="END_OF_FILE") {
        GRSetModuleVariable(stVtoSet);

        stVtoSet.sVarName = Get2DAString("mod_settings", "Name", iCounter);
        stVtoSet.sVarType = Get2DAString("mod_settings", "Type", iCounter);
        stVtoSet.sVarData = Get2DAString("mod_settings", "Value", iCounter);
        iCounter++;
    }
    h2_CopyEventVariablesToCoreDataPoint();
}


void main() {
    GRLoadModuleSettings();
}