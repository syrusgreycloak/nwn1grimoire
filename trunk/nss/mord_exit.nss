//*:**************************************************************************
//*:*  MORD_EXIT.NSS
//*:**************************************************************************
//*:* Mordenkainen's Magnificent Mansion (sg_s0_mordmans.nss) Player Resource Consortium
//*:* Adapted By: Karl Nickels (Syrus Greycloak)  Adapted On: March 7, 2006
//*:*
//*:**************************************************************************
//*:* Updated On: March 11, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"
//#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //PrintString("mord_exit entering");

    // Get the person walking through the door and their area, i.e.
    // the mansion.
    object oActivator = GetLastUsedBy();
    object aActivator = GetArea(oActivator);

    // Get the saved return location for the activator, we want to boot all
    // players who have this location saved on them.  This will solve the
    // problem of 2 parties getting mixed somehow, only the party that clicks
    // on the door actually gets booted.
    location lActivatorReturnLoc = GetLocalLocation(oActivator, "MMM_RETURNLOC");

    // Loop through all the players and check to see if they are in
    // the mansion and dump them out if they are.
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        // If the PC's are in the same area and have the same return location
        // on them then boot the current PC.
        if (aActivator == GetArea (oPC) &&
            lActivatorReturnLoc == GetLocalLocation(oPC, "MMM_RETURNLOC"))
        {
            // Get the return location we saved on the PC and send them there.
            DeleteLocalLocation(oPC, "MMM_RETURNLOC");
            AssignCommand(oPC, DelayCommand(1.0,
                ActionJumpToLocation(lActivatorReturnLoc)));
        }

        oPC = GetNextPC();
    }

    // Now that all are moved, destroy the mansion door.
    object oGate = GetLocalObject(OBJECT_SELF, "MMM_ENTRANCE");
    DeleteLocalObject(OBJECT_SELF, "MMM_ENTRANCE");
    if (GetIsObjectValid(oGate)) DestroyObject(oGate, 1.0);
}
//*:**************************************************************************
//*:**************************************************************************
