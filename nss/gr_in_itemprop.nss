//*:**************************************************************************
//*:*  GR_IN_ITEMPROP.NSS
//*:**************************************************************************
//*:*
//*:* Wrappers for Bioware item property functions
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 23, 2005
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Constants
//*:**************************************************************************
const int SIZE_SMALL = 1;
const int SIZE_MEDIUM = 2;

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "X2_INC_ITEMPROP"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void GRAddACBonusToArmor(object oMyArmor, float fDuration, int iAmount=1);
void GRAddBlackStaffEffectOnWeapon(object oTarget, float fDuration);
void GRAddBladeThirstEffectToWeapon(object oMyWeapon, float fDuration);
void GRAddBlessEffectToWeapon(object oTarget, float fDuration);
void GRAddDarkfireEffectToWeapon(object oTarget, float fDuration, int iCasterLevel);
void GRAddDeafeningClangEffectToWeapon(object oMyWeapon, float fDuration);
void GRAddEnhancementBonusToWeapon(object oMyWeapon, float fDuration, int iEnhanceBonus = 1);
void GRAddFlameWeaponEffectToWeapon(object oTarget, float fDuration, int iCasterLevel);
void GRAddHolyAvengerEffectToWeapon(object oMyWeapon, float fDuration);
void GRAddKeenEffectToWeapon(object oMyWeapon, float fDuration);
int  GRGetIsValidAnimate(object oTarget);
int  GRGetWeaponAnimateSize(object oTarget);
void GRIPSafeAddItemProperty(object oItem, itemproperty nip, float fDuration = 0.0f,
            int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, int bIgnoreDurationType = FALSE,
            int bIgnoreSubType = FALSE);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRAddACBonusToArmor
