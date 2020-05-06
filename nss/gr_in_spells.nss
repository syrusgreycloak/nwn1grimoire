//*:**************************************************************************
//*:*  GR_IN_SPELLS.NSS
//*:**************************************************************************
//*:*
//*:* Main base include for spell-related info functions
//*:* Includes new structure for storing spell info and function for transferring
//*:* that info to/from local variables
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2007
//*:**************************************************************************
//*:* Updated On: July 20, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
//#include "X2_I0_SPELLS" - INCLUDED IN GR_IN_LIB

//*:**********************************************
//*:* Constant Libraries
//#include "GR_IC_NAMES" - included in GR_IN_LIB
//#include "GR_IC_SPELLS"   - INCLUDED IN GR_IN_RACIAL
#include "GR_IC_SPELLINFO"      // other spell related constants
#include "GR_IC_DOMAINS"

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_AOE"
#include "GR_IN_EFFECTS"
//#include "GR_IN_LIB" - INCLUDED IN GR_IN_RACIAL & GR_IN_EFFECTS
#include "GR_IN_RACIAL"
#include "GR_IN_STRUCTS"

//*:**************************************************************************
//*:* Constants
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Prototypes
//*:**************************************************************************
//*:* SpellStruct related functions
//*:**************************************************************************
              void GRClearSpellInfo(int iSpellID, object oCaster=OBJECT_SELF, int bWarlock=FALSE);
               int GRGetSpellDamageAmount(struct SpellStruct spSpellInfo, int iSaveInfo = SPELL_SAVE_NONE,
                        object oCaster = OBJECT_SELF, int iSaveType = SAVING_THROW_TYPE_NONE, float fDelay = 0.0f);
             float GRGetSpellDuration(struct SpellStruct spSpellInfo, int iEnergyType = DAMAGE_TYPE_MAGICAL, int iFogSpell = FALSE);
               int GRGetSpellHasSecondaryDamage(struct SpellStruct spSpellInfo);
               int GRGetSpellSubschoolFromSpellId(int iSpellID);
struct SpellStruct GRGetSpellStruct(int iSpellID, object oCaster = OBJECT_SELF);
struct SpellStruct GRGetSpellInfoFromObject(int iSpellID, object oCaster = OBJECT_SELF);
                int GRGetSpellSecDmgAmt(int iDmgAmt, int iDieType, int iNumDice, int iMetamagic, int iBonus, int iAmtType);
                int GRGetSpellSecondaryDamageAmount(int iDmgAmt, struct SpellStruct spSpellInfo, int iSaveInfo = SPELL_SAVE_NONE,
                                    object oCaster = OBJECT_SELF, int iSaveType = SAVING_THROW_TYPE_NONE, float fDelay = 0.0);
struct SpellStruct GRReplaceEnergyType(struct SpellStruct spSpellInfo, int iOldEnergyType, int iNewEnergyType, object oCaster=OBJECT_SELF);
void               GRSetCanCastSpellUnderwater(int iSpellID, int bCanCast, object oCaster = OBJECT_SELF);
struct SpellStruct GRSetSpellDamageChangePercent(struct SpellStruct spSpellInfo, float fPercent = 1.0);
struct SpellStruct GRSetSpellDamageInfo(struct SpellStruct spSpellInfo, int iDieType, int iNumDice = 1, int iBonus = 0, int iOverride = 0);
struct SpellStruct GRSetSpellDurationInfo(struct SpellStruct spSpellInfo, int iAmount, int iType = DUR_TYPE_ROUNDS, float fOverride = 0.0);
              void GRSetSpellInfo(struct SpellStruct spSpellInfo, object oCaster=OBJECT_SELF);
struct SpellStruct GRSetSpellSecondaryDamageInfo(struct SpellStruct spSpellInfo, int iSecDmgType, int iSecDamageAmount, int iSecDamageOverride = 0);
int         GRGetSpellSlotLevel(int iSpellLevel, int iMetamagic);
int GRGetSpellDmgSaveMade(int iSpellID, object oCaster=OBJECT_SELF);
void GRSetSpellXPCost(int iSpellID, int iXPCost, object oCaster=OBJECT_SELF);
void GRSetSpellIsEpic(int iSpellID, int bEpicSpell, object oCaster=OBJECT_SELF);
void GRSetSpellEpicSpellCraftDC(int iSpellID, int iEpicSpellcraftDC, object oCaster=OBJECT_SELF);
//*:**************************************************************************
//*:* Caster related spell functions
//*:**************************************************************************
int     GRGetCasterLevel(object oCaster=OBJECT_SELF, int iCastingClass=CLASS_TYPE_INVALID);
int     GRGetHasDomain(int iDomainToCheck, object oCreature = OBJECT_SELF);

//*:**************************************************************************
//*:* Spell related functions
//*:**************************************************************************
int     GRGetIsEnergyDescriptor(int iDescriptor);
int     GRGetIsHealingSpell(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetIsPlayerSpell(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetIsSpellTurnable(int iSpellID, object oCaster=OBJECT_INVALID);
int     GRGetLastSpellCastClass(object oCaster=OBJECT_SELF);
int     GRGetMetamagicAdjustedDamage(int iDieType, int iNumDice = 1, int iMetamagic = 0, int iBonus = 0);
int     GRGetMetamagicFeat();
int     GRGetMetamagicUsed(int iMetamagic, int iMetamagicType);
int     GRGetReflexAdjustedDamage(int iDamage, object oTarget, int iDC, int iSaveType = SAVING_THROW_TYPE_NONE,
            object oSaveVersus = OBJECT_SELF);
int GRGetSaveResult(int iSavingThrow, object oTarget, int iDC, int iSaveType = SAVING_THROW_TYPE_NONE,
    object oSaveVersus = OBJECT_SELF, float fDelay = 0.0f, int bNoMagic = FALSE, int bRevertFalseOnResist = TRUE, int bBrother = FALSE);
int     GRGetSpellCastClass(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetSpellCasterLevel(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetSpellDescriptor(int iSpellID, object oCaster=OBJECT_SELF, int iPosition = 1);
object  GRGetSpellEffectCreator(object oTarget, int iSpellID);
int     GRGetSpellEnergyDamageType(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetSpellEnergyType(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetSpellEnergyTypePosition(int iSpellID, int iEnergyType, object oCaster=OBJECT_SELF);
int     GRGetSpellHasDescriptor(int iSpellID, int iSpellType, object oCaster=OBJECT_SELF);
int     GRGetSpellLevel(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetSpellLevelBy2da(object oCaster, int iSpellCastClass, int iSpellID);
int     GRGetSpellMetamagic(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetSpellRequiresConcentration(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetSpellSaveDC(object oCaster, object oTarget);
int     GRGetSpellSchool(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetSpellSlotLevel(int iSpellLevel, int iMetamagic);
int     GRGetSpellSubschool(int iSpellID, object oCaster=OBJECT_SELF);
void    GRSetKilledByDeathEffect(object oTarget, object oCaster=OBJECT_SELF);
void    GRSetIsPlayerSpell(int iSpellID, int bPlayerSpell, object oCaster=OBJECT_SELF);
void    GRSetIsSpellTurnable(int iSpellID, int bTurnable, object oCaster=OBJECT_SELF);
void    GRSetSpellCasterLevel(int iSpellID, int iCasterLevel, object oCaster=OBJECT_SELF);
void    GRSetSpellCastClass(int iSpellID, int iSpellCastClass, object oCaster=OBJECT_SELF);
void    GRSetSpellDescriptor(int iSpellID, int iSpellType, object oCaster=OBJECT_SELF, int iPosition = 1);
void    GRSetSpellDmgBonus(int iSpellID, int iDmgBonus, object oCaster=OBJECT_SELF);
void    GRSetSpellDmgChangePct(int iSpellID, float fDmgChangePct, object oCaster=OBJECT_SELF);
void    GRSetSpellDmgDieType(int iSpellID, int iDmgDieType, object oCaster=OBJECT_SELF);
void    GRSetSpellDmgNumDice(int iSpellID, int iDmgNumDice, object oCaster=OBJECT_SELF);
void    GRSetSpellDmgOverride(int iSpellID, int iDmgOverride, object oCaster=OBJECT_SELF);
void    GRSetSpellDurAmount(int iSpellID, int iDurAmount, object oCaster=OBJECT_SELF);
void    GRSetSpellDurOverride(int iSpellID, float fDurOverride, object oCaster=OBJECT_SELF);
void    GRSetSpellDurType(int iSpellID, int iDurType, object oCaster=OBJECT_SELF);
void    GRSetSpellLevel(int iSpellID, int iSpellLevel, object oCaster=OBJECT_SELF);
void    GRSetSpellMetamagic(int iSpellID, int iMetamagic, object oCaster=OBJECT_SELF);
void    GRSetSpellRequiresConcentration(int iSpellID, int iRequiresConcentration, object oCaster=OBJECT_SELF);
void    GRSetSpellSchool(int iSpellID, int iSchoolType=SPELL_SCHOOL_GENERAL, object oCaster=OBJECT_SELF);
void    GRSetSpellSubschool(int iSpellID, int iSubschoolType=SPELL_SUBSCHOOL_GENERAL, object oCaster=OBJECT_SELF);
void    GRSetSpellTarget(int iSpellID, object oTarget, object oCaster=OBJECT_SELF);
void    GRSetSpellLocation(int iSpellID, location lTarget, object oCaster=OBJECT_SELF);
void    GRSetSpellDC(int iSpellID, int iDC, object oCaster=OBJECT_SELF);
void    GRSetSpellSecDmgAmountType(int iSpellID, int iSecDmgAmountType, object oCaster=OBJECT_SELF);
void    GRSetSpellSecDmgOverride(int iSpellID, int iSecDmgOverride, object oCaster=OBJECT_SELF);
void    GRSetSpellSecDmgType(int iSpellID, int iSecDmgType, object oCaster=OBJECT_SELF);
void    GRSetSpellDmgSaveMade(int iSpellID, int bDmgSaveMade, object oCaster=OBJECT_SELF);
object GRCheckMisdirection(object oTarget, object oCaster = OBJECT_SELF);
void GRDoIncendiarySlimeExplosion(object oTarget);
int     GRSpellHasVerbalComponent(int iSpellID);
int     GRSpellHasSomaticComponent(int iSpellID);

void    GRRemoveSpellSubschoolEffects(int iSubschool, object oTarget, object oCaster = OBJECT_INVALID);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************
//*:* SpellStruct related functions
//*:**************************************************************************

//*:**********************************************
//*:* GRClearSpellInfo
//*:**********************************************
//*:*
//*:* Removes spell school and descriptor info from
//*:* the caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
void GRClearSpellInfo(int iSpellID, object oCaster=OBJECT_SELF, int bWarlock=FALSE) {

    int i;
    string sSpellID = IntToString(iSpellID);

    if(GetIsObjectValid(oCaster)) {
        for(i=1; i<=3; i++) {
            DeleteLocalInt(oCaster,"GR_"+sSpellID+"_DESCRIPTOR_"+IntToString(i));
        }
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_SCHOOL");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_SUBSCHOOL");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_UNDERWATER");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_TURNABLE");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_PLAYERSPELL");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_SPELLLEVEL");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_CASTCLASS");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_REQCONCENTRATION");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_CASTERLEVEL");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_METAMAGIC");
        DeleteLocalObject(oCaster,"GR_"+sSpellID+"_TARGET");
        DeleteLocalLocation(oCaster,"GR_"+sSpellID+"_LOCATION");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_DC");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_DURAMOUNT");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_DURTYPE");
        DeleteLocalFloat(oCaster,"GR_"+sSpellID+"_DUROVERRIDE");
        DeleteLocalFloat(oCaster,"GR_"+sSpellID+"_DMGCHANGEPCT");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_DMGDIETYPE");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_DMGNUMDICE");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_DMGBONUS");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_DMGOVERRIDE");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_SECDMGTYPE");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_SECDMGAMTTYPE");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_SECDMGOVERRIDE");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_XPCOST");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_ISEPICSPELL");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_EPICSPELLCRAFTDC");
        DeleteLocalInt(oCaster,"GR_"+sSpellID+"_DMGSAVEMADE");
        if(bWarlock) {
            DeleteLocalInt(oCaster, "GR_ESSENCE_INV_ID");
            DeleteLocalInt(oCaster, "GR_ESSENCE_INV_LEVEL");
            DeleteLocalInt(oCaster, "GR_ESSENCE_ENERGY_TYPE");
            DeleteLocalInt(oCaster, "GR_BLAST_SHAPE_ID");
            DeleteLocalInt(oCaster, "GR_BLAST_SHAPE_LEVEL");
        }
    }
}

//*:**********************************************
//*:* GRGetSpellDamageAmount
//*:**********************************************
//*:*
//*:* Determines spell damage done by spell.  Takes
//*:* into account metamagic and saving throw, plus
//*:* and percentage change done through scripting
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 14, 2007
//*:**********************************************
int GRGetSpellDamageAmount(struct SpellStruct spSpellInfo, int iSaveInfo = SPELL_SAVE_NONE, object oCaster = OBJECT_SELF, int iSaveType = SAVING_THROW_TYPE_NONE, float fDelay = 0.0f) {
    int iDamage = 0;
    int iSavingThrow;
    int bNegates = FALSE;
    int bSaveMade = FALSE;

    switch(iSaveInfo) {
        case FORTITUDE_NEGATES:
            bNegates = TRUE;
        case FORTITUDE_HALF:
            iSavingThrow = SAVING_THROW_FORT;
            break;
        case WILL_NEGATES:
            bNegates = TRUE;
        case WILL_HALF:
            iSavingThrow = SAVING_THROW_WILL;
            break;
        case REFLEX_NEGATES:
            bNegates = TRUE;
        case REFLEX_HALF:
            iSavingThrow = SAVING_THROW_REFLEX;
            break;
    }

    if(spSpellInfo.iDmgOverride>0) {
        iDamage = spSpellInfo.iDmgOverride;
    } else {
        iDamage = GRGetMetamagicAdjustedDamage(spSpellInfo.iDmgDieType, spSpellInfo.iDmgNumDice, spSpellInfo.iMetamagic, spSpellInfo.iDmgBonus);
    }

    if(iSaveInfo==REFLEX_HALF) {
        int iNewDamage = GRGetReflexAdjustedDamage(iDamage, spSpellInfo.oTarget, spSpellInfo.iDC, iSaveType, oCaster);
        int bHasEvasion = GetHasFeat(FEAT_EVASION, spSpellInfo.oTarget);
        int bHasImprovedEvasion = GetHasFeat(FEAT_IMPROVED_EVASION, spSpellInfo.oTarget);

        if(iNewDamage!=iDamage) {
            if(!bHasEvasion && !bHasImprovedEvasion) {
                bSaveMade = TRUE;
            } else if(iNewDamage==0) {
                bSaveMade = TRUE;
            }
        }
        iDamage = iNewDamage;
    } else if(iSaveInfo!=SPELL_SAVE_NONE) {
        int iSaveResult = GRGetSaveResult(iSavingThrow, spSpellInfo.oTarget, spSpellInfo.iDC, iSaveType, oCaster, fDelay);
        if(iSaveResult>0) {
            bSaveMade = TRUE;
            if(bNegates) {
                iDamage = 0;
            } else {
                iDamage /= 2;
            }
        }
    }

    GRSetSpellDmgSaveMade(spSpellInfo.iSpellID, bSaveMade, oCaster);
    iDamage = FloatToInt(iDamage*spSpellInfo.fDmgChangePct);

    return iDamage;
}

//*:**********************************************
//*:* GRGetSpellDuration
//*:**********************************************
//*:*
//*:* Computes the duration for the spell
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 18, 2007
//*:**********************************************
float GRGetSpellDuration(struct SpellStruct spSpellInfo, int iEnergyType = DAMAGE_TYPE_MAGICAL, int iFogSpell = FALSE) {

    float fDuration;

    if(GRGetIsUnderwater(OBJECT_SELF) && (iEnergyType==DAMAGE_TYPE_ACID || iFogSpell==TRUE)) {
        if(spSpellInfo.iDurType!=DUR_TYPE_ROUNDS) {
            spSpellInfo.iDurType--;
        } else {
            spSpellInfo.iDurAmount = 1;
        }
    }

    if(spSpellInfo.fDurOverride>0.0f) {
        fDuration = spSpellInfo.fDurOverride;
    } else {
        fDuration = GRGetDuration(spSpellInfo.iDurAmount, spSpellInfo.iDurType, iEnergyType, iFogSpell);
    }

    return fDuration;
}

