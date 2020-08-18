//*:**************************************************************************
//*:*  GR_S0_ENESPELL.NSS
//*:**************************************************************************
//*:*
//*:* Master Energy Spell Script
//*:* Script for the elemental protection spells -
//*:* Endure Elements
//*:* Resist Elements
//*:* Protection from Elements
//*:* Mass Resist Elements
//*:* Energy Immunity
//*:*
//*:* This way it keeps all of them together so you can take care of avoiding
//*:* stacking in the same script.
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: Oct 28, 2003
//*:**************************************************************************
//*:* Updated On: October 25, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
#include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
struct EnergyProtections {
    int     bHasEndureAcid;
    int     bHasEndureCold;
    int     bHasEndureElectricity;
    int     bHasEndureFire;
    int     bHasEndureSonic;
    int     bHasResistAcid;
    int     bHasResistCold;
    int     bHasResistElectricity;
    int     bHasResistFire;
    int     bHasResistSonic;
    int     bHasProtAcid;
    int     bHasProtCold;
    int     bHasProtElectricity;
    int     bHasProtFire;
    int     bHasProtSonic;
    int     bHasImmuneAcid;
    int     bHasImmuneCold;
    int     bHasImmuneElectricity;
    int     bHasImmuneFire;
    int     bHasImmuneSonic;
    int     bHasGreaterEffect;
    int     bHasEqualOrLesserEffect;

};

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
struct EnergyProtections GRGetEnergyProtections(object oCreature, int iSpellID) {

    struct EnergyProtections epEnergy;

    epEnergy.bHasEndureAcid = GetHasSpellEffect(SPELL_GR_ENDURE_ELEMENTS_ACID, oCreature);
    epEnergy.bHasEndureCold = GetHasSpellEffect(SPELL_GR_ENDURE_ELEMENTS_COLD, oCreature);
    epEnergy.bHasEndureElectricity = GetHasSpellEffect(SPELL_GR_ENDURE_ELEMENTS_ELECTRICITY, oCreature);
    epEnergy.bHasEndureFire = GetHasSpellEffect(SPELL_GR_ENDURE_ELEMENTS_FIRE, oCreature);
    epEnergy.bHasEndureSonic = GetHasSpellEffect(SPELL_GR_ENDURE_ELEMENTS_SONIC, oCreature);
    epEnergy.bHasResistAcid = GetHasSpellEffect(SPELL_GR_RESIST_ENERGY_ACID, oCreature) || GetHasSpellEffect(SPELL_GR_MASS_RESIST_ELEMENTS_ACID, oCreature);
    epEnergy.bHasResistCold = GetHasSpellEffect(SPELL_GR_RESIST_ENERGY_COLD, oCreature) || GetHasSpellEffect(SPELL_GR_MASS_RESIST_ELEMENTS_COLD, oCreature);
    epEnergy.bHasResistElectricity = GetHasSpellEffect(SPELL_GR_RESIST_ENERGY_ELECTRICITY, oCreature) || GetHasSpellEffect(SPELL_GR_MASS_RESIST_ELEMENTS_ELECTRICITY, oCreature);
    epEnergy.bHasResistFire = GetHasSpellEffect(SPELL_GR_RESIST_ENERGY_FIRE, oCreature) || GetHasSpellEffect(SPELL_GR_MASS_RESIST_ELEMENTS_FIRE, oCreature);
    epEnergy.bHasResistSonic = GetHasSpellEffect(SPELL_GR_RESIST_ENERGY_SONIC, oCreature) || GetHasSpellEffect(SPELL_GR_MASS_RESIST_ELEMENTS_SONIC, oCreature);
    epEnergy.bHasProtAcid = GetHasSpellEffect(SPELL_GR_PROTECTION_FROM_ENERGY_ACID, oCreature);
    epEnergy.bHasProtCold = GetHasSpellEffect(SPELL_GR_PROTECTION_FROM_ENERGY_COLD, oCreature);
    epEnergy.bHasProtElectricity = GetHasSpellEffect(SPELL_GR_PROTECTION_FROM_ENERGY_ELECTRICITY, oCreature);
    epEnergy.bHasProtFire = GetHasSpellEffect(SPELL_GR_PROTECTION_FROM_ENERGY_FIRE, oCreature);
    epEnergy.bHasProtSonic = GetHasSpellEffect(SPELL_GR_PROTECTION_FROM_ENERGY_SONIC, oCreature);
    epEnergy.bHasImmuneAcid = GetHasSpellEffect(SPELL_ENERGY_IMMUNITY_ACID, oCreature);
    epEnergy.bHasImmuneCold = GetHasSpellEffect(SPELL_ENERGY_IMMUNITY_COLD, oCreature);
    epEnergy.bHasImmuneElectricity = GetHasSpellEffect(SPELL_ENERGY_IMMUNITY_ELECTRICITY, oCreature);
    epEnergy.bHasImmuneFire = GetHasSpellEffect(SPELL_ENERGY_IMMUNITY_FIRE, oCreature);
    epEnergy.bHasImmuneSonic = GetHasSpellEffect(SPELL_ENERGY_IMMUNITY_SONIC, oCreature);

