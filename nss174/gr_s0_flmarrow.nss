//*:**************************************************************************
//*:*  GR_S0_FLMARROW.NSS
//*:**************************************************************************
//*:*
//*:* Flame Arrow
//*:* 3.5 Player's Handlbook (p. 231)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 17, 2005
//*:**************************************************************************
//*:* Updated On: October 25, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"

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
    int     iDurAmount        = spInfo.iCasterLevel*10;
    int     iDurType          = DUR_TYPE_TURNS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

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

    object  oItem           = spInfo.oTarget;
    int     iIPDamageType   = GRGetEnergyIPDamageType(iEnergyType);
    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_S, iEnergyType);
    int     iStackSize      = GetItemStackSize(oItem);

    itemproperty ipEnergyDamageBonus = ItemPropertyDamageBonus(iIPDamageType, IP_CONST_DAMAGEBONUS_1d6);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eVis     = EffectVisualEffect(iVisualType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetObjectType(oItem)==OBJECT_TYPE_CREATURE) {
        oItem = GetItemInSlot(INVENTORY_SLOT_ARROWS, spInfo.oTarget);
        if(!GetIsObjectValid(oItem)) oItem = GetItemInSlot(INVENTORY_SLOT_BOLTS, spInfo.oTarget);
        if(!GetIsObjectValid(oItem)) oItem = GetItemInSlot(INVENTORY_SLOT_BULLETS, spInfo.oTarget);
    }
    if(GetIsObjectValid(oItem)) {
        iStackSize = GetItemStackSize(oItem);
        if(GetBaseItemType(oItem)==BASE_ITEM_ARROW ||
            GetBaseItemType(oItem)==BASE_ITEM_BOLT ||
            GetBaseItemType(oItem)==BASE_ITEM_BULLET) {
                if(iStackSize>50) {
                    SetItemStackSize(oItem, 50);
                }
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, GetItemPossessor(oItem));
                GRIPSafeAddItemProperty(oItem, ipEnergyDamageBonus, fDuration);
                if(iStackSize>50) {
                    object oNewItem = CreateItemOnObject(GetResRef(oItem), GetItemPossessor(oItem), iStackSize-50);
                }
        }
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
