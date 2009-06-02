//*:**************************************************************************
//*:*  GR_S0_COLSPRAY.NSS
//*:**************************************************************************
//*:*
//*:* Color Spray (NW_S0_ColSpray.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 210)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: July 25, 2001
//*:**************************************************************************
//*:* Updated On: April 12, 2007
//*:* FIX:  Updated how effects are applied to accurately represent the
//*:*       spell description
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

    int     iDieType          = 4;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
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

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(15.0);
    float   fDelay;
    float   fMaxDelay       = 0.0f;
    int     iHD;

    int     iUnconsciousDur = 0;
    int     iStunnedDur     = 0;
    int     iBlindDur       = 0;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SINGLE ***/ if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eSleep   = EffectSleep();
    effect eStun    = EffectStunned();
    effect eBlind   = EffectBlindness();
    /*** NWN1 SPECIFIC ***/
        effect eMind    = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

        effect eVis1    = EffectVisualEffect(VFX_IMP_SLEEP);
        effect eVis2    = EffectVisualEffect(VFX_IMP_STUN);
        effect eVis3    = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);

        effect eVLAll   = EffectLinkEffects(eVis1, eVis2);
        eVLAll = EffectLinkEffects(eVLAll, eVis3);

        effect eVL23    = EffectLinkEffects(eVis2, eVis3);
    /*** END NWN1 SPECIFIC ***/

    effect eVisual;
    /*** NWN2 SPECIFIC ***
        eVisual = EffectVisualEffect(VFX_HIT_SPELL_ILLUSION);
        eCone = EffectVisualEffect(VFX_DUR_CONE_COLORSPRAY);
    /*** END NWN2 SPECIFIC ***/
    /*** NWN1 SINGLE ***/ effect eEffects = EffectLinkEffects(eMind, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE);
    while (GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_COLOR_SPRAY));
            fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/30;
            //*** NWN2 SINGLE ***/ if(fDelay>fMaxDelay) fMaxDelay = fDelay;
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay) && GRGetIsLiving(spInfo.oTarget)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, oCaster, fDelay)) {
                    iHD = GetHitDice(spInfo.oTarget);
                    if(iHD <= 2) {
                        //*:**********************************************
                        //*:* Unconscious, Blind, Stunned for 2d4   - roll 2d4
                        //*:* THEN Blind, Stunned for 1d4 more      - roll 1d4, add prior result
                        //*:* THEN Stunned 1 round                  - take 2nd result, add 1
                        //*:**********************************************
                        iUnconsciousDur = GRGetMetamagicAdjustedDamage(iDieType, 2, spInfo.iMetamagic, 0);
                        iBlindDur = GRGetMetamagicAdjustedDamage(iDieType, 1, spInfo.iMetamagic, iUnconsciousDur);
                        iStunnedDur = iBlindDur + 1;
                        /*** NWN1 SINGLE ***/ eVisual = eVLAll;
                    } else if(iHD > 2 && iHD < 5) {
                        //*:**********************************************
                        //*:* Blind, Stunned for 1d4        - roll 1d4
                        //*:* THEN Stunned 1 round          - take result, add 1
                        //*:**********************************************
                        iBlindDur = GRGetMetamagicAdjustedDamage(iDieType, 1, spInfo.iMetamagic, 0);
                        iStunnedDur = iBlindDur + 1;
                        /*** NWN1 SINGLE ***/ eVisual = eVL23;
                    } else {
                        //*:**********************************************
                        //*:* Stunned 1 round
                        //*:**********************************************
                        iStunnedDur = 1;
                        /*** NWN1 SINGLE ***/ eVisual = eVis2;
                    }
                    //*:**********************************************
                    //*:* Stunned duration always longest - use for
                    //*:* duration visuals
                    //*:**********************************************
                    fDuration = (GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND) ? GRGetDuration(iStunnedDur)*2 : GRGetDuration(iStunnedDur));
                    /*** NWN1 SINGLE ***/ DelayCommand(fDelay-0.1, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffects, spInfo.oTarget, fDuration));
                    //*:**********************************************
                    //*:* Apply other effects
                    //*:**********************************************
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spInfo.oTarget));
                    if(iUnconsciousDur>0) {
                        fDuration = (GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND) ? GRGetDuration(iUnconsciousDur)*2 : GRGetDuration(iUnconsciousDur));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSleep, spInfo.oTarget, GRGetDuration(iUnconsciousDur)));
                    }
                    if(iBlindDur>0) {
                        fDuration = (GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND) ? GRGetDuration(iBlindDur)*2 : GRGetDuration(iBlindDur));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBlind, spInfo.oTarget, GRGetDuration(iBlindDur)));
                    }
                    fDuration = (GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND) ? GRGetDuration(iStunnedDur)*2 : GRGetDuration(iStunnedDur));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, spInfo.oTarget, GRGetDuration(iStunnedDur)));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE);
        iUnconsciousDur = 0;
        iBlindDur = 0;
        iStunnedDur = 0;
    }

    /*** NWN2 SPECIFIC ***
        fMaxDelay += 0.5f;
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCone, OBJECT_SELF, fMaxDelay);
    /*** END NWN2 SPECIFIC ***/

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
