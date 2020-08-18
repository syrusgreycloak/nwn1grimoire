//*:**************************************************************************
//*:*  GR_S0_RETENERV.NSS
//*:**************************************************************************
//*:* Retributive Enervation
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 21, 2008
//*:* Complete Mage (p. 116)
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
    int     iDurAmount        = MinInt(10, spInfo.iCasterLevel/2)*2;
    int     iDurType          = DUR_TYPE_HOURS;

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

    int     iNumLevels      = MinInt(10, spInfo.iCasterLevel/2);

    itemproperty ipOnHitCastSpell = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_RETRIBUTIVE_ENERVATION_HIT, spInfo.iCasterLevel);
    object oPCHide;

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
    effect eNegAura = EffectVisualEffect(VFX_DUR_PROT_SHADOW_ARMOR);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);
    SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_RETRIBUTIVE_ENERVATION));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eNegAura, oCaster, fDuration);

    //*:**********************************************
    //*:*  This section implements adding a temp item
    //*:* property to activate on hit property
    //*:**********************************************
    oPCHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, spInfo.oTarget);
    if(!GetIsObjectValid(oPCHide)) {
        oPCHide = CreateItemOnObject("x2_it_emptyskin", spInfo.oTarget);
    }
    GRIPSafeAddItemProperty(oPCHide, ipOnHitCastSpell, fDuration);
    AssignCommand(spInfo.oTarget, ActionEquipItem(oPCHide, INVENTORY_SLOT_CARMOUR));

    GRSetAOESpellId(spInfo.iSpellID, oPCHide);
    GRSetSpellInfo(spInfo, oPCHide);
    //*:**********************************************
    SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_NUMLEVELS", iNumLevels);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