//*:**********************************************
//*:* GRGetSpellHasSecondaryDamage
//*:**********************************************
//*:*
//*:* Returns if spell has secondary damage
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 24, 2007
//*:**********************************************
int GRGetSpellHasSecondaryDamage(struct SpellStruct spSpellInfo) {

    return spSpellInfo.iSecDmgAmountType!=SECDMG_TYPE_NONE;
}



int GRGetSpellSubschoolFromSpellId(int iSpellID) {
    return StringToInt(Get2DAString(SPELLS, SPELLS_SUBSCHOOL, iSpellID));
}
//*:**********************************************
//*:* GRGetSpellStruct
//*:**********************************************
//*:*
//*:* Retrieves most of necessary info about spell
//*:* from functions or spells.2da
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
struct SpellStruct GRGetSpellStruct(int iSpellID, object oCaster = OBJECT_SELF) {
    struct SpellStruct spSpellInfo;

    //*:**********************************************
    //*:* Set default values
    //*:**********************************************
    spSpellInfo.oCaster = oCaster;
    spSpellInfo.iSpellSchool = SPELL_SCHOOL_GENERAL;
    spSpellInfo.iSpellSubschool = SPELL_SUBSCHOOL_GENERAL;
    spSpellInfo.iSpellType1 = SPELL_TYPE_GENERAL;
    spSpellInfo.iSpellType2 = SPELL_TYPE_GENERAL;
    spSpellInfo.iSpellType3 = SPELL_TYPE_GENERAL;
    spSpellInfo.iUnderwater = TRUE;
    spSpellInfo.iTurnable = FALSE;
    spSpellInfo.iReqConcentration = FALSE;
    spSpellInfo.oTarget = OBJECT_INVALID;
    spSpellInfo.iDC = -1;
    spSpellInfo.iDurType = DUR_TYPE_ROUNDS;
    spSpellInfo.fDurOverride = 0.0;
    spSpellInfo.fDmgChangePct = 1.0;
    spSpellInfo.iDmgDieType = 0;
    spSpellInfo.iDmgNumDice = 0;
    spSpellInfo.iDmgBonus = 0;
    spSpellInfo.iDmgOverride = 0;
    spSpellInfo.iSecDmgType = DAMAGE_TYPE_MAGICAL;
    spSpellInfo.iSecDmgAmountType = SECDMG_TYPE_NONE;
    spSpellInfo.iSecDmgOverride = 0;
    spSpellInfo.iXPCost = 0;
    spSpellInfo.bEpicSpell = FALSE;
    spSpellInfo.iEpicSpellcraftDC = 0;
    spSpellInfo.bDmgSaveMade = FALSE;
    spSpellInfo.bNWN2 = GetLocalInt(GetModule(), GAME_VERSION_IS_NWN2);

    spSpellInfo.iSpellID = iSpellID;
    spSpellInfo.iSpellSchool = StringToInt(Get2DAString(SPELLS, SPELLS_SCHOOL_INT, spSpellInfo.iSpellID));
    spSpellInfo.iSpellCastClass = GRGetLastSpellCastClass();
    /*** NWN1 SINGLE ***/ spSpellInfo.iSpellLevel = GRGetSpellLevelBy2da(oCaster, spSpellInfo.iSpellCastClass, spSpellInfo.iSpellID);
    //*** NWN2 SINGLE ***/ spSpellInfo.iSpellLevel = GetSpellLevel(spSpellInfo.iSpellID);
    spSpellInfo.iSpellSubschool = StringToInt(Get2DAString(SPELLS, SPELLS_SUBSCHOOL, spSpellInfo.iSpellID));
    spSpellInfo.iSpellType1 = StringToInt(Get2DAString(SPELLS, "Desc1", spSpellInfo.iSpellID));
    spSpellInfo.iSpellType2 = StringToInt(Get2DAString(SPELLS, "Desc2", spSpellInfo.iSpellID));
    spSpellInfo.iSpellType3 = StringToInt(Get2DAString(SPELLS, "Desc3", spSpellInfo.iSpellID));
    spSpellInfo.iTurnable = GRGetIsSpellTurnable(spSpellInfo.iSpellID);
    spSpellInfo.iUnderwater = StringToInt(Get2DAString(SPELLS, "UndWater", spSpellInfo.iSpellID));
    spSpellInfo.iPlayerSpell = (StringToInt(Get2DAString(SPELLS,"UserType", spSpellInfo.iSpellID))==1);
    spSpellInfo.iReqConcentration = StringToInt(Get2DAString(SPELLS, "ReqConcen", spSpellInfo.iSpellID));
    spSpellInfo.iXPCost = StringToInt(Get2DAString(SPELLS, "XPCost", spSpellInfo.iSpellID));
    GRSetSpellInfo(spSpellInfo, oCaster);

    spSpellInfo.iCasterLevel = GRGetCasterLevel(oCaster);
    spSpellInfo.iDurAmount = spSpellInfo.iCasterLevel;
    spSpellInfo.iMetamagic = GRGetMetamagicFeat();
    spSpellInfo.oTarget = GetSpellTargetObject();
    if(GetIsObjectValid(spSpellInfo.oTarget)) {
        spSpellInfo.iDC = GRGetSpellSaveDC(oCaster, spSpellInfo.oTarget);
    }
    spSpellInfo.lTarget = GetSpellTargetLocation();

    if(GetLocalInt(oCaster, HAS_SPELL_REFLECTION)) {
        spSpellInfo.oCaster = GetLocalObject(oCaster, SPELL_REFLECTION + "_CASTER");
        spSpellInfo.iCasterLevel = GetLocalInt(oCaster, SPELL_REFLECTION + "_CLVL");
        spSpellInfo.iMetamagic = GetLocalInt(oCaster, SPELL_REFLECTION + "_MM");
        spSpellInfo.iDC = GetLocalInt(oCaster, SPELL_REFLECTION + "_DC");
        spSpellInfo.fDmgChangePct = GetLocalFloat(oCaster, SPELL_REFLECTION + "_DMGPCT");
    }

    return spSpellInfo;
}

//*:**********************************************
//*:* GRGetSpellInfoFromObject
//*:**********************************************
//*:*
//*:* Retrieves previously saved spell info from
//*:* the specified object
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
struct SpellStruct GRGetSpellInfoFromObject(int iSpellID, object oCaster = OBJECT_SELF) {

    struct SpellStruct spSpellInfo;
    string sSpellID = IntToString(iSpellID);

    spSpellInfo.iSpellID = iSpellID;
    spSpellInfo.iSpellCastClass = GetLocalInt(oCaster, "GR_"+sSpellID+"_CASTCLASS");
    spSpellInfo.iSpellLevel = GetLocalInt(oCaster, "GR_"+sSpellID+"_SPELLLEVEL");
    spSpellInfo.iSpellSchool = GetLocalInt(oCaster, "GR_"+sSpellID+"_SCHOOL");
    spSpellInfo.iSpellSubschool = GetLocalInt(oCaster, "GR_"+sSpellID+"_SUBSCHOOL");
    spSpellInfo.iSpellType1 = GetLocalInt(oCaster, "GR_"+sSpellID+"_DESCRIPTOR_1");
    spSpellInfo.iSpellType2 = GetLocalInt(oCaster, "GR_"+sSpellID+"_DESCRIPTOR_2");
    spSpellInfo.iSpellType3 = GetLocalInt(oCaster, "GR_"+sSpellID+"_DESCRIPTOR_3");
    spSpellInfo.iTurnable = GetLocalInt(oCaster, "GR_"+sSpellID+"_TURNABLE");
    spSpellInfo.iUnderwater = GetLocalInt(oCaster, "GR_"+sSpellID+"_UNDERWATER");
    spSpellInfo.iPlayerSpell = GetLocalInt(oCaster, "GR_"+sSpellID+"_PLAYERSPELL");
    spSpellInfo.iReqConcentration = GetLocalInt(oCaster, "GR_"+sSpellID+"_REQCONCENTRATION");
    spSpellInfo.iCasterLevel = GetLocalInt(oCaster, "GR_"+sSpellID+"_CASTERLEVEL");
    spSpellInfo.iMetamagic = GetLocalInt(oCaster, "GR_"+sSpellID+"_METAMAGIC");
    spSpellInfo.oTarget = GetLocalObject(oCaster, "GR_"+sSpellID+"_TARGET");
    spSpellInfo.lTarget = GetLocalLocation(oCaster, "GR_"+sSpellID+"_LOCATION");
    spSpellInfo.iDC = GetLocalInt(oCaster, "GR_"+sSpellID+"_DC");
    spSpellInfo.iDurAmount = GetLocalInt(oCaster, "GR_"+sSpellID+"_DURAMOUNT");
    spSpellInfo.iDurType = GetLocalInt(oCaster, "GR_"+sSpellID+"_DURTYPE");
    spSpellInfo.fDurOverride = GetLocalFloat(oCaster, "GR_"+sSpellID+"_DUROVERRIDE");
    spSpellInfo.fDmgChangePct = GetLocalFloat(oCaster, "GR_"+sSpellID+"_DMGCHANGEPCT");
    spSpellInfo.iDmgDieType = GetLocalInt(oCaster, "GR_"+sSpellID+"_DMGDIETYPE");
    spSpellInfo.iDmgNumDice = GetLocalInt(oCaster, "GR_"+sSpellID+"_DMGNUMDICE");
    spSpellInfo.iDmgBonus = GetLocalInt(oCaster, "GR_"+sSpellID+"_DMGBONUS");
    spSpellInfo.iDmgOverride = GetLocalInt(oCaster, "GR_"+sSpellID+"_DMGOVERRIDE");
    spSpellInfo.iSecDmgType = GetLocalInt(oCaster,"GR_"+sSpellID+"_SECDMGTYPE");
    spSpellInfo.iSecDmgAmountType = GetLocalInt(oCaster,"GR_"+sSpellID+"_SECDMGAMTTYPE");
    spSpellInfo.iSecDmgOverride = GetLocalInt(oCaster,"GR_"+sSpellID+"_SECDMGOVERRIDE");
    spSpellInfo.iXPCost = GetLocalInt(oCaster,"GR_"+sSpellID+"_XPCOST");
    spSpellInfo.bEpicSpell = GetLocalInt(oCaster,"GR_"+sSpellID+"_ISEPICSPELL");
    spSpellInfo.iEpicSpellcraftDC = GetLocalInt(oCaster,"GR_"+sSpellID+"_EPICSPELLCRAFTDC");
    spSpellInfo.bDmgSaveMade = GetLocalInt(oCaster,"GR_"+sSpellID+"_DMGSAVEMADE");

    return spSpellInfo;
}

int GRGetSpellSecDmgAmt(int iDmgAmt, int iDieType, int iNumDice, int iMetamagic, int iBonus, int iAmtType) {

    switch(iAmtType) {
        case SECDMG_TYPE_NONE:
            iDmgAmt = 0;
            break;
        case SECDMG_TYPE_HALF:
            iDmgAmt /= 2;
            break;
        case SECDMG_TYPE_EQUAL:
            iDmgAmt = iDmgAmt;
            break;
        case SECDMG_TYPE_DICE:
            iDmgAmt = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, iMetamagic, iBonus);
            break;
    }

    return iDmgAmt;
}


//*:**********************************************
//*:* GRGetSpellSecondaryDamageAmount
//*:**********************************************
//*:*
//*:* Gets spell secondary damage amount.  To be used
//*:* for Energy Admixture feats, or (possibly)
//*:* special powers like Dragonlance Order of Black
//*:* Robes Magic of Darkness secret.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 24, 2007
//*:**********************************************
int GRGetSpellSecondaryDamageAmount(int iDmgAmt, struct SpellStruct spSpellInfo, int iSaveInfo = SPELL_SAVE_NONE, object oCaster = OBJECT_SELF,
                                    int iSaveType = SAVING_THROW_TYPE_NONE, float fDelay = 0.0) {

    int bPriorSaveMade = GRGetSpellDmgSaveMade(spSpellInfo.iSpellID, oCaster);

    switch(spSpellInfo.iSecDmgAmountType) {
        case SECDMG_TYPE_NONE:
            iDmgAmt = 0;
            break;
        case SECDMG_TYPE_HALF:
            iDmgAmt /= 2;
            break;
        case SECDMG_TYPE_EQUAL:
            iDmgAmt = iDmgAmt;
            break;
        case SECDMG_TYPE_DICE:
            iDmgAmt = GRGetMetamagicAdjustedDamage(spSpellInfo.iDmgDieType, spSpellInfo.iDmgNumDice, spSpellInfo.iMetamagic, spSpellInfo.iDmgBonus);
            if(bPriorSaveMade) {
                switch(iSaveInfo) {
                    case FORTITUDE_NEGATES:
                    case WILL_NEGATES:
                    case REFLEX_NEGATES:
                        iDmgAmt = 0;
                        break;
                    case FORTITUDE_HALF:
                    case WILL_HALF:
                        iDmgAmt /= 2;
                        break;
                    case REFLEX_HALF:
                        if(GetHasFeat(FEAT_EVASION, spSpellInfo.oTarget) || GetHasFeat(FEAT_IMPROVED_EVASION, spSpellInfo.oTarget)) {
                            //*:**********************************************
                            //*:* Armor check - Chain Shirt is Light
                            //*:* Hide is Medium
                            //*:**********************************************
                            object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, spSpellInfo.oTarget);
                            int iArmorType = GRGetArmorType(oArmor);
                            string sArmorName = GetName(oArmor);
                            int bPassArmorCheck = FALSE;
                            if( (iArmorType<=3 && GetStringUpperCase(GetStringLeft(sArmorName, 4))!="HIDE") ||          // all light armors not including chain shirt
                                (iArmorType>3 && GetStringUpperCase(GetStringLeft(sArmorName,11))=="CHAIN SHIRT")) {    // try to catch chain shirt
                                bPassArmorCheck = TRUE;
                            }
                            //*:**********************************************
                            //*:* Weight check
                            //*:**********************************************
                            int bPassWeightCheck = !GRGetHasMediumOrGreaterLoad(spSpellInfo.oTarget);
                            if(bPassArmorCheck && bPassWeightCheck) {
                                iDmgAmt = 0;
                            }
                        }
                        break;
                }
            } else if(iSaveInfo==REFLEX_HALF && GetHasFeat(FEAT_IMPROVED_EVASION, spSpellInfo.oTarget)) {
                //*:**********************************************
                //*:* Armor check - Chain Shirt is Light
                //*:* Hide is Medium
                //*:**********************************************
                object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, spSpellInfo.oTarget);
                int iArmorType = GRGetArmorType(oArmor);
                string sArmorName = GetName(oArmor);
                int bPassArmorCheck = FALSE;
                if( (iArmorType<=3 && GetStringUpperCase(GetStringLeft(sArmorName, 4))!="HIDE") ||          // all light armors not including chain shirt
                    (iArmorType>3 && GetStringUpperCase(GetStringLeft(sArmorName,11))=="CHAIN SHIRT")) {    // try to catch chain shirt
                    bPassArmorCheck = TRUE;
                }
                //*:**********************************************
                //*:* Weight check
                //*:**********************************************
                int bPassWeightCheck = !GRGetHasMediumOrGreaterLoad(spSpellInfo.oTarget);
                if(bPassArmorCheck && bPassWeightCheck) {
                    iDmgAmt /= 2;
                }
            }
            break;
        case SECDMG_TYPE_OVERRIDE:
            iDmgAmt = spSpellInfo.iSecDmgOverride;
            break;
    }

    return iDmgAmt;
}

//*:**********************************************
//*:* GRReplaceEnergyType
//*:**********************************************
//*:*
//*:* Replaces the energy type of the spell. Used
//*:* by the Energy Substitution feats
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**********************************************
struct SpellStruct GRReplaceEnergyType(struct SpellStruct spSpellInfo, int iOldEnergyType, int iNewEnergyType, object oCaster=OBJECT_SELF) {

    int iPosition = GRGetSpellEnergyTypePosition(spSpellInfo.iSpellID, iOldEnergyType, oCaster);

    if(iPosition>0) {
        switch(iPosition) {
            case 1:
                spSpellInfo.iSpellType1 = iNewEnergyType;
                break;
            case 2:
                spSpellInfo.iSpellType2 = iNewEnergyType;
                break;
            case 3:
                spSpellInfo.iSpellType3 = iNewEnergyType;
                break;
        }
        GRSetSpellDescriptor(spSpellInfo.iSpellID, iNewEnergyType, oCaster, iPosition);
    }

