/*
Filename: gr_client_oce.nss
System: Grimoire spell system
Author: Karl Nickels (Syrus Greycloak)
Date Created: November 5, 2008
Summary:
This script sets a deity variable necessary for certain spells to work and
ensures some of the custom domain feats are added to the character if missing.
-----------------
Revision Date:
Revision Author:
Revision Summary:
*/

#include "GR_IN_DEITIES"
#include "GR_IN_DOMAINS"
#include "GR_IN_LIB"

void main() {
    object oPC = GetEnteringObject();

    if(!GetLocalInt(oPC, "MY_DEITY")) GRSetPCDeity(oPC);

    if(GRGetHasClass(CLASS_TYPE_CLERIC, oPC)) {
        if(!GetLocalInt(oPC, "GR_L_DOMAIN_FEATS")) {
            GRCheckSpecialDomainFeats(oPC);
        }
    }
}


