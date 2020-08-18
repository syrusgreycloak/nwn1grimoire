//*:**************************************************************************
//*:*  GR_SPELLHOOK_OSH.NSS
//*:**************************************************************************
//*:* Grimoire Module-level OnUserDefined Script
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 30, 2008
//*:*
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//*:* #include "GR_IN_SPELLS"
#include "GR_IC_MESSAGES"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {

    switch(GetUserDefinedEventNumber()) {
        case GR_MESSAGE_RAYDEFLECT_CASTER:
            SendMessageToPC(GetLocalObject(GetModule(), "GR_RAYDEFLECT_CASTER"), GetStringByStrRef(16939259));
            DeleteLocalObject(GetModule(), "GR_RAYDEFLECT_CASTER");
            break;
        case GR_MESSAGE_RAYDEFLECT_TARGET:
            SendMessageToPC(GetLocalObject(GetModule(), "GR_RAYDEFLECT_TARGET"), GetStringByStrRef(16939260));
            DeleteLocalObject(GetModule(), "GR_RAYDEFLECT_TARGET");
            break;
    }
}