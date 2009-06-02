//*:**************************************************************************
//*:*  GR_O0_DYING.NSS
//*:**************************************************************************
//*:*
//*:* Edited version of Bioware's OnDying script by Brent Knowles
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 16, 2007
//*:**************************************************************************
//*:* Updated On: September 25, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**********************************************
//*:* Constant Libraries
#include "GR_IC_SPELLS"

//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"
#include "GR_IN_EFFECTS"
#include "GR_IN_LIB"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    object oPC = GetLastPlayerDying();

    effect eDeath = EffectDeath(FALSE, FALSE);
    effect eBleed = EffectDamage(1, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY);

    if(GetCurrentHitPoints(oPC)<=-10) {  // Dead
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oPC);
        DeleteLocalInt(oPC, "GR_IS_STABLE");
    } else if(GetCurrentHitPoints(oPC)<=0) {
        if(!GetHasSpellEffect(SPELL_GR_BEASTLAND_FEROCITY, oPC)) {
            if(!GetLocalInt(oPC, "GR_IS_UNCONSCIOUS")) {
                effect eUnconscious = EffectLinkEffects(EffectKnockdown(), EffectCutsceneParalyze());
                // apply unconscious effect
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eUnconscious, oPC, GRGetDuration(11));
                SetLocalInt(oPC, "GR_IS_UNCONSCIOUS", TRUE);
                DelayCommand(GRGetDuration(11), DeleteLocalInt(oPC, "GR_IS_UNCONSCIOUS"));
            }

            if(!GetLocalInt(oPC, "GR_IS_STABLE")) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBleed, oPC);
            }
        }
    }
}
//*:**************************************************************************
//*:**************************************************************************
