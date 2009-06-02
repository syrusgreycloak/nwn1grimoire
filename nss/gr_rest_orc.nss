/*
Filename: gr_rest_ocr
System: Grimoire spell system
Author: Karl Nickels (Syrus Greycloak)
Date Created: November 5, 2008
Summary:
Resets the domain check done variable to false so that clerics need to complete
a rest event and verify at least one domain spell is memorized prior to being able to cast.
-----------------
Revision Date:
Revision Author:
Revision Summary:
*/

void main() {
    object oPC = GetLastPCRested();

    SetLocalInt(oPC, "GR_DOMAIN_CHECK_DONE", FALSE);
}