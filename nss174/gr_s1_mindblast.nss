//*:**************************************************************************
//*:*  GR_S1_MINDBLAST.NSS
//*:**************************************************************************
//:: GreaterWildShape IV - Mindflayer Mindblast  Copyright (c) 2003Bioware Corp.
//:: GreaterWildShape IV - Mindflayer Mindblast x2_s1_illithidb  Copyright (c) 2003Bioware Corp.
//:: Created By: Georg Zoeller  Created On: July, 07, 2003
//*:**************************************************************************
//*:* Updated On: January 10, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
#include "X2_INC_SHIFTER"

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"  --- INCLUDED IN GR_IN_CREATURE
#include "GR_IN_CREATURE"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**************************************************************************
    //*:* Enforce artifical use limit on that ability
    //*:**************************************************************************
    int iDC = 19;

    if(GetSpellId()==693) { //*:* GWShape - Mindflayer Mindblast
        if(ShifterDecrementGWildShapeSpellUsesLeft()<1) {
            FloatingTextStrRefOnCreature(83576, OBJECT_SELF);
            return;
        }
        iDC = ShifterGetSaveDC(OBJECT_SELF, SHIFTER_DC_EASY) + GetAbilityModifier(ABILITY_WISDOM, OBJECT_SELF);
    }

    //*:* Do the mind blast
    GRDoMindBlast(iDC, d4(1), 15.0f);
}
//*:**************************************************************************
//*:**************************************************************************
