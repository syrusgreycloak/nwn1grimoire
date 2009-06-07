//*:**************************************************************************
//*:*  GR_S0_AOEEXIT.NSS
//*:**************************************************************************
//*:*
//*:* Standard Exiting of AOE object
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 20, 2007
//*:**************************************************************************
//*:* Updated On: October 25, 2007
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
    object  oCaster         = GetAreaOfEffectCreator();
    object  oTarget         = GetExitingObject();

    GRRemoveSpellEffects(GRGetAOESpellId(), oTarget, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************