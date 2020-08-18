//*:**************************************************************************
//*:*  GR_IN_UNDWATER.NSS
//*:**************************************************************************
//*:*
//*:* Functions to assist underwater spell-casting
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IN_SPELLS"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
int     GRGetCanCastSpellUnderwater(int iSpellID, object oCaster=OBJECT_SELF);
int     GRGetUnderwaterFireSuccess(int iEnergyType, object oCaster=OBJECT_SELF);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRGetCanCastSpellUnderwater
//*:**********************************************
//*:*
//*:* Checks if spell can be cast underwater
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2007
//*:**********************************************
//*:* Updated On:
//*:**********************************************
int GRGetCanCastSpellUnderwater(int iSpellID, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "GR_"+IntToString(iSpellID)+"_UNDERWATER");
}

//*:**********************************************
//*:* GRGetUnderwaterFireSuccess
//*:**********************************************
//*:*
//*:* Makes a spellcraft check vs 20+spell level
//*:* for fire spells cast underwater
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetUnderwaterFireSuccess(int iSpellID, object oCaster=OBJECT_SELF) {

    if(!GRGetIsUnderwater(oCaster)) return TRUE;

    if(!GRGetSpellHasDescriptor(iSpellID, SPELL_TYPE_FIRE)) return TRUE;

    int iAbilityModifier = 0;

    int iCastingClass = GetLastSpellCastClass();
    switch(iCastingClass) {
        case CLASS_TYPE_BARD:
        case CLASS_TYPE_SORCERER:
            iAbilityModifier = GetAbilityModifier(ABILITY_CHARISMA, oCaster);
            break;
        case CLASS_TYPE_WIZARD:
            iAbilityModifier = GetAbilityModifier(ABILITY_INTELLIGENCE, oCaster);
            break;
        default:
            iAbilityModifier = GetAbilityModifier(ABILITY_WISDOM, oCaster);
            break;
    }


    int iDC = 20 + (GetSpellSaveDC()-10-iAbilityModifier);
    int iSpellCraftRanks = GetSkillRank(SKILL_SPELLCRAFT, oCaster);
    int iINTMod = GetAbilityModifier(ABILITY_INTELLIGENCE, oCaster);
    int iSkillCheckRoll = d20()+iSpellCraftRanks+iINTMod;

    string sMessage = GetStringByStrRef(16939239)+IntToString(iDC)+": Roll "+IntToString(iSkillCheckRoll);

    if(iSkillCheckRoll>=iDC) {
        sMessage = sMessage+" Success!";
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, sMessage);
        }
        return TRUE;
    }

    sMessage = sMessage+" Failure.";
    if(GetIsPC(oCaster)) {
        SendMessageToPC(oCaster, sMessage);
    }
    return FALSE;
}

//*:**************************************************************************
/*
void main() { }/**/
//*:**************************************************************************
