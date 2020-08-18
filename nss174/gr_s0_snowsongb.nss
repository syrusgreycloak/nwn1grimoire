//*:**************************************************************************
//*:*  GR_S0_SNOWSONGB.NSS
//*:**************************************************************************
//*:* Snowsong: OnExit
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 9, 2008
//*:* Frostburn (p. 105)
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
    if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
        object  oMyWeapon = GetLocalObject(oTarget, "GR_"+IntToString(SPELL_GR_SNOWSONG)+"_WEAPON");
        int     bFound = FALSE;

        itemproperty ipCheck = GetFirstItemProperty(oMyWeapon);
        while(GetIsItemPropertyValid(ipCheck) && !bFound) {
            if(GetItemPropertyType(ipCheck)==ITEM_PROPERTY_DAMAGE_BONUS) {
                if(GetItemPropertySubType(ipCheck)==SUBTYPE_MAGICAL) {
                    if(GetItemPropertyDurationType(ipCheck)==DURATION_TYPE_TEMPORARY) {
                        if(Get2DAString("iprp_paramtable", "TableResRef", GetItemPropertyParam1(ipCheck))=="IPRP_DAMAGETYPE") {
                            if(GetItemPropertyParam1Value(ipCheck)==IP_CONST_DAMAGETYPE_COLD) {
                                RemoveItemProperty(oMyWeapon, ipCheck);
                                bFound = TRUE;  // we found one, don't remove others if there are any
                            }
                        }
                    }
                }
            }
            ipCheck = GetNextItemProperty(oMyWeapon);
        }
    }
}
//*:**************************************************************************
//*:**************************************************************************
