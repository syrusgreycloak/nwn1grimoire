//*:**************************************************************************
//*:*  GR_S0_WAILBANSH.NSS
//*:**************************************************************************
//:: Wail of the Banshee (NW_S0_WailBansh) Copyright (c) 2001 Bioware Corp.
//:: Created By: Preston Watamaniuk  Created On:  Dec 12, 2000
//*:* 3.5 Player's Handbook (p. 298)
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
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
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iNumToAffect    = spInfo.iCasterLevel;
    int     iCount          = 0;
    location lTargetLoc;
    float   fTargetDistance;
    float   fDelay;

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
    /*** NWN1 SPECIFIC ***/
        effect eVis     = EffectVisualEffect(VFX_IMP_DEATH);
        effect eWail    = EffectVisualEffect(VFX_FNF_WAIL_O_BANSHEES);
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        effect eVis     = EffectVisualEffect(VFX_HIT_SPELL_NECROMANCY);
        effect eWail    = EffectVisualEffect(VFX_HIT_SPELL_WAIL_OF_THE_BANSHEE);
    /*** END NWN2 SPECIFIC ***/
    effect eDeath   = EffectDeath();

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eWail, spInfo.lTarget);

    if(!GetIsObjectValid(spInfo.oTarget))
        spInfo.oTarget = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, spInfo.lTarget, iCount);

    while(iCount<iNumToAffect) {
        lTargetLoc = GetLocation(spInfo.oTarget);
        fDelay = GetRandomDelay(3.0, 4.0);//
        fTargetDistance = GetDistanceBetweenLocations(spInfo.lTarget, lTargetLoc);
        if(GetIsObjectValid(spInfo.oTarget) && fTargetDistance <= 10.0) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster, NO_CASTER) &&
                (!GetHasSpellEffect(SPELL_SILENCE, spInfo.oTarget) || GetHasEffect(EFFECT_TYPE_DEAF, spInfo.oTarget)) ) {

                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_WAIL_OF_THE_BANSHEE));
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) /*, 0.1))*/ {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH) /*, oCaster, 3.0)*/ ) {
                        DelayCommand(fDelay-0.3, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget)); // no delay
                    }
                }
            }
        } else {
            iCount = iNumToAffect;
        }
        iCount++;
        spInfo.oTarget = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, spInfo.lTarget, iCount);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
