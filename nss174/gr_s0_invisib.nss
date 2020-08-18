//*:**************************************************************************
//*:*  GR_S0_INVISIB.NSS
//*:**************************************************************************
//*:* Invisibility (NW_S0_Invisib.nss) Copyright (c) 2001 Bioware Corp.
//*:* Invisibility, Greater (NW_S0_ImprInvis.nss) Copyright (c) 2001 Bioware Corp.
//*:* Invisibility Sphere (NW_S0_InvSph.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:* 3.5 Player's Handbook (p. 245)
//*:**************************************************************************
//*:* Invisibility, Swift - Spell Compendium (p. 125)
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: March 31, 2003
//*:*
//*:* Greater Invisibility (Invocation) Complete Arcane (p. 135)
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: May 1, 2008
//*:* *** instead of retributive invisibility - greater instead of dark invocation ***
//*:* *** Retributive invisibility in NWN2 ***
//*:*
//*:* Walk Unseen        Complete Arcane (p. 136)
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: May 7, 2008
//*:**************************************************************************
//*:* Updated On: May 7, 2008
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
//*:* Supporting functions
//*:**************************************************************************
/*** NWN2 SPECIFIC ***
void RetributiveInvisCallback(object oCaster, int iSaveDC, float fDuration) {
    //SpawnScriptDebugger();

    if(!GetIsObjectValid(oCaster))  return;

    location lTarget = GetLocation(oCaster);

    // Do a quick explosion effect
    effect eExplode = EffectVisualEffect(VFX_INVOCATION_ELDRITCH_AOE);
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);

    int iDamageType     = DAMAGE_TYPE_SONIC;
    int iDamagePower    = DAMAGE_POWER_NORMAL;
    int iSaveType       = SAVING_THROW_TYPE_NONE;
    float fDistToDelay  = 0.25f;


    int iDamageAmt;
    float fDelay;
    effect eDmg;
    effect eStun;
    effect eDur;
    effect eDur2;


    object oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE );

    while(GetIsObjectValid(oTarget)) {
        if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {

            iDamageAmt = d6(4);
            iDamageAmt = ApplyMetamagicVariableMods(iDamageAmt, 4 * 6 );

            int iSaveResult = FortitudeSave(oTarget, iSaveDC, iSaveType, oCaster);
            if(iSaveResult==SAVING_THROW_CHECK_FAILED) { // saving throw failed
                eDmg = EffectDamage(iDamageAmt, iDamageType, iDamagePower);  // create the effects
                eStun = EffectStunned();
                eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                eDur2 = EffectVisualEffect(VFX_DUR_STUN);
                effect eLink = EffectLinkEffects(eStun, eDur);
                eLink = EffectLinkEffects(eLink, eDur2);

                fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget)) * fDistToDelay;
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, fDuration));
            } else if(iSaveResult==SAVING_THROW_CHECK_SUCCEEDED) { // Saving throw successful
                iDamageAmt /= 2; // halve the damage

                eDmg = EffectDamage(iDamageAmt, iDamageType, iDamagePower); // create the effect

                fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget)) * fDistToDelay;
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget));
            }

        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE );
    }

}
/*** END NWN2 SPECIFIC ***/

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    if(spInfo.iSpellID==SPELLABILITY_AS_INVISIBILITY) spInfo.iCasterLevel = GetLevelByClass(CLASS_TYPE_ASSASSIN);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

    int     iAOEType;
    string  sAOEType;
    object  oAOE;
    int     iVisType          = VFX_DUR_INVISIBILITY;

    switch(spInfo.iSpellID) {
        case SPELL_GR_INVISIBILITY_SWIFT:
            iDurAmount = 2;
            break;
        case SPELL_INVISIBILITY_SPHERE:
            iAOEType = AOE_PER_INVIS_SPHERE;
            sAOEType = AOE_TYPE_INVIS_SPHERE;
        case SPELL_INVISIBILITY:
            iDurType = DUR_TYPE_TURNS;
            break;
        case SPELL_GREATER_INVISIBILITY:
        case 799:   // Vampire_Invisibility
        case SPELL_I_RETRIBUTIVE_INVISIBILITY:
            iDurAmount = (spInfo.iSpellID==799 ? 5 : spInfo.iCasterLevel);
            iAOEType = AOE_MOB_IMPROVED_INVISIBILITY;
            sAOEType = AOE_TYPE_IMPROVED_INVISIBILITY;
            //*** NWN2 SINGLE ***/ if(spInfo.iSpellID==SPELL_I_RETRIBUTIVE_INVISIBILITY) iVisType = VFX_DUR_INVOCATION_RETRIBUTIVE_INVISIBILITY;
            break;
        case SPELL_I_WALK_UNSEEN:
            iDurAmount = 24;
            iDurType = DUR_TYPE_HOURS;
            break;
    }


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

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(10.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     bMultiTarget    = (spInfo.iSpellID==SPELL_INVISIBILITY_SPHERE);

    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);

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
    effect eInvis   = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
    effect eVis     = EffectVisualEffect(iVisType);
    effect eAOE     = GREffectAreaOfEffect(iAOEType, "", "", "", sAOEType);
    effect eLink    = EffectLinkEffects(eAOE, eVis);

    /*** NWN1 SINGLE ***/ effect eImpact  = EffectVisualEffect(VFX_IMP_HEAD_MIND);

    /*** NWN2 SPECIFIC ***
        effect eImpact      = EffectVisualEffect(VFX_HIT_SPELL_ILLUSION);
        effect eOnDispel;
        if(spInfo.iSpellID==SPELL_I_RETRIBUTIVE_INVISIBILITY) {
            eOnDispel = EffectOnDispel(0.5f, RetributiveInvisCallback(OBJECT_SELF, spInfo.iDC, GRGetDuration(1)));
        } else {
            eOnDispel = EffectOnDispel(0.0f, RemoveEffectsFromSpell(oTarget, spInfo.iSpellID));
        }
        eLink = EffectLinkEffects(eLink, eOnDispel);
        eInvis = EffectLinkEffects(eInvis, eOnDispel);
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        GRApplyEffectToObject(iDurationType, eAOE, spInfo.oTarget, fDuration);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
                if(!GetHasSpellEffect(SPELL_GR_FAERIE_FIRE, spInfo.oTarget) && !GRGetHasEffectTypeFromSpell(EFFECT_TYPE_VISUALEFFECT, spInfo.oTarget, SPELL_GR_HEARTFIRE) &&
                    !GetHasSpellEffect(SPELL_GR_GLITTERDUST, spInfo.oTarget)) {
                    //*:**********************************************
                    //*:* if not under the effect of faerie fire,
                    //*:* glitterdust, or the visual outline of heartfire
                    //*:* (a darkness spell may have snuffed the outlining
                    //*:* but not the damage component), then we can
                    //*:* go invisible
                    //*:**********************************************
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                    GRApplyEffectToObject(iDurationType, eInvis, spInfo.oTarget, fDuration);

                    switch(spInfo.iSpellID) {
                        case SPELL_GREATER_INVISIBILITY:   // Invisiblity, Greater (3.5e)
                        case 799:
                        case SPELL_I_RETRIBUTIVE_INVISIBILITY:
                            if(spInfo.iSpellID==799 && GetAppearanceType(oCaster)==156) {
                                eLink = EffectLinkEffects(EffectCutsceneGhost(), eLink);
                            }
                            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, spInfo.oTarget);
                            GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
                        case SPELL_INVISIBILITY_SPHERE:
                            /*** NWN1 SINGLE ***/ oAOE = GRGetAOEOnObject(spInfo.oTarget, sAOEType, oCaster);
                            //*** NWN2 SINGLE ***/ oAOE = GetObjectByTag(sAOEType);
                            GRSetAOESpellId(spInfo.iSpellID, oAOE);
                            GRSetSpellInfo(spInfo, oAOE);
                            SetLocalInt(oAOE, "REMAINING_DURATION", FloatToInt(fDuration)/6);
                            break;
                    }
                }
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
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