    return spSpellInfo;
}

//*:**********************************************
//*:* GRSetCanCastSpellUnderwater
//*:**********************************************
//*:*
//*:* Sets if spell can be cast underwater
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2007
//*:**********************************************
//*:* Updated On:
//*:**********************************************
void GRSetCanCastSpellUnderwater(int iSpellID, int bCanCast, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_UNDERWATER", bCanCast);
}

//*:**********************************************
//*:* GRSetSpellInfo
//*:**********************************************
//*:*
//*:* Saves a SpellStruct's values to locals on
//*:* the specified object
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
void GRSetSpellInfo(struct SpellStruct spSpellInfo, object oCaster=OBJECT_SELF) {

    GRSetSpellDescriptor(spSpellInfo.iSpellID, spSpellInfo.iSpellType1, oCaster, 1);
    GRSetSpellDescriptor(spSpellInfo.iSpellID, spSpellInfo.iSpellType2, oCaster, 2);
    GRSetSpellDescriptor(spSpellInfo.iSpellID, spSpellInfo.iSpellType3, oCaster, 3);
    GRSetSpellSubschool(spSpellInfo.iSpellID, spSpellInfo.iSpellSubschool, oCaster);
    GRSetSpellSchool(spSpellInfo.iSpellID, spSpellInfo.iSpellSchool, oCaster);
    GRSetCanCastSpellUnderwater(spSpellInfo.iSpellID, spSpellInfo.iUnderwater, oCaster);
    GRSetIsSpellTurnable(spSpellInfo.iSpellID, spSpellInfo.iTurnable, oCaster);
    GRSetIsPlayerSpell(spSpellInfo.iSpellID, spSpellInfo.iPlayerSpell, oCaster);
    GRSetSpellLevel(spSpellInfo.iSpellID, spSpellInfo.iSpellLevel, oCaster);
    GRSetSpellCastClass(spSpellInfo.iSpellID, spSpellInfo.iSpellCastClass, oCaster);
    GRSetSpellRequiresConcentration(spSpellInfo.iSpellID, spSpellInfo.iReqConcentration, oCaster);
    GRSetSpellCasterLevel(spSpellInfo.iSpellID, spSpellInfo.iCasterLevel, oCaster);
    GRSetSpellMetamagic(spSpellInfo.iSpellID, spSpellInfo.iMetamagic, oCaster);
    GRSetSpellTarget(spSpellInfo.iSpellID, spSpellInfo.oTarget, oCaster);
    GRSetSpellLocation(spSpellInfo.iSpellID, spSpellInfo.lTarget, oCaster);
    GRSetSpellDC(spSpellInfo.iSpellID, spSpellInfo.iDC, oCaster);
    GRSetSpellDurAmount(spSpellInfo.iSpellID, spSpellInfo.iDurAmount, oCaster);
    GRSetSpellDurType(spSpellInfo.iSpellID, spSpellInfo.iDurType, oCaster);
    GRSetSpellDurOverride(spSpellInfo.iSpellID, spSpellInfo.fDurOverride, oCaster);
    GRSetSpellDmgChangePct(spSpellInfo.iSpellID, spSpellInfo.fDmgChangePct, oCaster);
    GRSetSpellDmgDieType(spSpellInfo.iSpellID, spSpellInfo.iDmgDieType, oCaster);
    GRSetSpellDmgNumDice(spSpellInfo.iSpellID, spSpellInfo.iDmgNumDice, oCaster);
    GRSetSpellDmgBonus(spSpellInfo.iSpellID, spSpellInfo.iDmgBonus, oCaster);
    GRSetSpellDmgOverride(spSpellInfo.iSpellID, spSpellInfo.iDmgOverride, oCaster);
    GRSetSpellSecDmgType(spSpellInfo.iSpellID, spSpellInfo.iSecDmgType, oCaster);
    GRSetSpellSecDmgAmountType(spSpellInfo.iSpellID, spSpellInfo.iSecDmgAmountType, oCaster);
    GRSetSpellSecDmgOverride(spSpellInfo.iSpellID, spSpellInfo.iSecDmgOverride, oCaster);
    GRSetSpellXPCost(spSpellInfo.iSpellID, spSpellInfo.iXPCost, oCaster);
    GRSetSpellIsEpic(spSpellInfo.iSpellID, spSpellInfo.bEpicSpell, oCaster);
    GRSetSpellEpicSpellCraftDC(spSpellInfo.iSpellID, spSpellInfo.iEpicSpellcraftDC, oCaster);
    GRSetSpellDmgSaveMade(spSpellInfo.iSpellID, spSpellInfo.bDmgSaveMade, oCaster);

}

struct SpellStruct GRSetSpellDamageInfo(struct SpellStruct spSpellInfo, int iDieType, int iNumDice = 1, int iBonus = 0, int iOverride = 0) {

    spSpellInfo.iDmgDieType = iDieType;
    spSpellInfo.iDmgNumDice = iNumDice;
    spSpellInfo.iDmgBonus = iBonus;
    spSpellInfo.iDmgOverride = iOverride;

    return spSpellInfo;
}


struct SpellStruct GRSetSpellDurationInfo(struct SpellStruct spSpellInfo, int iAmount, int iType = DUR_TYPE_ROUNDS, float fOverride = 0.0) {

    GRSetSpellDurAmount(spSpellInfo.iSpellID, iAmount, spSpellInfo.oCaster);
    GRSetSpellDurType(spSpellInfo.iSpellID, iType, spSpellInfo.oCaster);
    GRSetSpellDurOverride(spSpellInfo.iSpellID, fOverride, spSpellInfo.oCaster);
    spSpellInfo.iDurAmount = iAmount;
    spSpellInfo.iDurType = iType;
    spSpellInfo.fDurOverride = fOverride;

    return spSpellInfo;
}


//*:**********************************************
//*:* GRSetSpellSecondaryDamageInfo
//*:**********************************************
//*:*
//*:* Set Secondary Damage Info in the SpellStruct
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 24, 2007
//*:**********************************************
struct SpellStruct GRSetSpellSecondaryDamageInfo(struct SpellStruct spSpellInfo, int iSecDmgType, int iSecDamageAmount, int iSecDamageOverride = 0) {

    spSpellInfo.iSecDmgType = iSecDmgType;
    spSpellInfo.iSecDmgAmountType = iSecDamageAmount;
    spSpellInfo.iSecDmgOverride = iSecDamageOverride;

    return spSpellInfo;
}


//*:**************************************************************************
//*:* Caster related spell functions
//*:**************************************************************************

//*:**********************************************
//*:* GRGetCasterLevel
//*:*   (formerly SGGetCasterLevel)
//*:**********************************************
//*:*
//*:* Gets caster level, checking for domain increases
//*:* or making other caster level changes necessary
//*:*
//*:* Domains that receive caster level increases are:
//*:*     Chaos (+1 to chaos spells)
//*:*     Evil (+1 to evil spells)
//*:*     Good (+1 to good spells)
//*:*     Healing (+1 to healing spells)
//*:*     Knowledge (+1 to divination spells)
//*:*     Law (+1 to law spells)
//*:*     Gnome (+1 to illusion spells)
//*:*     Illusion (+1 to illusion spells)
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetCasterLevel(object oCaster=OBJECT_SELF, int iCastingClass=CLASS_TYPE_INVALID) {

    int iCasterLevel=10;
    int i;
    int iTmp;
    iCastingClass = (iCastingClass==CLASS_TYPE_INVALID ? GetLastSpellCastClass() : iCastingClass);
    int iSpellID = GetSpellId();

    if(GetIsObjectValid(oCaster)) {
        //*:**********************************************
        //*:*  3/7/06 - Added code for AOE objects
        //*:**********************************************
        if(GetObjectType(oCaster)==OBJECT_TYPE_CREATURE) {
            iCasterLevel = (iCastingClass==CLASS_TYPE_BLACKGUARD ? GRGetLevelByClass(iCastingClass, oCaster) : GetCasterLevel(oCaster));
            if(GetLocalInt(oCaster, SPELLTURN_CASTER_LEVEL)>0) {
                iCasterLevel = GetLocalInt(oCaster, SPELLTURN_CASTER_LEVEL);
            }
            //*:**********************************************
            //*:* Blackguard
            //*:**********************************************
            else if(iCastingClass==CLASS_TYPE_BLACKGUARD) {
                //*:**********************************************
                //*:* Infernal Threnody - +2 caster levels if evil
                //*:* aligned
                //*:**********************************************
                if(GetAlignmentGoodEvil(oCaster)==ALIGNMENT_EVIL && GetHasSpellEffect(SPELL_GR_INFERNAL_THRENODY, oCaster)) {
                    iCasterLevel += 2;
                }
            }
            //*:**********************************************
            //*:* Cleric domain level & spell effect changes
            //*:**********************************************
            else if(iCastingClass==CLASS_TYPE_CLERIC) {
                //*:**********************************************
                //*:* Chaos Domain - +1 caster level for Chaotic spells
                //*:* +3 caster levels with Improved Alignment-Based Casting (Chaos)
                //*:**********************************************
                if(GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_CHAOTIC, oCaster)) {
                    if(GetHasFeat(FEAT_GR_IMPROVED_ALIGN_CASTING_CHAOS, oCaster)) {
                        iCasterLevel += 3;
                    } else if(GRGetHasDomain(DOMAIN_CHAOS, oCaster)) {
                        iCasterLevel++;
                    }
                //*:**********************************************
                //*:* Evil Domain - +1 caster level for Evil spells
                //*:* +3 caster levels with Improved Alignment-Based Casting (Evil)
                //*:**********************************************
                } else if(GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_EVIL, oCaster)) {
                    if(GetHasFeat(FEAT_GR_IMPROVED_ALIGN_CASTING_EVIL, oCaster)) {
                        iCasterLevel += 3;
                    } else if(GRGetHasDomain(DOMAIN_EVIL,oCaster)) {
                        iCasterLevel++;
                    }
                //*:**********************************************
                //*:* Good Domain - +1 caster level for Good Spells
                //*:* +3 caster levels with Improved Alignment-Based Casting (Good)
                //*:**********************************************
                } else if(GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_GOOD, oCaster)) {
                    if(GetHasFeat(FEAT_GR_IMPROVED_ALIGN_CASTING_GOOD, oCaster)) {
                        iCasterLevel += 3;
                    } else if(GRGetHasDomain(DOMAIN_GOOD,oCaster)) {
                        iCasterLevel++;
                    }
                //*:**********************************************
                //*:* Healing Domain - +1 caster level for (Healing) spells
                //*:**********************************************
                } else if(GRGetHasDomain(DOMAIN_HEALING,oCaster) && GRGetSpellSubschool(iSpellID, oCaster)==SPELL_SUBSCHOOL_HEALING) {
                    if(!GetIsObjectValid(GetSpellCastItem())) {  // make sure we're not getting bonus for item use
                        iCasterLevel++;
                    }
                //*:**********************************************
                //*:* Knowledge Domain - +1 caster level for Divination spells
                //*:**********************************************
                } else if(GRGetHasDomain(DOMAIN_KNOWLEDGE, oCaster) && GRGetSpellSchool(iSpellID, oCaster)==SPELL_SCHOOL_DIVINATION) {
                    iCasterLevel++;
                //*:**********************************************
                //*:* Law Domain - +1 caster level for Lawful spells
                //*:* +3 caster levels with Improved Alignment-Based Casting (Law)
                //*:**********************************************
                } else if(GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_LAWFUL, oCaster)) {
                    if(GetHasFeat(FEAT_GR_IMPROVED_ALIGN_CASTING_LAW, oCaster)) {
                        iCasterLevel += 3;
                    } else if(GRGetHasDomain(DOMAIN_LAW, oCaster)) {
                        iCasterLevel++;
                    }
                }
                //*:**********************************************
                //*:* Illusion Domain - +1 caster level for Illusion spells
                //*:* Gnome Domain not Implemented yet - +1 caster level for Illusion spells
                //*:**********************************************
                else if(/*(GRGetHasDomain(DOMAIN_GNOME, oCaster) ||*/ GRGetHasDomain(DOMAIN_ILLUSION, oCaster)/*)*/ &&
                    GRGetSpellSchool(iSpellID, oCaster)==SPELL_SCHOOL_ILLUSION) {
                        iCasterLevel++;
                //*:**********************************************
                //*:* Summoner Domain - +2 caster levels for Conjuration
                //*:* (Calling) and Conjuration (Summoning) spells
                //*:**********************************************
                } else if(GRGetHasDomain(DOMAIN_SUMMONER, oCaster) && GRGetSpellSchool(iSpellID, oCaster)==SPELL_SCHOOL_CONJURATION &&
                    (GRGetSpellSubschool(iSpellID, oCaster)==SPELL_SUBSCHOOL_CALLING || GRGetSpellSubschool(iSpellID, oCaster)==SPELL_SUBSCHOOL_SUMMONING)) {
                        iCasterLevel += 2;
                }
                //*:**********************************************
                //*:* Hymn of Praise - +2 caster levels if good
                //*:* aligned
                //*:**********************************************
                if(GetAlignmentGoodEvil(oCaster)==ALIGNMENT_GOOD && GetHasSpellEffect(SPELL_GR_HYMN_OF_PRAISE, oCaster)) {
                    iCasterLevel += 2;
                }
                //*:**********************************************
                //*:* Infernal Threnody - +2 caster levels if evil
                //*:* aligned
                //*:**********************************************
                if(GetAlignmentGoodEvil(oCaster)==ALIGNMENT_EVIL && GetHasSpellEffect(SPELL_GR_INFERNAL_THRENODY, oCaster)) {
                    iCasterLevel += 2;
                }
            //*:**********************************************
            //*:* Class fixes for Paladins/Rangers
            //*:* caster level is HALF of CLASS level - see PHB
            //*:**********************************************
            } else if(iCastingClass==CLASS_TYPE_PALADIN || iCastingClass==CLASS_TYPE_RANGER) {
                iCasterLevel = MaxInt(1, GRGetLevelByClass(iCastingClass, oCaster)/2);
                //*:**********************************************
                //*:* Hymn of Praise - +2 caster levels if good
                //*:* aligned
                //*:**********************************************
                if(GetAlignmentGoodEvil(oCaster)==ALIGNMENT_GOOD && GetHasSpellEffect(SPELL_GR_HYMN_OF_PRAISE, oCaster)) {
                    iCasterLevel += 2;
                }
                //*:**********************************************
                //*:* Infernal Threnody - +2 caster levels if evil
                //*:* aligned (Rangers only as Paladins aren't evil)
                //*:**********************************************
                if(GetAlignmentGoodEvil(oCaster)==ALIGNMENT_EVIL && GetHasSpellEffect(SPELL_GR_INFERNAL_THRENODY, oCaster)) {
                    iCasterLevel += 2;
                }
            } else if(iCastingClass==CLASS_TYPE_DRUID) {
                //*:**********************************************
                //*:* Hymn of Praise - +2 caster levels if good
                //*:* aligned
                //*:**********************************************
                if(GetAlignmentGoodEvil(oCaster)==ALIGNMENT_GOOD && GetHasSpellEffect(SPELL_GR_HYMN_OF_PRAISE, oCaster)) {
                    iCasterLevel += 2;
                }
                //*:**********************************************
                //*:* Infernal Threnody - +2 caster levels if evil
                //*:* aligned
                //*:**********************************************
                if(GetAlignmentGoodEvil(oCaster)==ALIGNMENT_EVIL && GetHasSpellEffect(SPELL_GR_INFERNAL_THRENODY, oCaster)) {
                    iCasterLevel += 2;
                }
            }
            //*:**********************************************
            //*:* Arcane Archer Imbue Arrow
            //*:**********************************************
            //*:*
            //*:* SG - Arcane archers can "imbue" an arrow with an area spell.
            //*:*   NWN uses fireball by default.
            //*:*   AAs do not get spells, so spell caster level is level
            //*:*   of the arcane class the spell belongs to.
            //*:*   I choose the highest level arcane class, and default
            //*:*   back to archer if they don't have one (although
            //*:*   it is against rules not to)
            //*:**********************************************
            else if(GetSpellId()==600) {
                iCasterLevel = 0;
                for(i=1; i<=3; i++) {
                    if(GRGetClassByPosition(i, oCaster)!=CLASS_TYPE_ARCANE_ARCHER) {
                        iTmp = GRGetClassByPosition(i, oCaster);
                        if(iTmp==CLASS_TYPE_BARD || iTmp==CLASS_TYPE_SORCERER || iTmp==CLASS_TYPE_WIZARD) {
                            if(GRGetLevelByClass(iTmp)>iCasterLevel) {
                                iCasterLevel=GRGetLevelByClass(iTmp);
                            }
                        }
                    }
                }
                if(iCasterLevel==0) {
                    iCasterLevel = GRGetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oCaster);
                }
            }
            //*:**********************************************
            //*:*  Creature  - return hit dice
            //*:**********************************************
            else if(iCastingClass==CLASS_TYPE_INVALID) {
                iCasterLevel = GetHitDice(oCaster);
            }
            //*:**********************************************
            //*:*  Has orange ioun stone effect  OR
            //*:*  has Death Knell effect
            //*:**********************************************
            if(GetHasSpellEffect(SPELL_GR_IOUN_STONE_ORANGE, oCaster) ||
                GetHasSpellEffect(SPELL_DEATH_KNELL, oCaster)) {
                iCasterLevel += 1;
            }
            //*:**********************************************
            //*:*  Has Harmonic Chorus effect
            //*:**********************************************
            if(GetHasSpellEffect(SPELL_GR_HARMONIC_CHORUS, oCaster)) {
                iCasterLevel += 2;
            }
        }
        //*:**********************************************
        //*:* Area of Effect Object
        //*:**********************************************
        else if(GetObjectType(oCaster)==OBJECT_TYPE_AREA_OF_EFFECT) {
            //*:**********************************************
            //*:* Try to get caster level of AOE creator -
            //*:* should have been set when spell was cast
            //*:**********************************************
            int iSpellID = GRGetAOESpellId(oCaster);
            struct SpellStruct spInfo = GRGetSpellInfoFromObject(iSpellID, oCaster);
            iCasterLevel = spInfo.iCasterLevel;

            if(!iCasterLevel) {
                oCaster = GetAreaOfEffectCreator();
                if(GetIsObjectValid(oCaster)) {
                    iCasterLevel = GRGetCasterLevel(oCaster);
                }
            }
        }
    }

    return iCasterLevel;
}

