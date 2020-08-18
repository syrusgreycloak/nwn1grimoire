//*:**************************************************************************
//*:*  GR_IN_DOMAINS.NSS
//*:**************************************************************************
//*:*
//*:* Domain-related functions
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2004
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IC_DOMAINS"
#include "GR_IN_LIB"
#include "GR_IN_ITEMPROP"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void    GRCheckDomainSpellsMemorized(object oCaster=OBJECT_SELF);
void    GRCheckSpecialDomainFeats(object oCaster);
int     GRGetDomain(int iDomainNum, int iDomain1, object oCaster=OBJECT_SELF);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRGetHasDomain
//*:*   (formerly SGGetHasDomain)
//*:**********************************************
//*:*
//*:* Checks if has domain (wraps GetHasFeat)
//*:* - uses DOMAIN_* constants, but constants have
//*:* same value as the FEAT_*_DOMAIN_POWER constants
//*:* so that they work in GetHasFeat
//*:*
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 29, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetHasDomain(int iDomainToCheck, object oCreature=OBJECT_SELF) {

    return GetHasFeat(iDomainToCheck, oCreature);
}

//*:**********************************************
//*:* GRCheckDomainSpellsMemorized
//*:**********************************************
//*:*
//*:* Checks caster to see if they have memorized at
//*:* least one domain spell at each level (if those
//*:* spells have been implemented).
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2004
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRCheckDomainSpellsMemorized(object oCaster=OBJECT_SELF) {

    int iClassLevel = GRGetSpellcastingLevelByClass(CLASS_TYPE_CLERIC, oCaster);
    int iMaxSpellLevel = (iClassLevel+1)/2;
    int iDomain1 = GetLocalInt(oCaster, DOMAIN_1);
    int iDomain2 = GetLocalInt(oCaster, DOMAIN_2);

    //*:**********************************************
    //*:* If 0, set to -1 to be sure locals weren't missed being set.
    //*:**********************************************
    if(!iDomain1) iDomain1 = DOMAIN_2DA_INVALID;
    if(!iDomain2) iDomain2 = DOMAIN_2DA_INVALID;

    //*:**********************************************
    //*:* Max spell level is 9
    //*:**********************************************
    if(iMaxSpellLevel>9) iMaxSpellLevel=9;

    if(iDomain1 == DOMAIN_2DA_INVALID) {
        iDomain1 = GRGetDomain(1, iDomain1, oCaster);
        SetLocalInt(oCaster, DOMAIN_1, iDomain1);
    }
    if(iDomain2 == DOMAIN_2DA_INVALID) {
        iDomain2 = GRGetDomain(2, iDomain1, oCaster);
        SetLocalInt(oCaster, DOMAIN_2, iDomain2);
    }

    SetLocalInt(oCaster, DOMAINS_BLOCK_USAGE, FALSE);
    SetLocalInt(oCaster, DOMAINS_CHECK_DONE, FALSE);

    if(iDomain1 == DOMAIN_2DA_INVALID) {
        FloatingTextStrRefOnCreature(16939272, oCaster);
    }
    if(iDomain2 == DOMAIN_2DA_INVALID) {
        FloatingTextStrRefOnCreature(16939273,oCaster);
    }

    //*:**********************************************
    //*:* Check Memorized Spells
    //*:**********************************************
    int i;
    string sDomainSpell1;
    string sDomainSpell2;
    int iHasDomain1;
    int iHasDomain2;
    int iHasSpellForLevel;

    for(i=1; i<=iMaxSpellLevel; i++) {
        iHasDomain1 = FALSE;
        iHasDomain2 = FALSE;
        iHasSpellForLevel = FALSE;
        sDomainSpell1 = Get2DAString(SG_DOMAINS, "Level_"+IntToString(i), iDomain1);
        sDomainSpell2 = Get2DAString(SG_DOMAINS, "Level_"+IntToString(i), iDomain2);

        if(sDomainSpell1 != "****" && sDomainSpell1 != "") {
            if(GetHasSpell(StringToInt(sDomainSpell1), oCaster)) iHasDomain1 = TRUE;
            iHasSpellForLevel=TRUE;
        }
        if(sDomainSpell2 != "****" && sDomainSpell2 != "") {
            if(GetHasSpell(StringToInt(sDomainSpell2), oCaster)) iHasDomain2 = TRUE;
            iHasSpellForLevel=TRUE;
        }

        if(iHasSpellForLevel) {
            if(!(iHasDomain1 || iHasDomain2)) {
                FloatingTextStringOnCreature(GetStringByStrRef(16939237)+IntToString(i), oCaster);
                if(GetIsPC(oCaster)) {
                    SendMessageToPC(oCaster, GetStringByStrRef(16939237)+IntToString(i));
                    SendMessageToPC(oCaster, GetStringByStrRef(16939238));
                    SetLocalInt(oCaster, DOMAINS_BLOCK_USAGE, TRUE);
                }
            } //else {
                //*:**********************************************
                //*:* Caster has spell memorized for this level
                //*:**********************************************
                // provide debug feedback here
            //}
        }
    }
    SetLocalInt(oCaster, DOMAINS_CHECK_DONE, TRUE);
}

