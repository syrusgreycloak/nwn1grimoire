//*:**************************************************************************
//*:*  GR_IN_FEATS.NSS
//*:**************************************************************************
//*:*
//*:* Functions to implement various abilities granted by feats
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IN_ITEMPROP"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void    GRCheckAndApplyEpicRageFeats(int iRounds);
void    GRCheckAndApplyThunderingRage(int iRounds);
void    GRCheckAndApplyTerrifyingRage(int iRounds);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRCheckAndapplyEpicRageFeats
//*:**********************************************
//*:* GZ, 2003-07-09
//*:* Hub function for the epic barbarian feats that
//*:* upgrade rage. Call from the end of the barbarian
//*:* rage spellscript
//*:**********************************************
//*:* Updated on: February 12, 2007
//*:**********************************************
void GRCheckAndApplyEpicRageFeats(int iRounds) {

    GRCheckAndApplyThunderingRage(iRounds);
    GRCheckAndApplyTerrifyingRage(iRounds);
}

//*:**********************************************
//*:* GRCheckAndApplyThunderingRage
//*:**********************************************
//*:* GZ, 2003-07-09
//*:* If the character calling this function from a
//*:* spellscript has the thundering rage feat,
//*:* his weapons are upgraded to deafen and cause
//*:* 2d6 points of massive criticals
//*:**********************************************
//*:* Updated on: February 12, 2007
//*:**********************************************
void GRCheckAndApplyThunderingRage(int iRounds) {

    if(GetHasFeat(988, OBJECT_SELF)) {

        object oWeapon =  GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);

        if(GetIsObjectValid(oWeapon)) {
           GRIPSafeAddItemProperty(oWeapon, ItemPropertyMassiveCritical(IP_CONST_DAMAGEBONUS_2d6), GRGetDuration(iRounds), X2_IP_ADDPROP_POLICY_KEEP_EXISTING,TRUE,TRUE);
           GRIPSafeAddItemProperty(oWeapon, ItemPropertyVisualEffect(ITEM_VISUAL_SONIC), GRGetDuration(iRounds), X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
           GRIPSafeAddItemProperty(oWeapon, ItemPropertyOnHitProps(IP_CONST_ONHIT_DEAFNESS, IP_CONST_ONHIT_SAVEDC_20, IP_CONST_ONHIT_DURATION_25_PERCENT_3_ROUNDS),
                GRGetDuration(iRounds), X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
        }

        oWeapon =  GetItemInSlot(INVENTORY_SLOT_LEFTHAND);

        if(GetIsObjectValid(oWeapon)) {
           GRIPSafeAddItemProperty(oWeapon, ItemPropertyMassiveCritical(IP_CONST_DAMAGEBONUS_2d6), GRGetDuration(iRounds), X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE, TRUE);
           GRIPSafeAddItemProperty(oWeapon, ItemPropertyVisualEffect(ITEM_VISUAL_SONIC), GRGetDuration(iRounds), X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
        }
    }
}

//*:**********************************************
//*:* GRCheckAndApplyTerrifyingRage
//*:**********************************************
//*:* GZ, 2003-07-09
//*:* If the character calling this function from a spellscript has the terrifying
//*:* rage feat, he gets an aura of fear for the specified duration
//*:* The saving throw against this fear is a check opposed to the character's
//*:* intimidation skill
//*:**********************************************
//*:* Updated on: February 12, 2007
//*:**********************************************
void GRCheckAndApplyTerrifyingRage(int iRounds) {

    if(GetHasFeat(989, OBJECT_SELF)) {
        effect eAOE = EffectAreaOfEffect(AOE_MOB_FEAR, "gr_s2_terrage_A", "", "");
        eAOE = ExtraordinaryEffect(eAOE);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, OBJECT_SELF, GRGetDuration(iRounds));
    }
}

//*:**************************************************************************
//*:**************************************************************************