//*:**************************************************************************
//*:* Spell related functions
//*:**************************************************************************

//*:**********************************************
//*:* GRGetIsEnergyDescriptor
//*:**********************************************
//*:*
//*:* Determines if a spell descriptor is an energy
//*:* type
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**********************************************
int GRGetIsEnergyDescriptor(int iDescriptor) {

    int bIsEnergyDescriptor = FALSE;

    switch(iDescriptor) {
        case SPELL_TYPE_ACID:
        case SPELL_TYPE_COLD:
        case SPELL_TYPE_ELECTRICITY:
        case SPELL_TYPE_FIRE:
        case SPELL_TYPE_SONIC:
            bIsEnergyDescriptor = TRUE;
    }

    return bIsEnergyDescriptor;
}

//*:**********************************************
//*:* GRGetIsHealingSpell
//*:**********************************************
//*:*
//*:* Returns whether spell cast is a healing spell
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: December 29, 2004
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
int GRGetIsHealingSpell(int iSpellID, object oCaster=OBJECT_SELF) {

    if(GRGetSpellSubschool(iSpellID, oCaster)==SPELL_SUBSCHOOL_HEALING) {
        return TRUE;
    }

    return FALSE;
}

int GRGetIsPlayerSpell(int iSpellID, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_PLAYERSPELL");
}

//*:**********************************************
//*:* GRGetIsSpellTarget
//*:**********************************************
//*:*
//*:* Gets adjustments based on reflex save/evasion/
//*:* improved evasion
//*:*
//*:* const int   SPELL_TARGET_ANY = 0;
//*:* const int   SPELL_TARGET_ALLALLIES = 1;
//*:* const int   SPELL_TARGET_STANDARDHOSTILE = 2;
//*:* const int   SPELL_TARGET_SELECTIVEHOSTILE = 3;
//*:* const int   SPELL_TARGET_PARTYONLY = 4;
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 9, 2007
//*:**********************************************
int GRGetIsSpellTarget(object oTarget, int iTargetGroup, object oSource, int bCasterIncluded = FALSE) {

    int iReturnValue = FALSE;
    //*:**********************************************
    //*:* NWN2 ScriptHidden
    //*:**********************************************
    // If the target is a ScriptHidden creature, we do not want to affect it.
    //*** NWN2 SINGLE ***/ if(GetScriptHidden(oTarget)==TRUE) return FALSE;

    //*:**********************************************
    //*:* NWN2 IgnoreTargetRules
    //*:**********************************************
    // If we want to ignore the rules of target selection for this spell, always return true.
    /*** NWN2 SPECIFIC ***
        int iEntry = IgnoreTargetRulesGetFirstIndex(oSource, oTarget);
        if(iEntry != -1) {
            IgnoreTargetRulesRemoveEntry(oSource, iEntry);
            return TRUE;
        }
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* if affects affects any
    //*:**********************************************
    if(iTargetGroup==SPELL_TARGET_ANY) return TRUE;
    //*:**********************************************
    //*:* if affects caster and target is caster
    //*:**********************************************
    if(bCasterIncluded==TRUE && oTarget==oSource) return TRUE;
    //*:**********************************************
    //*:* if caster is not to be affected ever
    //*:**********************************************
    if(bCasterIncluded==NO_CASTER && oTarget==oSource) return FALSE;
    //*:**********************************************
    //*:* if dead, not a valid target
    //*:**********************************************
    if(GetIsDead(oTarget) || oTarget==OBJECT_INVALID) return FALSE;
    //*:**********************************************


    //*:**********************************************
    //*:* Spell faction/game difficulty target selection
    //*:**********************************************
    switch(iTargetGroup) {
        //*:**********************************************
        //*:* this kind of spell will affect all friendlies and anyone in my
        //*:* party, even if we are upset with each other currently
        //*:* only on low difficulty settings.  It affects everyone
        //*:* on higher game difficulty settings
        //*:**********************************************
        case SPELL_TARGET_ALLIESEASY:
            if(GetGameDifficulty()>GAME_DIFFICULTY_NORMAL) {
                iReturnValue = TRUE;
            } else if(GetIsReactionTypeFriendly(oTarget, oSource) || GetFactionEqual(oTarget, oSource)) {
                iReturnValue = TRUE;
            }
            break;
        //*:**********************************************
        //*:* this kind of spell will affect all friendlies and anyone in my
        //*:* party, even if we are upset with each other currently.
        //*:**********************************************
        case SPELL_TARGET_ALLALLIES:
            if(GetIsReactionTypeFriendly(oTarget, oSource) || GetFactionEqual(oTarget, oSource)) {
                iReturnValue = TRUE;
            }
            break;
        //*:**********************************************
        //*:* this kind of spell will affect anyone in my
        //*:* party, even if we are upset with each other currently.
        //*:**********************************************
        case SPELL_TARGET_PARTYONLY:
            if(GetFactionEqual(oTarget, oSource)) {
                iReturnValue = TRUE;
            }
            break;
        //*:**********************************************
        //*:* this kind of spell will affect only enemies and
        //*:* neutrals (if overridden) at Game Difficulty normal and below -
        //*:* otherwise affects everyone
        //*:**********************************************
        case SPELL_TARGET_STANDARDHOSTILE:
            //SpawnScriptDebugger();
            int bPC = GetIsPC(oTarget);
            int bNotAFriend = FALSE;
            int bReactionTypeFriendly = GetIsReactionTypeFriendly(oTarget, oSource);
            int bInSameFaction  = GetFactionEqual(oTarget, oSource);

            if(!bReactionTypeFriendly && !bInSameFaction) bNotAFriend = TRUE;

            //*:**********************************************
            // * Local Override is just an out for end users who want
            // * the area effect spells to hurt 'neutrals'
            //*:**********************************************
            if(GetLocalInt(GetModule(), "X0_G_ALLOWSPELLSTOHURT") == 10) bPC = TRUE;
            //*:**********************************************

            int bSelfTarget = FALSE;
            object oTargetMaster = GetMaster(oTarget);
            object oSourceMaster = GetMaster(oSource);

            if(!GetIsObjectValid(oTargetMaster)) oTargetMaster = GetFactionLeader(oTarget);
            if(!GetIsObjectValid(oSourceMaster)) oSourceMaster = GetFactionLeader(oSource);

            //*:**********************************************
            // March 25 2003. The player itself can be harmed
            // by their own area of effect spells if in Hardcore mode...
            //*:**********************************************
            if(GetGameDifficulty() > GAME_DIFFICULTY_NORMAL) {
                // Have I hit myself with my spell?
                if(oTarget==oSource && GetIsObjectValid(oSourceMaster)) {
                    bSelfTarget = TRUE;
                } else if(oTargetMaster==oSourceMaster && GetIsObjectValid(oTargetMaster) && GetIsObjectValid(oSourceMaster)) {
                // * Is the target an associate of the spellcaster
                    bSelfTarget = TRUE;
                }
            }

            //*:**********************************************
            // April 9 2003
            // Hurt the associates of a hostile player
            //*:**********************************************
            if(bSelfTarget == FALSE && GetIsObjectValid(oTargetMaster) == TRUE) {
                // * I am an associate
                // * of someone
                if(GetIsReactionTypeHostile(oTargetMaster, oSource)==TRUE) {
                    bSelfTarget = TRUE;
                }
            }

            //*:**********************************************
            // Assumption: In Full PvP players, even if in same party, are Neutral
            // * GZ: 2003-08-30: Patch to make creatures hurt each other in hardcore mode...
            //*:**********************************************
            if(GetIsReactionTypeHostile(oTarget,oSource)) {
                iReturnValue = TRUE;         // Hostile creatures are always a target
            } else if(bSelfTarget == TRUE) {
                iReturnValue = TRUE;         // Targetting Self (set above)?
            } else if(bPC && bNotAFriend) {
                iReturnValue = TRUE;         // Enemy PC
            } else if(bNotAFriend && (GetGameDifficulty() > GAME_DIFFICULTY_NORMAL)) {
                if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_NPC_AOE_HURT_ALLIES) == TRUE) {
                    iReturnValue = TRUE;        // Hostile Creature and Difficulty > Normal
                }                               // note that in hardcore mode any creature is hostile
            }
            break;

        //*:**********************************************
        // * only harms enemies, ever
        // * current list:call lightning, isaac missiles, firebrand, chain lightning, dirge, Nature's balance,
        // * Word of Faith
        //*:**********************************************
        case SPELL_TARGET_SELECTIVEHOSTILE:
            if(GetIsEnemy(oTarget, oSource) && !GetFactionEqual(oTarget, oSource)) iReturnValue = TRUE;
            break;
    }

    //*:**********************************************
    //*:* GZ: Creatures with the same master will never damage each other
    //*:**********************************************
    //*:* SG: Added Game Difficulty Check
    //*:**********************************************
    if(GetGameDifficulty()<=GAME_DIFFICULTY_NORMAL) {
        if(GetMaster(oTarget) != OBJECT_INVALID && GetMaster(oSource) != OBJECT_INVALID ) {
            if(GetMaster(oTarget) == GetMaster(oSource)) {
                if(GetModuleSwitchValue(MODULE_SWITCH_ENABLE_MULTI_HENCH_AOE_DAMAGE) == 0 ) {
                    iReturnValue = FALSE;
                }
            }
        }
    }

    return iReturnValue;
}

//*:**********************************************
//*:* GRGetIsSpellTurnable
//*:**********************************************
//*:*
//*:* Checks if spell is turnable.  Checks spells.2da
//*:* if caster object is invalid
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 30, 2004
//*:**********************************************
//*:* Updated On: April 12, 2007
//*:**********************************************
int GRGetIsSpellTurnable(int iSpellID, object oCaster=OBJECT_INVALID) {

    int iReturnValue;

    if(!GetIsObjectValid(oCaster)) {
        iReturnValue = StringToInt(Get2DAString(SPELLS, SPELLS_TURNABLE,iSpellID));
    } else {
        iReturnValue = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_TURNABLE");
    }

    return iReturnValue;
}

//*:**********************************************
//*:* GRGetLastSpellCastClass
//*:**********************************************
//*:*
//*:* Returns which class the caster is using to
//*:* cast the spell
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 30, 2007
//*:**********************************************
int GRGetLastSpellCastClass(object oCaster=OBJECT_SELF) {

    int iSpellCastClass = GetLastSpellCastClass();
    object oItem = GetSpellCastItem();

    if(GetIsObjectValid(oItem)) {
        if(GetStringLeft(GetTag(oItem), 8)=="itsp_asn") {
            iSpellCastClass = CLASS_TYPE_ASSASSIN;
        } else if(GetStringLeft(GetTag(oItem), 8)=="itsp_blk") {
            iSpellCastClass = CLASS_TYPE_BLACKGUARD;
        }
    }

    return iSpellCastClass;
}

//*:**********************************************
//*:* GRGetMetamagicAdjustedDamage
//*:*   (formerly SGMaximizeOrEmpower)
//*:**********************************************
//*:*
//*:* Returns proper damage value based on Maximize
//*:* or Empower spell feats being used (if any).
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetMetamagicAdjustedDamage(int iDieType, int iNumDice = 1, int iMetamagic = 0, int iBonus = 0) {

    int i = 0;
    int iDamage = 0;
    int iEnergyType;

    //*:**********************************************
    //*:* Resolve metamagic
    //*:**********************************************
    if(GRGetMetamagicUsed(iMetamagic, METAMAGIC_MAXIMIZE)) {
        iDamage = iDieType * iNumDice;
    } else {
        for (i=1; i<=iNumDice; i++) {
            iDamage = iDamage + Random(iDieType) + 1;
        }
        if(GRGetMetamagicUsed(iMetamagic, METAMAGIC_EMPOWER)) {
            iDamage = iDamage + iDamage / 2;
        }
    }

    iDamage += iBonus;

    if(GRGetIsUnderwater(OBJECT_SELF)) {
        iEnergyType = GRGetSpellEnergyType(GetSpellId(), OBJECT_SELF);
        iDamage = GRGetAdjustedUnderwaterSonicDamage(iDamage, iEnergyType);
        if(GetSpellId()==SPELL_BOMBARDMENT) {
            //*:**********************************************
            //*:*  water buoyancy reduces damage
            //*:**********************************************
            iDamage /= 2;
        }
    }

    //*:**********************************************
    //*:* Mestil's Acid Sheath bonus to acid spells
    //*:*
    //*:* Bonus is 1 pt per damage die
    //*:**********************************************
    if(GetHasSpellEffect(524, OBJECT_SELF) && GRGetSpellEnergyType(GetSpellId())==SPELL_TYPE_ACID) {
        iBonus = 1*iNumDice;
        iDamage += iBonus;
    }

    return iDamage;
}

//*:**********************************************
//*:* GRGetMetamagicFeat
//*:**********************************************
//*:*
//*:* Gets the Metamagic feat used in casting a spell
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 17, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetMetamagicFeat() {

    object oCaster = OBJECT_SELF;
    int iMetamagic = METAMAGIC_NONE;

    iMetamagic = GetMetaMagicFeat();

    return iMetamagic;
}

//*:**********************************************
//*:* GRGetMetamagicUsed
//*:*   (formerly SGCheckMetamagic)
//*:**********************************************
//*:*
//*:* Checks current metamagic used
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetMetamagicUsed(int iMetamagic, int iMetamagicType) {

    //*:**********************************************
    //*:* Eventually I want to update this so that it uses
    //*:* bit-masking so types can be created that are
    //*:* metamagic combinations
    //*:**********************************************
    if(iMetamagic == iMetamagicType)
        return TRUE;

    return FALSE;
}

//*:**********************************************
//*:* GRGetReflexAdjustedDamage
//*:**********************************************
//*:*
//*:* Gets adjustments based on reflex save/evasion/
//*:* improved evasion
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetReflexAdjustedDamage(int iDamage, object oTarget, int iDC, int iSaveType = SAVING_THROW_TYPE_NONE,
    object oSaveVersus = OBJECT_SELF) {

        object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget);
        int iArmorType = GRGetArmorType(oArmor);
        string sArmorName = GetName(oArmor);
        int iAdjDamage = iDamage;
        int iResult = ReflexSave(oTarget, iDC, iSaveType, oSaveVersus);
        int bHasEvasion = GetHasFeat(FEAT_EVASION, oTarget);
        int bHasImpEvasion = GetHasFeat(FEAT_IMPROVED_EVASION, oTarget);
        int bPassArmorCheck = FALSE;
        int bPassWeightCheck = FALSE;
        int bHasFireShield = FALSE;

        //*:**********************************************
        //*:* Fire Shield check
        //*:**********************************************
        if(GetHasSpellEffect(SPELL_GR_FIRE_SHIELD_HOT, oTarget) || GetHasSpellEffect(SPELL_GR_FIRE_SHIELD_COLD, oTarget)) {
            if((GetHasSpellEffect(SPELL_GR_FIRE_SHIELD_HOT, oTarget) && iSaveType==SAVING_THROW_TYPE_COLD) ||
               (GetHasSpellEffect(SPELL_GR_FIRE_SHIELD_COLD, oTarget) && iSaveType==SAVING_THROW_TYPE_FIRE)) {
                bHasFireShield = TRUE;
                if(iResult) {
                    iAdjDamage = 0;
                } else {
                    iAdjDamage /= 2;
                }
            }
        }

        if(iAdjDamage>0) {  // no point in running further code if damage already negated
            //*:**********************************************
            //*:* Evasion check - wearing Medium or Heavy armor or
            //*:* carrying a Medium or greater load does not allow
            //*:* use of evasion or improved evasion feats
            //*:**********************************************
            if((bHasEvasion || bHasImpEvasion)) {
                //*:**********************************************
                //*:* Armor check - Chain Shirt is Light
                //*:* Hide is Medium
                //*:**********************************************
                if( (iArmorType<=3 && GetStringUpperCase(GetStringLeft(sArmorName, 4))!="HIDE") ||          // all light armors not including chain shirt
                    (iArmorType>3 && GetStringUpperCase(GetStringLeft(sArmorName,11))=="CHAIN SHIRT")) {    // try to catch chain shirt
                    bPassArmorCheck = TRUE;
                }
                //*:**********************************************
                //*:* Weight check
                //*:**********************************************
                bPassWeightCheck = !GRGetHasMediumOrGreaterLoad(oTarget);
                if(bPassArmorCheck && bPassWeightCheck) {
                    if(bHasImpEvasion && iResult!=1) {
                        iAdjDamage /= 2;
                        if(bHasFireShield && iAdjDamage>0) {
                            iAdjDamage = 0;
                        }
                    } else if(iResult==1) {
                        iAdjDamage = 0;
                    }
                }
            }
        }

        return iAdjDamage;
}

//*:**********************************************
//*:* GRGetSaveResult
//*:**********************************************
//*:*
//*:*    Gets saving throw results
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetSaveResult(int iSavingThrow, object oTarget, int iDC, int iSaveType = SAVING_THROW_TYPE_NONE,
    object oSaveVersus = OBJECT_SELF, float fDelay = 0.0f, int bNoMagic = FALSE, int bRevertFalseOnResist = TRUE, int bBrother = FALSE) {

    int iSaveResult;
    int iSpellID = GetSpellId();
    int iSpellSchool = GRGetSpellSchool(iSpellID, oSaveVersus);

    //*:**********************************************
    //*:* Any poison or disease saves attempted in
    //*:* Breath of the Jungle AOE has +2 on its DC
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_BREATH_OF_THE_JUNGLE, oTarget) && (iSaveType==SAVING_THROW_TYPE_POISON || iSaveType==SAVING_THROW_TYPE_DISEASE)) {
        iDC += 2;
    }
    //*:**********************************************
    //*:* Any creature under effect of Lullaby
    //*:* has -2 on its will save for sleep effects
    //*:* We'll increase DC by 2 to mimic the effect
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_LULLABY, oTarget) && iSaveType==SAVING_THROW_TYPE_SLEEP) {
        iDC += 2;
        iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    }
    //*:**********************************************
    //*:* Gnomes get a +2 to save vs illusions
    //*:* We'll decrease DC by 2 to mimic the effect
    //*:**********************************************
    if(GetHasFeat(FEAT_GR_HARDINESS_VERSUS_ILLUSIONS, oTarget) && iSpellSchool==SPELL_SCHOOL_ILLUSION) {
        iDC -= 2;
    }
    //*:**********************************************
    //*:* Elves & Monks get a +2 to save vs enchantments
    //*:* We'll decrease DC by 2 to mimic the effect
    //*:**********************************************
    if( (GetHasFeat(FEAT_GR_HARDINESS_VERSUS_ENCHANTMENTS, oTarget) || GetHasFeat(FEAT_GR_STILL_MIND, oTarget))
        && iSpellSchool==SPELL_SCHOOL_ENCHANTMENT) {

        iDC -= 2;
    }
    //*:**********************************************
    //*:* Any creature under the effect of Peaceful Serenity of Io
    //*:* gets +4 to save vs compulsions
    //*:* lower dc by 4 to mimic effect
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_PEACEFUL_SERENITY, oTarget) && GRGetSpellSubschool(iSpellID, oSaveVersus)==SPELL_SUBSCHOOL_COMPULSION) {
        iDC -= 4;
    }

    if(!GRGetMagicBlocked(oTarget) && !bNoMagic) {
        // -------------------------------------------------------------------------
        // GZ: sanity checks to prevent wrapping around
        // -------------------------------------------------------------------------
        iDC = MaxInt(1, MinInt(255, iDC));

        effect eVis;
        int iDurationType = DURATION_TYPE_INSTANT;

        if(iSavingThrow == SAVING_THROW_FORT) {
            iSaveResult = FortitudeSave(oTarget, iDC, iSaveType, oSaveVersus);
            if(iSaveResult == 1) {
                /*** NWN1 SINGLE ***/ eVis = EffectVisualEffect(VFX_IMP_FORTITUDE_SAVING_THROW_USE);
            }
        } else if(iSavingThrow == SAVING_THROW_REFLEX) {
            iSaveResult = ReflexSave(oTarget, iDC, iSaveType, oSaveVersus);
            if(iSaveResult == 1) {
                /*** NWN1 SINGLE ***/ eVis = EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE);
            }
        } else if(iSavingThrow == SAVING_THROW_WILL) {
            iSaveResult = WillSave(oTarget, iDC, iSaveType, oSaveVersus);
            if(iSaveResult == 1) {
                /*** NWN1 SINGLE ***/ eVis = EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE);
            }
        }

        /*
            return 0 = FAILED SAVE
            return 1 = SAVE SUCCESSFUL
            return 2 = IMMUNE TO WHAT WAS BEING SAVED AGAINST
        */
        switch(iSaveResult) {
            case 0:
                if((iSaveType == SAVING_THROW_TYPE_DEATH
                 || iSpellID == SPELL_WEIRD
                 || iSpellID == SPELL_FINGER_OF_DEATH) &&
                 iSpellID != SPELL_HORRID_WILTING) {
                    eVis = EffectVisualEffect(VFX_IMP_DEATH);
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
                break;
            case 2:
            /*** NWN1 SINGLE ***/ eVis = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);
            /*** NWN2 SPECIFIC ***
                eVis = EffectVisualEffect(VFX_DUR_SPELL_SPELL_RESISTANCE);
                iDurationType = DURATION_TYPE_TEMPORARY;
            /*** END NWN2 SPECIFIC ***/
                if(GetHasSpellEffect(SPELL_GR_BLADE_BROTHERS, oTarget)) {
                    SetLocalInt(oTarget, "GR_BLADEBROTHERS_SAVEIMMUNE", TRUE);
                }
                if(bRevertFalseOnResist) iSaveResult = FALSE;
            case 1:
                DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eVis, oTarget, GRGetDuration(1)));
                break;
        }
    } else {
        int iBaseSaveValue = GRDetermineBaseSaveValue(oTarget, iSavingThrow);
        int iAbilityMod;
        int iVisualType;

        switch(iSavingThrow) {
            case SAVING_THROW_FORT:
                iAbilityMod = GRGetAbilityModifier(ABILITY_CONSTITUTION, oTarget, TRUE);
                iVisualType = VFX_IMP_FORTITUDE_SAVING_THROW_USE;
                break;
            case SAVING_THROW_REFLEX:
                iAbilityMod = GRGetAbilityModifier(ABILITY_DEXTERITY, oTarget, TRUE);
                iVisualType = VFX_IMP_REFLEX_SAVING_THROW_USE;
                break;
            case SAVING_THROW_WILL:
                iAbilityMod = GRGetAbilityModifier(ABILITY_WISDOM, oTarget, TRUE);
                iVisualType = VFX_IMP_WILL_SAVING_THROW_USE;
                break;
        }

        int iRoll = d20();
        switch(iRoll) {
            case 1:
                iSaveResult = FALSE;
                break;
            case 20:
                iSaveResult = TRUE;
                break;
            default:
                iSaveResult = (d20()+iBaseSaveValue+iAbilityMod)>=iDC;
                break;
        }
        if(iSaveResult) DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(iVisualType), oTarget));
    }

    //*:**********************************************
    //*:* Protection Domain ward only good for 1 save
    //*:**********************************************
    if(GetHasSpellEffect(SPELLABILITY_DIVINE_PROTECTION, oTarget)) {
        GRRemoveSpellEffects(SPELLABILITY_DIVINE_PROTECTION, oTarget);
    }

    //*:**********************************************
    //*:* Blade Brothers - use best result of two people
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_BLADE_BROTHERS, oTarget) && !bBrother) {
        object oBrother = GetLocalObject(oTarget, "GR_BLADEBROTHERS_OBJ");
        int iAltResult = GRGetSaveResult(iSavingThrow, oBrother, iDC, iSaveType, oSaveVersus, fDelay, bNoMagic, FALSE, TRUE);
        int bSaveImmune = GetLocalInt(oTarget, "GR_BLADEBROTHERS_SAVEIMMUNE");
        int bBrotherSaveImmune = GetLocalInt(oBrother, "GR_BLADEBROTHERS_SAVEIMMUNE");

        if(!iSaveResult && !bSaveImmune) {
            if(!iAltResult && !bBrotherSaveImmune) {
                SetLocalInt(oTarget, "GR_BLADEBROTHERS_APPLYDOUBLE", TRUE);
                SetLocalInt(oBrother, "GR_BLADEBROTHERS_APPLYDOUBLE", TRUE);
            } else {
                iSaveResult = TRUE;
                SetLocalInt(oTarget, "GR_BLADEBROTHERS_APPLYDOUBLE", FALSE);
                SetLocalInt(oBrother, "GR_BLADEBROTHERS_APPLYDOUBLE", FALSE);
            }
        }
        DeleteLocalInt(oTarget, "GR_BLADEBROTHERS_SAVEIMMUNE");
        DeleteLocalInt(oBrother, "GR_BLADEBROTHERS_SAVEIMMUNE");
    } else if(bBrother) {
        SetLocalInt(oTarget, "GR_BLADEBROTHERS_SAVEDONE", TRUE);
    }

    return iSaveResult;
}

