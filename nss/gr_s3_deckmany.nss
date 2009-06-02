//*:**************************************************************************
//*:*  GR_S3_DECKMANY.NSS
//*:**************************************************************************
//*:* Deck of Many Things (X0_S3_DECKMANY) Copyright (c) 2002 Floodgate Entertainment
//*:* Created By: Naomi Novik  Created On: 11/25/2002
//*:**************************************************************************
//*:* Updated On: December 10, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
#include "x0_i0_deckmany"

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Function declarations
//*:**************************************************************************
// Run the multiple-card draw
void DoDeck(object oCaster);

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;  // This is the person using the deck
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iCards          = GRGetCasterLevel(oCaster);  // This is the number of cards being drawn
    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    //GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    //*:* int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    //*:* int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    //*:* spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    /*if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);*/

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    object oDeck = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_invisobj", GetLocation(oCaster));

    SetNumberDeckDraws(oCaster, iCards);
    AssignCommand(oDeck, DoDeck(oCaster));

    // Clean up the deck object
    DestroyObject(oDeck, DECK_DELAY * 20);

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    //GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
void DoDeck(object oCaster) {
    // Randomly start with a positive or negative card
    int bNegative = Random(2);

    // Keep track of how many we've drawn so far
    // so we can delay effects
    int nTurn = 0;

    // No interrupting the deck!
    int nDrawsLeft = GetNumberDeckDraws(oCaster);

    while (nDrawsLeft > 0) {
        SetNumberDeckDraws(oCaster, nDrawsLeft-1);
        if (bNegative) {
            DoDeckDrawNegative(oCaster, nTurn);
        } else {
            DoDeckDrawPositive(oCaster, nTurn);
        }

        // We use this just to space out the card draws
        nTurn++;

        // Flip the negative setting so the next card will
        // be the opposite type
        bNegative = (bNegative + 1) % 2;

        // We have to get this off the caster again because it may have
        // been modified by the card drawn
        nDrawsLeft = GetNumberDeckDraws(oCaster);

    }
}
//*:**************************************************************************
