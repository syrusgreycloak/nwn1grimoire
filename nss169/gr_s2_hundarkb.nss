//*:**************************************************************************
//*:*  GR_S2_HUNDARKB.NSS
//*:**************************************************************************
//*:* Hungry Darkness: OnExit
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 29, 2008
//*:* Complete Arcane (p. 134)
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
    struct SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    spInfo.oTarget         = GetExitingObject();

    if(GetTag(spInfo.oTarget)=="GR_HUNDARK_BAT") {
        AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
        AssignCommand(spInfo.oTarget, ActionDoCommand(JumpToLocation(spInfo.lTarget)));
    } else {
        GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget, oCaster);
    }
}
//*:**************************************************************************
//*:**************************************************************************
