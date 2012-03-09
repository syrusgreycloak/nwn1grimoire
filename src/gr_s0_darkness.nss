//*:**************************************************************************
//*:*  GR_S0_DARKNESS.NSS
//*:**************************************************************************
//*:* MASTER SCRIPT FOR DARKNESS TYPE SPELLS
//*:**************************************************************************
//*:* Darkness (NW_S0_Darkness.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:* 3.5 Player's Handbook (p. 216)
//*:*
//*:* GreaterWildShape III - Drider Darkness Ability
//*:* x2_s2_driderdark     Copyright (c) 2003Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: July, 07, 2003
//*:**************************************************************************
//*:* Blacklight
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: March 16, 2003
//*:* Spell Compendium (p. 30)
//*:*
//*:* Deeper Darkness
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 4, 2004
//*:* 3.5 Player's Handbook (p. 217)
//*:*
//*:* Pall of Twilight
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 18, 2008
//*:* Complete Mage (p. 113)
//*:*
//*:* Darkness (Warlock Invocation)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 23, 2008
//*:* Complete Arcane (p. 133)
//*:*
//*:* Hungry Darkness
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 29, 2008
//*:* Complete Arcane (p. 134)
//*:**************************************************************************
//*:* Updated On: April 29, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
#include "x2_inc_shifter"

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_LIGHTDARK"

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

    //*:* GWIII - Drider Darkness
    if(spInfo.iSpellID==688 && ShifterDecrementGWildShapeSpellUsesLeft()<1) {
        FloatingTextStrRefOnCreature(83576, OBJECT_SELF);
        return;
    }

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = (spInfo.iSpellID==688 ? 6 : spInfo.iCasterLevel);
    int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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

    object  oAOE;
    int     iAOEType        = AOE_PER_DARKNESS;
    string  sAOEType        = AOE_TYPE_DARKNESS;

    switch(spInfo.iSpellID) {
        case SPELL_GR_BLACKLIGHT:
            iAOEType = AOE_PER_BLACKLIGHT;
            sAOEType = AOE_TYPE_BLACKLIGHT;
            break;
        case SPELL_GR_DEEPER_DARKNESS:
            iAOEType = AOE_MOB_DEEPER_DARKNESS;
            sAOEType = AOE_TYPE_DEEPER_DARKNESS;
            break;
        case SPELL_GR_PALL_OF_TWILIGHT:
            iAOEType = AOE_PER_PALL_OF_TWILIGHT;
            sAOEType = AOE_TYPE_PALL_OF_TWILIGHT;
            break;
        case SPELL_I_HUNGRY_DARKNESS:
            iAOEType = AOE_PER_HUNGRY_DARKNESS;
            sAOEType = AOE_TYPE_HUNGRY_DARKNESS;
            break;
    }

    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
            switch(spInfo.iSpellID) {
                case SPELL_GR_BLACKLIGHT:
                    iAOEType = AOE_PER_BLACKLIGHT_WIDE;
                    sAOEType = AOE_TYPE_BLACKLIGHT_WIDE;
                    break;
                case SPELL_GR_LSE_DARKNESS:
                case SPELL_DARKNESS:
                    iAOEType = AOE_PER_DARKNESS_WIDE;
                    sAOEType = AOE_TYPE_DARKNESS_WIDE;
                    break;
                case SPELL_GR_DEEPER_DARKNESS:
                    iAOEType = AOE_MOB_DEEPER_DARKNESS_WIDE;
                    sAOEType = AOE_TYPE_DEEPER_DARKNESS_WIDE;
                    break;
                case SPELL_GR_PALL_OF_TWILIGHT:
                    iAOEType = AOE_PER_PALL_OF_TWILIGHT_WIDE;
                    sAOEType = AOE_TYPE_PALL_OF_TWILIGHT_WIDE;
                    break;
            }
        }
    /*** END NWN1 SPECIFIC ***/
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
    effect eAOE = GREffectAreaOfEffect(iAOEType, "", "", "", sAOEType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GRGetHigherLvlLightEffectsInArea(spInfo.iSpellID, spInfo.lTarget)) {
        if(spInfo.iSpellID!=SPELL_I_HUNGRY_DARKNESS) {
            GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);
        } else {
            GRApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eAOE, spInfo.lTarget);
        }

        /*** NWN1 SINGLE ***/ oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
        //*** NWN2 SINGLE ***/ oAOE = GetObjectByTag(sAOEType);
        GRSetAOESpellId(spInfo.iSpellID, oAOE);
        GRSetSpellInfo(spInfo, oAOE);
    }

    GRRemoveLowerLvlLightEffectsInArea(spInfo.iSpellID, spInfo.lTarget);

    if(spInfo.iSpellID==SPELL_I_HUNGRY_DARKNESS) {
        int i;

        for(i=0; i<30; i++) {
            /*** NWN1 SINGLE ***/ object oBat = CreateObject(OBJECT_TYPE_CREATURE, "nw_bat", spInfo.lTarget, FALSE, "GR_HUNDARK_BAT");
            //*** NWN2 SINGLE ***/ object oBat = CreateObject(OBJECT_TYPE_CREATURE, "c_bat", spInfo.lTarget, FALSE, "GR_HUNDARK_BAT");
            ChangeFaction(oBat, oCaster);
        }
        SetLocalInt(oAOE, "GR_REMAINING_ROUNDS", 99);
        SetLocalInt(oCaster, "GR_L_CASTER_NEEDS_CONCENTRATION", TRUE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
