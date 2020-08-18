//*:**************************************************************************
//*:*  GR_S2_ENERGYSUB.NSS
//*:**************************************************************************
//*:* Energy Substitution (sg_s0_elemsub.nss) 2005 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: June 24, 2005
//*:* Complete Arcane (p. 79)
//*:**************************************************************************
//*:* Updated On: March 11, 2008
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

    int     iCurrentSubType = GetLocalInt(oCaster, ENERGY_SUBSTITUTION_TYPE);
    int     iSetSubType;

    switch(spInfo.iSpellID) {
        case SPELLFEAT_GR_ENERGY_SUBSTITUTION_ACID:
            iSetSubType = ENERGY_SUBSTITUTION_TYPE_ACID;
            break;
        case SPELLFEAT_GR_ENERGY_SUBSTITUTION_COLD:
            iSetSubType = ENERGY_SUBSTITUTION_TYPE_COLD;
            break;
        case SPELLFEAT_GR_ENERGY_SUBSTITUTION_ELECTRICITY:
            iSetSubType = ENERGY_SUBSTITUTION_TYPE_ELECTRICITY;
            break;
        case SPELLFEAT_GR_ENERGY_SUBSTITUTION_FIRE:
            iSetSubType = ENERGY_SUBSTITUTION_TYPE_FIRE;
            break;
        case SPELLFEAT_GR_ENERGY_SUBSTITUTION_SONIC:
            iSetSubType = ENERGY_SUBSTITUTION_TYPE_SONIC;
            break;
    }

    //AutoDebugString("Setting Elemental Substitution Type to "+ IntToString(iSpellID));
    if(iCurrentSubType==ENERGY_SUBSTITUTION_TYPE_NONE || iCurrentSubType!=iSetSubType) {
        SetLocalInt(oCaster, ENERGY_SUBSTITUTION_TYPE, iSetSubType);
        DelayCommand(GRGetDuration(1)*1.5, SetLocalInt(oCaster, ENERGY_SUBSTITUTION_TYPE, ENERGY_SUBSTITUTION_TYPE_NONE));
    } else {
        SetLocalInt(oCaster, ENERGY_SUBSTITUTION_TYPE, ENERGY_SUBSTITUTION_TYPE_NONE);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
