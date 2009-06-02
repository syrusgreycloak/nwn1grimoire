//*:**************************************************************************
//*:*  GR_S0_FIRESHLD.NSS
//*:**************************************************************************
//*:*
//*:* Fire Shield
//*:* 3.5 Player's Handbook (p. 230)
//*:* Fire Shield, Mass
//*:* Spell Compendium (p. 92)
//*:*
//*:*
//*:*        FIRE SHIELD NO LONGER CAUSES DOUBLE DAMAGE FOR SAME-TYPE ATTACKS!!!!!
//*:*        (ie COLD attacks vs CHILL shield) in 3.5 edition
//*:*
//*:*
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: October 3, 2003
//*:**************************************************************************
//*:* Updated On: October 25, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType        = 6;
    int     iNumDice        = 1;
    int     iBonus          = spInfo.iCasterLevel;
    int     iDamage         = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

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
    float   fRange          = FeetToMeters(15.0);

    int     bMultiTarget    = (spInfo.iSpellID==SPELL_GR_MASS_FIRE_SHIELD ? TRUE : FALSE);


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
    effect eImpact = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eVis;
    effect eCold;
    effect eFire;
    effect eShield;
    effect eLink;

    switch(spInfo.iSpellID) {
        case SPELL_GR_MASS_FIRE_SHIELD_HOT:
            bMultiTarget = TRUE;
        case SPELL_GR_FIRE_SHIELD_HOT:
            eVis    = EffectVisualEffect(VFX_DUR_FIRE_SHIELD_HOT);
            eCold   = EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, 50);
            eShield = EffectDamageShield(spInfo.iCasterLevel, iDamage, iEnergyType);
            eLink   = EffectLinkEffects(eVis, eShield);
            eLink   = EffectLinkEffects(eLink, eCold);
            break;
        case SPELL_GR_MASS_FIRE_SHIELD_COLD:
            bMultiTarget = TRUE;
        case SPELL_GR_FIRE_SHIELD_COLD:
            eVis    = EffectVisualEffect(VFX_DUR_FIRE_SHIELD_COLD);
            eFire   = EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, 50);
            eShield = EffectDamageShield(spInfo.iCasterLevel, iDamage, iEnergyType);
            eLink   = EffectLinkEffects(eVis, eShield);
            eLink   = EffectLinkEffects(eLink, eFire);
            break;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, TRUE)) {
                GRRemoveMultipleSpellEffects(SPELL_GR_FIRE_SHIELD_HOT, SPELL_GR_FIRE_SHIELD_COLD, spInfo.oTarget, TRUE, SPELL_GR_MASS_FIRE_SHIELD_HOT,
                    SPELL_GR_MASS_FIRE_SHIELD_COLD);
                GRRemoveSpellEffects(SPELL_ELEMENTAL_SHIELD,spInfo.oTarget);

                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
