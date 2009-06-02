//*:**************************************************************************
//*:*  GR_S0_SPIKEGRO.NSS
//*:**************************************************************************
//*:* Spike Growth (x0_s0_spikegro.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Brent  Created On: July 2002
//*:* 3.5 Player's Handbook (p. 283)
//*:**************************************************************************
//*:* Updated On: December 3, 2007
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

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GetSpellId(), oCaster);

    int     iDieType          = 4;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 1;
    int     iDurType          = DUR_TYPE_DAYS;

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    float   fDist;

    int     bResisted;
    int     bAlreadyAffected;
    location lLastLoc;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eDam;    //= EffectDamage(iDamage, DAMAGE_TYPE_PIERCING);
    effect eVis     = EffectVisualEffect(VFX_IMP_ACID_S);
    effect eSpeed   = EffectMovementSpeedDecrease(50);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetFirstInPersistentObject(OBJECT_SELF);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_SPIKE_GROWTH));
            bResisted = GetLocalInt(spInfo.oTarget, "GR_SPIKEGROWTH_RESISTED_"+ObjectToString(oCaster));
            bAlreadyAffected = GetHasSpellEffect(SPELL_SPIKE_GROWTH, spInfo.oTarget);
            lLastLoc = GetLocalLocation(spInfo.oTarget, "GR_SPIKEGROWTH_LOC_"+ObjectToString(oCaster));

            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay) && !bResisted) {
                fDist = GetDistanceBetweenLocations(GetLocation(spInfo.oTarget), lLastLoc);
                iNumDice = FloatToInt(GRMetersToFeet(fDist))/5; //*:* Dmg is for every 5 ft, so must divide after conversion
                iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                fDelay = GetRandomDelay(1.0, 2.2);
                eDam = EffectDamage(iDamage, DAMAGE_TYPE_PIERCING);
                if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));

                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));

                if(!bAlreadyAffected) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    if(!GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC, SAVING_THROW_ALL, oCaster, fDelay)) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSpeed, spInfo.oTarget, fDuration);
                    }
               }
            } else if(!bResisted) {
                SetLocalInt(spInfo.oTarget, "GR_SPIKEGROWTH_RESISTED_"+ObjectToString(oCaster), TRUE);
            }
        }
        SetLocalLocation(spInfo.oTarget, "GR_SPIKEGROWTH_LOC_"+ObjectToString(oCaster), GetLocation(spInfo.oTarget));
        spInfo.oTarget = GetNextInPersistentObject(OBJECT_SELF);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
