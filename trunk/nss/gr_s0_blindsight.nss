//*:**************************************************************************
//*:*  GR_S0_BLINDSIGHT.NSS
//*:**************************************************************************
//*:* Blindsight (sg_s0_blndsight.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 3, 2004
//*:* Spell Compendium (p. 32)
//*:*
//*:* Greater Blindsight   2007 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 19, 2007
//*:* Spell Compendium (p. 32)
//*:*
//*:* Voidsense
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 1, 2008
//*:* Complete Arcane (p. 136)
//*:**************************************************************************
//*:* Updated On: May 1, 2008
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
    int     iDurAmount        = (spInfo.iSpellID==SPELL_I_VOIDSENSE ? 24 : spInfo.iCasterLevel);
    int     iDurType          = (spInfo.iSpellID==SPELL_I_VOIDSENSE ? DUR_TYPE_HOURS : DUR_TYPE_TURNS);

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

    int     iIPFeatType = (spInfo.iSpellID!=SPELL_GR_GREATER_BLINDSIGHT ? IP_CONST_FEAT_BLIND_FIGHT : IP_CONST_FEAT_BLINDSIGHT_60_FEET);
    object oPCHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCaster);

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
    effect eImpVis  = EffectVisualEffect(VFX_IMP_GOOD_HELP);  // Visible impact effect
    effect eVis     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    itemproperty ipBlindsightFeat = ItemPropertyBonusFeat(iIPFeatType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
    if(!GetIsObjectValid(oPCHide)) {
        oPCHide = CreateItemOnObject("x2_it_emptyskin", spInfo.oTarget);
    }
    GRIPSafeAddItemProperty(oPCHide, ipBlindsightFeat, fDuration);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, fDuration);
    AssignCommand(oCaster, ActionEquipItem(oPCHide, INVENTORY_SLOT_CARMOUR));

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