//*:**********************************************
//*:* GRGetSpellCastClass
//*:**********************************************
//*:*
//*:* Gets spell casting class info from Caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2007
//*:**********************************************
//*:* Updated On:
//*:**********************************************
int GRGetSpellCastClass(int iSpellID, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_CASTCLASS");
}

//*:**********************************************
//*:* GRGetSpellCasterLevel
//*:**********************************************
//*:*
//*:* Gets spell caster level info from Caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**********************************************
int GRGetSpellCasterLevel(int iSpellID, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_CASTERLEVEL");
}

int GRGetSpellDmgSaveMade(int iSpellID, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_DMGSAVEMADE");
}

//*:**********************************************
//*:* GRGetSpellDescriptor
//*:**********************************************
//*:*
//*:* Sets a spell descriptor on the caster.  For use
//*:* with getting "Creation" or "Healing" spells, etc.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
int GRGetSpellDescriptor(int iSpellID, object oCaster=OBJECT_SELF, int iPosition = 1) {

    int iSpellDescriptor = SPELL_TYPE_GENERAL;

    if(GetIsObjectValid(oCaster))
        iSpellDescriptor = GetLocalInt(oCaster,"GR_"+IntToString(iSpellID)+"_DESCRIPTOR_"+IntToString(iPosition));

    return iSpellDescriptor;
}

//*:**********************************************
//*:* GRGetSpellEffectCreator
//*:**********************************************
//*:*
//*:* Got tired of writing this stupid loop over and
//*:* over.  Finds the creator of a specific spell effect.
//*:* Only use this function for spells that CANNOT
//*:* stack.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 26, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
object GRGetSpellEffectCreator(object oTarget, int iSpellID) {

     object oObject = OBJECT_INVALID;

     effect eEffect = GetFirstEffect(oTarget);
     while(GetIsEffectValid(eEffect) && oObject==OBJECT_INVALID) {
         if(GetEffectSpellId(eEffect)==iSpellID) {
             oObject = GetEffectCreator(eEffect);
         }
         eEffect = GetNextEffect(oTarget);
     }

     return oObject;
 }

//*:**********************************************
//*:* GRGetSpellEnergyDamageType
//*:**********************************************
//*:*
//*:* Returns the damage type of the first energy
//*:* descriptor found for the spell - otherwise
//*:* returns magical.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**********************************************
int GRGetSpellEnergyDamageType(int iSpellID, object oCaster=OBJECT_SELF) {

    int iDamageType = DAMAGE_TYPE_MAGICAL;
    int iEnergyType = GRGetSpellEnergyType(iSpellID, oCaster);

    switch(iEnergyType) {
        case SPELL_TYPE_ACID:
            iDamageType = DAMAGE_TYPE_ACID;
            break;
        case SPELL_TYPE_COLD:
            iDamageType = DAMAGE_TYPE_COLD;
            break;
        case SPELL_TYPE_ELECTRICITY:
            iDamageType = DAMAGE_TYPE_ELECTRICAL;
            break;
        case SPELL_TYPE_FIRE:
            iDamageType = DAMAGE_TYPE_FIRE;
            break;
        case SPELL_TYPE_SONIC:
            iDamageType = DAMAGE_TYPE_SONIC;
            break;
    }

    return iDamageType;
}

//*:**********************************************
//*:* GRGetSpellEnergyType
//*:**********************************************
//*:*
//*:* Returns the first energy descriptor found for
//*:* the spell - otherwise returns general.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**********************************************
int GRGetSpellEnergyType(int iSpellID, object oCaster=OBJECT_SELF) {

    int iEnergyType = SPELL_TYPE_GENERAL;
    int iDescriptor;
    int i = 1;

    while(iEnergyType==SPELL_TYPE_GENERAL && i<4) {
        iDescriptor = GRGetSpellDescriptor(iSpellID, oCaster, i);
        if(GRGetIsEnergyDescriptor(iDescriptor)) {
            iEnergyType = iDescriptor;
        }
        i+=1;
    }

    return iEnergyType;
}

//*:**********************************************
//*:* GRGetSpellEnergyTypePosition
//*:**********************************************
//*:*
//*:* Returns one of the three energy descriptor
//*:* positions if it has the corresponding energy
//*:* type.  Needed to be able to replace the value
//*:* for the Energy Substitution feats.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**********************************************
int GRGetSpellEnergyTypePosition(int iSpellID, int iEnergyType, object oCaster=OBJECT_SELF) {

    int iPosition = 0;
    int iDescriptor;
    int i;

    for(i=1; i<4; i++) {
        iDescriptor = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_DESCRIPTOR_"+IntToString(i));
        iPosition = (iDescriptor==iEnergyType ? i : iPosition);
    }

    return iPosition;
}

//*:**********************************************
//*:* GRGetSpellHasDescriptor
//*:**********************************************
//*:*
//*:* Checks to see if the spell has a particular
//*:* descriptor.  Needed this function once
//*:* multiple descriptors were included.
//*:*
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 19, 2007
//*:**********************************************
int GRGetSpellHasDescriptor(int iSpellID, int iSpellType, object oCaster=OBJECT_SELF) {
    int iHasDescriptor = FALSE;
    int i = 1;

    while(i<=3 && !iHasDescriptor) {
        iHasDescriptor = (iSpellType==GRGetSpellDescriptor(iSpellID, oCaster, i));
        i++;
    }

    return iHasDescriptor;
}

//*:**********************************************
//*:* GRGetSpellLevel
//*:**********************************************
//*:*
//*:* Gets spell level info from caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2007
//*:**********************************************
//*:* Updated On:
//*:**********************************************
int GRGetSpellLevel(int iSpellID, object oCaster=OBJECT_SELF) {
    int iSpellLevel;

    if(!GetIsObjectValid(oCaster)) {
        iSpellLevel = 0;
    } else {
        iSpellLevel = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SPELLLEVEL");
    }

    return iSpellLevel;
}