    switch(iSpellID) {
        case SPELL_GR_ENDURE_ELEMENTS_ACID:
            epEnergy.bHasGreaterEffect = epEnergy.bHasResistAcid && epEnergy.bHasProtAcid && epEnergy.bHasImmuneAcid;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasEndureAcid;
            break;
        case SPELL_GR_ENDURE_ELEMENTS_COLD:
            epEnergy.bHasGreaterEffect = epEnergy.bHasResistCold && epEnergy.bHasProtCold && epEnergy.bHasImmuneCold;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasEndureCold;
            break;
        case SPELL_GR_ENDURE_ELEMENTS_ELECTRICITY:
            epEnergy.bHasGreaterEffect = epEnergy.bHasResistElectricity && epEnergy.bHasProtElectricity && epEnergy.bHasImmuneElectricity;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasEndureElectricity;
            break;
        case SPELL_GR_ENDURE_ELEMENTS_FIRE:
            epEnergy.bHasGreaterEffect = epEnergy.bHasResistFire && epEnergy.bHasProtFire && epEnergy.bHasImmuneFire;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasEndureFire;
            break;
        case SPELL_GR_ENDURE_ELEMENTS_SONIC:
            epEnergy.bHasGreaterEffect = epEnergy.bHasResistSonic && epEnergy.bHasProtSonic && epEnergy.bHasImmuneSonic;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasEndureSonic;
            break;
        case SPELL_GR_RESIST_ENERGY_ACID:
        case SPELL_GR_MASS_RESIST_ELEMENTS_ACID:
            epEnergy.bHasGreaterEffect = epEnergy.bHasProtAcid && epEnergy.bHasImmuneAcid;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistAcid && epEnergy.bHasEndureAcid;
            break;
        case SPELL_GR_RESIST_ENERGY_COLD:
        case SPELL_GR_MASS_RESIST_ELEMENTS_COLD:
            epEnergy.bHasGreaterEffect = epEnergy.bHasProtCold && epEnergy.bHasImmuneCold;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistCold && epEnergy.bHasEndureCold;
            break;
        case SPELL_GR_RESIST_ENERGY_ELECTRICITY:
        case SPELL_GR_MASS_RESIST_ELEMENTS_ELECTRICITY:
            epEnergy.bHasGreaterEffect = epEnergy.bHasProtElectricity && epEnergy.bHasImmuneElectricity;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistElectricity && epEnergy.bHasEndureElectricity;
            break;
        case SPELL_GR_RESIST_ENERGY_FIRE:
        case SPELL_GR_MASS_RESIST_ELEMENTS_FIRE:
            epEnergy.bHasGreaterEffect = epEnergy.bHasProtFire && epEnergy.bHasImmuneFire;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistFire && epEnergy.bHasEndureFire;
            break;
        case SPELL_GR_RESIST_ENERGY_SONIC:
        case SPELL_GR_MASS_RESIST_ELEMENTS_SONIC:
            epEnergy.bHasGreaterEffect = epEnergy.bHasProtSonic && epEnergy.bHasImmuneSonic;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistSonic && epEnergy.bHasEndureSonic;
            break;
        case SPELL_GR_PROTECTION_FROM_ENERGY_ACID:
            epEnergy.bHasGreaterEffect = epEnergy.bHasImmuneAcid;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistAcid && epEnergy.bHasProtAcid && epEnergy.bHasEndureAcid;
            break;
        case SPELL_GR_PROTECTION_FROM_ENERGY_COLD:
            epEnergy.bHasGreaterEffect = epEnergy.bHasImmuneCold;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistCold && epEnergy.bHasProtCold && epEnergy.bHasEndureCold;
            break;
        case SPELL_GR_PROTECTION_FROM_ENERGY_ELECTRICITY:
            epEnergy.bHasGreaterEffect = epEnergy.bHasImmuneElectricity;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistElectricity && epEnergy.bHasProtElectricity && epEnergy.bHasEndureElectricity;
            break;
        case SPELL_GR_PROTECTION_FROM_ENERGY_FIRE:
            epEnergy.bHasGreaterEffect = epEnergy.bHasImmuneFire;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistFire && epEnergy.bHasProtFire && epEnergy.bHasEndureFire;
            break;
        case SPELL_GR_PROTECTION_FROM_ENERGY_SONIC:
            epEnergy.bHasGreaterEffect = epEnergy.bHasImmuneSonic;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistSonic && epEnergy.bHasProtSonic && epEnergy.bHasEndureSonic;
            break;
        case SPELL_ENERGY_IMMUNITY_ACID:
            epEnergy.bHasGreaterEffect = FALSE;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistAcid && epEnergy.bHasProtAcid && epEnergy.bHasEndureAcid && epEnergy.bHasImmuneAcid;
            break;
        case SPELL_ENERGY_IMMUNITY_COLD:
            epEnergy.bHasGreaterEffect = FALSE;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistCold && epEnergy.bHasProtCold && epEnergy.bHasEndureCold && epEnergy.bHasImmuneCold;
            break;
        case SPELL_ENERGY_IMMUNITY_ELECTRICITY:
            epEnergy.bHasGreaterEffect = FALSE;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistElectricity && epEnergy.bHasProtElectricity && epEnergy.bHasEndureElectricity && epEnergy.bHasImmuneElectricity;
            break;
        case SPELL_ENERGY_IMMUNITY_FIRE:
            epEnergy.bHasGreaterEffect = FALSE;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistFire && epEnergy.bHasProtFire && epEnergy.bHasEndureFire && epEnergy.bHasImmuneFire;
            break;
        case SPELL_ENERGY_IMMUNITY_SONIC:
            epEnergy.bHasGreaterEffect = FALSE;
            epEnergy.bHasEqualOrLesserEffect = epEnergy.bHasResistSonic && epEnergy.bHasProtSonic && epEnergy.bHasEndureSonic && epEnergy.bHasImmuneSonic;
            break;
    }

