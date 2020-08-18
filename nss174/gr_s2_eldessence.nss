//*:**************************************************************************
//*:*  GR_S2_ELDESSENCE.NSS
//*:**************************************************************************
//*:* This script doesn't apply the effects for the following Eldritch Essences.
//*:* It merely sets the appropriate info needed for the main Eldritch Blast
//*:* script.
//*:**************************************************************************
//*:* Beshadowed Blast
//*:* Bewitching Blast
//*:* Brimstone Blast
//*:* Frightful Blast
//*:* Hellrime Blast
//*:* Noxious Blast
//*:* Repelling Blast
//*:* Sickening Blast
//*:* Utterdark Blast
//*:* Vitriolic Blast
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created: April, 2008
//*:* Complete Arcane
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    SetLocalInt(oCaster, "GR_ESSENCE_INV_ID", spInfo.iSpellID);
    SetLocalInt(oCaster, "GR_ESSENCE_INV_LEVEL", spInfo.iSpellLevel);
    SetLocalInt(oCaster, "GR_ESSENCE_ENERGY_TYPE", GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster)));
    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetAOESpellId(spInfo.iSpellID, oCaster);
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Eldritch Essences will not trigger Eldritch Blast
    //*:* - will have Blast Shape do that, or will have
    //*:* to trigger Eldritch Blast manually
    //*:**********************************************
    //ExecuteScript("gr_s2_eldblast", oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