//*:**********************************************
//*:* GRGetSpellLevelBy2da
//*:**********************************************
//*:*
//*:* Determines the level of the cast spell using 2das.
//*:* For efficiency, use GetSpellLevelByDC.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 30, 2004
//*:**********************************************
//*:* Updated On: April 12, 2007
//*:* BUGFIX:  did not take into account subradial spells
//*:**********************************************
int GRGetSpellLevelBy2da(object oCaster, int iSpellCastClass, int iSpellID) {

    int iResult;
    string sResult;

    switch(iSpellCastClass) {
        case CLASS_TYPE_CLERIC:
            sResult = Get2DAString("spells","Cleric",iSpellID);
            if(sResult=="") {
                sResult = Get2DAString("spells","Cleric",StringToInt(Get2DAString("spells","Master",iSpellID)));
            }
            if(sResult=="") {
                iResult = 0;
            } else {
                iResult = StringToInt(sResult);
            }
            break;
        case CLASS_TYPE_DRUID:
            sResult = Get2DAString("spells","Druid",iSpellID);
            if(sResult=="") {
                sResult = Get2DAString("spells","Druid",StringToInt(Get2DAString("spells","Master",iSpellID)));
            }
            if(sResult=="") {
                iResult = 0;
            } else {
                iResult = StringToInt(sResult);
            }
            break;
        case CLASS_TYPE_PALADIN:
            sResult = Get2DAString("spells","Paladin",iSpellID);
            if(sResult=="") {
                sResult = Get2DAString("spells","Paladin",StringToInt(Get2DAString("spells","Master",iSpellID)));
            }
            if(sResult=="") {
                iResult = 0;
            } else {
                iResult = StringToInt(sResult);
            }
            break;
        case CLASS_TYPE_RANGER:
            sResult = Get2DAString("spells","Ranger",iSpellID);
            if(sResult=="") {
                sResult = Get2DAString("spells","Ranger",StringToInt(Get2DAString("spells","Master",iSpellID)));
            }
            if(sResult=="") {
                iResult = 0;
            } else {
                iResult = StringToInt(sResult);
            }
            break;
        case CLASS_TYPE_SORCERER:
        case CLASS_TYPE_WIZARD:
            sResult = Get2DAString("spells","Wiz_Sorc",iSpellID);
            if(sResult=="") {
                sResult = Get2DAString("spells","Wiz_Sorc",StringToInt(Get2DAString("spells","Master",iSpellID)));
            }
            if(sResult=="") {
                iResult = 0;
            } else {
                iResult = StringToInt(sResult);
            }
            break;
        case CLASS_TYPE_BARD:
            sResult = Get2DAString("spells","Bard",iSpellID);
            if(sResult=="") {
                sResult = Get2DAString("spells","Bard",StringToInt(Get2DAString("spells","Master",iSpellID)));
            }
            if(sResult=="") {
                iResult = 0;
            } else {
                iResult = StringToInt(sResult);
            }
            break;
        case CLASS_TYPE_WARLOCK:
            int iEssenceLevel = GetLocalInt(oCaster, "GR_ESSENCE_INV_LEVEL");
            int iBlastLevel = GetLocalInt(oCaster, "GR_BLAST_SHAPE_LEVEL");
            sResult = Get2DAString("spells","Innate",iSpellID);
            if(sResult=="") {
                sResult = Get2DAString("spells","Innate",StringToInt(Get2DAString("spells","Master",iSpellID)));
            }
            if(sResult=="") {
                iResult = MinInt(9, MaxInt(1, GRGetCasterLevel(oCaster, iSpellCastClass)/2));
            } else {
                iResult = StringToInt(sResult);
            }
            iResult = MaxInt(iResult, iEssenceLevel, iBlastLevel);
            break;
    }
    return iResult;
}

//*:**********************************************
//*:* GRGetSpellLevelByDC
//*:**********************************************
//*:*
//*:* Determines the level of the cast spell
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 30, 2004
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
int GRGetSpellLevelByDC(object oCaster, int iSpellCastClass, int iSpellSaveDC) {

    int iSpellLevel = iSpellSaveDC - 10 - GRGetCasterAbilityModifierByClass(oCaster, iSpellCastClass);

    return iSpellLevel;
}

//*:**********************************************
//*:* GRGetSpellMetamagic
//*:**********************************************
//*:*
//*:* Gets spell metamagic info from Caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**********************************************
int GRGetSpellMetamagic(int iSpellID, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_METAMAGIC");
}

//*:**********************************************
//*:* GRGetSpellRequiresConcentration
//*:**********************************************
//*:*
//*:* Gets whether spell requires concentration
//*:* from caster.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 19, 2007
//*:**********************************************
int GRGetSpellRequiresConcentration(int iSpellID, object oCaster=OBJECT_SELF) {
    int iReqConcentration = FALSE;

    if(GetIsObjectValid(oCaster)) {
        iReqConcentration = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_REQCONCENTRATION");
    }

    return iReqConcentration;
}

//*:**********************************************
//*:* GRGetSpellResisted
//*:*   (formerly SGMyResistSpell)
//*:**********************************************
//*:*
//*:* Gets spell resistance results
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: April 17, 2008
//*:**********************************************
int GRGetSpellResisted(object oCaster, object oTarget, float fDelay = 0.0f) {

    int iResistValue = GetSpellResistance(oTarget);
    int iResist = ResistSpell(oCaster, oTarget);
    int iSpellID = GetSpellId();
    struct SpellStruct spInfo = GRGetSpellInfoFromObject(iSpellID, oCaster);

    if(iResist>-1 && iResist<2) {
        if(!GetIsObjectValid(oCaster) || !GetIsObjectValid(oTarget)) {
            iResist = FALSE;
        } else {
            //*:**********************************************
            //*:* Check Spell Penetration-type feats
            //*:**********************************************
            if(GetHasFeat(FEAT_SPELL_PENETRATION, oCaster)) {
                spInfo.iCasterLevel += 2;
            }
            if(GetHasFeat(FEAT_GREATER_SPELL_PENETRATION, oCaster)) {
                spInfo.iCasterLevel += 2;
            }
            if(GetHasFeat(FEAT_EPIC_SPELL_PENETRATION, oCaster)) {
                spInfo.iCasterLevel += 2;
            }

            int bDivinePenetrationApplied = FALSE;

            if(GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_CHAOTIC, oCaster)) {
                if(GetAlignmentLawChaos(oCaster)==ALIGNMENT_CHAOTIC && GetHasFeat(FEAT_GR_DIVINE_SPELL_PENETRATION_CHAOS, oCaster)) {
                    spInfo.iCasterLevel += 4;
                    bDivinePenetrationApplied = TRUE;
                }
            }
            if(GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_EVIL, oCaster) && !bDivinePenetrationApplied) {
                if(GetAlignmentGoodEvil(oCaster)==ALIGNMENT_EVIL && GetHasFeat(FEAT_GR_DIVINE_SPELL_PENETRATION_EVIL, oCaster)) {
                    spInfo.iCasterLevel += 4;
                    bDivinePenetrationApplied = TRUE;
                }
            }
            if(GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_GOOD, oCaster) && !bDivinePenetrationApplied) {
                if(GetAlignmentGoodEvil(oCaster)==ALIGNMENT_GOOD && GetHasFeat(FEAT_GR_DIVINE_SPELL_PENETRATION_GOOD, oCaster)) {
                    spInfo.iCasterLevel += 4;
                    bDivinePenetrationApplied = TRUE;
                }
            }
            if(GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_LAWFUL, oCaster) && !bDivinePenetrationApplied) {
                if(GetAlignmentLawChaos(oCaster)==ALIGNMENT_LAWFUL && GetHasFeat(FEAT_GR_DIVINE_SPELL_PENETRATION_LAW, oCaster)) {
                    spInfo.iCasterLevel += 4;
                }
            }
            //*:**********************************************
            //*:* Check specific spell instances
            //*:**********************************************
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SURGE, oCaster, oCaster) && iSpellID==SPELL_GR_INCENDIARY_SURGE) {
                spInfo.iCasterLevel += 2;
            }
            if(GetHasSpellEffect(SPELL_GR_TRUE_CASTING, oCaster)) {
                spInfo.iCasterLevel += 10;
            }
            //*:**********************************************
            //*:* Make Spell Resistance check
            //*:**********************************************
            iResist = (d20()+spInfo.iCasterLevel < iResistValue);
        }
    }

    if(fDelay > 0.5) fDelay = fDelay - 0.1;

    /*** NWN1 SPECIFIC ***/
        effect eSR      = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);
        effect eGlobe   = EffectVisualEffect(VFX_IMP_GLOBE_USE);
        effect eMantle  = EffectVisualEffect(VFX_IMP_SPELL_MANTLE_USE);
        int iDurationType = DURATION_TYPE_INSTANT;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        effect eSR      = EffectVisualEffect(VFX_DUR_SPELL_SPELL_RESISTANCE);
        effect eGlobe   = EffectVisualEffect(VFX_DUR_SPELL_GLOBE_INV_LESS);
        effect eMantle  = EffectVisualEffect(VFX_DUR_SPELL_SPELL_MANTLE);
        int iDurationType = DURATION_TYPE_TEMPORARY;
    /*** END NWN2 SPECIFIC ***/

    switch(iResist) {
        case 1:         // Spell Resistance
            DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eSR, oTarget, 2.0));
            break;
        case 2:         // Globe
            DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eGlobe, oTarget, 2.0));
            break;
        case 3:         // Spell Mantle
            if(fDelay > 0.5) fDelay = fDelay - 0.1;
            DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eMantle, oTarget, 2.0));
            break;
    }

    return iResist;
}

//*:**********************************************
//*:* GRGetSpellSaveDC
//*:*   (formerly SGGetSpellSaveDC)
//*:**********************************************
//*:*
//*:* Gets the spell save DC
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetSpellSaveDC(object oCaster, object oTarget=OBJECT_INVALID) {

    int iSpellSaveDC = GetSpellSaveDC();
    int iSpellID = GetSpellId();

    //*:**********************************************
    //*:* Creature spellability save
    //*:**********************************************
    if(GetLastSpellCastClass()==CLASS_TYPE_INVALID) {
        iSpellSaveDC = 10 + GRGetCasterLevel(oCaster)/3;
    } else if(GetLastSpellCastClass()==CLASS_TYPE_WARLOCK) {
        iSpellSaveDC = 10 + GRGetSpellLevel(iSpellID, oCaster) + GetAbilityModifier(ABILITY_CHARISMA, oCaster);
    } else {
        //*:**********************************************
        //*:* Tyranny Domain granted power - Compulsion spells +2 DC
        //*:**********************************************
        if(GRGetHasDomain(DOMAIN_TYRANNY, oCaster) && GRGetSpellSubschool(iSpellID, oCaster)==SPELL_SUBSCHOOL_COMPULSION)
            iSpellSaveDC += 2;
        //*:**********************************************
        //*:* Horrid Wilting vs water elementals and plant creatures +2 DC
        //*:**********************************************
        if(iSpellID==SPELL_HORRID_WILTING && GRGetRacialType(oTarget)==RACIAL_TYPE_ELEMENTAL &&
            FindSubString(GetStringLowerCase(GetName(oTarget)),"water")>-1)
                iSpellSaveDC += 2;
        //*:**********************************************
        //*:* Caster has Harmonic Chorus effect
        //*:**********************************************
        if(GetHasSpellEffect(SPELL_GR_HARMONIC_CHORUS, oCaster)) iSpellSaveDC += 2;
        //*:**********************************************
        //*:* Armor of Darkness vs light & good spells
        //*:**********************************************
        if(GetHasSpellEffect(SPELL_GR_ARMOR_DARKNESS , oTarget) &&
            (GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_LIGHT, oCaster) ||
             GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_GOOD, oCaster)))
                iSpellSaveDC -= 2;
        //*:**********************************************
        //*:* Purple Dragon Knight Inspire Courage vs Charm
        //*:**********************************************
        if(GRGetSpellSubschool(iSpellID, oCaster)==SPELL_SUBSCHOOL_CHARM && GetHasSpellEffect(811, oTarget)) {
            iSpellSaveDC -= 2;
        }
        if(GetLocalInt(oCaster, "GR_L_SPELLTURN_CASTER_LEVEL")>0) {
            iSpellSaveDC = 10 + GetLocalInt(oCaster, "GR_L_SPELLTURN_CASTER_LEVEL");
        }
    }

    return iSpellSaveDC;
}

//*:**********************************************
//*:* GRGetSpellSchool
//*:**********************************************
//*:*
//*:* Sets a spell school on the caster.  For use
//*:* with getting caster levels.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
int GRGetSpellSchool(int iSpellID, object oCaster=OBJECT_SELF) {

    int iSpellSchool = SPELL_SCHOOL_GENERAL;

    if(GetIsObjectValid(oCaster))
        iSpellSchool = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SCHOOL");

    return iSpellSchool;
}

//*:**********************************************
//*:* GRGetSpellSubschool
//*:**********************************************
//*:*
//*:* Sets a spell school on the caster.  For use
//*:* with getting caster levels.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
int GRGetSpellSubschool(int iSpellID, object oCaster=OBJECT_SELF) {

    int iSpellSubschool = SPELL_SUBSCHOOL_GENERAL;

    if(GetIsObjectValid(oCaster))
        iSpellSubschool = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SUBSCHOOL");

    return iSpellSubschool;
}

//*:**********************************************
//*:* GRSetKilledByDeathEffect
//*:**********************************************
//*:*
//*:* Sets that oTarget was killed by a death effect.
//*:* Used for check in Raise Dead
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 8, 2007
//*:**********************************************
void GRSetKilledByDeathEffect(object oTarget, object oCaster=OBJECT_SELF) {
    if(!GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, oCaster)) {
        SetLocalInt(oTarget, "GR_KILLED_DEATH_EFFECT", TRUE);
    }
}

void GRSetIsPlayerSpell(int iSpellID, int bPlayerSpell, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_PLAYERSPELL", bPlayerSpell);
}

//*:**********************************************
//*:* GRSetIsSpellTurnable
//*:**********************************************
//*:*
//*:* Sets spell turnable information on caster.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2007
//*:**********************************************
//*:* Updated On:
//*:**********************************************
void GRSetIsSpellTurnable(int iSpellID, int bTurnable, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_TURNABLE", bTurnable);
}

//*:**********************************************
//*:* GRSetSpellCastClass
//*:**********************************************
//*:*
//*:* Sets spell casting class info on caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2007
//*:**********************************************
//*:* Updated On:
//*:**********************************************
void GRSetSpellCastClass(int iSpellID, int iSpellCastClass, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_CASTCLASS", iSpellCastClass);
}

//*:**********************************************
//*:* GRSetSpellCasterLevel
//*:**********************************************
//*:*
//*:* Sets spell caster level info on caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**********************************************
void GRSetSpellCasterLevel(int iSpellID, int iCasterLevel, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_CASTERLEVEL", iCasterLevel);
}

//*:**********************************************
//*:* GRSetSpellDescriptor
//*:**********************************************
//*:*
//*:* Sets a spell descriptor on the caster.  For use
//*:* with getting "Creation" or "Healing" spells, etc.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
void GRSetSpellDescriptor(int iSpellID, int iSpellType, object oCaster=OBJECT_SELF, int iPosition = 1) {

    if(GetIsObjectValid(oCaster)) {
        DeleteLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_DESCRIPTOR_"+IntToString(iPosition));
        SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_DESCRIPTOR_"+IntToString(iPosition), iSpellType);
    }
}

//*:**********************************************
//*:* GRSetSpellDmgBonus
//*:**********************************************
//*:*
//*:* Sets the spells' damage bonus on the caster.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 17, 2007
//*:**********************************************
void GRSetSpellDmgBonus(int iSpellID, int iDmgBonus, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster,"GR_"+IntToString(iSpellID)+"_DMGBONUS", iDmgBonus);
}

//*:**********************************************
//*:* GRSetSpellDmgChangePct
//*:**********************************************
//*:*
//*:* Set damage change percentage on caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 17, 2007
//*:**********************************************
void GRSetSpellDmgChangePct(int iSpellID, float fDmgChangePct, object oCaster=OBJECT_SELF) {

    SetLocalFloat(oCaster,"GR_"+IntToString(iSpellID)+"_DMGCHANGEPCT", fDmgChangePct);
}

