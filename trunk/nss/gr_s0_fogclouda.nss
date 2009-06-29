//*:**************************************************************************
//*:*  GR_S0_FOGCLOUDA.NSS
//*:**************************************************************************
//*:* Stinking Cloud (NW_S0_StinkCld.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: May 17, 2001
//*:* 3.5 Player's Handbook (p. 284)
//*:**************************************************************************
//*:* Fog Cloud
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 23, 2004
//*:* 3.5 Player's Handbook (p. 232)
//*:**************************************************************************
//*:* Solid Fog
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 13, 2008
//*:* 3.5 Player's Handbook (p. 281)
//*:**************************************************************************
//*:* Updated On: March 13, 2008
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
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo.oTarget         = GetEnteringObject();

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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eImpairSight = EffectDarkness();
    effect eHideMelee   = EffectConcealment(20, MISS_CHANCE_TYPE_VS_MELEE); // is hidden by cloud
    effect eHideRanged  = EffectConcealment(100, MISS_CHANCE_TYPE_VS_RANGED);

    //*:* Stinking Cloud
    effect eNauseated   = EffectDazed();
    effect eNauseatedVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    eNauseated = EffectLinkEffects(eNauseated, eNauseatedVis);

    //*:* Solid Fog
    effect eMovement    = EffectMovementSpeedDecrease(85);
    effect eAttack      = EffectAttackDecrease(2);
    effect eDamage      = EffectDamageDecrease(2);
    effect eSolidFog    = EffectLinkEffects(eMovement, eAttack);
    eSolidFog = EffectLinkEffects(eSolidFog, eDamage);

    effect eHide = EffectLinkEffects(eHideMelee, eHideRanged);
    effect eLink = EffectLinkEffects(eImpairSight, eHide);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    if(GetHasEffect(EFFECT_TYPE_DARKNESS, spInfo.oTarget) && !GetHasEffect(EFFECT_TYPE_CONCEALMENT, spInfo.oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eHide, spInfo.oTarget);
    } else if(!GetHasEffect(EFFECT_TYPE_DARKNESS, spInfo.oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
    }
    if(spInfo.iSpellID==SPELL_GR_SOLIDFOG && !GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT, spInfo.oTarget) &&
        !GetHasSpellEffect(SPELLABILITY_GR_FREEDOM_OF_MOVEMENT, spInfo.oTarget)) {

        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eSolidFog, spInfo.oTarget);
    } else if(spInfo.iSpellID==SPELL_STINKING_CLOUD) {
        if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_POISON)) {
           if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_POISON)) {
               GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eNauseated, spInfo.oTarget);
           }
        }
    } else if(GRGetSpellSchool(spInfo.iSpellID, oCaster)==SPELL_SCHOOL_ILLUSION) {
        if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC)) {
            if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eNauseated, spInfo.oTarget);
            } else {
                SetLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_WILLDISBELIEF", TRUE);
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
