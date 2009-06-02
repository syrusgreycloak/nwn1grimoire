//*:**************************************************************************
//*:*  GR_S2_DIVMIGHT.NSS
//*:**************************************************************************
//*:*
//*:* Divine Might
//*:* Created By: Brent  Created On: Sep 13 2002
//*:**************************************************************************
//*:* Updated On: December 3, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_ITEMPROP"

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
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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
    int     iCharismaBonus  = GetAbilityModifier(ABILITY_CHARISMA);
    int     iDamage         = IPGetDamageBonusConstantFromNumber(iCharismaBonus);

    itemproperty ipAdd      = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, iDamage);
    float   fDuration       = RoundsToSeconds(1) + 1.0; // Trying to make sure we get 1 full round
    object  oWeapon1        = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spInfo.oTarget);
    object  oWeapon2        = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spInfo.oTarget);

    int     bWeapon1        = FALSE;
    int     bWeapon2        = FALSE;

    if(IPGetIsMeleeWeapon(oWeapon1)) bWeapon1 = TRUE;
    if(IPGetIsMeleeWeapon(oWeapon2)) bWeapon2 = TRUE;
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GetHasFeat(FEAT_TURN_UNDEAD, oCaster)) {
        SpeakStringByStrRef(40550);
    } else if(!GetHasFeatEffect(413, spInfo.oTarget)) {
        if(bWeapon1 || bWeapon2) {
            if(iCharismaBonus>0) {
                GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget);
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_DIVINE_MIGHT, FALSE));
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, fDuration);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                if(bWeapon1) GRIPSafeAddItemProperty(oWeapon1, ipAdd, fDuration);
                if(bWeapon2) GRIPSafeAddItemProperty(oWeapon2, ipAdd, fDuration);
            }
            DecrementRemainingFeatUses(oCaster, FEAT_TURN_UNDEAD);
            DecrementRemainingFeatUses(oCaster, FEAT_GR_DISPEL_TURNING);
            DecrementRemainingFeatUses(oCaster, FEAT_GR_BOLSTER_UNDEAD);
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
