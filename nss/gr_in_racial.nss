//*:**************************************************************************
//*:*  GR_IN_RACIAL.NSS
//*:**************************************************************************
//*:*
//*:* Functions to retrieve particular information about character/monster
//*:* objects
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: August 23, 2004
//*:**************************************************************************
//*:* Updated On: February 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Constant Libraries
//#include "GR_IC_SPELLS" - INCLUDED IN GR_IN_LIB

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_LIB"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
int     GRGetCreatureSize(object oCreature);
int     GRGetIsHumanoid(object oCreature);
int     GRGetIsLightSensitive(object oTarget);
int     GRGetIsLiving(object oCreature);
int     GRGetIsMindless(object oCreature);
int     GRGetRacialType(object oCreature);

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************
//*:**********************************************
//*:* GRGetCreatureSize
//*:**********************************************
//*:*
//*:* Gets creature size and adjusts for Enlarge/
//*:* Reduce spells
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**********************************************
int GRGetCreatureSize(object oCreature) {

    int iCreatureSize = GetCreatureSize(oCreature);

    if(
        GetHasSpellEffect(SPELL_ENLARGE_PERSON, oCreature) ||
        GetHasSpellEffect(SPELL_GR_MASS_ENLARGE, oCreature) ||
        GetHasSpellEffect(SPELL_GR_GREATER_ENLARGE, oCreature) ) {
            iCreatureSize++;
    } else
    if(
        GetHasSpellEffect(SPELL_GR_REDUCE, oCreature) ||
        GetHasSpellEffect(SPELL_GR_MASS_REDUCE, oCreature) ||
        GetHasSpellEffect(SPELL_GR_GREATER_REDUCE, oCreature) ) {
            iCreatureSize--;
    }

    return iCreatureSize;
}

//*:**********************************************
//*:* GRGetIsHumanoid
//*:*   (formerly SGIsTargetHumanoid)
//*:**********************************************
//*:*
//*:* Gets the racial type of the creature specified
//*:* and checks if it is a humanoid living creature
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 10, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetIsHumanoid(object oCreature) {

   int nRacial = GetRacialType(oCreature);

   if((nRacial == RACIAL_TYPE_DWARF) ||
      (nRacial == RACIAL_TYPE_HALFELF) ||
      (nRacial == RACIAL_TYPE_HALFORC) ||
      (nRacial == RACIAL_TYPE_ELF) ||
      (nRacial == RACIAL_TYPE_GNOME) ||
      (nRacial == RACIAL_TYPE_HUMANOID_GOBLINOID) ||
      (nRacial == RACIAL_TYPE_HALFLING) ||
      (nRacial == RACIAL_TYPE_HUMAN) ||
      (nRacial == RACIAL_TYPE_HUMANOID_MONSTROUS) ||
      (nRacial == RACIAL_TYPE_HUMANOID_ORC) ||
      (nRacial == RACIAL_TYPE_HUMANOID_REPTILIAN))
   {
    return TRUE;
   }
   return FALSE;
}

//*:**********************************************
//*:* GRGetIsLightSensitive
//*:**********************************************
//*:*
//*:* Checks subrace and name field to see if target
//*:* is a light sensitive creature.
//*:*
//*:* NOTE: Need to check Monster Manual and game resources
//*:* for light sensitive creatures to flesh this out properly.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: August 23, 2004
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetIsLightSensitive(object oTarget) {

    string sName = GetStringLowerCase(GetName(oTarget));
    string sSubRace = GetStringLowerCase(GetSubRace(oTarget));

    if(GetSubString(sSubRace,0,4)=="drow" || GetSubString(sSubRace,0,7)=="duergar" ||
        GetSubString(sSubRace,0,12)=="svirfneblin" || GetSubString(sSubRace,0,4)=="deep" ||
        GetSubString(sSubRace,0,4)=="dark" || FindSubString(sName,"orc")>=0 ||
        FindSubString(sName,"drow")>=0 || FindSubString(sName,"duergar")>=0 ||
        FindSubString(sName,"kobold")>=0) {
            return TRUE;
    }

    if(GRGetRacialType(oTarget)==RACIAL_TYPE_HUMANOID_ORC) return TRUE;

    if(GRGetRacialType(oTarget)==RACIAL_TYPE_UNDEAD) {
        if(FindSubString(sName,"vampir")>=0 ||
            GetAppearanceType(oTarget) == APPEARANCE_TYPE_VAMPIRE_MALE ||
            GetAppearanceType(oTarget) == APPEARANCE_TYPE_VAMPIRE_FEMALE ||
            FindSubString(sSubRace,"vampire")>=0) {

            return TRUE;
        }
    }

    return FALSE;
}

