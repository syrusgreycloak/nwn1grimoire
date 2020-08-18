//*:**************************************************************************
//*:*  GR_S0_POWERWORD.NSS
//*:**************************************************************************
//*:*
//*:* Master script for power words
//*:* Power Word, Blind
//*:* Power Word, Kill
//*:* Power Word, Stun
//*:* Power Word, Thunder
//*:* NWN2:
//*:* Power Word, Disable
//*:* Power Word Maladroit
//*:* Power Word Petrify
//*:* Power Word Weaken
//*:* Races of the Dragon (p. 115)
//*:* Power Word, Deafen
//*:* Power Word, Nauseate
//*:* Power Word, Pain
//*:* Power Word, Sicken
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: August 7, 2007
//*:**************************************************************************
//*:* Updated On: July 3, 2008
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
    int     iNumDice          = 1;
    int     iBonus            = 1;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

    int     iMaxHPAffected;
    int     iTargetHP       = GetCurrentHitPoints(spInfo.oTarget);
    int     iEffectDurType  = DURATION_TYPE_TEMPORARY;
    /*** NWN1 SINGLE ***/ int     iImpVisual      = -1;
    //*** NWN2 SINGLE ***/ int     iImpVisual       = VFX_HIT_SPELL_ENCHANTMENT;
    int     iVisual         = -1;
    int     iDurVis;
    int     iImmuneType     = IMMUNITY_TYPE_NONE;
    int     iAbilityType;

    int     bMultiTarget       = (spInfo.iSpellID==SPELL_GR_POWER_WORD_THUNDER);

    switch(spInfo.iSpellID) {
        case SPELL_POWORD_BLIND:
            if(iTargetHP<=50) {
                iEffectDurType = DURATION_TYPE_PERMANENT;
            } else if(iTargetHP<=100) {
                iDurType = DUR_TYPE_TURNS;
            }
            iMaxHPAffected = 200;
            /*** NWN1 SPECIFIC ***/
                iVisual = VFX_FNF_PWBLIND;
                iImpVisual = VFX_IMP_BLIND_DEAF_M;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/ iDurVis = VFX_DUR_SPELL_POWER_WORD_BLIND;
            iImmuneType = IMMUNITY_TYPE_BLINDNESS;
            iDurAmount = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
            break;
        case SPELL_POWER_WORD_KILL:
            iEffectDurType = DURATION_TYPE_INSTANT;
            iMaxHPAffected = 100;
            /*** NWN1 SPECIFIC ***/
                iVisual = VFX_FNF_PWKILL;
                iImpVisual = VFX_IMP_DEATH;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/  iVisual = VFX_HIT_AOE_ENCHANTMENT;
            iImmuneType = IMMUNITY_TYPE_DEATH;
            break;
        case SPELL_POWER_WORD_STUN:
            iBonus = 0;
            if(iTargetHP<=50) {
                iNumDice = 4;
            } else if(iTargetHP<=100) {
                iNumDice = 2;
            }
            iMaxHPAffected = 150;
            /*** NWN1 SPECIFIC ***/
                iVisual = VFX_FNF_PWSTUN;
                iImpVisual = VFX_IMP_STUN;
                iDurVis = VFX_DUR_MIND_AFFECTING_DISABLED;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/ iDurVis = VFX_DUR_STUN;
            iImmuneType = IMMUNITY_TYPE_STUN;
            iDurAmount = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
            break;
        case SPELL_GR_POWER_WORD_THUNDER:
            iMaxHPAffected = 60;
            /*** NWN1 SPECIFIC ***/
                iVisual = VFX_FNF_SOUND_BURST;
                iImpVisual = VFX_IMP_BLIND_DEAF_M;
                iDurVis = VFX_DUR_MIND_AFFECTING_DISABLED;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iVisual = VFX_HIT_AOE_SONIC;
                iImpVisual = VFX_HIT_SPELL_SONIC;
                iDurVis = VFX_DUR_SPELL_BLIND_DEAF;
            /*** END NWN2 SPECIFIC ***/
            iImmuneType = IMMUNITY_TYPE_DEAFNESS;
            iDurAmount = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
            break;
        case SPELL_POWER_WORD_DISABLE:
            iMaxHPAffected = 50;
            /*** NWN1 SINGLE ***/ iImpVisual = VFX_IMP_NEGATIVE_ENERGY;
            break;
        case SPELL_POWORD_MALADROIT:
        case SPELL_POWORD_WEAKEN:
            iMaxHPAffected = 75;
            /*** NWN1 SPECIFIC ***/
                iImpVisual = VFX_IMP_REDUCE_ABILITY_SCORE;
                iDurVis = VFX_DUR_CESSATE_NEGATIVE;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/ iDurVis = (spInfo.iSpellID==SPELL_POWORD_MALADROIT ? VFX_DUR_SPELL_POWER_WORD_MALADROIT : VFX_DUR_SPELL_POWER_WORD_WEAKEN);
            iAbilityType = (spInfo.iSpellID==SPELL_POWORD_MALADROIT ? ABILITY_DEXTERITY : ABILITY_STRENGTH);
            if(iTargetHP<=25) {
                iEffectDurType = DURATION_TYPE_PERMANENT;
            } else if(iTargetHP<=50) {
                iDurType = DUR_TYPE_TURNS;
            }
            iImmuneType = IMMUNITY_TYPE_ABILITY_DECREASE;
            iDurAmount = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
            break;
        case SPELL_POWORD_PETRIFY:
            iMaxHPAffected = 100;
            /*** NWN1 SINGLE ***/ iDurVis = VFX_DUR_PETRIFY;
            //*** NWN2 SINGLE ***/ iDurVis = VFX_DUR_SPELL_POWER_WORD_PETRIFY;
            iEffectDurType = DURATION_TYPE_PERMANENT;
            break;
        case SPELL_GR_POWER_WORD_DEAFEN:
            iMaxHPAffected = 100;
            if(iTargetHP<=25) {
                iEffectDurType = DURATION_TYPE_PERMANENT;
            } else if(iTargetHP<=50) {
                iDurType = DUR_TYPE_TURNS;
            }
            /*** NWN1 SPECIFIC ***/
                iImpVisual = VFX_IMP_BLIND_DEAF_M;
                iDurVis = VFX_DUR_MIND_AFFECTING_DISABLED;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iImpVisual = VFX_HIT_SPELL_SONIC;
                iDurVis = VFX_DUR_SPELL_BLIND_DEAF;
            /*** END NWN2 SPECIFIC ***/
            iImmuneType = IMMUNITY_TYPE_DEAFNESS;
            iDurAmount = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
            break;
        case SPELL_GR_POWER_WORD_NAUSEATE:
            iMaxHPAffected = 150;
            if(iTargetHP<=50) {
                iNumDice = 2;
                iBonus = 2;
            }
            /*** NWN1 SINGLE ***/ iDurVis = VFX_DUR_MIND_AFFECTING_DISABLED;
            //*** NWN2 SINGLE ***/ iDurVis = VFX_DUR_NAUSEA;
            iDurAmount = (iTargetHP>100 ? 1 : GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus));
            break;
        case SPELL_GR_POWER_WORD_SICKEN:
            iMaxHPAffected = 100;
            if(iTargetHP<=25) {
                iDurType = DUR_TYPE_HOURS;
            } else if(iTargetHP<=50) {
                iDurType = DUR_TYPE_TURNS;
            }
            /*** NWN1 SINGLE ***/ iDurVis = VFX_DUR_MIND_AFFECTING_DISABLED;
            iDurAmount = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(30.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eVis;
    effect ePWVisual;
    effect ePWEffect;

    if(iImpVisual>-1) eVis          = EffectVisualEffect(iImpVisual);
    if(iVisual>-1) ePWVisual     = EffectVisualEffect(iVisual);

    switch(spInfo.iSpellID) {
        case SPELL_POWORD_BLIND:
            ePWEffect = EffectLinkEffects(EffectBlindness(), EffectVisualEffect(iDurVis));
            break;
        case SPELL_POWER_WORD_KILL:
            ePWEffect = EffectDeath();
            break;
        case SPELL_POWER_WORD_STUN:
            ePWEffect = EffectLinkEffects(EffectStunned(), EffectVisualEffect(iDurVis));
            break;
        case SPELL_GR_POWER_WORD_THUNDER:
        case SPELL_GR_POWER_WORD_DEAFEN:
            ePWEffect = EffectLinkEffects(EffectDeaf(), EffectVisualEffect(iDurVis));
            if(iTargetHP<=30 && spInfo.iSpellID==SPELL_GR_POWER_WORD_THUNDER) {
                ePWEffect = EffectLinkEffects(ePWEffect, EffectDazed());
            }
            break;
        case SPELL_POWER_WORD_DISABLE:
            /*** NWN1 SINGLE ***/ ePWEffect = EffectDamage(iTargetHP, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_NORMAL);
            //*** NWN2 SINGLE ***/ ePWEffect = EffectDamage(iTargetHP, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_NORMAL, TRUE);
            break;
        case SPELL_POWORD_MALADROIT:
        case SPELL_POWORD_WEAKEN:
            ePWEffect = EffectLinkEffects(EffectAbilityDecrease(iAbilityType, 2), EffectVisualEffect(iDurVis));
            break;
        case SPELL_POWORD_PETRIFY:
            ePWEffect = EffectLinkEffects(EffectPetrify(), EffectVisualEffect(iDurVis));
            break;
        case SPELL_GR_POWER_WORD_NAUSEATE:
            ePWEffect = ExtraordinaryEffect(EffectLinkEffects(EffectDazed(), EffectVisualEffect(iDurVis)));
            break;
        case SPELL_GR_POWER_WORD_SICKEN:
            /*** NWN1 SINGLE ***/ ePWEffect = EffectLinkEffects(GREffectSickened(), EffectVisualEffect(iDurVis));
            //*** NWN2 SINGLE ***/ ePWEffect = GREffectSickened();
            break;
    }


    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(iVisual>-1) GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, ePWVisual, GetLocation(oCaster));

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                //*:**********************************************
                //*:* Power Word, Thunder loops, get hp from target here
                //*:**********************************************
                if(spInfo.iSpellID==SPELL_GR_POWER_WORD_THUNDER) {
                    iTargetHP = GetCurrentHitPoints(spInfo.oTarget);
                    if(iTargetHP<=30) {
                        iNumDice = 4;
                    } else {
                        iNumDice = 2;
                    }
                    fDuration = GRGetDuration(GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus), iDurType);
                    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
                }

                if(iTargetHP<=iMaxHPAffected) {
                    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                        if(iImmuneType==IMMUNITY_TYPE_NONE || !GetIsImmune(spInfo.oTarget, iImmuneType)) {
                            if(iImpVisual>-1) GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                            if(iEffectDurType==DURATION_TYPE_TEMPORARY) {
                                GRApplyEffectToObject(iEffectDurType, ePWEffect, spInfo.oTarget, fDuration);
                            } else {
                                DelayCommand(1.0f, GRApplyEffectToObject(iEffectDurType, ePWEffect, spInfo.oTarget));
                                if(spInfo.iSpellID==SPELL_POWER_WORD_KILL) GRSetKilledByDeathEffect(spInfo.oTarget, oCaster);
                            }
                        }
                    }
                }
            }

            if(bMultiTarget) {
                if(GetHasEffect(EFFECT_TYPE_SILENCE, spInfo.oTarget)) {
                    GRRemoveEffects(EFFECT_TYPE_SILENCE, spInfo.oTarget);
                }
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
