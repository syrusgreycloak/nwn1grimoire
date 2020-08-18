//*:**************************************************************************
//*:*  GR_S0_DEATHWARD.NSS
//*:**************************************************************************
//*:* Death Ward (NW_S0_DeaWard.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: July 27, 2001
//*:* 3.5 Player's Handbook (p. 217)
//*:*
//*:* Undeath's Eternal Foe (x0_s0_udetfoe.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Brent  Created On: July 31, 2002
//*:* Spell Compendium (p. 226)
//*:**************************************************************************
//*:* Death Ward, Mass
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: August 6, 2007
//*:* Spell Compendium (p. 61)
//*:**************************************************************************
//*:* Updated On: October 25, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
#include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

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
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = (spInfo.iSpellID==SPELL_UNDEATHS_ETERNAL_FOE ? DUR_TYPE_ROUNDS : DUR_TYPE_TURNS);

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
    float   fRange          = FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     bMultiTarget        = (spInfo.iSpellID!=SPELL_DEATH_WARD);
    int     iNumCreatures       = (spInfo.iSpellID==SPELL_MASS_DEATH_WARD ? spInfo.iCasterLevel : spInfo.iCasterLevel/5);
    int     iSpellTargetType    = (spInfo.iSpellID==SPELL_MASS_DEATH_WARD ? SPELL_TARGET_ALLALLIES : SPELL_TARGET_PARTYONLY);

    //*** NWN2 SINGLE ***/ int      iDurVisType = (spInfo.iSpellID==SPELL_UNDEATHS_ETERNAL_FOE ? VFX_DUR_SPELL_UNDEATH_ETERNAL_FOE : VFX_DUR_SPELL_DEATH_WARD);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration     = ApplyMetamagicDurationMods(fDuration);
        iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
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
    /*** NWN1 SINGLE ***/ effect eMassVis = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));

    //*:* Death Ward Effects
    effect eDeath   = EffectImmunity(IMMUNITY_TYPE_DEATH);
    effect eNeg     = EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, 100);
    effect eNegLevel= EffectImmunity(IMMUNITY_TYPE_NEGATIVE_LEVEL);
    /*** NWN1 SPECIFIC ***/
        effect eVis     = EffectVisualEffect(VFX_IMP_DEATH_WARD);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        effect eVis     = EffectVisualEffect(VFX_HIT_SPELL_HOLY);
        effect eDur     = EffectVisualEffect(iDurVisType);
    /*** END NWN2 SPECIFIC ***/

    effect eLink    = EffectLinkEffects(eDeath, eDur);
    eLink = EffectLinkEffects(eLink, eNeg);
    eLink = EffectLinkEffects(eLink, eNegLevel);

    //*:* Undeath's Eternal Foe Effects
    effect eImm1    = EffectImmunity(IMMUNITY_TYPE_ABILITY_DECREASE);
    effect eImm2    = EffectImmunity(IMMUNITY_TYPE_FEAR);
    effect eImm3    = EffectImmunity(IMMUNITY_TYPE_DISEASE);
    effect eImm4    = EffectImmunity(IMMUNITY_TYPE_POISON);
    effect eImm5    = EffectImmunity(IMMUNITY_TYPE_PARALYSIS);
    effect eAC      = EffectACIncrease(4, AC_DEFLECTION_BONUS);
    effect eDur2    = EffectVisualEffect(VFX_DUR_GHOSTLY_VISAGE);

    effect eUndFoeLink = EffectLinkEffects(eImm1, eImm2);
    eUndFoeLink = EffectLinkEffects(eUndFoeLink, eImm3);
    eUndFoeLink = EffectLinkEffects(eUndFoeLink, eImm4);
    eUndFoeLink = EffectLinkEffects(eUndFoeLink, eImm5);
    eUndFoeLink = EffectLinkEffects(eUndFoeLink, eAC);
    eUndFoeLink = EffectLinkEffects(eUndFoeLink, eDur2);
    eUndFoeLink = VersusRacialTypeEffect(eUndFoeLink, RACIAL_TYPE_UNDEAD);  // only vs. Undead!!

    if(spInfo.iSpellID==SPELL_UNDEATHS_ETERNAL_FOE) eLink = EffectLinkEffects(eLink, eUndFoeLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eMassVis, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, iSpellTargetType, oCaster, TRUE)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
                if(!spInfo.bNWN2 || spInfo.iSpellID==SPELL_UNDEATHS_ETERNAL_FOE) GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                iNumCreatures--;
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumCreatures>0);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
