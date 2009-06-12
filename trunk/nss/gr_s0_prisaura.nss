//*:**************************************************************************
//*:*  GR_S0_PRISAURA.NSS
//*:**************************************************************************
//*:* Prismatic Aura
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 21, 2008
//*:* Complete Mage (p. 113)
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

    itemproperty ipOnHitCastSpell = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_PRISMATIC_AURA_HIT, spInfo.iCasterLevel);
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
    effect eVis = EffectVisualEffect(VFX_DUR_GLOBE_INVULNERABILITY);
    effect eConceal = EffectConcealment(20);
    effect eLink = EffectLinkEffects(eVis, eConceal);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
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
    SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_RED", TRUE);
    SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_ORANGE", TRUE);
    SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_YELLOW", TRUE);
    SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_GREEN", TRUE);
    SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_BLUE", TRUE);
    SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_INDIGO", TRUE);
    SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_VIOLET", TRUE);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
