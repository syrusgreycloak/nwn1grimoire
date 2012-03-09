/*
Filename: gr_rest_orf.nss
System: Grimoire spell system
Author: Karl Nickels (Syrus Greycloak)
Date Created: November 5, 2008
Summary:
This script checks if clerics have at least one domain spell per level memorized.  If not
they get blocked from being able to cast spells.
-----------------
Revision Date:
Revision Author:
Revision Summary:
*/

#include "GR_IN_DOMAINS"
#include "GR_IN_EFFECTS"
//#include "GR_IN_FATIGUE"

void main() {
    object oPC = GetLastPCRested();

    if(GRGetHasClass(CLASS_TYPE_CLERIC, oPC)) {
        //AutoDebugString("You are a cleric.");
        if(!GetLocalInt(oPC, "GR_L_DOMAIN_FEATS")) {
            //AutoDebugString("Checking if needs special domain feats.");
            GRCheckSpecialDomainFeats(oPC);
        }

        //AutoDebugString("Checking if Enforcing Domain Spells");
        if(GetModuleSwitchValue("GR_ENFORCE_DOMAINSPELLS")==TRUE) {
            //AutoDebugString("Checking domain spells for "+GetName(oPC));
            GRCheckDomainSpellsMemorized(oPC);
            if(GetLocalInt(oPC, "GR_DOMAIN_BLOCK")) {
                FloatingTextStrRefOnCreature(16939275, oPC);
            }
        } /*else {  // debug message
            //AutoDebugString("Domain spell variable not set.");
        }*/
    } /*else {
        //AutoDebugString("You are not a cleric.");
    }*/
    GRRemoveSpecialEffect(SPECIALEFFECT_TYPE_EXHAUSTION, oPC);
    GRRemoveSpecialEffect(SPECIALEFFECT_TYPE_FATIGUE, oPC);
}