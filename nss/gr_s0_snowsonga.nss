//*:**************************************************************************
//*:*  GR_S0_SNOWSONGA.NSS
//*:**************************************************************************
//*:* Snowsong: OnEnter
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 9, 2008
//*:* Frostburn (p. 105)
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

    spInfo.oTarget = GetEnteringObject();
    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iIPDmgBonus     = IP_CONST_DAMAGEBONUS_1d6;
    object  oMyWeapon       = IPGetTargetedOrEquippedMeleeWeapon();

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EMPOWER)) iIPDmgBonus = IP_CONST_DAMAGEBONUS_1d10;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_MAXIMIZE)) iIPDmgBonus = IP_CONST_DAMAGEBONUS_6;

    itemproperty ipColdDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, iIPDmgBonus);

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eAllyImp     = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MINOR);
    effect eChaInc      = EffectAbilityIncrease(ABILITY_CHARISMA, 4);
    effect eACInc       = EffectACIncrease(4);
    effect eColdResist  = EffectDamageResistance(DAMAGE_TYPE_COLD, 15);
    effect eFastHeal    = EffectRegenerate(1, GRGetDuration(1));
    effect eAllyLink    = EffectLinkEffects(eChaInc, eACInc);
    eAllyLink = EffectLinkEffects(eAllyLink, eColdResist);
    eAllyLink = EffectLinkEffects(eAllyLink, eFastHeal);

    effect eEnemyImp    = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MINOR);
    effect eSpellFailure= EffectSpellFailure(20);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, spInfo.iSpellID, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAllyImp, spInfo.oTarget, 1.7f);
        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eAllyLink, spInfo.oTarget);

        if(GetIsObjectValid(oMyWeapon)) {
            GRIPSafeAddItemProperty(oMyWeapon, ItemPropertyVisualEffect(ITEM_VISUAL_COLD), fDuration);
            GRIPSafeAddItemProperty(oMyWeapon, ipColdDamage, fDuration);
        }
        SetLocalObject(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_WEAPON", oMyWeapon);
    } else if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster, NO_CASTER)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, spInfo.iSpellID, TRUE));
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS)) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEnemyImp, spInfo.oTarget, 1.7f);
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eSpellFailure, spInfo.oTarget);
            }
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