//*:**********************************************
//*:* GRSetSpellDmgDieType
//*:**********************************************
//*:*
//*:* Sets the spells' damage die type on caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 17, 2007
//*:**********************************************
void GRSetSpellDmgDieType(int iSpellID, int iDmgDieType, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster,"GR_"+IntToString(iSpellID)+"_DMGDIETYPE", iDmgDieType);
}

//*:**********************************************
//*:* GRSetSpellDmgNumDice
//*:**********************************************
//*:*
//*:* Sets the spells' number of damage dice on the caster.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 17, 2007
//*:**********************************************
void GRSetSpellDmgNumDice(int iSpellID, int iDmgNumDice, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster,"GR_"+IntToString(iSpellID)+"_DMGNUMDICE", iDmgNumDice);
}

void GRSetSpellDmgOverride(int iSpellID, int iDmgOverride, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster,"GR_"+IntToString(iSpellID)+"_DMGOVERRIDE", iDmgOverride);
}

//*:**********************************************
//*:* GRSetSpellDurAmount
//*:**********************************************
//*:*
//*:* Sets the amount for the spell duration on caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 17, 2007
//*:**********************************************
void GRSetSpellDurAmount(int iSpellID, int iDurAmount, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster,"GR_"+IntToString(iSpellID)+"_DURAMOUNT", iDurAmount);
}

//*:**********************************************
//*:* GRSetSpellDurOverride
//*:**********************************************
//*:*
//*:* Sets duration override value on the caster.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 17, 2007
//*:**********************************************
void GRSetSpellDurOverride(int iSpellID, float fDurOverride, object oCaster=OBJECT_SELF) {

    SetLocalFloat(oCaster,"GR_"+IntToString(iSpellID)+"_DUROVERRIDE", fDurOverride);
}

//*:**********************************************
//*:* GRSetSpellDurType
//*:**********************************************
//*:*
//*:* Sets the spells' duration type (rounds, turns)
//*:* on the caster.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 17, 2007
//*:**********************************************
void GRSetSpellDurType(int iSpellID, int iDurType, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster,"GR_"+IntToString(iSpellID)+"_DURTYPE", iDurType);
}

//*:**********************************************
//*:* GRSetSpellEpicSpellCraftDC
//*:**********************************************
//*:*
//*:* Sets the spells' epic spellcraft check dc
//*:* on the caster.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 10, 2008
//*:**********************************************
void GRSetSpellEpicSpellCraftDC(int iSpellID, int iEpicSpellcraftDC, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster,"GR_"+IntToString(iSpellID)+"_EPICSPELLCRAFTDC", iEpicSpellcraftDC);
}

//*:**********************************************
//*:* GRSetSpellIsEpic
//*:**********************************************
//*:*
//*:* Boolean for epic spells - to be used in
//*:* spellhook for spellcraft check
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 10, 2008
//*:**********************************************
void GRSetSpellIsEpic(int iSpellID, int bEpicSpell, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster,"GR_"+IntToString(iSpellID)+"_ISEPICSPELL", bEpicSpell);
}

//*:**********************************************
//*:* GRSetSpellLevel
//*:**********************************************
//*:*
//*:* Sets spell level info on caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2007
//*:**********************************************
//*:* Updated On:
//*:**********************************************
void GRSetSpellLevel(int iSpellID, int iSpellLevel, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SPELLLEVEL", iSpellLevel);
}

//*:**********************************************
//*:* GRSetSpellMetamagic
//*:**********************************************
//*:*
//*:* Sets spell metamagic info on caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**********************************************
void GRSetSpellMetamagic(int iSpellID, int iMetamagic, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_METAMAGIC", iMetamagic);
}

//*:**********************************************
//*:* GRSetSpellRequiresConcentration
//*:**********************************************
//*:*
//*:* Sets whether spell requires concentration
//*:* on caster.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 19, 2007
//*:**********************************************
void GRSetSpellRequiresConcentration(int iSpellID, int iRequiresConcentration, object oCaster=OBJECT_SELF) {

    if(GetIsObjectValid(oCaster)) {
        SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_REQCONCENTRATION", iRequiresConcentration);
    }
}

//*:**********************************************
//*:* GRSetSpellSchool
//*:**********************************************
//*:*
//*:* Sets a spell school on the caster.  For use
//*:* with getting caster levels.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
void GRSetSpellSchool(int iSpellID, int iSchoolType=SPELL_SCHOOL_GENERAL, object oCaster=OBJECT_SELF) {

    if(GetIsObjectValid(oCaster)) {
        DeleteLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SCHOOL");
        SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SCHOOL", iSchoolType);
    }
}

//*:**********************************************
//*:* GRSetSpellSubschool
//*:**********************************************
//*:*
//*:* Sets a spell school on the caster.  For use
//*:* with getting caster levels.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
void GRSetSpellSubschool(int iSpellID, int iSubschoolType=SPELL_SUBSCHOOL_GENERAL, object oCaster=OBJECT_SELF) {

    if(GetIsObjectValid(oCaster)) {
        DeleteLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SUBSCHOOL");
        SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SUBSCHOOL", iSubschoolType);
    }
}

//*:**********************************************
//*:* GRSetSpellTarget
//*:**********************************************
//*:*
//*:* Sets a new target on the caster.  Returns an
//*:* object to assign to SpellStruct target
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
void GRSetSpellTarget(int iSpellID, object oTarget, object oCaster=OBJECT_SELF) {

    if(GetIsObjectValid(oCaster)) {
        DeleteLocalObject(oCaster, "GR_"+IntToString(iSpellID)+"_TARGET");
        SetLocalObject(oCaster, "GR_"+IntToString(iSpellID)+"_TARGET", oTarget);
    }

}

//*:**********************************************
//*:* GRSetSpellLocation
//*:**********************************************
//*:*
//*:* Sets the spell's target locaton on the caster.
//*:* Returns the location to assign to SpellStruct lTarget
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
void GRSetSpellLocation(int iSpellID, location lTarget, object oCaster=OBJECT_SELF) {

    if(GetIsObjectValid(oCaster)) {
        DeleteLocalLocation(oCaster, "GR_"+IntToString(iSpellID)+"_LOCATION");
        SetLocalLocation(oCaster, "GR_"+IntToString(iSpellID)+"_LOCATION", lTarget);
    }

}

//*:**********************************************
//*:* GRSetSpellDC
//*:**********************************************
//*:*
//*:* Sets a new spell DC on the caster.
//*:* Returns the DC to assign to SpellStruct DC
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2005
//*:**********************************************
//*:* Updated On: February 13, 2007
//*:**********************************************
void GRSetSpellDC(int iSpellID, int iDC, object oCaster=OBJECT_SELF) {

    if(GetIsObjectValid(oCaster)) {
        DeleteLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_DC");
        SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_DC", iDC);
    }

}

//*:**********************************************
//*:* GRSetSpellSecDmgAmountType
//*:**********************************************
//*:*
//*:* Sets SECDMG_TYPE_* constant on caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 24, 2007
//*:**********************************************
void GRSetSpellSecDmgAmountType(int iSpellID, int iSecDmgAmountType, object oCaster=OBJECT_SELF) {

    if(GetIsObjectValid(oCaster)) {
        DeleteLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SECDMGAMTTYPE");
        SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SECDMGAMTTYPE", iSecDmgAmountType);
    }
}

//*:**********************************************
//*:* GRSetSpellSecDmgOverride
//*:**********************************************
//*:*
//*:* Sets SECDMG_TYPE_* constant on caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 24, 2007
//*:**********************************************
void GRSetSpellSecDmgOverride(int iSpellID, int iSecDmgOverride, object oCaster=OBJECT_SELF) {

    if(GetIsObjectValid(oCaster)) {
        DeleteLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SECDMGOVERRIDE");
        SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SECDMGOVERRIDE", iSecDmgOverride);
    }
}

//*:**********************************************
//*:* GRSetSpellSecDmgType
//*:**********************************************
//*:*
//*:* Sets SECDMG_TYPE_* constant on caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 24, 2007
//*:**********************************************
void GRSetSpellSecDmgType(int iSpellID, int iSecDmgType, object oCaster=OBJECT_SELF) {

    if(GetIsObjectValid(oCaster)) {
        DeleteLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SECDMGTYPE");
        SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SECDMGTYPE", iSecDmgType);
    }
}

//*:**********************************************
//*:* GRSetSpellXPCost
//*:**********************************************
//*:*
//*:* Sets the xp material component cost on the
//*:* caster
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 24, 2007
//*:**********************************************
void GRSetSpellXPCost(int iSpellID, int iXPCost, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_XPCOST", iXPCost);
}

void GRSetSpellDmgSaveMade(int iSpellID, int bDmgSaveMade, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_DMGSAVEMADE", bDmgSaveMade);
}

//*:**********************************************
//*:* GRGetIsCorporeal
//*:*   (formerly SGGetIsCorporeal)
//*:**********************************************
//*:*
//*:*  Checks to see if target is corporeal or not
//*:*  (ie ethereal, gaseous form, etc)
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 16, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetIsIncorporeal(object oTarget) {

    return GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL);
}

//*:**********************************************
//*:* GRSetIsCorporeal
//*:*   (formerly SGSetIsCorporeal)
//*:**********************************************
//*:*
//*:* Sets whether the target is corporeal or not
//*:* (ie ethereal, gaseous form, etc)
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 16, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
void GRSetIsIncorporeal(object oTarget, int bIsCorporeal) {

    SetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL, bIsCorporeal);
}

//*:**********************************************
//*:* GRGetAlignmentImpactVisual
//*:**********************************************
//*:*
//*:* Gets VFX_FNF_LOS_XXX visual based on alignment
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 8, 2007
//*:**********************************************
int GRGetAlignmentImpactVisual(object oCaster=OBJECT_SELF, float fRange = -1.0) {

    int iAlign = GetAlignmentGoodEvil(oCaster);
    int iVisual = VFX_FNF_LOS_NORMAL_20;

    if(GetLastSpellCastClass()!=CLASS_TYPE_CLERIC) iAlign = ALIGNMENT_NEUTRAL;

    switch(iAlign) {
        case ALIGNMENT_GOOD:
            if(fRange<1.6) {
                iVisual = VFX_FNF_LOS_HOLY_10;
            } else if(fRange<4.0) {
                iVisual = VFX_FNF_LOS_HOLY_20;
            } else if(fRange>4.5 || fRange==-1.0) {
                iVisual = VFX_FNF_LOS_HOLY_30;
            }
            break;
        case ALIGNMENT_NEUTRAL:
            if(fRange<1.6) {
                iVisual = VFX_FNF_LOS_NORMAL_10;
            } else if(fRange<3.1) {
                iVisual = VFX_FNF_LOS_NORMAL_20;
            } else if(fRange>4.5 || fRange==-1.0) {
                iVisual = VFX_FNF_LOS_NORMAL_30;
            }
            break;
        case ALIGNMENT_EVIL:
            if(fRange<1.6) {
                iVisual = VFX_FNF_LOS_EVIL_10;
            } else if(fRange<3.1) {
                iVisual = VFX_FNF_LOS_EVIL_20;
            } else if(fRange>4.5 || fRange==-1.0) {
                iVisual = VFX_FNF_LOS_EVIL_30;
            }
            break;
    }

    return iVisual;
}

//*:**********************************************
//*:* GRGetDiseaseType
//*:**********************************************
//*:*
//*:* Removing common code out of bolts/cones monster
//*:* abilities
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 27, 2005
//*:**********************************************
int GRGetDiseaseType(int iCasterLevel, object oCaster=OBJECT_SELF) {

    int iDisease;

    switch(GRGetRacialType(oCaster)) {
        case RACIAL_TYPE_OUTSIDER:
            iDisease = DISEASE_DEMON_FEVER;
            break;
        case RACIAL_TYPE_VERMIN:
            iDisease = DISEASE_VERMIN_MADNESS;
            break;
        case RACIAL_TYPE_UNDEAD:
            if(iCasterLevel<4) {
                iDisease = DISEASE_ZOMBIE_CREEP;
            } else if(iCasterLevel<11) {
                iDisease = DISEASE_GHOUL_ROT;
            } else {
                iDisease = DISEASE_MUMMY_ROT;
            }
        default:
            if(iCasterLevel<4) {
                iDisease = DISEASE_MINDFIRE;
            } else if(iCasterLevel<11) {
                iDisease = DISEASE_RED_ACHE;
            } else {
                iDisease = DISEASE_SHAKES;
            }
            break;
    }

    return iDisease;
}

//*:**********************************************
//*:* GRGetPoisonType
//*:**********************************************
//*:*
//*:* Removing common code out of bolts/cones monster
//*:* abilities
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 27, 2005
//*:**********************************************
int GRGetPoisonType(int iCasterLevel, object oCaster=OBJECT_SELF) {

    int iPoison;

    switch(GRGetRacialType(oCaster)) {
        case RACIAL_TYPE_CONSTRUCT:
            iPoison = POISON_IRON_GOLEM;
            break;
        case RACIAL_TYPE_OUTSIDER:
            if(iCasterLevel<10) {
                iPoison = POISON_QUASIT_VENOM;
            } else if(iCasterLevel<13) {
                iPoison = POISON_BEBILITH_VENOM;
            } else {
                iPoison = POISON_PIT_FIEND_ICHOR;
            }
            break;
        case RACIAL_TYPE_VERMIN:
            if(iCasterLevel<3) {
                iPoison = POISON_TINY_SPIDER_VENOM;
            } else if(iCasterLevel<6) {
                iPoison = POISON_SMALL_SPIDER_VENOM;
            } else if(iCasterLevel<9) {
                iPoison = POISON_MEDIUM_SPIDER_VENOM;
            } else if(iCasterLevel<12) {
                iPoison =  POISON_LARGE_SPIDER_VENOM;
            } else if(iCasterLevel<15) {
                iPoison = POISON_HUGE_SPIDER_VENOM;
            } else if(iCasterLevel<18) {
                iPoison = POISON_GARGANTUAN_SPIDER_VENOM;
            } else {
                iPoison = POISON_COLOSSAL_SPIDER_VENOM;
            }
            break;
        default:
            if(iCasterLevel<3) {
                iPoison = POISON_NIGHTSHADE;
            } else if(iCasterLevel<6) {
                iPoison = POISON_BLADE_BANE;
            } else if(iCasterLevel<9) {
                iPoison = POISON_BLOODROOT;
            } else if(iCasterLevel<12) {
                iPoison =  POISON_LARGE_SPIDER_VENOM;
            } else if(iCasterLevel<15) {
                iPoison = POISON_LICH_DUST;
            } else if(iCasterLevel<18) {
                iPoison = POISON_DARK_REAVER_POWDER;
            } else {
                iPoison = POISON_BLACK_LOTUS_EXTRACT;
            }
            break;
    }

    return iPoison;
}

//*:**********************************************
//*:* GRGetAlignmentDetectionBlocked
//*:**********************************************
//*:*
//*:* Checks if alignment detection is blocked for
//*:* some reason
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 15, 2007
//*:**********************************************
int GRGetAlignmentDetectionBlocked(object oTarget, object oCaster = OBJECT_SELF) {

    return GetHasSpellEffect(SPELL_GR_UNDETECTABLE_ALIGNMENT, oTarget);
}

//*:**********************************************
//*:* GRApplyXPCostToCaster
//*:**********************************************
//*:*
//*:* Deducts XP Component cost from caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 19, 2007
//*:**********************************************
void GRApplyXPCostToCaster(int iXPLossAmount, object oCaster=OBJECT_SELF) {

    if(GetLocalInt(GetModule(), "GR_USE_SPELL_XP_COST")) {
        if(GetObjectType(oCaster)==OBJECT_TYPE_CREATURE && GetSpellCastItem()==OBJECT_INVALID) {
            SetXP(oCaster, GetXP(oCaster)-iXPLossAmount);
        }
    }
}


int GRGetScaledBlindDeafDuration() {

    int iDurType = 0;

    switch(GetGameDifficulty()) {
        case GAME_DIFFICULTY_VERY_EASY:
            iDurType = DUR_TYPE_ROUNDS;
            break;
        case GAME_DIFFICULTY_EASY:
            iDurType = DUR_TYPE_TURNS;
            break;
        case GAME_DIFFICULTY_NORMAL:
            iDurType = DUR_TYPE_HOURS;
            break;
        case GAME_DIFFICULTY_CORE_RULES:
        case GAME_DIFFICULTY_DIFFICULT:
            iDurType = 5;
            break;
    }

    return iDurType;
}

