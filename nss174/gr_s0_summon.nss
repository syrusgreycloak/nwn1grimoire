//*:**************************************************************************
//*:*  GR_S0_SUMMON.NSS
//*:**************************************************************************
//*:* Summon Creature Series (SG_S0_Summon) 2004 Karl Nickels (Syrus Greycloak)
//*:* Edited By: Karl Nickels (Syrus Greycloak)
//*:* Edited On: April 28, 2004
//*:* Edited Again: March 9, 2004
//*:* Edited Again: August 17, 2004
//*:**************************************************************************
//*:* Updated On: November 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"   -- included in GR_IN_SUMMON
#include "GR_IN_SPELLHOOK"
#include "GR_IN_SUMMON"

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
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    //*:* int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    //*:* int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    //*:* spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);
    object  oTemp;
    int i;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    //*:* iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    //*:* list effect declarations here

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetArrayDimensions(ARR_SUMMON, oCaster)==0) {
        GRCreateArrayList(ARR_SUMMON, CREATURE, VALUE_TYPE_OBJECT, oCaster);
    }

    if(GetLocalInt(GetModule(), "GR_L_DESTROY_SUMMONS")) {
        GRDestroyPreviousSummons();
    } else {
        //*:* Attempt to protect the summons from being destroyed
        //*:* when summoning the new ones

        //AutoDebugString("Getting associate");
        for(i=1; i<=GRGetDimSize(ARR_SUMMON, CREATURE); i++) {
            oTemp = GRObjectGetValueAt(ARR_SUMMON, CREATURE, i);
            if(GetIsObjectValid(oTemp)) {
                //AutoDebugString("Associate is Valid.  Name is: "+GetName(oTemp));
                SetPlotFlag(oTemp, TRUE);
                SetImmortal(oTemp, TRUE);
                AssignCommand(oTemp, SetIsDestroyable(FALSE));
            } else {
                // not valid - remove from list
                oTemp = GRObjectGetAndRemoveValue(ARR_SUMMON, CREATURE, i);
            }
        }
    }

    GRDoMultiSummonEffect(spInfo.iSpellID, oCaster, DURATION_TYPE_TEMPORARY, spInfo.lTarget, fDuration);

    //*:* remove the "protection"
    for(i=1; i<=GRGetDimSize(ARR_SUMMON, CREATURE); i++) {
        oTemp = GRObjectGetValueAt(ARR_SUMMON, CREATURE, i);
        if(GetIsObjectValid(oTemp)) {
            SetPlotFlag(oTemp, FALSE);
            SetImmortal(oTemp, FALSE);
            AssignCommand(oTemp, SetIsDestroyable(TRUE));
        } else {
            // not valid - remove from list
            oTemp = GRObjectGetAndRemoveValue(ARR_SUMMON, CREATURE, i);
        }
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
