//*:**************************************************************************
//*:*  GR_S0_TENSTRANS.NSS
//*:**************************************************************************
//*:* Tenser's Transformation (NW_S0_TensTrans.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Oct 26, 2001
//*:* 3.5 Player's Handbook (p. 294)
//*:**************************************************************************
//*:* Updated On: November 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //----------------------------------------------------------------------------
    // GZ, Nov 3, 2003
    // There is a serious problems with creatures turning into unstoppable killer
    // machines when affected by tensers transformation. NPC AI can't handle that
    // spell anyway, so I added this code to disable the use of Tensers by any
    // NPC.
    //----------------------------------------------------------------------------
    if (!GetIsPC(OBJECT_SELF))
    {
      WriteTimestampedLogEntry(GetName(OBJECT_SELF) + "[" + GetTag (OBJECT_SELF) +"] tried to cast Tenser's Transformation. Bad! Remove that spell from the creature");
      return;
    }

    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = 4;
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     bAddSimpleWeaponFeat    = FALSE;
    int     bAddMartialWeaponFeat   = FALSE;
    object  oPCHide                 = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCaster);

    if(!GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE)) bAddSimpleWeaponFeat = TRUE;
    if(!GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL)) bAddMartialWeaponFeat = TRUE;

    itemproperty ipSimpleWeapFeat = ItemPropertyBonusFeat(IP_CONST_FEAT_WEAPON_PROF_SIMPLE);
    itemproperty ipMartialWeapFeat = ItemPropertyBonusFeat(IP_CONST_FEAT_WEAPON_PROF_MARTIAL);
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
    /*** NWN1 SPECIFIC ***/
        effect eVis     = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eDur = EffectVisualEffect(VFX_DUR_SPELL_TENSERS_TRANSFORMATION);
    effect eSave    = EffectSavingThrowIncrease(SAVING_THROW_FORT, 5);
    effect eAC      = EffectACIncrease(iBonus, AC_NATURAL_BONUS);
    effect eStr     = EffectAbilityIncrease(ABILITY_STRENGTH, iBonus);
    effect eDex     = EffectAbilityIncrease(ABILITY_DEXTERITY, iBonus);
    effect eCon     = EffectAbilityIncrease(ABILITY_CONSTITUTION, iBonus);
    effect eSwing   = EffectModifyAttacks(2);

    //Link effects
    effect eLink = EffectLinkEffects(eDur, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eStr);
    eLink = EffectLinkEffects(eLink, eDex);
    eLink = EffectLinkEffects(eLink, eCon);
    eLink = EffectLinkEffects(eLink, eSwing);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_TENSERS_TRANSFORMATION, FALSE));

    ClearAllActions(); // prevents an exploit
    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
    if(bAddSimpleWeaponFeat || bAddMartialWeaponFeat) {
        if(!GetIsObjectValid(oPCHide)) {
            oPCHide = CreateItemOnObject("x2_it_emptyskin", spInfo.oTarget);
        }
        if(bAddSimpleWeaponFeat) GRIPSafeAddItemProperty(oPCHide, ipSimpleWeapFeat, fDuration);
        if(bAddMartialWeaponFeat) GRIPSafeAddItemProperty(oPCHide, ipMartialWeapFeat, fDuration);
        DelayCommand(1.0f, AssignCommand(oCaster, ActionEquipItem(oPCHide, INVENTORY_SLOT_CARMOUR)));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
