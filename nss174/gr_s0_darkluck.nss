//*:**************************************************************************
//*:*  GR_S0_DARKLUCK.NSS
//*:**************************************************************************
//*:* Dark One's Own Luck
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 23, 2008
//*:* Complete Arcane (p. 133)
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
    int     iBonus            = MinInt(GetLevelByClass(CLASS_TYPE_WARLOCK), GetAbilityModifier(ABILITY_CHARISMA));
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 24;
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

    int     iVisualType     = (GetAlignmentGoodEvil(oCaster)==ALIGNMENT_EVIL ? VFX_IMP_EVIL_HELP : VFX_IMP_GOOD_HELP);
    int     iSaveAffected;

    switch(spInfo.iSpellID) {
        case SPELL_I_DARK_ONES_OWN_LUCK:
        case SPELL_I_DARK_ONES_OWN_LUCK_FORTITUDE:
            iSaveAffected = SAVING_THROW_FORT;
            break;
        case SPELL_I_DARK_ONES_OWN_LUCK_WILL:
            iSaveAffected = SAVING_THROW_WILL;
            break;
        case SPELL_I_DARK_ONES_OWN_LUCK_REFLEX:
            iSaveAffected = SAVING_THROW_REFLEX;
            break;
    }

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
    effect eVis         = EffectVisualEffect(iVisualType);
    effect eSaveBonus   = EffectSavingThrowIncrease(iSaveAffected, iBonus);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink        = EffectLinkEffects(eSaveBonus, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_I_DARK_ONES_OWN_LUCK, spInfo.oTarget)) {
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetStringByStrRef(16939248));
        }
    } else {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_I_DARK_ONES_OWN_LUCK));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
