//*:**************************************************************************
//*:*  GR_S0_STORMVENGC.NSS
//*:**************************************************************************
//*:* Storm of Vengeance (NW_S0_StormVeng.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Nov 8, 2001
//*:* 3.5 Player's Handbook (p. 285)
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
#include "GR_IN_CONCEN"

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

    int     iDieType          = 0;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     bConcentrating  = GRCheckCasterConcentration(oCaster);
    int     iStormRound     = GetLocalInt(OBJECT_SELF, "GR_L_STORM_ROUND_NUM");
    int     iNumBolts       = 6;
    int     iDamageType;
    object  oBoltTarget;

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
    effect eSlow    = EffectMovementSpeedDecrease(75);
    effect eConceal = EffectInvisibility(INVISIBILITY_TYPE_DARKNESS);
    effect eDeaf    = EffectDeaf();
    /*** NWN1 SINGLE ***/ effect eVisDeaf = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    //*** NWN2 SINGLE ***/ effect eVisDeaf = EffectVisualEffect(VFX_DUR_SPELL_BLIND_DEAF);
    effect eVis;
    effect eDam;
    effect eExplode;

    effect eLink = EffectLinkEffects(eSlow, eConceal);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bConcentrating) {
        switch(iStormRound) {
            case 2:
                iNumDice = 1;
                iDamageType = DAMAGE_TYPE_ACID;
                /*** NWN1 SPECIFIC ***/
                    eVis = EffectVisualEffect(VFX_IMP_ACID_S);
                    eExplode = GREffectAreaOfEffect(AOE_PER_ACID_STORM);
                    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eExplode, spInfo.lTarget, 4.0f);
                /*** END NWN1 SPECIFIC ***/
                /*** NWN2 SPECIFIC ***
                    eVis = EffectVisualEffect(VFX_HIT_SPELL_ACID);
                    eExplode = EffectVisualEffect(VFX_HIT_AOE_ACID);
                    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);
                /*** END NWN2 SPECIFIC ***/
                break;
            case 3:
                iNumDice = 10;
                iDamageType = DAMAGE_TYPE_ELECTRICAL;
                /*** NWN1 SINGLE ***/ eVis = EffectVisualEffect(VFX_IMP_LIGHTNING_M);
                //*** NWN2 SINGLE ***/ eVis = EffectVisualEffect(VFX_HIT_SPELL_LIGHTNING);
                break;
            case 4:
                iNumDice = 5;
                iDamageType = DAMAGE_TYPE_BLUDGEONING;
                /*** NWN1 SPECIFIC ***/
                    eVis = EffectVisualEffect(VFX_COM_CHUNK_STONE_SMALL);
                    eExplode = EffectVisualEffect(VFX_FNF_ICESTORM);
                /*** END NWN1 SPECIFIC ***/
                /*** NWN2 SPECIFIC ***
                    eVis = EffectVisualEffect(VFX_HIT_SPELL_CONJURATION);
                    eExplode = EffectVisualEffect(VFX_HIT_AOE_ICE);
                /*** END NWN2 SPECIFIC ***/
                GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);
                break;
        }

        spInfo.oTarget = GetFirstInPersistentObject(OBJECT_SELF);
        while(GetIsObjectValid(spInfo.oTarget)) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster) && spInfo.oTarget!=oCaster) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_STORM_OF_VENGEANCE));
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                    iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic);
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    if(!GetHasEffect(EFFECT_TYPE_DEAF, spInfo.oTarget)) {
                        if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC)) {
                            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisDeaf, spInfo.oTarget);
                            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeaf, spInfo.oTarget,
                                GRGetDuration(GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic)*10, DUR_TYPE_TURNS));
                        }
                    }
                    if(iStormRound==2 || iStormRound==4) {
                        eDam = EffectDamage(iDamage, iDamageType);
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget);
                    } else if(iStormRound==3 && iNumBolts>0) {
                        while(iNumBolts>0) {
                            oBoltTarget = GetFirstInPersistentObject(OBJECT_SELF);
                            while(GetIsObjectValid(oBoltTarget)) {
                                if(GetObjectType(oBoltTarget)==OBJECT_TYPE_CREATURE) {
                                    if(GRGetIsSpellTarget(oBoltTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster) && oBoltTarget!=oCaster) {
                                        iDamage = GRGetReflexAdjustedDamage(iDamage, oBoltTarget, spInfo.iDC, SAVING_THROW_TYPE_ELECTRICITY,
                                            oCaster);
                                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oBoltTarget);
                                        if(iDamage>0) {
                                            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oBoltTarget);
                                        }
                                        iNumBolts--;
                                    }
                                }
                                oBoltTarget = GetNextInPersistentObject(OBJECT_SELF);
                            }
                        }
                    } else if(iStormRound>4 && !GetHasEffect(EFFECT_TYPE_MOVEMENT_SPEED_DECREASE, spInfo.oTarget)) {
                        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eConceal, spInfo.oTarget);
                        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eSlow, spInfo.oTarget);
                    }
                }
            }
            spInfo.oTarget = GetNextInPersistentObject(OBJECT_SELF);
        }
    } else {
        DestroyObject(OBJECT_SELF);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
