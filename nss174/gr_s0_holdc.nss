//*:**************************************************************************
//*:*  GR_S0_HOLDC.NSS
//*:**************************************************************************
//*:* NWN1 Heartbeat script for the following Hold spells
//*:**************************************************************************
//*:* Hold Animal (nw_s0_HoldAnim) Copyright (c) 2001 Bioware Corp.
//*:* Hold Monster (nw_s0_HoldMon) Copyright (c) 2001 Bioware Corp.
//*:* Hold Person (NW_S0_HoldPers) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Keith Soleski  Created On: Jan 18, 2001
//*:* 3.5 Player's Handbook (p. 241)
//*:**************************************************************************
//*:* Hold Monster, Mass
//*:* Hold Person, Mass
//*:* 3.5 Player's Handbook (p. 241)
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Master Script Created On: July 16, 2007
//*:**************************************************************************
//*:* Updated On: November 2, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

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
    struct  SpellStruct spInfo  = GRGetSpellInfoFromObject(GRGetAOESpellId());
    int     iSaveType           = GetLocalInt(spInfo.oTarget, "HOLD_SPELL_SAVE_TYPE");

    if(GRGetSaveResult(iSaveType, spInfo.oTarget, spInfo.iDC)) {
        GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget, GetAreaOfEffectCreator());
        DestroyObject(OBJECT_SELF);
    }
}
//*:**************************************************************************
//*:**************************************************************************
