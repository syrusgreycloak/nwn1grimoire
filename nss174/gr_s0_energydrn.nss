//*:**************************************************************************
//*:*  GR_S0_ENERGYDRN.NSS
//*:**************************************************************************
//*:* Enervation (NW_S0_Enervat.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:* 3.5 Player's Handbook (p. 226)
//*:*
//*:* Energy Drain (NW_S0_EneDrain.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:* 3.5 Player's Handbook (p. 226)
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
#include "GR_IC_MESSAGES"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void GRDoEnergyDrain(object oTarget, object oCaster, int iDC, int iNumNegLevels) {

    int iNumLost = 0;

    if(GetIsObjectValid(oTarget)) {
        GRRemoveSpellEffects(SPELL_ENERGY_DRAIN, oTarget, oCaster);
        int i;

        for(i=0; i<iNumNegLevels; i++) {
            if(!GRGetSaveResult(SAVING_THROW_FORT, oTarget, iDC, SAVING_THROW_TYPE_NEGATIVE, oCaster))
                iNumLost++;
        }

        if(iNumLost>0) {
            int iNewCharLevel = ((GetHitDice(oTarget)-iNumLost)>0 ? GetHitDice(oTarget)-iNumLost : 0);
            SetXP(oTarget, (iNewCharLevel*(iNewCharLevel-1) / 2)*1000);
            if(iNewCharLevel>0) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE), oTarget);
            } else {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH), oTarget);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, SupernaturalEffect(EffectDeath()), oTarget);
            }
        }
    }
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType        = 4;
    int     iNumDice        = 1;
    int     iBonus          = 0;
    int     iDamage         = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = (spInfo.iCasterLevel>15 ? 15 : spInfo.iCasterLevel);
    int     iDurType          = DUR_TYPE_HOURS;

    if(spInfo.iSpellID==SPELL_ENERGY_DRAIN) {
        iNumDice = 2;
        iDurAmount = 24;
    }

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
    //*:* float   fRange          = FeetToMeters(15.0);

    /*** NWN1 SINGLE ***/ int     iBeamType       = VFX_BEAM_BLACK;
    //*** NWN2 SINGLE ***/ int     iBeamType       = VFX_BEAM_NECROMANCY ;

    int     iRangedTouch    = GRTouchAttackRanged(spInfo.oTarget);
    int     bHasRayDeflection = GRGetHasSpellEffect(SPELL_GR_RAY_DEFLECTION, spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo)*iRangedTouch;
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eBeam;
    /*** NWN1 SPECIFIC ***/
        effect eVis     = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        effect eVis     = EffectVisualEffect(VFX_HIT_SPELL_NECROMANCY);
        effect eDur     = EffectVisualEffect(VFX_DUR_SPELL_ENERGY_DRAIN);
    /*** END NWN2 SPECIFIC ***/
    effect eDrain   = EffectNegativeLevel(iDamage);
    effect eLink    = (spInfo.iSpellID==SPELL_ENERVATION ? eDrain : EffectLinkEffects(eDrain, eDur));
    eLink = SupernaturalEffect(eLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    eBeam = EffectBeam(iBeamType, oCaster, BODY_NODE_HAND, (iRangedTouch==0) || bHasRayDeflection);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, spInfo.oTarget, 1.7f);

    if(iRangedTouch) {
        if(!bHasRayDeflection) {
            if(GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_UNDEAD) {
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                    DelayCommand(1.5f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration));
                    if(!spInfo.bNWN2 || spInfo.iSpellID==SPELL_ENERVATION) GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                    if(spInfo.iSpellID==SPELL_ENERGY_DRAIN && !GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL, oCaster)) {
                        DelayCommand(fDuration, GRDoEnergyDrain(spInfo.oTarget, oCaster, spInfo.iDC, iDamage));
                    }
                }
            } else {
                iDamage*=5;
                effect eTempHP = EffectTemporaryHitpoints(iDamage);
                eVis = EffectVisualEffect(VFX_IMP_HEALING_S);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                fDuration = GRGetDuration(1, DUR_TYPE_HOURS);
                if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTempHP, spInfo.oTarget, fDuration);
            }
        } else {
            if(GetIsPC(oCaster)) {
                SetLocalObject(GetModule(), "GR_RAYDEFLECT_CASTER", oCaster);
                SignalEvent(GetModule(), EventUserDefined(GR_MESSAGE_RAYDEFLECT_CASTER));
            }
            if(GetIsPC(spInfo.oTarget)) {
                SetLocalObject(GetModule(), "GR_RAYDEFLECT_TARGET", spInfo.oTarget);
                SignalEvent(GetModule(), EventUserDefined(GR_MESSAGE_RAYDEFLECT_TARGET));
            }
        }
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