//*:**********************************************
//*:*
//*:* Magic Vestment
//*:* Any spell that needs to add armor bonus
//*:*
//*:**********************************************
void GRAddACBonusToArmor(object oMyArmor, float fDuration, int iAmount=1)
{
    GRIPSafeAddItemProperty(oMyArmor, ItemPropertyACBonus(iAmount), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
    return;
}

//*:**********************************************
//*:* GRAddBlackStaffEffectOnWeapon
//*:**********************************************
//*:*
//*:* Blackstaff spell
//*:*
//*:**********************************************
void GRAddBlackStaffEffectOnWeapon(object oTarget, float fDuration)
{
   GRIPSafeAddItemProperty(oTarget, ItemPropertyEnhancementBonus(4), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
   GRIPSafeAddItemProperty(oTarget, ItemPropertyOnHitProps(IP_CONST_ONHIT_DISPELMAGIC, IP_CONST_ONHIT_SAVEDC_16), fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
   GRIPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect(ITEM_VISUAL_EVIL), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);

   return;
}

//*:**********************************************
//*:* GRAddBladeThirstEffectToWeapon
//*:**********************************************
//*:*
//*:* Blade Thirst spell
//*:*
//*:**********************************************
void GRAddBladeThirstEffectToWeapon(object oMyWeapon, float fDuration)
{
   GRIPSafeAddItemProperty(oMyWeapon, ItemPropertyEnhancementBonus(3), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
   GRIPSafeAddItemProperty(oMyWeapon, ItemPropertyVisualEffect(ITEM_VISUAL_COLD), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);

   return;
}

//*:**********************************************
//*:* GRAddBlessEffectToWeapon
//*:**********************************************
//*:*
//*:* ** NWN1 Bless effect BY BIOWARE ***
//*:* This is actually more like an Undead Bane effect - NOT BLESS
//*:**********************************************
void GRAddBlessEffectToWeapon(object oTarget, float fDuration)
{
   // If the spell is cast again, any previous enhancement boni are kept
   GRIPSafeAddItemProperty(oTarget, ItemPropertyEnhancementBonus(1), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE);
   // Replace existing temporary anti undead boni
   GRIPSafeAddItemProperty(oTarget, ItemPropertyDamageBonusVsRace(IP_CONST_RACIALTYPE_UNDEAD, IP_CONST_DAMAGETYPE_DIVINE, IP_CONST_DAMAGEBONUS_2d6), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
   GRIPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect(ITEM_VISUAL_HOLY), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);

   return;
}
//*:**********************************************
//*:* GRAddVsAlignEnhancementToWeapon
//*:**********************************************
//*:*
//*:* Bless/Corrupt Weapon
//*:*
//*:**********************************************
void GRAddVsAlignEnhancementToWeapon(object oTarget, int iAlignAgainst, float fDuration, int iBonus = 1) {
    switch(iAlignAgainst) {
        case ALIGNMENT_EVIL: iAlignAgainst = IP_CONST_ALIGNMENTGROUP_EVIL; break;
        case ALIGNMENT_GOOD: iAlignAgainst = IP_CONST_ALIGNMENTGROUP_GOOD; break;
        case ALIGNMENT_NEUTRAL: iAlignAgainst = IP_CONST_ALIGNMENTGROUP_NEUTRAL; break;
        case ALIGNMENT_CHAOTIC: iAlignAgainst = IP_CONST_ALIGNMENTGROUP_CHAOTIC; break;
        case ALIGNMENT_LAWFUL: iAlignAgainst = IP_CONST_ALIGNMENTGROUP_LAWFUL; break;
    }

    GRIPSafeAddItemProperty(oTarget, ItemPropertyEnhancementBonusVsAlign(iAlignAgainst, iBonus), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE);
    return;
}
//*:**********************************************
//*:* GRAddDarkfireEffectToWeapon
//*:**********************************************
//*:*
//*:* Darkfire spell
//*:*
//*:**********************************************
void GRAddDarkfireEffectToWeapon(object oTarget, float fDuration, int iCasterLevel)
{
   GRIPSafeAddItemProperty(oTarget, ItemPropertyOnHitCastSpell(127, iCasterLevel), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
   GRIPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect(ITEM_VISUAL_FIRE), fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
   return;
}

//*:**********************************************
//*:* GRAddDeafeningClangEffectToWeapon
//*:**********************************************
//*:*
//*:* Deafening Clang spell
//*:*
//*:**********************************************
void GRAddDeafeningClangEffectToWeapon(object oMyWeapon, float fDuration)
{
   GRIPSafeAddItemProperty(oMyWeapon,ItemPropertyAttackBonus(1), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE, TRUE);
   GRIPSafeAddItemProperty(oMyWeapon,ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_SONIC, IP_CONST_DAMAGEBONUS_3), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
   GRIPSafeAddItemProperty(oMyWeapon, ItemPropertyOnHitCastSpell(137, 5), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE, FALSE);
   GRIPSafeAddItemProperty(oMyWeapon, ItemPropertyVisualEffect(ITEM_VISUAL_SONIC), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE, TRUE);

   return;
}

//*:**********************************************
//*:* GRAddEnhancementBonusToWeapon
//*:**********************************************
//*:*
//*:* Magic Weapon/Greater Magic Weapon
//*:* Any spell that needs to add an enhancement bonus
//*:*
//*:**********************************************
void GRAddEnhancementBonusToWeapon(object oMyWeapon, float fDuration, int iEnhanceBonus = 1)
{
   GRIPSafeAddItemProperty(oMyWeapon, ItemPropertyEnhancementBonus(iEnhanceBonus), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE,TRUE);
   return;
}

//*:**********************************************
//*:* GRAddFlamingEffectToWeapon
//*:**********************************************
//*:*
//*:* Flame Weapon spell
//*:*
//*:**********************************************
void GRAddFlameWeaponEffectToWeapon(object oTarget, float fDuration, int iCasterLevel)
{
   // If the spell is cast again, any previous itemproperties matching are removed.
   GRIPSafeAddItemProperty(oTarget, ItemPropertyOnHitCastSpell(124, iCasterLevel), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
   GRIPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect(ITEM_VISUAL_FIRE), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE, TRUE);
   return;
}

//*:**********************************************
//*:* GRAddHolyAvengerEffectToWeapon
//*:**********************************************
//*:*
//*:* Holy Sword spell
//*:*
//*:**********************************************
void GRAddHolyAvengerEffectToWeapon(object oMyWeapon, float fDuration)
{
   GRIPSafeAddItemProperty(oMyWeapon, ItemPropertyHolyAvenger(), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE, TRUE);
   return;
}

//*:**********************************************
//*:* GRAddKeenEffectToWeapon
//*:**********************************************
//*:*
//*:* Keen Edge spell
//*:*
//*:**********************************************
void GRAddKeenEffectToWeapon(object oMyWeapon, float fDuration)
{
   GRIPSafeAddItemProperty(oMyWeapon, ItemPropertyKeen(), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE, TRUE);
   return;
}

//*:**********************************************
//*:* GRGetIsValidAnimate
//*:**********************************************
//*:*
//*:* Copy of PRC function GetIsValidAnimate
//*:*
//*:**********************************************
int GRGetIsValidAnimate(object oTarget) {

    int iBaseItemType = GetBaseItemType(oTarget);
    itemproperty ipMagicWeapon = GetFirstItemProperty(oTarget);

    if(GetIsItemPropertyValid(ipMagicWeapon)) {
        if(iBaseItemType == BASE_ITEM_WHIP) {
            ipMagicWeapon = GetNextItemProperty(oTarget);
            if(GetIsItemPropertyValid(ipMagicWeapon)) {
                return FALSE;
            } else {
                ipMagicWeapon = GetFirstItemProperty(oTarget);
                if(GetItemPropertyType(ipMagicWeapon) == ITEM_PROPERTY_BONUS_FEAT) {
                    if(GetItemPropertySubType(ipMagicWeapon) != 37)
                        return FALSE;
                } else {
                    return FALSE;
                }
            }
        } else {
            return FALSE;
        }
    }

    switch(iBaseItemType) {
        case BASE_ITEM_ARMOR:
        case BASE_ITEM_BASTARDSWORD:
        case BASE_ITEM_BATTLEAXE:
        case BASE_ITEM_DAGGER:
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_DWARVENWARAXE:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_HANDAXE:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_KAMA:
        case BASE_ITEM_KATANA:
        case BASE_ITEM_KUKRI:
        case BASE_ITEM_LIGHTFLAIL:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_MORNINGSTAR:
        case BASE_ITEM_QUARTERSTAFF:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_SHORTSPEAR:
        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_TWOBLADEDSWORD:
        case BASE_ITEM_WARHAMMER:
        case BASE_ITEM_WHIP:
            return TRUE;
            break;
        default:
            return FALSE;
            break;
    }
    return FALSE;
}

//*:**********************************************
//*:* GRGetWeaponAnimateSize
//*:**********************************************
//*:*
//*:* Copy of PRC function GetWeaponAnimateSize
//*:*
//*:**********************************************
int GRGetWeaponAnimateSize(object oTarget) {

    int iBaseItemType = GetBaseItemType(oTarget);
    switch (iBaseItemType) {
        case BASE_ITEM_BASTARDSWORD:
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_TWOBLADEDSWORD:
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_SCYTHE:
            return SIZE_MEDIUM;
            break;
        case BASE_ITEM_DWARVENWARAXE:
        case BASE_ITEM_BATTLEAXE:
        case BASE_ITEM_DAGGER:
        case BASE_ITEM_HANDAXE:
        case BASE_ITEM_KAMA:
        case BASE_ITEM_KATANA:
        case BASE_ITEM_KUKRI:
        case BASE_ITEM_LIGHTFLAIL:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_MORNINGSTAR:
        case BASE_ITEM_QUARTERSTAFF:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_SHORTSPEAR:
        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_WARHAMMER:
        case BASE_ITEM_WHIP:
            return SIZE_SMALL;
            break;
    }
    return SIZE_SMALL;
}

//*:**********************************************
//*:* GRIPSafeAddItemProperty
//*:* 2005 Karl Nickels (Syrus Greycloak)
//*:**********************************************
/*
    Applies item properties to item
*/
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 28, 2005
//*:**********************************************
void GRIPSafeAddItemProperty(object oItem, itemproperty nip, float fDuration = 0.0f,
    int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, int bIgnoreDurationType = FALSE,
    int bIgnoreSubType = FALSE) {

        IPSafeAddItemProperty(oItem, nip, fDuration, nAddItemPropertyPolicy, bIgnoreDurationType, bIgnoreSubType);
}

//*:**************************************************************************
//*:**************************************************************************
