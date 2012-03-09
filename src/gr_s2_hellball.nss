//*:**************************************************************************
//*:*  GR_S2_HELLBALL.NSS
//*:**************************************************************************
//*:* Hellball (X2_S2_HELLBALL) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Andrew Noobs, Georg Zoeller  Created On: 2003-08-20
//*:* Epic Level Handbook (p. 80)
//*:**************************************************************************
//*:* Updated On: January 10, 2007
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

    spInfo.iDC = GetEpicSpellSaveDC(oCaster);

    //*:* int     iDieType          = 6;
    //*:* int     iNumDice          = 10;
    //*:* int     iBonus            = 0;
    int     iDamage           = d6(10);
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(40.0);

    int     iAcidDmg, iElecDmg, iFireDmg, iSonicDmg;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    //*:* iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eExplode     = EffectVisualEffect(464);
    effect eVis         = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect eVis2        = EffectVisualEffect(VFX_IMP_ACID_L);
    effect eVis3        = EffectVisualEffect(VFX_IMP_SONIC);
    effect eCast        = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eKnock       = EffectKnockdown();

    effect eDmgAcid, eDmgElec, eDmgFire, eDmgSonic;
    effect eDmgCaster   = EffectDamage(iDamage);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));

            fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20 + 0.5f;
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                iAcidDmg = d6(10);
                iElecDmg = d6(10);
                iFireDmg = d6(10);
                iSonicDmg = d6(10);

                if(GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SPELL, OBJECT_SELF, fDelay)>0) {
                    iAcidDmg /= 2;
                    iElecDmg /= 2;
                    iFireDmg /= 2;
                    iSonicDmg /= 2;
                }
                iDamage = iAcidDmg + iElecDmg + iFireDmg + iSonicDmg;
                //*:* Set the damage effects
                eDmgAcid = EffectDamage(iAcidDmg, DAMAGE_TYPE_ACID);
                eDmgElec = EffectDamage(iElecDmg, DAMAGE_TYPE_ELECTRICAL);
                eDmgFire = EffectDamage(iFireDmg, DAMAGE_TYPE_FIRE);
                eDmgSonic = EffectDamage(iSonicDmg, DAMAGE_TYPE_SONIC);

                if(iDamage > 50) {
                    DelayCommand(fDelay + 0.3f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnock, spInfo.oTarget, 3.0f));
                }

                //*:* Apply effects to the currently selected target.
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDmgAcid, spInfo.oTarget));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDmgElec, spInfo.oTarget));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDmgFire, spInfo.oTarget));
                if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                }
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDmgSonic, spInfo.oTarget));
                //*:* This visual effect is applied to the target object not the location as above.  This visual effect
                //*:* represents the flame that erupts on the target not on the ground.
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                DelayCommand(fDelay+0.2f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spInfo.oTarget));
                DelayCommand(fDelay+0.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis3, spInfo.oTarget));
             }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
