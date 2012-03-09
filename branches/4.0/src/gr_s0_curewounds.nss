//*:**************************************************************************
//*:*  GR_S0_CUREWOUNDS.NSS
//*:**************************************************************************
//*:*
//*:* Master script for most cure wounds type spells
//*:*
//*:* Styptic - WotC Website
//*:* Cure Minor Wounds - 3.5 Player's Handbook (p. 216)
//*:* Cure Light Wounds - 3.5 Player's Handbook (p. 215)
//*:* Cure Light Wounds, Mass - 3.5 Player's Handbook (p. 215)
//*:* Cure Moderate Wounds - 3.5 Player's Handbook (p. 216)
//*:* Cure Moderate Wounds, Mass - 3.5 Player's Handbook (p. 216)
//*:* Cure Serious Wounds - 3.5 Player's Handbook (p. 216)
//*:* Cure Serious Wounds, Mass - 3.5 Player's Handbook (p. 216)
//*:* Cure Critical Wounds - 3.5 Player's Handbook (p. 215)
//*:* Cure Critical Wounds, Mass - 3.5 Player's Handbook (p. 215)
//*:* Cure Critical Wounds, Other - Blackguard
//*:* Lesser Body Adjustment - Monk
//*:* Healing Touch - Spell Compendium (p. 111)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 14, 2005
//*:**************************************************************************
//*:* Updated On: October 25, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS" - INCLUDED IN GR_IN_HEALHARM
#include "GR_IN_SPELLHOOK"
#include "GR_IN_HEALHARM"

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

    int     iDieType        = 8;
    int     iNumDice        = 1;
    int     iBonus          = spInfo.iCasterLevel;
    int     iDamage         = 0;
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int iVis = VFX_IMP_SUNSTRIKE;
    int iVis2;

    switch(spInfo.iSpellID) {
        case SPELL_GR_STYPTIC:
        case SPELL_CURE_MINOR_WOUNDS:
            iDieType = 1;
            iNumDice = 1;
            iBonus = 0;
            iDamage = 1;
            /*** NWN1 SINGLE ***/ iVis2 = VFX_IMP_HEAD_HEAL;
            //*** NWN2 SINGLE ***/ iVis2 = VFX_IMP_HEALING_S;
            break;
        case SPELL_CURE_LIGHT_WOUNDS:
        case SPELLABILITY_LESSER_BODY_ADJUSTMENT:
            iNumDice = 1;
            iBonus = MinInt(5, spInfo.iCasterLevel);
            /*** NWN1 SINGLE ***/ iVis2 = VFX_IMP_HEALING_S;
            //*** NWN2 SINGLE ***/ iVis2 = VFX_IMP_HEALING_M;
            break;
        case SPELL_CURE_MODERATE_WOUNDS:
            iNumDice = 2;
            iBonus = MinInt(10, spInfo.iCasterLevel);
            /*** NWN1 SINGLE ***/ iVis2 = VFX_IMP_HEALING_M;
            //*** NWN2 SINGLE ***/ iVis2 = VFX_IMP_HEALING_L;
            break;
        case SPELL_CURE_SERIOUS_WOUNDS:
            iNumDice = 3;
            iBonus = MinInt(15, spInfo.iCasterLevel);
            /*** NWN1 SINGLE ***/ iVis2 = VFX_IMP_HEALING_L;
            //*** NWN2 SINGLE ***/ iVis2 = VFX_IMP_HEALING_X;
            break;
        case SPELL_CURE_CRITICAL_WOUNDS:
        case 567:  // Cure Critcal Wounds Others
            iNumDice = 4;
            iBonus = MinInt(20, spInfo.iCasterLevel);
            /*** NWN1 SINGLE ***/ iVis2 = (spInfo.iSpellID==SPELL_CURE_CRITICAL_WOUNDS ? VFX_IMP_HEALING_G : VFX_IMP_SUPER_HEROISM);
            //*** NWN2 SINGLE ***/ iVis2 = VFX_IMP_HEALING_G;
            break;
        case SPELL_MASS_CURE_LIGHT_WOUNDS:
            iNumDice = 1;
            iBonus = MinInt(25, spInfo.iCasterLevel);
            iVis2 = VFX_IMP_HEALING_M;
            break;
        case SPELL_MASS_CURE_MODERATE_WOUNDS:
            iNumDice = 2;
            iBonus = MinInt(30, spInfo.iCasterLevel);
            iVis2 = VFX_IMP_HEALING_L;
            break;
        case SPELL_MASS_CURE_SERIOUS_WOUNDS:
            iNumDice = 3;
            if(iBonus>35) iBonus = 35;
            /*** NWN1 SINGLE ***/ iVis2 = VFX_IMP_HEALING_G;
            //*** NWN2 SINGLE ***/ iVis2 = VFX_IMP_HEALING_X;
            break;
        case SPELL_MASS_CURE_CRITICAL_WOUNDS:
            iNumDice = 4;
            iBonus = MinInt(40, spInfo.iCasterLevel);
            iVis2 = VFX_IMP_HEALING_G;
            break;
        case SPELL_GR_HEALING_TOUCH:
            iDieType = 6;
            iNumDice = MinInt(10, MaxInt(1, spInfo.iCasterLevel/2));
            iBonus = 0;
            iVis2 = VFX_IMP_HEALING_L;
            break;
    }

    iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, 0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    GRCureWounds(iDamage, iBonus, iDieType*iNumDice, iVis, iVis2, spInfo.iSpellID);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