//*:**********************************************
//*:* GRCheckSpecialDomainFeats
//*:**********************************************
//*:*
//*:* Checks caster to see if they have the feats
//*:* given by the domain.  If not, it adds them
//*:* to a hide item.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2004
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRCheckSpecialDomainFeats(object oCaster) {

    object oPCHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCaster);;
    itemproperty ipDomainFeat;

    if(!GetIsObjectValid(oPCHide)) {
        oPCHide = CreateItemOnObject(EMPTY_SKIN_TAG, oCaster);
    }
    if(GRGetHasDomain(DOMAIN_DARKNESS, oCaster) && !GetHasFeat(FEAT_BLIND_FIGHT, oCaster)) {
        ipDomainFeat = ItemPropertyBonusFeat(IP_CONST_FEAT_BLIND_FIGHT);
        GRIPSafeAddItemProperty(oPCHide, ipDomainFeat);
    }
    if(GRGetHasDomain(DOMAIN_DROW, oCaster) && !GetHasFeat(FEAT_LIGHTNING_REFLEXES, oCaster)) {
        ipDomainFeat = ItemPropertyBonusFeat(IP_CONST_FEAT_LIGHTNING_REFLEXES);
        GRIPSafeAddItemProperty(oPCHide, ipDomainFeat);
    }
    if(GRGetHasDomain(DOMAIN_DWARF, oCaster) && !GetHasFeat(FEAT_GREAT_FORTITUDE, oCaster)) {
        ipDomainFeat = ItemPropertyBonusFeat(IP_CONST_FEAT_GREAT_FORTITUDE);
        GRIPSafeAddItemProperty(oPCHide, ipDomainFeat);
    }
    if(GRGetHasDomain(DOMAIN_UNDEATH, oCaster) && !GetHasFeat(FEAT_EXTRA_TURNING,oCaster)) {
        ipDomainFeat = ItemPropertyBonusFeat(IP_CONST_FEAT_EXTRA_TURNING);
        GRIPSafeAddItemProperty(oPCHide, ipDomainFeat);
    }
    if(GRGetHasDomain(DOMAIN_LUCK, oCaster) && !GetHasFeat(FEAT_SLIPPERY_MIND, oCaster)) {
        ipDomainFeat = ItemPropertyBonusFeat(IP_CONST_FEAT_SLIPPERY_MIND);
        GRIPSafeAddItemProperty(oPCHide, ipDomainFeat);
    }
    AssignCommand(oCaster, ActionEquipItem(oPCHide, INVENTORY_SLOT_CARMOUR));

    SetLocalInt(oCaster, DOMAINS_FEATS_SET, TRUE);
}

