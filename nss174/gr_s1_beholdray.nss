//*:**************************************************************************
//*:*  GR_S1_BEHOLDRAY.NSS
//*:**************************************************************************
//*:* Beholder Ray Attacks (x2_s2_beholdray) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: 2003-09-16
//*:**************************************************************************
//*:* Updated On: January 28, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
//#include "X0_I0_POSITION"     - INCLUDED IN GR_IN_LIB

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

    spInfo.iDC = 17;
    spInfo.iCasterLevel = 13;

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
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
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iSave, bSave;

    switch(spInfo.iSpellID){
        case 776:       // BEHOLDER_RAY_FINGER_DEATH (Finger of Death)
            iSave = SAVING_THROW_FORT;
            break;
        case 777:       // BEHOLDER_RAY_TK (Telekenisis)
            iSave = SAVING_THROW_WILL;
            break;
        case 778:       // BEHOLDER_RAY_FLESH_TO_STONE (Flesh To Stone)
            iSave = SAVING_THROW_FORT;
            break;
        case 779:       // BEHOLDER_RAY_CHARM_MON (Charm Monster) -- created separate Charm Person)
            iSave = SAVING_THROW_WILL;
            break;
        case 780:       // BEHOLDER_RAY_SLOW (Slow)
            iSave = SAVING_THROW_WILL;
            break;
        case 783:       // BEHOLDER_RAY_INFLICT_MOD_WOUNDS (Inflict Moderate Wounds)
            iSave = SAVING_THROW_FORT;
            break;
        case 784:       // BEHOLDER_RAY_FEAR (Fear)
            iSave = SAVING_THROW_WILL;
            break;
        case 785:       // BEHOLDER_RAY_CHARM_PER (Charm Person)
            iSave = SAVING_THROW_WILL;
            break;
        case 786:       // BEHOLDER_RAY_DISINTEGRATE
            iSave = SAVING_THROW_FORT;
            break;
        case 787:       // BEHOLDER_RAY_SLEEP
            iSave = SAVING_THROW_WILL;
            break;
    }

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
    effect  e1, eLink, eVis, eDur;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, TRUE));
    fDelay  = 0.0f;  //old -- GetSpellEffectDelay(GetLocation(oTarget),OBJECT_SELF);
    if(iSave==SAVING_THROW_WILL) {
        bSave = GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_ALL, oCaster, fDelay) > 0;
    } else if(iSave==SAVING_THROW_FORT) {
        bSave = GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_ALL, oCaster, fDelay) > 0;
    }
    bSave = (bSave || GetHasSpellEffect(SPELL_GR_RAY_DEFLECTION, spInfo.oTarget));

    if(!bSave) {
        switch(spInfo.iSpellID) {
            case 776:
                e1 = EffectDeath(TRUE);
                eVis = EffectVisualEffect(VFX_IMP_DEATH);
                eLink = EffectLinkEffects(e1,eVis);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                GRSetKilledByDeathEffect(spInfo.oTarget);
                break;
            case 777:
                eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                e1 = EffectKnockdown();
                e1 = ExtraordinaryEffect(EffectLinkEffects(e1, eDur));
                eVis = EffectVisualEffect(VFX_IMP_STUN);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, e1, spInfo.oTarget, GRGetDuration(2));
                float fAngle = GetAngleBetweenLocations(GetLocation(spInfo.oTarget), GetLocation(oCaster));
                fAngle = GetNormalizedDirection(GetOppositeDirection(fAngle));
                location lNewLoc = GenerateNewLocationFromLocation(GetLocation(spInfo.oTarget), FeetToMeters(10.0), fAngle, GetFacing(spInfo.oTarget));
                AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
                DelayCommand(1.0f, AssignCommand(spInfo.oTarget, ActionJumpToLocation(lNewLoc)));
                break;
            //*:* Petrify for one round per SaveDC
            case 778:
                eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRDoPetrification(spInfo.iDC, oCaster, spInfo.oTarget, spInfo.iSpellID);
                break;
            case 779:   // Charm Monster
                e1 = EffectCharmed();
                eVis = EffectVisualEffect(VFX_IMP_CHARM);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, e1, spInfo.oTarget, GRGetDuration(spInfo.iCasterLevel, DUR_TYPE_HOURS));
                break;
            case 780:
                e1 = EffectSlow();
                eVis = EffectVisualEffect(VFX_IMP_SLOW);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, e1, spInfo.oTarget, GRGetDuration(spInfo.iCasterLevel));
                break;
            case 783:
                e1 = EffectDamage(d8(2)+10);
                eVis = EffectVisualEffect(VFX_COM_BLOOD_REG_RED);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, e1, spInfo.oTarget);
                break;
            case 784:
                e1 = EffectFrightened();
                eVis = EffectVisualEffect(VFX_IMP_FEAR_S);
                eDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
                e1 = EffectLinkEffects(eDur,e1);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, e1, spInfo.oTarget, GRGetDuration(spInfo.iCasterLevel));
                break;
            case 785:   // Charm Person
                e1 = EffectCharmed();
                eVis = EffectVisualEffect(VFX_IMP_CHARM);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, e1, spInfo.oTarget, GRGetDuration(spInfo.iCasterLevel, DUR_TYPE_TURNS));
                break;
            case 786:   // Disintegrate
                effect eSmoke   = EffectVisualEffect(VFX_FNF_SMOKE_PUFF);
                effect eAcid    = EffectVisualEffect(VFX_IMP_ACID_S);
                effect eInvis   = EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY);
                iDamage = d6(MaxInt(40, 2*spInfo.iCasterLevel));
                if(iDamage>GetCurrentHitPoints(spInfo.oTarget)) iDamage = GetCurrentHitPoints(spInfo.oTarget)+512;
                effect eDeath   = EffectDamage(iDamage);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eAcid, spInfo.oTarget);  // green color from green ray
                if(iDamage>GetCurrentHitPoints(spInfo.oTarget)) {
                    DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eInvis, spInfo.oTarget, 9.0));
                    DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, spInfo.oTarget));
                    DelayCommand(0.7f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                    GRSetKilledByDeathEffect(spInfo.oTarget);
                } else {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget);
                }
                break;
            case 787:   // Sleep
                e1 = EffectSleep();
                eVis = EffectVisualEffect(VFX_IMP_SLEEP);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, e1, spInfo.oTarget, GRGetDuration(spInfo.iCasterLevel, DUR_TYPE_TURNS));
                break;
        }
    } else {
        switch(spInfo.iSpellID) {
            case 776:
                e1 = EffectDamage(d6(3)+13);
                eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
                eLink = EffectLinkEffects(e1, eVis);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                break;
            case 786:
                effect eSmoke   = EffectVisualEffect(VFX_FNF_SMOKE_PUFF);
                effect eAcid    = EffectVisualEffect(VFX_IMP_ACID_S);
                effect eInvis   = EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY);
                iDamage = d6(5);
                if(iDamage>GetCurrentHitPoints(spInfo.oTarget)) iDamage = GetCurrentHitPoints(spInfo.oTarget)+512;
                effect eDeath   = EffectDamage(iDamage);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eAcid, spInfo.oTarget);  // green color from green ray
                if(iDamage>GetCurrentHitPoints(spInfo.oTarget)) {
                    DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eInvis, spInfo.oTarget, 9.0));
                    DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, spInfo.oTarget));
                    DelayCommand(0.7f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                    GRSetKilledByDeathEffect(spInfo.oTarget);
                } else {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget);
                }
                break;
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
