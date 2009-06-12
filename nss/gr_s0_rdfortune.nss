//*:**************************************************************************
//*:*  GR_S0_RDFORTUNE.NSS
//*:**************************************************************************
//*:* Ruin Delver's Fortune
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 21, 2009
//*:* Spell Compendium (p. 178)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
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

    int     iDieType          = 8;
    int     iNumDice          = 4;
    int     iBonus            = 0;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic, 0);
    int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iCHAMod         = MaxInt(0, GetAbilityModifier(ABILITY_CHARISMA, oCaster));
    int     bHasIp          = FALSE;
    itemproperty ip;
    object  oPCHide;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    iDamage = GRGetSpellDamageAmount(spInfo);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eImm;
    effect eLink;

    switch(spInfo.iSpellID) {
        case SPELL_GR_RUIN_DELVERS_FORTUNE_FORT:
            effect eFort = EffectSavingThrowIncrease(SAVING_THROW_FORT, iCHAMod);
            eImm  = EffectImmunity(IMMUNITY_TYPE_POISON);
            eLink = EffectLinkEffects(eDur, eFort);
            eLink = EffectLinkEffects(eLink, eImm);
            break;
        case SPELL_GR_RUIN_DELVERS_FORTUNE_REF:
            effect eRef  = EffectSavingThrowIncrease(SAVING_THROW_REFLEX, iCHAMod);
            eLink = EffectLinkEffects(eDur, eRef);
            bHasIp = TRUE;
            ip = ItemPropertyBonusFeat(IP_CONST_FEAT_EVASION);
            break;
        case SPELL_GR_RUIN_DELVERS_FORTUNE_WILL:
            effect eWill = EffectSavingThrowIncrease(SAVING_THROW_WILL, iCHAMod);
            eImm  = EffectImmunity(IMMUNITY_TYPE_FEAR);
            eLink = EffectLinkEffects(eDur, eWill);
            eLink = EffectLinkEffects(eLink, eImm);
            break;
        case SPELL_GR_RUIN_DELVERS_FORTUNE_THP:
            effect eTHP  = EffectTemporaryHitpoints(iDamage + iCHAMod);
            eLink = EffectLinkEffects(eLink, eTHP);
            break;
    }
    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(spInfo.iSpellID, oCaster);

    SignalEvent(oCaster, EventSpellCastAt(oCaster, spInfo.iSpellID));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);
    if(bHasIp) {
        oPCHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCaster);
        if(!GetIsObjectValid(oPCHide)) oPCHide = CreateItemOnObject("x2_it_emptyskin", oCaster);
        GRIPSafeAddItemProperty(oPCHide, ip, fDuration);
        AssignCommand(oCaster, ActionEquipItem(oPCHide, INVENTORY_SLOT_CARMOUR));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