//*:**********************************************
//*:* GRGetDomain
//*:**********************************************
//*:*
//*:* Checks caster to see if they have certain
//*:* domains and returns the values into sg_domains.2da
//*:* so that memorized spells can be checked.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 16, 2006
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetDomain(int iDomainNum, int iDomain1, object oCaster=OBJECT_SELF) {

    int iDomainValue = DOMAIN_2DA_INVALID;

    if(iDomainNum==1) {
        if(GRGetHasDomain(DOMAIN_AIR, oCaster)) {
            iDomainValue = DOMAIN_2DA_AIR;
        } else if(GRGetHasDomain(DOMAIN_ANIMAL, oCaster)) {
            iDomainValue = DOMAIN_2DA_ANIMAL;
        } else if(GRGetHasDomain(DOMAIN_CHAOS, oCaster)) {
            iDomainValue = DOMAIN_2DA_CHAOS;
        } else if(GRGetHasDomain(DOMAIN_DEATH, oCaster)) {
            iDomainValue = DOMAIN_2DA_DEATH;
        } else if(GRGetHasDomain(DOMAIN_DESTRUCTION, oCaster)) {
            iDomainValue = DOMAIN_2DA_DESTRUCTION;
        } else if(GRGetHasDomain(DOMAIN_EARTH, oCaster)) {
            iDomainValue = DOMAIN_2DA_EARTH;
        } else if(GRGetHasDomain(DOMAIN_EVIL, oCaster)) {
            iDomainValue = DOMAIN_2DA_EVIL;
        } else if(GRGetHasDomain(DOMAIN_FIRE, oCaster)) {
            iDomainValue = DOMAIN_2DA_FIRE;
        } else if(GRGetHasDomain(DOMAIN_GOOD, oCaster)) {
            iDomainValue = DOMAIN_2DA_GOOD;
        } else if(GRGetHasDomain(DOMAIN_HEALING, oCaster)) {
            iDomainValue = DOMAIN_2DA_HEALING;
        } else if(GRGetHasDomain(DOMAIN_KNOWLEDGE, oCaster)) {
            iDomainValue = DOMAIN_2DA_KNOWLEDGE;
        } else if(GRGetHasDomain(DOMAIN_LAW, oCaster)) {
            iDomainValue = DOMAIN_2DA_LAW;
        } else if(GRGetHasDomain(DOMAIN_LUCK, oCaster)) {
            iDomainValue = DOMAIN_2DA_LUCK;
        } else if(GRGetHasDomain(DOMAIN_MAGIC, oCaster)) {
            iDomainValue = DOMAIN_2DA_MAGIC;
        } else if(GRGetHasDomain(DOMAIN_PLANT, oCaster)) {
            iDomainValue = DOMAIN_2DA_PLANT;
        } else if(GRGetHasDomain(DOMAIN_PROTECTION, oCaster)) {
            iDomainValue = DOMAIN_2DA_PROTECTION;
        } else if(GRGetHasDomain(DOMAIN_STRENGTH, oCaster)) {
            iDomainValue = DOMAIN_2DA_STRENGTH;
        } else if(GRGetHasDomain(DOMAIN_SUN, oCaster)) {
            iDomainValue = DOMAIN_2DA_SUN;
        } else if(GRGetHasDomain(DOMAIN_TRAVEL, oCaster)) {
            iDomainValue = DOMAIN_2DA_TRAVEL;
        } else if(GRGetHasDomain(DOMAIN_TRICKERY, oCaster)) {
            iDomainValue = DOMAIN_2DA_TRICKERY;
        } else if(GRGetHasDomain(DOMAIN_WAR, oCaster)) {
            iDomainValue = DOMAIN_2DA_WAR;
        } else if(GRGetHasDomain(DOMAIN_WATER, oCaster)) {
            iDomainValue = DOMAIN_2DA_WATER;
        } else if(GRGetHasDomain(DOMAIN_WATER, oCaster)) {
            iDomainValue = DOMAIN_2DA_WATER;
        } else if(GRGetHasDomain(DOMAIN_BESTIAL, oCaster)) {
            iDomainValue = DOMAIN_2DA_BESTIAL;
        } else if(GRGetHasDomain(DOMAIN_CHARM, oCaster)) {
            iDomainValue = DOMAIN_2DA_CHARM;
        } else if(GRGetHasDomain(DOMAIN_DARKNESS, oCaster)) {
            iDomainValue = DOMAIN_2DA_DARKNESS;
        } else if(GRGetHasDomain(DOMAIN_DROW, oCaster)) {
            iDomainValue = DOMAIN_2DA_DROW;
        } else if(GRGetHasDomain(DOMAIN_DWARF, oCaster)) {
            iDomainValue = DOMAIN_2DA_DWARF;
        } else if(GRGetHasDomain(DOMAIN_HALFLING, oCaster)) {
            iDomainValue = DOMAIN_2DA_HALFLING;
        } else if(GRGetHasDomain(DOMAIN_HATRED, oCaster)) {
            iDomainValue = DOMAIN_2DA_HATRED;
        } else if(GRGetHasDomain(DOMAIN_ILLUSION, oCaster)) {
            iDomainValue = DOMAIN_2DA_ILLUSION;
        } else if(GRGetHasDomain(DOMAIN_ORC, oCaster)) {
            iDomainValue = DOMAIN_2DA_ORC;
        } else if(GRGetHasDomain(DOMAIN_SLIME, oCaster)) {
            iDomainValue = DOMAIN_2DA_SLIME;
        } else if(GRGetHasDomain(DOMAIN_SUMMONER, oCaster)) {
            iDomainValue = DOMAIN_2DA_SUMMONER;
        } else if(GRGetHasDomain(DOMAIN_TYRANNY, oCaster)) {
            iDomainValue = DOMAIN_2DA_TYRANNY;
        } else if(GRGetHasDomain(DOMAIN_UNDEATH, oCaster)) {
            iDomainValue = DOMAIN_2DA_UNDEATH;
        }
    } else {
        if(GRGetHasDomain(DOMAIN_AIR) && iDomain1!=DOMAIN_2DA_AIR) {
            iDomainValue = DOMAIN_2DA_AIR;
        } else if(GRGetHasDomain(DOMAIN_ANIMAL, oCaster) && iDomain1!=DOMAIN_2DA_ANIMAL) {
            iDomainValue = DOMAIN_2DA_ANIMAL;
        } else if(GRGetHasDomain(DOMAIN_CHAOS, oCaster) && iDomain1!=DOMAIN_2DA_CHAOS) {
            iDomainValue = DOMAIN_2DA_CHAOS;
        } else if(GRGetHasDomain(DOMAIN_DEATH, oCaster) && iDomain1!=DOMAIN_2DA_DEATH) {
            iDomainValue = DOMAIN_2DA_DEATH;
        } else if(GRGetHasDomain(DOMAIN_DESTRUCTION, oCaster) && iDomain1!=DOMAIN_2DA_DESTRUCTION) {
            iDomainValue = DOMAIN_2DA_DESTRUCTION;
        } else if(GRGetHasDomain(DOMAIN_EARTH, oCaster) && iDomain1!=DOMAIN_2DA_EARTH) {
            iDomainValue = DOMAIN_2DA_EARTH;
        } else if(GRGetHasDomain(DOMAIN_EVIL, oCaster) && iDomain1!=DOMAIN_2DA_EVIL) {
            iDomainValue = DOMAIN_2DA_EVIL;
        } else if(GRGetHasDomain(DOMAIN_FIRE, oCaster) && iDomain1!=DOMAIN_2DA_FIRE) {
            iDomainValue = DOMAIN_2DA_FIRE;
        } else if(GRGetHasDomain(DOMAIN_GOOD, oCaster) && iDomain1!=DOMAIN_2DA_GOOD) {
            iDomainValue = DOMAIN_2DA_GOOD;
        } else if(GRGetHasDomain(DOMAIN_HEALING, oCaster) && iDomain1!=DOMAIN_2DA_HEALING) {
            iDomainValue = DOMAIN_2DA_HEALING;
        } else if(GRGetHasDomain(DOMAIN_KNOWLEDGE, oCaster) && iDomain1!=DOMAIN_2DA_KNOWLEDGE) {
            iDomainValue = DOMAIN_2DA_KNOWLEDGE;
        } else if(GRGetHasDomain(DOMAIN_LAW, oCaster) && iDomain1!=DOMAIN_2DA_LAW) {
            iDomainValue = DOMAIN_2DA_LAW;
        } else if(GRGetHasDomain(DOMAIN_LUCK, oCaster) && iDomain1!=DOMAIN_2DA_LUCK) {
            iDomainValue = DOMAIN_2DA_LUCK;
        } else if(GRGetHasDomain(DOMAIN_MAGIC, oCaster) && iDomain1!=DOMAIN_2DA_MAGIC) {
            iDomainValue = DOMAIN_2DA_MAGIC;
        } else if(GRGetHasDomain(DOMAIN_PLANT, oCaster) && iDomain1!=DOMAIN_2DA_PLANT) {
            iDomainValue = DOMAIN_2DA_PLANT;
        } else if(GRGetHasDomain(DOMAIN_PROTECTION, oCaster) && iDomain1!=DOMAIN_2DA_PROTECTION) {
            iDomainValue = DOMAIN_2DA_PROTECTION;
        } else if(GRGetHasDomain(DOMAIN_STRENGTH, oCaster) && iDomain1!=DOMAIN_2DA_STRENGTH) {
            iDomainValue = DOMAIN_2DA_STRENGTH;
        } else if(GRGetHasDomain(DOMAIN_SUN, oCaster) && iDomain1!=DOMAIN_2DA_SUN) {
            iDomainValue = DOMAIN_2DA_SUN;
        } else if(GRGetHasDomain(DOMAIN_TRAVEL, oCaster) && iDomain1!=DOMAIN_2DA_TRAVEL) {
            iDomainValue = DOMAIN_2DA_TRAVEL;
        } else if(GRGetHasDomain(DOMAIN_TRICKERY, oCaster) && iDomain1!=DOMAIN_2DA_TRICKERY) {
            iDomainValue = DOMAIN_2DA_TRICKERY;
        } else if(GRGetHasDomain(DOMAIN_WAR, oCaster) && iDomain1!=DOMAIN_2DA_WAR) {
            iDomainValue = DOMAIN_2DA_WAR;
        } else if(GRGetHasDomain(DOMAIN_WATER, oCaster) && iDomain1!=DOMAIN_2DA_WATER) {
            iDomainValue = DOMAIN_2DA_WATER;
        } else if(GRGetHasDomain(DOMAIN_CHARM, oCaster) && iDomain1!=DOMAIN_2DA_CHARM) {
            iDomainValue = DOMAIN_2DA_CHARM;
        } else if(GRGetHasDomain(DOMAIN_DARKNESS, oCaster) && iDomain1!=DOMAIN_2DA_DARKNESS) {
            iDomainValue = DOMAIN_2DA_DARKNESS;
        } else if(GRGetHasDomain(DOMAIN_DROW, oCaster) && iDomain1!=DOMAIN_2DA_DROW) {
            iDomainValue = DOMAIN_2DA_DROW;
        } else if(GRGetHasDomain(DOMAIN_DWARF, oCaster) && iDomain1!=DOMAIN_2DA_DWARF) {
            iDomainValue = DOMAIN_2DA_DWARF;
        } else if(GRGetHasDomain(DOMAIN_HALFLING, oCaster) && iDomain1!=DOMAIN_2DA_HALFLING) {
            iDomainValue = DOMAIN_2DA_HALFLING;
        } else if(GRGetHasDomain(DOMAIN_HATRED, oCaster) && iDomain1!=DOMAIN_2DA_HATRED) {
            iDomainValue = DOMAIN_2DA_HATRED;
        } else if(GRGetHasDomain(DOMAIN_ILLUSION, oCaster) && iDomain1!=DOMAIN_2DA_ILLUSION) {
            iDomainValue = DOMAIN_2DA_ILLUSION;
        } else if(GRGetHasDomain(DOMAIN_ORC, oCaster) && iDomain1!=DOMAIN_2DA_ORC) {
            iDomainValue = DOMAIN_2DA_ORC;
        } else if(GRGetHasDomain(DOMAIN_SLIME, oCaster) && iDomain1!=DOMAIN_2DA_SLIME) {
            iDomainValue = DOMAIN_2DA_SLIME;
        } else if(GRGetHasDomain(DOMAIN_TYRANNY, oCaster) && iDomain1!=DOMAIN_2DA_TYRANNY) {
            iDomainValue = DOMAIN_2DA_TYRANNY;
        } else if(GRGetHasDomain(DOMAIN_UNDEATH, oCaster) && iDomain1!=DOMAIN_2DA_UNDEATH) {
            iDomainValue = DOMAIN_2DA_UNDEATH;
        }
    }

    return iDomainValue;
}

//*:**************************************************************************
//*:**************************************************************************
