//*:**************************************************************************
//*:*  GR_S0_LIGHT.NSS
//*:**************************************************************************
//*:*
//*:* Light (NW_S0_Light.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p.
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Aug 15, 2001
//*:**************************************************************************
//*:* Updated On: November 2, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
#include "X2_INC_CRAFT"

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_LIGHTDARK"
//#include "GR_IN_SPELLS" - INCLUDED IN GR_IN_LIGHTDARK
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"
#include "GR_IN_DEBUG"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    AutoDebugString("Entering spell script for spell " + GRSpellToString(GetSpellId()));
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;

    AutoDebugString("Getting spell struct");
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
    AutoDebugString("Storing spell struct on caster");
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
    AutoDebugString("Checking spellhook");
    if(!GRSpellhookAbortSpell()) {
        AutoDebugString("Spellhook returned 'TRUE'.  Aborting spell.");
        return;
    }

    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAOEType;
    string  sAOEType;
    int     iVisualType;
    int     iLightBrightness;
    int     iLightColor;

    switch(spInfo.iSpellID) {
        case SPELL_LIGHT:
            iAOEType = AOE_MOB_LIGHT;
            sAOEType = AOE_TYPE_LIGHT;
            iVisualType = VFX_DUR_LIGHT_WHITE_15;
            iLightBrightness = IP_CONST_LIGHTBRIGHTNESS_NORMAL;
            iLightColor = IP_CONST_LIGHTCOLOR_WHITE;
            break;
        case SPELL_GR_DAYLIGHT:
            iAOEType = AOE_MOB_DAYLIGHT;
            sAOEType = AOE_TYPE_DAYLIGHT;
            iVisualType = VFX_DUR_LIGHT_YELLOW_20;
            iLightBrightness = IP_CONST_LIGHTBRIGHTNESS_BRIGHT;
            iLightColor = IP_CONST_LIGHTCOLOR_YELLOW;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    AutoDebugString("Resolving metamagic");
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        iAOEType = (spInfo.iSpellID==SPELL_LIGHT ? AOE_MOB_LIGHT_WIDE : AOE_MOB_DAYLIGHT_WIDE);
        sAOEType = (spInfo.iSpellID==SPELL_LIGHT ? AOE_TYPE_LIGHT_WIDE : AOE_TYPE_DAYLIGHT_WIDE);
    }
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
    AutoDebugString("Setting effect variables");
    effect eVis     = EffectVisualEffect(iVisualType);
    /*** NWN1 SINGLE ***/ effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eAOE     = GREffectAreaOfEffect(iAOEType);

    effect eLink    = EffectLinkEffects(eVis, eAOE);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    AutoDebugString("Applying spell effects");
    //*:* Handle spell cast on item....
    if(GetObjectType(spInfo.oTarget)==OBJECT_TYPE_ITEM && !CIGetIsCraftFeatBaseItem(spInfo.oTarget)) {
        // Do not allow casting on non-equippable items
        if(!IPGetIsItemEquipable(spInfo.oTarget)) {
         // Item must be equipable...
            FloatingTextStrRefOnCreature(83326, OBJECT_SELF);
            return;
        }

        itemproperty ip = ItemPropertyLight(iLightBrightness, iLightColor);

        if(GetItemHasItemProperty(spInfo.oTarget, ITEM_PROPERTY_LIGHT)) {
            IPRemoveMatchingItemProperties(spInfo.oTarget, ITEM_PROPERTY_LIGHT, DURATION_TYPE_TEMPORARY);
        }

        GRIPSafeAddItemProperty(spInfo.oTarget, ip, fDuration);

    } else {
        if(!GRGetHigherLvlDarknessEffectsInArea(spInfo.iSpellID, GetLocation(spInfo.oTarget))) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
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
