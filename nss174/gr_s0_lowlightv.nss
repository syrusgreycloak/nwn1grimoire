//*:**************************************************************************
//*:*  GR_S0_LOWLIGHTV.NSS
//*:**************************************************************************
//*:* Low-light Vision
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: June 4, 2008
//*:* Spell Compendium (p. 134)
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    /*** NWN1 SPECIFIC ***/
        object oPCHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, spInfo.oTarget);
        itemproperty ipLowLightVision = ItemPropertyBonusFeat(IP_CONST_FEAT_LOWLIGHT_VISION);
    /*** END NWN1 SPECIFIC ***/
    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
    fDuration       = ApplyMetamagicDurationMods(fDuration);
    iDurationType   = ApplyMetamagicDurationTypeMods(iDurationType);
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
    effect eLink;
    /*** NWN1 SPECIFIC ***/
        effect eDur = EffectVisualEffect(VFX_DUR_MAGICAL_SIGHT);
        eLink = eDur;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        effect eDur     = EffectVisualEffect(VFX_DUR_SPELL_LOWLIGHT_VISION);
        effect eSight   = EffectLowLightVision();
        eLink = EffectLinkEffects(eDur, eSight);
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(SPELL_LOW_LIGHT_VISION, spInfo.oTarget);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));

    /*** NWN1 SPECIFIC ***/
        if(!GetIsObjectValid(oPCHide)) {
            oPCHide = CreateItemOnObject("x2_it_emptyskin", spInfo.oTarget);
        }
        GRIPSafeAddItemProperty(oPCHide, ipLowLightVision, fDuration);
        AssignCommand(spInfo.oTarget, ActionEquipItem(oPCHide, INVENTORY_SLOT_CARMOUR));
    /*** END NWN1 SPECIFIC ***/

    GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
