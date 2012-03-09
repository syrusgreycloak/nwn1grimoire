//*:**************************************************************************
//*:*  GR_S0_IRONBODY.NSS
//*:**************************************************************************
//*:* Iron Body (sg_s0_ironbody.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 10, 2004
//*:* 3.5 Player's Handbook (p. 245)
//*:*
//*:* Stone Body
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 2, 2009
//*:* Spell Compendium (p. 207)
//*:**************************************************************************
//*:* Updated On: January 2, 2009
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
    int     iBonus            = (spInfo.iSpellID==SPELL_STONE_BODY ? 4 : 6);
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_TURNS;

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

    int     iCurrentDex       = GetAbilityScore(oCaster, ABILITY_DEXTERITY);
    int     iDmgReductionAmt  = (spInfo.iSpellID==SPELL_IRON_BODY ? 50 : 10);
    int     iDmgReductionPlus = (spInfo.iSpellID==SPELL_IRON_BODY ? DAMAGE_POWER_PLUS_THREE : DAMAGE_POWER_PLUS_TWO);
    int     iStrAdj           = iBonus;
    int     iDexAdj           = MinInt(iBonus, iCurrentDex-1);
    int     iArcaneFail       = 50;
    int     iArmorCheck       = 8;
    int     iMoveAdj          = 50;

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
    effect eImpVis = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MAJOR);  // Visible impact effect - 1.0 dur for "impact" look
    effect eStrInc = EffectAbilityIncrease(ABILITY_STRENGTH, iStrAdj);
    effect eDexDec = EffectAbilityDecrease(ABILITY_DEXTERITY, iDexAdj);
    effect eArcaneSpellFail = EffectSpellFailure(iArcaneFail);
    effect eArmorCheckPenalty = GREffectArmorCheckPenalty(iArmorCheck);
    effect eDamageReduction = EffectDamageReduction(iDmgReductionAmt, iDmgReductionPlus);
    effect eMovementReduction = EffectMovementSpeedDecrease(iMoveAdj);

    effect eLink1 = EffectLinkEffects(eStrInc, eDexDec);
    eLink1 = EffectLinkEffects(eLink1, eMovementReduction);
    eLink1 = EffectLinkEffects(eLink1, eDamageReduction);
    if(spInfo.iSpellID==SPELL_IRON_BODY) {
        eLink1 = EffectLinkEffects(eLink1, eArcaneSpellFail);
        eLink1 = EffectLinkEffects(eLink1, eArmorCheckPenalty);
    } else {
        eLink1 = EffectLinkEffects(eLink1, EffectVisualEffect(VFX_DUR_PETRIFY));
    }

    effect eImmune1 = EffectImmunity(IMMUNITY_TYPE_CRITICAL_HIT);
    effect eImmune2 = EffectImmunity(IMMUNITY_TYPE_ABILITY_DECREASE);
    effect eImmune3 = EffectImmunity(IMMUNITY_TYPE_BLINDNESS);
    effect eImmune4 = EffectImmunity(IMMUNITY_TYPE_DEAFNESS);
    effect eImmune5 = EffectImmunity(IMMUNITY_TYPE_DISEASE);
    effect eImmune6 = EffectSpellImmunity(SPELL_DROWN);
    effect eImmune7 = EffectDamageImmunityIncrease(DAMAGE_TYPE_ELECTRICAL, 100);
    effect eImmune8 = EffectImmunity(IMMUNITY_TYPE_POISON);
    effect eImmune9 = EffectImmunity(IMMUNITY_TYPE_STUN);
    effect eImmune10 = EffectDamageImmunityIncrease(DAMAGE_TYPE_ACID, 50);
    effect eImmune11 = EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, 50);
    effect eImmune12 = EffectSpellImmunity(SPELL_STINKING_CLOUD);
    effect eImmune13 = EffectSpellImmunity(SPELL_CLOUDKILL);
    effect eImmune14 = EffectSpellImmunity(SPELL_CONTAGION);
    effect eImmune15 = EffectSpellImmunity(SPELLABILITY_TYRANT_FOG_MIST);
    effect eImmune16 = EffectSpellImmunity(SPELL_POLYMORPH_SELF);
    effect eImmune17 = EffectSpellImmunity(SPELL_SHAPECHANGE);
    effect eImmune18 = EffectSpellImmunity(SPELL_GR_IGEDRAZAARS_MIASMA);
    effect eImmune19 = EffectSpellImmunity(SPELL_GR_FREEZING_CURSE);
    effect eImmune20 = EffectSpellImmunity(SPELL_DESTRUCTION);
    effect eImmune21 = EffectSpellImmunity(SPELL_HORRID_WILTING);
    effect eImmune22 = EffectSpellImmunity(406);  // Beer
    effect eImmune23 = EffectSpellImmunity(407);  // Wine
    effect eImmune24 = EffectSpellImmunity(408);  // Spirits
    effect eImmune25 = EffectSpellImmunity(SPELL_WOUNDING_WHISPERS);
    effect eImmune26 = EffectSpellImmunity(SPELL_TASHAS_HIDEOUS_LAUGHTER);
    effect eImmune27 = EffectSpellImmunity(SPELL_INFESTATION_OF_MAGGOTS);
    effect eImmune28 = EffectSpellImmunity(SPELL_GR_FLENSING);
    effect eImmune29 = EffectSpellImmunity(SPELL_GR_HEMORRHAGE);
    effect eImmune30 = EffectSpellImmunity(SPELL_FLESH_TO_STONE);
    effect eImmune31 = EffectSpellImmunity(495); // Breath_Petrify
    effect eImmune32 = EffectSpellImmunity(496); // Touch_Petrify
    effect eImmune33 = EffectSpellImmunity(496); // Gaze_Petrify
    effect eImmune34 = EffectSpellImmunity(SPELL_GR_CAST_IN_STONE);
    effect eImmune35 = EffectSpellImmunity(778); // Beholder ray Flesh to Stone
    effect eImmune36 = EffectSpellImmunity(SPELL_GR_CHROMATIC_ORB_VIOLET);

    effect eImmuneLink = EffectLinkEffects(eImmune1, eImmune2);
    if(spInfo.iSpellID==SPELL_IRON_BODY) eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune3);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune4);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune5);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune6);
    if(spInfo.iSpellID==SPELL_IRON_BODY) eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune7);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune8);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune9);
    if(spInfo.iSpellID==SPELL_IRON_BODY) eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune10);
    if(spInfo.iSpellID==SPELL_IRON_BODY) eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune11);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune12);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune13);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune14);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune15);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune16);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune17);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune18);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune19);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune20);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune21);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune22);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune23);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune24);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune25);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune26);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune27);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune28);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune29);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune30);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune31);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune32);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune33);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune34);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune35);
    eImmuneLink = EffectLinkEffects(eImmuneLink, eImmune36);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(SPELL_STONE_BODY, spInfo.oTarget);
    if(spInfo.iSpellID==SPELL_IRON_BODY) {
        GRRemoveSpellEffects(SPELL_IRON_BODY, spInfo.oTarget);
    } else if(GetHasSpellEffect(SPELL_IRON_BODY, oCaster) && spInfo.iSpellID==SPELL_STONE_BODY) {
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetStringByStrRef(16939246));
        }
        GRClearSpellInfo(spInfo.iSpellID, oCaster);
        return;
    }

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eImpVis, spInfo.oTarget, 1.0);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, spInfo.oTarget, fDuration);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eImmuneLink, spInfo.oTarget, fDuration);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
