//*:**************************************************************************
//*:*  GR_S0_INFLICT.NSS
//*:**************************************************************************
//*:*
//*:* Combination script for all inflict spells
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**************************************************************************
//*:* Updated On: June 21, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//*:* #include "GR_IN_SPELLS" - included in GR_IN_INFLICT
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
    int     iBonus          = 0;
    int     iDamage         = 0;
    int     iSecDamage      = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    if(spInfo.iSpellID==611 || spInfo.iCasterLevel==612) { // Blackguard versions
        spInfo.iSpellCastClass = CLASS_TYPE_BLACKGUARD;
        spInfo.iCasterLevel = GRGetCasterLevel(oCaster, spInfo.iSpellCastClass);
    }

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

    float   fDuration       = GRGetDuration(spInfo.iCasterLevel);

    int     iVis            = 246;
    int     iVis2;
    /*** NWN1 SINGLE ***/ iVis2 = VFX_IMP_HEALING_G;

        switch(spInfo.iSpellID) {
            case SPELL_INFLICT_MINOR_WOUNDS:
                iDieType = 1;
                iNumDice = 1;
                iBonus = 0;
                iDamage = 1;
                //*** NWN2 SINGLE ***/ iVis2 = VFX_HIT_SPELL_INFLICT_1;
                break;
            case SPELL_INFLICT_LIGHT_WOUNDS:
                iNumDice = 1;
                iBonus = (spInfo.iCasterLevel>5 ? 5 : spInfo.iCasterLevel);
                //*** NWN2 SINGLE ***/ iVis2 = VFX_HIT_SPELL_INFLICT_2;
                break;
            case SPELL_INFLICT_MODERATE_WOUNDS:
                iNumDice = 2;
                iBonus = (spInfo.iCasterLevel>10 ? 10 : spInfo.iCasterLevel);
                //*** NWN2 SINGLE ***/ iVis2 = VFX_HIT_SPELL_INFLICT_3;
                break;
            case SPELL_INFLICT_SERIOUS_WOUNDS:
            case 611:   //SPELLABILITY_BG_INFLICT_SERIOUS_WOUNDS:
                iNumDice = 3;
                iBonus = (spInfo.iCasterLevel>15 ? 15 : spInfo.iCasterLevel);
                //*** NWN2 SINGLE ***/ iVis2 = VFX_HIT_SPELL_INFLICT_4;
                break;
            case SPELL_INFLICT_CRITICAL_WOUNDS:
            case 612:   //SPELLABILITY_BG_INFLICT_CRITICAL_WOUNDS:
                iNumDice = 4;
                iBonus = (spInfo.iCasterLevel>20 ? 20 : spInfo.iCasterLevel);
                //*** NWN2 SINGLE ***/ iVis2 = VFX_HIT_SPELL_INFLICT_5;
                break;
            case SPELL_MASS_INFLICT_LIGHT_WOUNDS:
                //*** NWN2 SINGLE ***/ iVis = VFX_HIT_SPELL_INFLICT_2;
                iVis2 = VFX_IMP_HEALING_M;
                iNumDice = 1;
                iBonus = (spInfo.iCasterLevel>25 ? 25 : spInfo.iCasterLevel);
                break;
            case SPELL_MASS_INFLICT_MODERATE_WOUNDS:
                //*** NWN2 SINGLE ***/ iVis = VFX_HIT_SPELL_INFLICT_3;
                iVis2 = VFX_IMP_HEALING_L;
                iNumDice = 2;
                iBonus = (spInfo.iCasterLevel>30 ? 30 : spInfo.iCasterLevel);
                break;
            case SPELL_MASS_INFLICT_SERIOUS_WOUNDS:
                //*** NWN2 SINGLE ***/ iVis = VFX_HIT_SPELL_INFLICT_4;
                iNumDice = 3;
                iBonus = (spInfo.iCasterLevel>35 ? 35 : spInfo.iCasterLevel);
                break;
            case SPELL_MASS_INFLICT_CRITICAL_WOUNDS:
                //*** NWN2 SINGLE ***/ iVis = VFX_HIT_SPELL_INFLICT_5;\
                iVis2 = VFX_IMP_HEALING_X;
                iNumDice = 4;
                iBonus = (spInfo.iCasterLevel>40 ? 40 : spInfo.iCasterLevel);
                break;
        }

    iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    //*:* effect eVis     = EffectVisualEffect(VFX_IMP_DEATH);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRInflictWounds(iDamage, iBonus, iDieType*iNumDice, iVis, iVis2, spInfo.iSpellID);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
