//*:**************************************************************************
//*:*  GR_S0_COBWEBSB.NSS
//*:**************************************************************************
//*:* Choking Cobwebs: OnExit
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: April 21, 2008
//*:* Complete Mage (p. 99)
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

    int     iDC             = GRGetSpellSaveDC(oCaster, oTarget);

    effect  eSicken         = GREffectSickened();
    effect  eDur            = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect  eLink           = EffectLinkEffects(eSicken, eDur);

    GRRemoveSpellEffects(GRGetAOESpellId(), oTarget, oCaster);
    if(!GRGetSaveResult(SAVING_THROW_FORT, oTarget, iDC)) {
        SignalEvent(oTarget, EventSpellCastAt(oCaster, SPELL_GR_CHOKING_COBWEBS));
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, GRGetDuration(1));
    }
}
//*:**************************************************************************
//*:**************************************************************************
