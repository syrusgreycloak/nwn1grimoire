//*:**************************************************************************
//*:*  GR_S0_BLCKBLDE.NSS
//*:**************************************************************************
//*:*
//*:* Black Blade of Disaster (X2_S0_BlckBlde) Copyright (c) 2001 Bioware Corp.
//*:*
//*:**************************************************************************
//*:* Created By: Andrew Nobbs
//*:* Created On: Nov 26, 2002
//*:**************************************************************************
//*:* Updated On: December 20, 2007
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
//*:* Creates the weapon that the creature will be using.
//*:**************************************************************************
void GRCreateBlackBladeSummonedItem(struct SpellStruct spInfo) {
    int iStat;

    //*:**********************************************
    //*:* cast from scroll, we just assume +5 ability modifier
    //*:**********************************************
    if(GetSpellCastItem()!=OBJECT_INVALID) {
        iStat = 5;
    } else {
        iStat = GRGetCasterAbilityModifierByClass(OBJECT_SELF, spInfo.iSpellCastClass);
        iStat = (iStat>20 ? 20 : iStat);
        iStat = (iStat<1 ? 0 : iStat);
    }

    object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED);
    //*:**********************************************
    //*:* Make the blade require concentration
    //*:**********************************************
    SetLocalInt(oSummon, "X2_L_CREATURE_NEEDS_CONCENTRATION", TRUE);
    SetPlotFlag(oSummon, TRUE);
    GRSetSpellInfo(spInfo, oSummon);

    object oWeapon;
    //*:**********************************************
    //*;* Create item on the creature, epuip it and add properties.
    //*:**********************************************
    oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oSummon);
    if(iStat > 0) {
        IPSetWeaponEnhancementBonus(oWeapon, iStat);
    }
    SetDroppableFlag(oWeapon, FALSE);
}

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eSummon  = EffectSummonCreature("gr_s_bblade");
    effect eVis     = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_3);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eVis, spInfo.lTarget);
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spInfo.lTarget, fDuration);
    DelayCommand(1.5, GRCreateBlackBladeSummonedItem(spInfo));

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
