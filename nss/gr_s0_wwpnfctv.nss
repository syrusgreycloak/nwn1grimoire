//*:**************************************************************************
//*:*  GR_S0_WWPNFCTV.NSS
//*:**************************************************************************
//*:*
//*:* Simple script to have nearby NPC's check if they can attack the wall object
//*:* and if so then attack.
//*:*
//*:**************************************************************************
//*:* Created By: Dennis Dollins (Danmar)
//*:* Created On: ?
//*:**************************************************************************
//*:* Updated On: March 3, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object oWall = GetLocalObject(OBJECT_SELF, "Wall");

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsWeaponEffective(oWall)) {
        ClearAllActions(TRUE);
        ActionAttack(oWall);
    }
    DeleteLocalObject(OBJECT_SELF, "Wall");
}
//*:**************************************************************************
//*:**************************************************************************
