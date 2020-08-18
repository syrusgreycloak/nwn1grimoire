//*:**************************************************************************
//*:*  GR_S2_BLASTSHAPE.NSS
//*:**************************************************************************
//*:* This script sets the appropriate blast shape info needed for the main
//*:* Eldritch Blast script.  It then triggers the Eldritch Blast script to
//*:* apply effects.
//*:**************************************************************************
//*:* Eldritch Chain
//*:* Eldritch Cone
//*:* Eldritch Doom
//*:* Eldritch Spear
//*:* Hideous Blow
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created: April, 2008
//*:* Complete Arcane
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
//#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo;

    if(GetSpellId()==SPELL_I_HIDEOUS_BLOW_HIT) {
        spInfo.iSpellID = SPELL_I_HIDEOUS_BLOW;
        spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, GetSpellCastItem());
        oCaster = spInfo.oCaster;
        //*:* in case the warlock tried to trade the weapon
        //*:* to someone else
        if(oCaster!=GetItemPossessor(GetSpellCastItem())) {
            return;
        }
    } else {
        spInfo = GRGetSpellStruct(GetSpellId(), oCaster);
    }


    SetLocalInt(oCaster, "GR_BLAST_SHAPE_ID", spInfo.iSpellID);
    SetLocalInt(oCaster, "GR_BLAST_SHAPE_LEVEL", spInfo.iSpellLevel);
    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetAOESpellId(spInfo.iSpellID, oCaster);
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Blast Shape Invocations will trigger Eldritch Blast
    //*:**********************************************
    ExecuteScript("gr_s2_eldblast", oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
