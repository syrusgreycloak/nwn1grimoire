//*:**************************************************************************
//*:*  GR_S3_SEQUENCER.NSS
//*:**************************************************************************
//:: x2_s3_sequencer  Copyright (c) 2003 Bioware Corp.
//:: Created By: Brent  Created On: July 31, 2003
//:: Updated By: Georg
//*:**************************************************************************
/*
    Fires the spells stored on this sequencer.
    GZ: - Also handles clearing off spells if the
          item has the clear sequencer property
        - added feedback strings
*/
//*:**************************************************************************
//*:* Updated On: January 28, 2008
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);
    object  oItem           = GetSpellCastItem();

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     i               = 0;
    int     iSpellID        = -1;
    int     iMode           = spInfo.iSpellID;
    int     iMax            = IPGetItemSequencerProperty(oItem);

    if(iMax==0) { // should never happen unless you added clear sequencer to a non sequencer item
        return;
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(iMode==720) {    // Clear Sequencer
        for(i=1; i<=iMax; i++) {
            DeleteLocalInt(oItem, "X2_L_SPELLTRIGGER"+IntToString(i));
        }
        DeleteLocalInt(oItem, "X2_L_NUMTRIGGERS");
        effect eClear = EffectVisualEffect(VFX_IMP_BREACH);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eClear, OBJECT_SELF);
        FloatingTextStrRefOnCreature(83882, oCaster);   // Sequencer cleared
    } else {
        int bSuccess = FALSE;
        for(i=1; i<=iMax; i++) {
            iSpellID = GetLocalInt(oItem, "X2_L_SPELLTRIGGER"+IntToString(i));
            if(iSpellID>0) {
                bSuccess = TRUE;
                iSpellID--; // I added +1 to the spellID when the sequencer was created, so I have to remove it here
                ActionCastSpellAtObject(iSpellID, oCaster, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
        }
        if(!bSuccess) {
            FloatingTextStrRefOnCreature(83886, oCaster); // no spells stored
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
