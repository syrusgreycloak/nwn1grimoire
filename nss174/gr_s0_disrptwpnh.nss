//*:**************************************************************************
//*:*  GR_S0_DISRPTWPNH.NSS
//*:**************************************************************************
//*:* Disrupting Weapon: OnHit
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 11, 2008
//*:* 3.5 Player's Handbook (p. 223)
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
    object  oCaster         = GetItemPossessor(OBJECT_SELF);
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(SPELL_GR_DISRUPTING_WEAPON, OBJECT_SELF);

    spInfo.oTarget = GetSpellTargetObject();

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(VFX_IMP_DEATH);
    effect eDamage  = EffectDamage(GetMaxHitPoints(spInfo.oTarget)*2);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
        int iHD = GetHitDice(spInfo.oTarget);

        if(iHD<=spInfo.iCasterLevel) {
            if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                if(!GetIsPC(spInfo.oTarget)) {
                    DelayCommand(2.0f, DestroyObject(spInfo.oTarget));
                } else {
                    DelayCommand(2.0F, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget));
                }
            }
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    //GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
