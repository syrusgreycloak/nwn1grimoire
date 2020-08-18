//*:**************************************************************************
//*:*  GR_S0_CLOUDKILLC.NSS
//*:**************************************************************************
//*:*
//*:* Cloudkill: OnHeartbeat (NW_S0_CloudKillc.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 210)
//*:*
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: May 17, 2001
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
//*:* Supporting functions
//*:**************************************************************************
void DoCloudkillConDmg(object oTarget, object oCaster, int iDamage) {
    //------------------------------------------------------------------
    // The trick that allows this spellscript to do stacking ability
    // score damage (which is not possible to do from normal scripts)
    // is that the ability score damage is done from a delaycommanded
    // function which will sever the connection between the effect
    // and the SpellId
    //------------------------------------------------------------------

    effect eDam = ExtraordinaryEffect(EffectAbilityDecrease(ABILITY_CONSTITUTION, iDamage));

    if(iDamage>0) {
        if(GetAbilityScore(oTarget, ABILITY_CONSTITUTION)<=iDamage && GetGameDifficulty()>=GAME_DIFFICULTY_CORE_RULES) {
            if(!GetImmortal(oTarget)) {
                FloatingTextStrRefOnCreature(100932, oTarget);
                effect eKill = EffectDamage(GetCurrentHitPoints(oTarget)+1);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, oTarget);
                effect eVfx = EffectVisualEffect(VFX_IMP_DEATH_L);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVfx, oTarget);
             }
        } else {
            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDam, oTarget);
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
    object  oCaster         = GetAreaOfEffectCreator();

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    int     iDieType          = 4;
    int     iNumDice          = 1;
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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iHD;             //= GetHitDice(spInfo.oTarget);
    float   fDelay          = GetRandomDelay(0.5, 1.5);
    int     iPrevConDmg;     //= GetLocalInt(spInfo.oTarget, "GR_CLOUDKILL_DMG");

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;

    //*:*iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iPrevConDmg);

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(VFX_IMP_DEATH);
    effect eDeath   = EffectDeath();
    /*** NWN1 SINGLE ***/ effect eImp     = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    //*** NWN2 SINGLE ***/ effect eImp = EffectVisualEffect(VFX_HIT_SPELL_POISON);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetFirstInPersistentObject();

    while(GetIsObjectValid(spInfo.oTarget)) {
        fDelay = GetRandomDelay();
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster) && GRGetIsLiving(spInfo.oTarget)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_CLOUDKILL));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_POISON) && !GetHasSpellEffect(SPELL_GR_FILTER, spInfo.oTarget)) {
                    if(iHD <= 3) {
                        if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_DEATH)) {
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                            DelayCommand(fDelay+0.1, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                        }
                    } else if (iHD >= 4 && iHD <= 6) {
                        if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH, oCaster, fDelay)) {
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                            DelayCommand(fDelay+0.1, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                        } else {
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget));
                            DelayCommand(fDelay+0.1, DoCloudkillConDmg(spInfo.oTarget, oCaster, iDamage));
                        }
                    } else {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget));
                        if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_POISON, oCaster, fDelay)) {
                            DelayCommand(fDelay+0.1, DoCloudkillConDmg(spInfo.oTarget, oCaster, iDamage));
                        } else {
                            DelayCommand(fDelay+0.1, DoCloudkillConDmg(spInfo.oTarget, oCaster, iDamage/2));
                        }
                    }
                }
            }
        }
        spInfo.oTarget = GetNextInPersistentObject();
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
