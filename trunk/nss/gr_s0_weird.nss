//*:**************************************************************************
//*:*  GR_S0_WEIRD.NSS
//*:**************************************************************************
//*:* Weird (NW_S0_Weird) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: DEc 14 , 2001
//*:* 3.5 Player's Handbook (p. 301)
//*:**************************************************************************
//*:* Updated On: November 8, 2007
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

    int     iDieType          = 6;
    int     iNumDice          = 3;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 10;
    int     iDurType          = DUR_TYPE_ROUNDS;

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

    float   fSTRDuration        = GRGetSpellDuration(spInfo);
    float   fDuration           = GRGetDuration(1, iDurType);
    float   fRange              = FeetToMeters(15.0);
    float   fDelay;

    int     iSTR;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) {
        fDuration *= 2;
        fSTRDuration *= 2;
    }*/
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
    /*** NWN1 SPECIFIC ***/
        effect eVis     = EffectVisualEffect(VFX_IMP_SONIC);
        effect eVis2    = EffectVisualEffect(VFX_IMP_DEATH);
        effect eAbyss   = EffectVisualEffect(VFX_DUR_ANTI_LIGHT_10);
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        effect eVis     = EffectVisualEffect(VFX_HIT_SPELL_SONIC);
        effect eVis2    = EffectVisualEffect(VFX_HIT_SPELL_NECROMANCY);
        effect eAbyss   = EffectVisualEffect(VFX_HIT_AOE_EVIL);
    /*** END NWN2 SPECIFIC ***/
    effect eWeird   = EffectVisualEffect(VFX_FNF_WEIRD);
    effect eDeath   = SupernaturalEffect(EffectDeath());
    effect eStun    = EffectStunned();
    effect eSTR;
    effect eDam;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eWeird, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster)) {
            fDelay = GetRandomDelay(3.0, 4.0);
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_WEIRD));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_MIND_SPELLS, oCaster) && !GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_FEAR, oCaster)
                    /*** NWN2 SPECIFIC ***  && !GetHasFeat(FEAT_IMMUNITY_PHANTASMS, spInfo.oTarget) /**/) {
                    if(GetHitDice(spInfo.oTarget) >= 4) {
                        if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, oCaster, fDelay)) {
                            if(GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH, oCaster, fDelay)) {
                                iDamage = GRGetMetamagicAdjustedDamage(spInfo.iDmgDieType, spInfo.iDmgNumDice, spInfo.iMetamagic);
                                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                        iDamage = iSecDamage;
                                    }
                                }
                                iSTR = GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic);
                                eSTR = EffectAbilityDecrease(ABILITY_STRENGTH, iSTR);
                                eDam = EffectDamage(iDamage, DAMAGE_TYPE_MAGICAL);
                                if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSTR, spInfo.oTarget, fSTRDuration));
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, spInfo.oTarget, fDuration));
                            } else {
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                            }
                        }
                    } else {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
