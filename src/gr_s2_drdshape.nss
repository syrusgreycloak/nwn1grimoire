//*:**************************************************************************
//*:*  GR_S2_DRDSHAPE.NSS
//*:**************************************************************************
//*:* Elemental Shape (NW_S2_ElemShape) Copyright (c) 2001 Bioware Corp.
//*:* Wild Shape (NW_S2_WildShape) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 22, 2002
//*:*
//*:* Greater Wild Shape, Humanoid Shape (x2_s2_gwildshp) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller   Created On: 2003-07-02
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 16, 2007
//*:**************************************************************************
//*:* Updated On: November 16, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
#include "X2_INC_SHIFTER"

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

    int     iClassType      = (spInfo.iSpellID<=405 ? CLASS_TYPE_DRUID : CLASS_TYPE_SHIFTER);

    spInfo.iCasterLevel = GRGetLevelByClass(iClassType);
    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_HOURS;

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

    int     iPolyType;
    int     bElder          = spInfo.iCasterLevel>=20;
    int     bDire           = spInfo.iCasterLevel>=12;
    int     iDurationType   = (iClassType==CLASS_TYPE_DRUID ? DURATION_TYPE_TEMPORARY : DURATION_TYPE_PERMANENT);

    //*:**********************************************
    //*:* Feb 13, 2004, Jon: Added scripting to take
    //*:* care of case where it's an NPC using one of
    //*:* the feats. It will randomly pick one of the
    //*:* shapes associated with the feat.
    //*:**********************************************
    if(iClassType==CLASS_TYPE_SHIFTER) {
        switch(spInfo.iSpellID) {
            // Greater Wildshape I
            case 646: spInfo.iSpellID = Random(5)+658; break;
            // Greater Wildshape II
            case 675: switch(Random(3))
                      {
                        case 0: spInfo.iSpellID = 672; break;
                        case 1: spInfo.iSpellID = 678; break;
                        case 2: spInfo.iSpellID = 680;
                      }
                      break;
            // Greater Wildshape III
            case 676: switch(Random(3))
                      {
                        case 0: spInfo.iSpellID = 670; break;
                        case 1: spInfo.iSpellID = 673; break;
                        case 2: spInfo.iSpellID = 674;
                      }
                      break;
            // Greater Wildshape IV
            case 677: switch(Random(3))
                      {
                        case 0: spInfo.iSpellID = 679; break;
                        case 1: spInfo.iSpellID = 691; break;
                        case 2: spInfo.iSpellID = 694;
                      }
                      break;
            // Humanoid Shape
            case 681:  spInfo.iSpellID = Random(3)+682; break;
            // Undead Shape
            case 685:  spInfo.iSpellID = Random(3)+704; break;
            // Dragon Shape
            case 725:  spInfo.iSpellID = Random(3)+707; break;
            // Outsider Shape
            case 732:  spInfo.iSpellID = Random(3)+733; break;
            // Construct Shape
            case 737:  spInfo.iSpellID = Random(3)+738; break;
        }
    }

    //*:**********************************************
    //*:* Determine which form to use based on spell id, gender and level
    //*:**********************************************
    switch(spInfo.iSpellID) {
        //*:**********************************************
        //*:* Druid - Elemental Shape
        //*:**********************************************
        case 397:
            iPolyType = (bElder ? POLYMORPH_TYPE_ELDER_FIRE_ELEMENTAL : POLYMORPH_TYPE_HUGE_FIRE_ELEMENTAL);
            break;
        case 398:
            iPolyType = (bElder ? POLYMORPH_TYPE_ELDER_WATER_ELEMENTAL : POLYMORPH_TYPE_HUGE_WATER_ELEMENTAL);
            break;
        case 399:
            iPolyType = (bElder ? POLYMORPH_TYPE_ELDER_EARTH_ELEMENTAL : POLYMORPH_TYPE_HUGE_EARTH_ELEMENTAL);
            break;
        case 400:
            iPolyType = (bElder ? POLYMORPH_TYPE_ELDER_AIR_ELEMENTAL : POLYMORPH_TYPE_HUGE_AIR_ELEMENTAL);
            break;
        //*:**********************************************
        //*:* Druid - Wild Shape
        //*:**********************************************
        case 401:
            iPolyType = (bDire ? POLYMORPH_TYPE_DIRE_BROWN_BEAR : POLYMORPH_TYPE_BROWN_BEAR);
            break;
        case 402:
            iPolyType = (bDire ? POLYMORPH_TYPE_DIRE_PANTHER : POLYMORPH_TYPE_PANTHER);
            break;
        case 403:
            iPolyType = (bDire ? POLYMORPH_TYPE_DIRE_WOLF : POLYMORPH_TYPE_WOLF);
            break;
        case 404:
            iPolyType = (bDire ? POLYMORPH_TYPE_DIRE_BOAR : POLYMORPH_TYPE_BOAR);
            break;
        case 405:
            iPolyType = (bDire ? POLYMORPH_TYPE_DIRE_BADGER : POLYMORPH_TYPE_BADGER);
            break;
        //*:**********************************************
        //*:* Greater Wildshape I - Wyrmling Shape
        //*:**********************************************
        case 658:  iPolyType = POLYMORPH_TYPE_WYRMLING_RED; break;
        case 659:  iPolyType = POLYMORPH_TYPE_WYRMLING_BLUE; break;
        case 660:  iPolyType = POLYMORPH_TYPE_WYRMLING_BLACK; break;
        case 661:  iPolyType = POLYMORPH_TYPE_WYRMLING_WHITE; break;
        case 662:  iPolyType = POLYMORPH_TYPE_WYRMLING_GREEN; break;

        //*:**********************************************
        //*:* Greater Wildshape II  - Minotaur, Gargoyle, Harpy
        //*:**********************************************
        case 672: if (spInfo.iCasterLevel < X2_GW2_EPIC_THRESHOLD)
                     iPolyType = POLYMORPH_TYPE_HARPY;
                  else
                     iPolyType = 97;
                  break;

        case 678: if (spInfo.iCasterLevel < X2_GW2_EPIC_THRESHOLD)
                     iPolyType = POLYMORPH_TYPE_GARGOYLE;
                  else
                     iPolyType = 98;
                  break;

        case 680: if (spInfo.iCasterLevel < X2_GW2_EPIC_THRESHOLD)
                     iPolyType = POLYMORPH_TYPE_MINOTAUR;
                  else
                     iPolyType = 96;
                  break;
        //*:**********************************************
        //*:* Greater Wildshape III  - Drider, Basilisk, Manticore
        //*:**********************************************
        case 670: if (spInfo.iCasterLevel < X2_GW3_EPIC_THRESHOLD)
                     iPolyType = POLYMORPH_TYPE_BASILISK;
                  else
                     iPolyType = 99;
                  break;

        case 673: if (spInfo.iCasterLevel < X2_GW3_EPIC_THRESHOLD)
                     iPolyType = POLYMORPH_TYPE_DRIDER;
                  else
                     iPolyType = 100;
                  break;

        case 674: if (spInfo.iCasterLevel < X2_GW3_EPIC_THRESHOLD)
                     iPolyType = POLYMORPH_TYPE_MANTICORE;
                  else
                     iPolyType = 101;
                  break;
        //*:**********************************************
        //*:* Greater Wildshape IV - Dire Tiger, Medusa, MindFlayer
        //*:**********************************************
        case 679: iPolyType = POLYMORPH_TYPE_MEDUSA; break;
        case 691: iPolyType = 68; break; // Mindflayer
        case 694: iPolyType = 69; break; // DireTiger
        //*:**********************************************
        //*:* Humanoid Shape - Kobold Commando, Drow, Lizard Crossbow Specialist
        //*:**********************************************
       case 682: if(spInfo.iCasterLevel< 17) {
                     if (GetGender(OBJECT_SELF) == GENDER_MALE) //drow
                         iPolyType = 59;
                     else
                         iPolyType = 70;
                 } else {
                     if (GetGender(OBJECT_SELF) == GENDER_MALE) //drow
                         iPolyType = 105;
                     else
                         iPolyType = 106;
                 }
                 break;
       case 683: if(spInfo.iCasterLevel< 17) {
                    iPolyType = 82; break; // Lizard
                 }else {
                    iPolyType =104; break; // Epic Lizard
                 }
       case 684: if(spInfo.iCasterLevel< 17) {
                    iPolyType = 83; break; // Kobold Commando
                 } else {
                    iPolyType = 103; break; // Kobold Commando
                 }
        //*:**********************************************
        //*:* Undead Shape - Spectre, Risen Lord, Vampire
        //*:**********************************************
        case 704: iPolyType = 75; break; // Risen lord
        case 705: if (GetGender(OBJECT_SELF) == GENDER_MALE) // vampire
                     iPolyType = 74;
                  else
                     iPolyType = 77;
                  break;
        case 706: iPolyType = 76; break; /// spectre
        //*:**********************************************
        //*:* Dragon Shape - Red Blue and Green Dragons
        //*:**********************************************
        case 707: iPolyType = 72; break; // Ancient Red   Dragon
        case 708: iPolyType = 71; break; // Ancient Blue  Dragon
        case 709: iPolyType = 73; break; // Ancient Green Dragon
        //*:**********************************************
        //*:* Outsider Shape - Rakshasa, Azer Chieftain, Black Slaad
        //*:**********************************************
        case 733:   if (GetGender(OBJECT_SELF) == GENDER_MALE) //azer
                      iPolyType = 85;
                    else // anything else is female
                      iPolyType = 86;
                    break;

        case 734:   if (GetGender(OBJECT_SELF) == GENDER_MALE) //rakshasa
                      iPolyType = 88;
                    else // anything else is female
                      iPolyType = 89;
                    break;

        case 735: iPolyType =87; break; // slaad
        //*:**********************************************
        //*:* Construct Shape - Stone Golem, Iron Golem, Demonflesh Golem
        //*:**********************************************
        case 738: iPolyType =91; break; // stone golem
        case 739: iPolyType =92; break; // demonflesh golem
        case 740: iPolyType =90; break; // iron golem
    }

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
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly= EffectPolymorph(iPolyType);
    ePoly = ExtraordinaryEffect(ePoly);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(oCaster, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));

    int bWeapon = (iClassType==CLASS_TYPE_DRUID ? (StringToInt(Get2DAString("polymorph","MergeW",iPolyType)) == 1) : ShifterMergeWeapon(iPolyType));
    int bArmor  = (iClassType==CLASS_TYPE_DRUID ? (StringToInt(Get2DAString("polymorph","MergeA",iPolyType)) == 1) : ShifterMergeArmor(iPolyType));
    int bItems  = (iClassType==CLASS_TYPE_DRUID ? (StringToInt(Get2DAString("polymorph","MergeI",iPolyType)) == 1) : ShifterMergeItems(iPolyType));

    object oWeaponOld   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCaster);
    object oArmorOld    = GetItemInSlot(INVENTORY_SLOT_CHEST, oCaster);
    object oRing1Old    = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oCaster);
    object oRing2Old    = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oCaster);
    object oAmuletOld   = GetItemInSlot(INVENTORY_SLOT_NECK, oCaster);
    object oCloakOld    = GetItemInSlot(INVENTORY_SLOT_CLOAK, oCaster);
    object oBootsOld    = GetItemInSlot(INVENTORY_SLOT_BOOTS, oCaster);
    object oBeltOld     = GetItemInSlot(INVENTORY_SLOT_BELT, oCaster);
    object oHelmetOld   = GetItemInSlot(INVENTORY_SLOT_HEAD, oCaster);
    object oShield      = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCaster);

    if (GetIsObjectValid(oShield)) {
        if (GetBaseItemType(oShield) !=BASE_ITEM_LARGESHIELD &&
            GetBaseItemType(oShield) !=BASE_ITEM_SMALLSHIELD &&
            GetBaseItemType(oShield) !=BASE_ITEM_TOWERSHIELD)
        {
            oShield = OBJECT_INVALID;
        }
    }

    ClearAllActions(); // prevents an exploit
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster);
    GRApplyEffectToObject(iDurationType, ePoly, oCaster, fDuration);

    object oWeaponNew = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCaster);
    object oArmorNew = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCaster);

    if(iClassType==CLASS_TYPE_SHIFTER) SetIdentified(oWeaponNew, TRUE);

    if(bWeapon) {
        IPWildShapeCopyItemProperties(oWeaponOld, oWeaponNew, TRUE);
    }

    if(bArmor) {
        IPWildShapeCopyItemProperties(oHelmetOld, oArmorNew);
        IPWildShapeCopyItemProperties(oArmorOld, oArmorNew);
        IPWildShapeCopyItemProperties(oShield, oArmorNew);
    }

    if(bItems) {
        IPWildShapeCopyItemProperties(oRing1Old, oArmorNew);
        IPWildShapeCopyItemProperties(oRing2Old, oArmorNew);
        IPWildShapeCopyItemProperties(oAmuletOld, oArmorNew);
        IPWildShapeCopyItemProperties(oCloakOld, oArmorNew);
        IPWildShapeCopyItemProperties(oBootsOld, oArmorNew);
        IPWildShapeCopyItemProperties(oBeltOld, oArmorNew);
    }

    if(iClassType==CLASS_TYPE_SHIFTER) ShifterSetGWildshapeSpellLimits(spInfo.iSpellID);

    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