object GRCheckMisdirection(object oTarget, object oCaster = OBJECT_SELF) {

    object oCheckObject = oTarget;

    if(GetHasSpellEffect(SPELL_GR_MISDIRECTION, oTarget)) {
        int iHD = GetHitDice(oTarget);
        int iBonus;

        if(iHD<5) iBonus = 0;
        else if(iHD<15) iBonus = 2;
        else iBonus = 4;
        int iDC = 12 + iBonus;

        if(!GRGetSaveResult(SAVING_THROW_WILL, oCaster, iDC)) {
            oCheckObject = GetLocalObject(oTarget, "GR_MISDIRECT_TARGET");
        }
    }

    return oCheckObject;
}

//*:**************************************************************************
void GRDoSpellTurning(struct SpellStruct spInfo, object oTarget, object oCaster) {

    int     iTargetLevels = GetLocalInt(oTarget, "GR_SPELLTURN_LEVELS");
    int     iCasterLevels = GetLocalInt(oCaster, "GR_SPELLTURN_LEVELS");
    int     bTargetAffected = FALSE;
    int     bCasterAffected = TRUE;
    float   fTargetPercent = 1.0;
    float   fCasterPercent = 1.0;
    int     iTargetEffect = (GetHasSpellEffect(SPELL_SPELL_TURNING, oTarget) ? SPELL_SPELL_TURNING : SPELL_GR_LESSER_SPELL_TURNING);

    //*:**********************************************
    //*:* Just in case they somehow still have the spell
    //*:* effect, but used up all their levels
    //*:**********************************************
    if(iTargetLevels<=0) {
        bTargetAffected = TRUE;
        GRRemoveSpellEffects(iTargetEffect, oTarget);
    } else {
        //*:**********************************************
        //*:* If caster does not have a turning effect
        //*:**********************************************
        if(iCasterLevels<=0) {
            //*:**********************************************
            //*:* target has enough levels to fully reflect
            //*:**********************************************
            if(iTargetLevels>=spInfo.iSpellLevel) {
                iTargetLevels -= spInfo.iSpellLevel;
            } else {
            //*:**********************************************
            //*:* target has levels to partially reflect
            //*:**********************************************
                //*:**********************************************
                //*:* compute percentages
                //*:**********************************************
                float fPassThroughLevels = IntToFloat(spInfo.iSpellLevel - iTargetLevels);
                float fReflectedLevels = IntToFloat(iTargetLevels);
                iTargetLevels = 0;
                fTargetPercent = fPassThroughLevels/IntToFloat(spInfo.iSpellLevel);
                fCasterPercent = fReflectedLevels/IntToFloat(spInfo.iSpellLevel);
                //*:**********************************************
                //*:* check number of dice to determine if damage spell
                //*:**********************************************
                if(spInfo.iDmgNumDice>0) {
                    bTargetAffected = TRUE;
                    bCasterAffected = TRUE;
                } else {
                //*:**********************************************
                //*:* use percentages to see if affected by spell
                //*:* at all
                //*:**********************************************
                    bTargetAffected = (d100()<=FloatToInt(fTargetPercent*100));
                    bCasterAffected = (d100()<=FloatToInt(fCasterPercent*100));
                }
            }
        } else {
            //*:**********************************************
            //*:* caster has a turning effect
            //*:**********************************************
            effect eVis1 = EffectVisualEffect(VFX_IMP_AC_BONUS);
            effect eVis2 = EffectBeam(VFX_BEAM_LIGHTNING, oTarget, BODY_NODE_CHEST);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oTarget);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oCaster);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis2, oCaster, 2.2f);

            int iCasterEffect = (GetHasSpellEffect(SPELL_SPELL_TURNING, oTarget) ? SPELL_SPELL_TURNING : SPELL_GR_LESSER_SPELL_TURNING);
            int iTableResult = d100();
            if(iTableResult<71) {
                bCasterAffected = FALSE;
            } else if(iTableResult<81) {
                bTargetAffected = TRUE;
            } else if(iTableResult<98) {
                GRRemoveSpellEffects(iCasterEffect, oCaster);
                bCasterAffected = FALSE;
                DeleteLocalInt(oCaster, "GR_SPELLTURN_LEVELS");
                GRRemoveSpellEffects(iTargetEffect, oTarget);
                DeleteLocalInt(oTarget, "GR_SPELLTURN_LEVELS");
            } else {
                //*:**********************************************
                //*:* Kill Target and Caster
                //*:**********************************************
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH), oTarget);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH), oCaster);
                DelayCommand(2.0, GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetMaxHitPoints(oTarget)*2), oTarget));
                DelayCommand(2.0, GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetMaxHitPoints(oCaster)*2), oCaster));
                bCasterAffected = FALSE;
            }
        }
        //*:**********************************************
        //*:* Finish results
        //*:**********************************************
        if(bCasterAffected) {
            SetLocalInt(oTarget, "GR_SPELL_REFLECTION", TRUE);
            SetLocalInt(oTarget, "GR_SPELL_REFLECTION_CLVL", spInfo.iCasterLevel);
            SetLocalInt(oTarget, "GR_SPELL_REFLECTION_DC", spInfo.iDC);
            SetLocalInt(oTarget, "GR_SPELL_REFLECTION_MM", spInfo.iMetamagic);
            SetLocalFloat(oTarget, "GR_SPELL_REFLECTION_DMGPCT", fCasterPercent);
            AssignCommand(oTarget, ActionCastSpellAtObject(spInfo.iSpellID, oCaster, spInfo.iMetamagic, TRUE, spInfo.iCasterLevel, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
        }
        SetLocalInt(oTarget, "GR_SPELLTURN_TARGET_AFFECTED", bTargetAffected);
        if(bTargetAffected) {
            spInfo.fDmgChangePct = fTargetPercent;
            GRSetSpellInfo(spInfo, oCaster);
        }
    }
}
//*:**********************************************
//*:* GRDoDiscordantMalediction
//*:* 2008 Karl Nickels (Syrus Greycloak)
//*:**********************************************
int GRDoDiscordantMalediction(object oCaster) {
    int     iSpellID    = SPELL_GR_DISCORDANT_MALEDICTION;
    int     iMetamagic  = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_METAMAGIC");
    float   fRange      = GetLocalFloat(oCaster, "GR_"+IntToString(iSpellID)+"_RANGE");
    int     iEnergyType = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_ENERGYTYPE");
    int     iVisualType = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_VISUALTYPE");
    int     iSecDmgType = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SECDMGTYPE");
    int     iSecDmgAmountType = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SECDMGAMOUNTTYPE");
    int     iSecDmgOverride = GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_SECDMGOVERRIDE");
    location lTarget    = GetLocation(oCaster);
    int     iDamage     = 0;
    int     iSecDamage  = 0;
    int     iCasterDamage;

    object  oTarget     = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, lTarget);

    while(GetIsObjectValid(oTarget)) {
        SignalEvent(oTarget, EventSpellCastAt(oCaster, iSpellID));
        iDamage = GRGetMetamagicAdjustedDamage(6, 2, iMetamagic, 0);
        effect eDamage = EffectDamage(iDamage, iEnergyType);
        if(iSecDmgAmountType>0) iSecDamage = (iSecDmgOverride>0 ? iSecDmgOverride : GRGetSpellSecDmgAmt(iDamage, 6, 2, iMetamagic, 0, iSecDmgAmountType));
        if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, iSecDmgType));

        GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(iVisualType), oTarget);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || iSecDmgType==DAMAGE_TYPE_FIRE)) {
            GRDoIncendiarySlimeExplosion(oTarget);
        }
        if(oTarget==oCaster) iCasterDamage = iDamage + iSecDamage;

        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, lTarget);
    }

    return iCasterDamage;
}
//*:**********************************************
//*:* GRDoIncendiarySlimeExplosion
//*:* 2008 Karl Nickels (Syrus Greycloak)
//*:**********************************************
void GRDoIncendiarySlimeExplosion(object oTarget) {

    int i = 0;
    int bFound = FALSE;
    location lTarget = GetLocation(oTarget);
    object oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lTarget, i);

    while(GetIsObjectValid(oAOE) && i<20) {
        string sTag = GetTag(oAOE);
        /*** NWN1 SINGLE ***/ if(sTag!=AOE_TYPE_INCENDIARY_SLIME && sTag!=AOE_TYPE_INCENDIARY_SLIME_WIDE) {
        //*** NWN2 SINGLE ***/ if(sTag!=AOE_TYPE_INCENDIARY_SLIME && GRGetAOESpellId(oAOE)!=SPELL_GR_INCENDIARY_SLIME) {
            i++;
        } else {
            int iDamage = 0;
            int iSecDamage = 0;
            struct SpellStruct spInfo = GRGetSpellInfoFromObject(SPELL_GR_INCENDIARY_SLIME, oAOE);
            spInfo.iDmgDieType = 6;
            spInfo.iDmgNumDice = 4;
            spInfo.iDmgBonus = 0;

            GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_FIREBALL), spInfo.lTarget);
            object oExplodeTarget = GetFirstInPersistentObject(oAOE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

            while(GetIsObjectValid(oExplodeTarget)) {
                SignalEvent(oExplodeTarget, EventSpellCastAt(oAOE, SPELL_GR_INCENDIARY_SLIME, TRUE));
                float fDelay = GetDistanceBetweenLocations(GetLocation(oExplodeTarget), spInfo.lTarget)/20.0;
                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, spInfo.oCaster, SAVING_THROW_TYPE_FIRE, fDelay);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, spInfo.oCaster, SAVING_THROW_TYPE_FIRE, fDelay);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                if(iDamage>0) {
                    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
                    effect eDamage = EffectDamage(iDamage, DAMAGE_TYPE_FIRE);
                    if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    effect eLink = EffectLinkEffects(eVis, eDamage);
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oExplodeTarget);
                }
                oExplodeTarget = GetNextInPersistentObject(oAOE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
            }

            DestroyObject(oAOE);
        }
        oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lTarget, i);
    }
}

int GRGetSpellSlotLevel(int iSpellLevel, int iMetamagic) {

    if(GRGetMetamagicUsed(iMetamagic, METAMAGIC_EXTEND) ||
        GRGetMetamagicUsed(iMetamagic, METAMAGIC_SILENT) ||
        GRGetMetamagicUsed(iMetamagic, METAMAGIC_STILL)  )
            iSpellLevel += 1;

    if(GRGetMetamagicUsed(iMetamagic, METAMAGIC_EMPOWER))
        iSpellLevel += 2;

    /*** NWN1 SPECIFIC ***/
    if(GRGetMetamagicUsed(iMetamagic, METAMAGIC_MAXIMIZE) ||
        GRGetMetamagicUsed(iMetamagic, METAMAGIC_WIDEN)  )
            iSpellLevel += 3;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
    if(GRGetMetamagicUsed(iMetamagic, METAMAGIC_MAXIMIZE))
            iSpellLevel += 3;
    /*** END NWN2 SPECIFIC ***/

    if(GRGetMetamagicUsed(iMetamagic, METAMAGIC_QUICKEN))
        iSpellLevel += 4;

    return iSpellLevel;
}

int GRSpellHasVerbalComponent(int iSpellID) {
    string components = Get2DAString("spells", "VS", iSpellID);

    return (FindSubString(GetStringUpperCase(components), "V")>-1);
}

int GRSpellHasSomaticComponent(int iSpellID) {
    string components = Get2DAString("spells", "VS", iSpellID);

    return (FindSubString(GetStringUpperCase(components), "S")>-1);
}

//*:**********************************************
//*:* GRDoTrapSpike
//*:* Copyright (c) 2001 Bioware Corp.
//*:**********************************************
//*:*
//*:* Does a spike trap. Reflex save allowed.
//*:*
//*:**********************************************
//*:* Created By:
//*:* Created On:
//*:**********************************************
//*:* apply effects of spike trap on entering object
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRDoTrapSpike(int iDamage) {

    object oTarget = GetEnteringObject();

    int iRealDamage = GRGetReflexAdjustedDamage(iDamage, oTarget, 15, SAVING_THROW_TYPE_TRAP, OBJECT_SELF);
    if(iDamage > 0) {
        effect eDam = EffectDamage(iRealDamage, DAMAGE_TYPE_PIERCING);
        effect eVis = EffectVisualEffect(253);
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oTarget));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
    }
}

//*:**********************************************
//*:* GRDoPetrification
//*:* Copyright (c) 2001 Bioware Corp.
//*:**********************************************
// *  This is a wrapper for how Petrify will work in Expansion Pack 1
// * Scripts affected: flesh to stone, breath petrification, gaze petrification, touch petrification
// * iPower : This is the Hit Dice of a Monster using Gaze, Breath or Touch OR it is the Caster Spell of
// *   a spellcaster
// * iFortSaveDC: pass in this number from the spell script
//*:* only script that will not pass iFortSaveDC is beholder ray paralyze
//*:* or any script that has already done the saving throw and failed
//*:**********************************************
//*:* Updated On: January 29, 2008
//*:**********************************************
void GRDoPetrification(int iPower, object oSource, object oTarget, int iSpellID, int iFortSaveDC = -1) {

    if(!GetIsReactionTypeFriendly(oTarget) && !GetIsDead(oTarget)) {
        // * exit if creature is immune to petrification
        if(spellsIsImmuneToPetrification(oTarget) == TRUE) {
            return;
        }

        float   fDuration       = 0.0f;
        int     bIsPC           = GetIsPC(oTarget);
        int     bShowPopup      = FALSE;

        // * calculate Duration based on difficulty settings
        int     iGameDiff       = GetGameDifficulty();
        int     iSaveDC         = abs(iFortSaveDC);

        switch(iGameDiff) {
            case GAME_DIFFICULTY_VERY_EASY:
            case GAME_DIFFICULTY_EASY:
            case GAME_DIFFICULTY_NORMAL:
                    fDuration = GRGetDuration(iPower); // One Round per hit-die or caster level
                break;
            case GAME_DIFFICULTY_CORE_RULES:
            case GAME_DIFFICULTY_DIFFICULT:
                if(!GetPlotFlag(oTarget)) {
                    bShowPopup = TRUE;
                }
            break;
        }

        effect ePetrify     = EffectPetrify();
        effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
        effect eLink        = EffectLinkEffects(eDur, ePetrify);

        // Let target know the negative spell has been cast
        if(iFortSaveDC!=-1) {
            SignalEvent(oTarget, EventSpellCastAt(oSource, iSpellID));
            //SpeakString(IntToString(iSpellID));
        }

        // Do a fortitude save check
        if(iFortSaveDC==-1 || !GRGetSaveResult(SAVING_THROW_FORT, oTarget, iSaveDC)) {
            // Save failed; apply paralyze effect and VFX impact
            /// * The duration is permanent against NPCs but only temporary against PCs
            if(bIsPC==TRUE) {
                if(bShowPopup==TRUE) {
                    // * under hardcore rules or higher, this is an instant death
                    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
                    DelayCommand(2.75, PopUpDeathGUIPanel(oTarget, FALSE , TRUE, 40579));
                    // if in hardcore, treat the player as an NPC
                    bIsPC = FALSE;
                } else {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, fDuration);
                }
            } else {
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);

                //----------------------------------------------------------
                // GZ: Fix for henchmen statues haunting you when changing
                //     areas. Henchmen are now kicked from the party if
                //     petrified.
                //----------------------------------------------------------
                if (GetAssociateType(oTarget) == ASSOCIATE_TYPE_HENCHMAN)
                {
                    FireHenchman(GetMaster(oTarget),oTarget);
                }
                // April 2003: Clearing actions to kick them out of conversation when petrified
                AssignCommand(oTarget, ClearAllActions(TRUE));
            }
        }
    }
}

void GRRemoveSpellSubschoolEffects(int iSubschool, object oTarget, object oCaster = OBJECT_INVALID) {

    int bRemove;
    effect eEff = GetFirstEffect(oTarget);

    while(GetIsEffectValid(eEff)) {
        bRemove = FALSE;
        int iSpellID = GetEffectSpellId(eEff);
        if(GRGetSpellSubschoolFromSpellId(iSpellID)==iSubschool) {
            GRRemoveEffect(eEff, oTarget);
            //*** NWN2 SINGLE ***/ bRemove = TRUE;
        }
        eEff = (bRemove ? GetFirstEffect(oTarget) : GetNextEffect(oTarget));
    }
}
//*:**************************************************************************