    return epEnergy;
}


void GRRemoveEnergyProtections(struct EnergyProtections epEnergy, int iSpellID, object oCreature) {

    switch(iSpellID) {
        case SPELL_ENERGY_IMMUNITY_ACID:
            if(epEnergy.bHasImmuneAcid) GRRemoveSpellEffects(SPELL_ENERGY_IMMUNITY_ACID, oCreature);
        case SPELL_GR_PROTECTION_FROM_ENERGY_ACID:
            if(epEnergy.bHasProtAcid) GRRemoveSpellEffects(SPELL_GR_PROTECTION_FROM_ENERGY_ACID, oCreature);
        case SPELL_GR_RESIST_ENERGY_ACID:
        case SPELL_GR_MASS_RESIST_ELEMENTS_ACID:
            if(epEnergy.bHasResistAcid) {
                GRRemoveMultipleSpellEffects(SPELL_GR_RESIST_ENERGY_ACID, SPELL_GR_MASS_RESIST_ELEMENTS_ACID, oCreature);
            }
        case SPELL_GR_ENDURE_ELEMENTS_ACID:
            if(epEnergy.bHasEndureAcid) GRRemoveSpellEffects(SPELL_GR_ENDURE_ELEMENTS_ACID, oCreature);
            break;
        case SPELL_ENERGY_IMMUNITY_COLD:
            if(epEnergy.bHasImmuneCold) GRRemoveSpellEffects(SPELL_ENERGY_IMMUNITY_COLD, oCreature);
        case SPELL_GR_PROTECTION_FROM_ENERGY_COLD:
            if(epEnergy.bHasProtCold) GRRemoveSpellEffects(SPELL_GR_PROTECTION_FROM_ENERGY_COLD, oCreature);
        case SPELL_GR_RESIST_ENERGY_COLD:
        case SPELL_GR_MASS_RESIST_ELEMENTS_COLD:
            if(epEnergy.bHasResistCold) {
                GRRemoveMultipleSpellEffects(SPELL_GR_RESIST_ENERGY_COLD, SPELL_GR_MASS_RESIST_ELEMENTS_COLD, oCreature);
            }
        case SPELL_GR_ENDURE_ELEMENTS_COLD:
            if(epEnergy.bHasEndureCold) GRRemoveSpellEffects(SPELL_GR_ENDURE_ELEMENTS_COLD, oCreature);
            break;
        case SPELL_ENERGY_IMMUNITY_ELECTRICITY:
            if(epEnergy.bHasImmuneElectricity) GRRemoveSpellEffects(SPELL_ENERGY_IMMUNITY_ELECTRICITY, oCreature);
        case SPELL_GR_PROTECTION_FROM_ENERGY_ELECTRICITY:
            if(epEnergy.bHasProtElectricity) GRRemoveSpellEffects(SPELL_GR_PROTECTION_FROM_ENERGY_ELECTRICITY, oCreature);
        case SPELL_GR_RESIST_ENERGY_ELECTRICITY:
        case SPELL_GR_MASS_RESIST_ELEMENTS_ELECTRICITY:
            if(epEnergy.bHasResistElectricity) {
                GRRemoveMultipleSpellEffects(SPELL_GR_RESIST_ENERGY_ELECTRICITY, SPELL_GR_MASS_RESIST_ELEMENTS_ELECTRICITY, oCreature);
            }
        case SPELL_GR_ENDURE_ELEMENTS_ELECTRICITY:
            if(epEnergy.bHasEndureElectricity) GRRemoveSpellEffects(SPELL_GR_ENDURE_ELEMENTS_ELECTRICITY, oCreature);
            break;
        case SPELL_ENERGY_IMMUNITY_FIRE:
            if(epEnergy.bHasImmuneFire) GRRemoveSpellEffects(SPELL_ENERGY_IMMUNITY_FIRE, oCreature);
        case SPELL_GR_PROTECTION_FROM_ENERGY_FIRE:
            if(epEnergy.bHasProtFire) GRRemoveSpellEffects(SPELL_GR_PROTECTION_FROM_ENERGY_FIRE, oCreature);
        case SPELL_GR_RESIST_ENERGY_FIRE:
        case SPELL_GR_MASS_RESIST_ELEMENTS_FIRE:
            if(epEnergy.bHasResistFire) {
                GRRemoveMultipleSpellEffects(SPELL_GR_RESIST_ENERGY_FIRE, SPELL_GR_MASS_RESIST_ELEMENTS_FIRE, oCreature);
            }
        case SPELL_GR_ENDURE_ELEMENTS_FIRE:
            if(epEnergy.bHasEndureFire) GRRemoveSpellEffects(SPELL_GR_ENDURE_ELEMENTS_FIRE, oCreature);
            break;
        case SPELL_ENERGY_IMMUNITY_SONIC:
            if(epEnergy.bHasImmuneSonic) GRRemoveSpellEffects(SPELL_ENERGY_IMMUNITY_SONIC, oCreature);
        case SPELL_GR_PROTECTION_FROM_ENERGY_SONIC:
            if(epEnergy.bHasProtSonic) GRRemoveSpellEffects(SPELL_GR_PROTECTION_FROM_ENERGY_SONIC, oCreature);
        case SPELL_GR_RESIST_ENERGY_SONIC:
        case SPELL_GR_MASS_RESIST_ELEMENTS_SONIC:
            if(epEnergy.bHasResistSonic) {
                GRRemoveMultipleSpellEffects(SPELL_GR_RESIST_ENERGY_SONIC, SPELL_GR_MASS_RESIST_ELEMENTS_SONIC, oCreature);
            }
        case SPELL_GR_ENDURE_ELEMENTS_SONIC:
            if(epEnergy.bHasEndureSonic) GRRemoveSpellEffects(SPELL_GR_ENDURE_ELEMENTS_SONIC, oCreature);
            break;
    }
}

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
    float   fRange          = FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iResistAmount       = 5;
    int     iUpperLimit         = 0;
    int     iDamageType;
    int     bHasGreaterEffect   = FALSE;
    int     bMultiTarget        = FALSE;
    int     iNumTargets         = 1;
    int     iLoop               = 0;
    struct  EnergyProtections epEffects;
    /*** NWN1 SINGLE ***/ int     iDurVisType         = VFX_DUR_PROTECTION_ELEMENTS;
    //*** NWN2 SINGLE ***/ int      iDurVisType         = VFX_DUR_SPELL_PROT_ENERGY;

    switch(spInfo.iSpellID) {
        case SPELL_ENDURE_ELEMENTS:
            spInfo = GRGetSpellStruct(SPELL_GR_ENDURE_ELEMENTS_FIRE, oCaster);
            break;
        case SPELL_RESIST_ENERGY:
            spInfo = GRGetSpellStruct(SPELL_GR_RESIST_ENERGY_FIRE, oCaster);
            break;
        case SPELL_PROTECTION_FROM_ENERGY:
            spInfo = GRGetSpellStruct(SPELL_GR_PROTECTION_FROM_ENERGY_FIRE, oCaster);
            break;
        case SPELL_ENERGY_IMMUNITY:
            spInfo = GRGetSpellStruct(SPELL_ENERGY_IMMUNITY_FIRE, oCaster);
            break;
        case SPELL_GR_MASS_RESIST_ELEMENTS:
            spInfo = GRGetSpellStruct(SPELL_GR_MASS_RESIST_ELEMENTS_FIRE, oCaster);
        case SPELL_GR_MASS_RESIST_ELEMENTS_ACID:
        case SPELL_GR_MASS_RESIST_ELEMENTS_COLD:
        case SPELL_GR_MASS_RESIST_ELEMENTS_ELECTRICITY:
        case SPELL_GR_MASS_RESIST_ELEMENTS_FIRE:
        case SPELL_GR_MASS_RESIST_ELEMENTS_SONIC:
            bMultiTarget = TRUE;
            iNumTargets = spInfo.iCasterLevel;
            break;
    }

    switch(spInfo.iSpellID) {
        // ENDURE ELMENTS
        case SPELL_GR_ENDURE_ELEMENTS_ACID:
            //*** NWN2 SINGLE ***/ iDurVistype = VFX_DUR_SPELL_ENDURE_ELEMENTS;
            iDamageType = DAMAGE_TYPE_ACID;
            break;
        case SPELL_GR_ENDURE_ELEMENTS_COLD:
            //*** NWN2 SINGLE ***/ iDurVistype = VFX_DUR_SPELL_ENDURE_ELEMENTS;
            iDamageType = DAMAGE_TYPE_COLD;
            break;
        case SPELL_GR_ENDURE_ELEMENTS_ELECTRICITY:
            //*** NWN2 SINGLE ***/ iDurVistype = VFX_DUR_SPELL_ENDURE_ELEMENTS;
            iDamageType = DAMAGE_TYPE_ELECTRICAL;
            break;
        case SPELL_GR_ENDURE_ELEMENTS_FIRE:
            //*** NWN2 SINGLE ***/ iDurVistype = VFX_DUR_SPELL_ENDURE_ELEMENTS;
            iDamageType = DAMAGE_TYPE_FIRE;
            break;
        case SPELL_GR_ENDURE_ELEMENTS_SONIC:
            //*** NWN2 SINGLE ***/ iDurVistype = VFX_DUR_SPELL_ENDURE_ELEMENTS;
            iDamageType = DAMAGE_TYPE_SONIC;
            break;
        // RESIST ELEMENTS & MASS RESIST ELEMENTS
        case SPELL_GR_MASS_RESIST_ELEMENTS_ACID:
        case SPELL_GR_RESIST_ENERGY_ACID:
            //*** NWN2 SINGLE ***/ iDurVistype = VFX_DUR_SPELL_RESIST_ENERGY;
            iDamageType = DAMAGE_TYPE_ACID;
            iResistAmount = 10;
            if(spInfo.iCasterLevel>=7) iResistAmount = 20;
            if(spInfo.iCasterLevel>=11) iResistAmount = 30;
            break;
        case SPELL_GR_MASS_RESIST_ELEMENTS_COLD:
        case SPELL_GR_RESIST_ENERGY_COLD:
            //*** NWN2 SINGLE ***/ iDurVistype = VFX_DUR_SPELL_RESIST_ENERGY;
            iDamageType = DAMAGE_TYPE_COLD;
            iResistAmount = 10;
            if(spInfo.iCasterLevel>=7) iResistAmount = 20;
            if(spInfo.iCasterLevel>=11) iResistAmount = 30;
            break;
        case SPELL_GR_MASS_RESIST_ELEMENTS_ELECTRICITY:
        case SPELL_GR_RESIST_ENERGY_ELECTRICITY:
            //*** NWN2 SINGLE ***/ iDurVistype = VFX_DUR_SPELL_RESIST_ENERGY;
            iDamageType = DAMAGE_TYPE_ELECTRICAL;
            iResistAmount = 10;
            if(spInfo.iCasterLevel>=7) iResistAmount = 20;
            if(spInfo.iCasterLevel>=11) iResistAmount = 30;
            break;
        case SPELL_GR_MASS_RESIST_ELEMENTS_FIRE:
        case SPELL_GR_RESIST_ENERGY_FIRE:
            //*** NWN2 SINGLE ***/ iDurVistype = VFX_DUR_SPELL_RESIST_ENERGY;
            iDamageType = DAMAGE_TYPE_FIRE;
            iResistAmount = 10;
            if(spInfo.iCasterLevel>=7) iResistAmount = 20;
            if(spInfo.iCasterLevel>=11) iResistAmount = 30;
            break;
        case SPELL_GR_MASS_RESIST_ELEMENTS_SONIC:
        case SPELL_GR_RESIST_ENERGY_SONIC:
            //*** NWN2 SINGLE ***/ iDurVistype = VFX_DUR_SPELL_RESIST_ENERGY;
            iDamageType = DAMAGE_TYPE_SONIC;
            iResistAmount = 10;
            if(spInfo.iCasterLevel>=7) iResistAmount = 20;
            if(spInfo.iCasterLevel>=11) iResistAmount = 30;
            break;
        // PROTECTION FROM ELEMENTS && ENERGY IMMUNITY
        case SPELL_GR_PROTECTION_FROM_ENERGY_ACID:
            iUpperLimit = 12*spInfo.iCasterLevel;
            fDuration = GRGetDuration(spInfo.iCasterLevel, DUR_TYPE_TURNS);
        case SPELL_ENERGY_IMMUNITY_ACID:
            //*** NWN2 SINGLE ***/ if(spInfo.iSpellID>SPELL_ENERGY_IMMUNITY) iDurVistype = VFX_DUR_SPELL_ENERGY_IMMUNITY;
            iDamageType = DAMAGE_TYPE_ACID;
            iResistAmount = 9999;
            break;
        case SPELL_GR_PROTECTION_FROM_ENERGY_COLD:
            iUpperLimit = 12*spInfo.iCasterLevel;
            fDuration = GRGetDuration(spInfo.iCasterLevel, DUR_TYPE_TURNS);
        case SPELL_ENERGY_IMMUNITY_COLD:
            //*** NWN2 SINGLE ***/ if(spInfo.iSpellID>SPELL_ENERGY_IMMUNITY) iDurVistype = VFX_DUR_SPELL_ENERGY_IMMUNITY;
            iDamageType = DAMAGE_TYPE_COLD;
            iResistAmount = 9999;
            break;
        case SPELL_GR_PROTECTION_FROM_ENERGY_ELECTRICITY:
            iUpperLimit = 12*spInfo.iCasterLevel;
            fDuration = GRGetDuration(spInfo.iCasterLevel, DUR_TYPE_TURNS);
        case SPELL_ENERGY_IMMUNITY_ELECTRICITY:
            //*** NWN2 SINGLE ***/ if(spInfo.iSpellID>SPELL_ENERGY_IMMUNITY) iDurVistype = VFX_DUR_SPELL_ENERGY_IMMUNITY;
            iDamageType = DAMAGE_TYPE_ELECTRICAL;
            iResistAmount = 9999;
            break;
        case SPELL_GR_PROTECTION_FROM_ENERGY_FIRE:
            iUpperLimit = 12*spInfo.iCasterLevel;
            fDuration = GRGetDuration(spInfo.iCasterLevel, DUR_TYPE_TURNS);
        case SPELL_ENERGY_IMMUNITY_FIRE:
            //*** NWN2 SINGLE ***/ if(spInfo.iSpellID>SPELL_ENERGY_IMMUNITY) iDurVistype = VFX_DUR_SPELL_ENERGY_IMMUNITY;
            iDamageType = DAMAGE_TYPE_FIRE;
            iResistAmount = 9999;
            break;
        case SPELL_GR_PROTECTION_FROM_ENERGY_SONIC:
            iUpperLimit = 12*spInfo.iCasterLevel;
            fDuration = GRGetDuration(spInfo.iCasterLevel, DUR_TYPE_TURNS);
        case SPELL_ENERGY_IMMUNITY_SONIC:
            //*** NWN2 SINGLE ***/ if(spInfo.iSpellID>SPELL_ENERGY_IMMUNITY) iDurVistype = VFX_DUR_SPELL_ENERGY_IMMUNITY;
            iDamageType = DAMAGE_TYPE_SONIC;
            iResistAmount = 9999;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration     = ApplyMetamagicDurationMods(fDuration);
        iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
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
    /*** NWN1 SPECIFIC ***/
        effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
        effect eVis     = EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION);
        effect eDur2    = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    /*** END NWN1 SPECIFIC ***/
    effect eDur     = EffectVisualEffect(iDurVisType);
    effect eEnergyAbsorb;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        spInfo.lTarget = GetLocation(spInfo.oTarget);
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
                epEffects = GRGetEnergyProtections(spInfo.oTarget, spInfo.iSpellID);
                if(epEffects.bHasGreaterEffect) {
                    if(GetIsPC(spInfo.oTarget)) {
                        SendMessageToPC(spInfo.oTarget, GetStringByStrRef(16939246));
                    }
                } else {
                    if(epEffects.bHasEqualOrLesserEffect)
                        GRRemoveEnergyProtections(epEffects, spInfo.iSpellID, spInfo.oTarget);

                    eEnergyAbsorb = EffectDamageResistance(iDamageType, iResistAmount, iUpperLimit);
                    eLink = EffectLinkEffects(eDur, eEnergyAbsorb);
                    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur2);

                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                    GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
                }
                iNumTargets--;
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumTargets>0);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