//*:**********************************************
//*:* GRGetIsLiving
//*:*   (formerly SGIsLivingCreature)
//*:**********************************************
//*:*
//*:* Gets the racial type of the creature specified
//*:* and checks if it is a living creature
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 10, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetIsLiving(object oCreature) {

    if(GRGetRacialType(oCreature)==RACIAL_TYPE_UNDEAD || GRGetRacialType(oCreature)==RACIAL_TYPE_CONSTRUCT)
        return FALSE;

    return TRUE;
}

//*:**********************************************
//*:* GRGetIsMindless
//*:*   (formerly SGspellsIsMindless)
//*:**********************************************
//*:*
//*:* Checks whether the creature specified has a
//*:* mind.  Copy of Bioware function.  Currently
//*:* still considers all the following races
//*:* as mindless, unless creature is a transformed
//*:* PC.  Need to find way to allow for intelligent
//*:* undead (liches, vampires).
//*:*
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetIsMindless(object oCreature) {

    int iRacialType = GRGetRacialType(oCreature);
    int bIsMindless = FALSE;

    switch(iRacialType) {
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_ELEMENTAL:
        case RACIAL_TYPE_VERMIN:
        case RACIAL_TYPE_OOZE:
        case RACIAL_TYPE_UNDEAD:
            if(!GetIsPC(oCreature)) {
                bIsMindless = TRUE;
            }
    }

    return bIsMindless;
}

//*:**********************************************
//*:* GRGetRacialType
//*:*   (formerly SGGetRacialType)
//*:**********************************************
//*:*
//*:* Gets the racial type of the creature specified
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetRacialType(object oCreature) {

    int iRacialType = GetRacialType(oCreature);

    //*:**********************************************
    //*:* Gauntlets of the Lich change race to UNDEAD
    //*:**********************************************
    if(GetIsObjectValid(GetItemPossessedBy(oCreature, "x2_gauntletlich")) == TRUE) {
        if(GetTag(GetItemInSlot(INVENTORY_SLOT_ARMS, oCreature)) == "x2_gauntletlich") {
            iRacialType = RACIAL_TYPE_UNDEAD;
        }
    } else
    //*:**********************************************
    //*:* Iron Body spell changes race to CONSTRUCT
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_IRON_BODY, oCreature)) {
        iRacialType = RACIAL_TYPE_CONSTRUCT;
    } else
    //*:**********************************************
    //*:* Awaken spell on an animal changes it to Magical Beast
    //*:**********************************************
    if(iRacialType==RACIAL_TYPE_ANIMAL && GetHasSpellEffect(SPELL_AWAKEN, oCreature)) {
        iRacialType = RACIAL_TYPE_MAGICAL_BEAST;
    } else
    //*:**********************************************
    //*:* Dragon Apotheosis (gained at 10th level
    //*:* Dragon Disciple) makes type dragon
    //*:**********************************************
    if(GRGetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oCreature)>=10) {
        iRacialType = RACIAL_TYPE_DRAGON;
    }
    //*:**********************************************
    //*:* Perfect Self (Monk ability level 20)
    //*:* makes type outsitder
    //*:**********************************************
    if(GRGetLevelByClass(CLASS_TYPE_MONK, oCreature)>=20) {
        iRacialType = RACIAL_TYPE_OUTSIDER;
    }
    //*:**********************************************
    //*:* Greater Visage of the Deity spell
    //*:* makes type outsitder
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GREATER_VISAGE_OF_THE_DEITY, oCreature)) {
        iRacialType = RACIAL_TYPE_OUTSIDER;
    }

    return iRacialType;
}




//*:**************************************************************************
//*:**************************************************************************
