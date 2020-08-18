//*:**************************************************************************
//*:*  GR_S2_HUNDARKC.NSS
//*:**************************************************************************
//*:* Hungry Darkness: OnHeartbeat
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
#include "GR_IN_CONCEN"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    int     iRemainingRounds = GetLocalInt(OBJECT_SELF, "GR_REMAINING_ROUNDS");
    int     bDestroyAOE     = FALSE;
    int     bDestroyBats    = TRUE;
    float   fRange          = FeetToMeters(20.0);

    //*:* Check if caster is still concentrating
    if(iRemainingRounds>2) {
        if(!GRCheckCasterConcentration(oCaster)) {
            SetLocalInt(OBJECT_SELF, "GR_REMAINING_ROUNDS", 2);
        }
    }

    //*:* Check if bat remaining in area
    object oBat = GetNearestObjectByTag("GR_HUNDARK_BAT", OBJECT_SELF);
    if(!GetIsObjectValid(oBat)) {
        bDestroyAOE = TRUE;
        bDestroyBats = FALSE;
    } else if(GetDistanceBetweenLocations(GetLocation(oBat),spInfo.lTarget)>FeetToMeters(20.0)) {
        bDestroyAOE = TRUE;
    }

    //*:* check if duration is about to expire so we can destroy the bats
    if(iRemainingRounds<2) {
        SetLocalInt(OBJECT_SELF, "GR_REMAINING_ROUNDS", iRemainingRounds--);
    } else if(iRemainingRounds<=0) {
        bDestroyAOE = TRUE;
    }

    if(bDestroyAOE) {
        if(bDestroyBats) {
            object oBat = GetFirstInPersistentObject();
            while(GetIsObjectValid(oBat)) {
                if(GetTag(oBat)=="GR_HUNDARK_BAT") {
                    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oBat));
                    DestroyObject(oBat, 1.0f);
                }
                oBat = GetNextInPersistentObject();
            }
        }
        DestroyObject(OBJECT_SELF);
    }

}
//*:**************************************************************************
//*:**************************************************************************
