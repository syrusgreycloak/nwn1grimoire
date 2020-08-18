//*:**************************************************************************
//*:*  GR_S0_SONICRAY.NSS
//*:**************************************************************************
//:: Sonic Ray (3.0 WotC Website Sonic Blast - sg_s0_sonicblst.nss) 2004 Karl Nickels (Syrus Greycloak)
//:: Created By: Karl Nickels (Syrus Greycloak)  Created On: February 19, 2004
//*:*
//*:**************************************************************************
//*:* Updated On: February 28, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"

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
    int     iNumDice          = MinInt(10, spInfo.iCasterLevel);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

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
    float   fRange          = FeetToMeters(25.0 + 5.0*spInfo.iCasterLevel/2);

    int     iReflexDamage;
    int     iBullRushDC     = d20()+4; // d20 + 4 mod for Large size
    int     iBullRushSTRMod;    // str mod will be (iDamage-10)/2;
    int     iMissedSave;
    location lMoveToTarget;
    object  oTarget2, oNextTarget;

    int     iVisualType     = GRGetEnergyVisualType(VFX_COM_HIT_SONIC, iEnergyType);
    int     iBeamType       = GRGetEnergyBeamType(iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iCnt = 1;
    int     iObjectFilter   = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;

    if(GRGetIsUnderwater(oCaster) && iEnergyType==DAMAGE_TYPE_SONIC) fRange *= 2.0;
    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eBeam        = EffectBeam(iBeamType, oCaster, BODY_NODE_HAND);
    effect eDamage;
    effect eVis         = EffectVisualEffect(VFX_IMP_KNOCK);
    effect eVis1        = EffectVisualEffect(iVisualType);
    effect eLink        = EffectLinkEffects(eVis,eVis1);
    effect eKnockdown   = EffectKnockdown();

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    oTarget2 = GetNearestObject(iObjectFilter, OBJECT_SELF, iCnt);
    while(GetIsObjectValid(oTarget2) && GetDistanceToObject(oTarget2) <= fRange) {
        //Get first target in the lightning area by passing in the location of first target and the casters vector (position)
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, iObjectFilter, GetPosition(oCaster));
        while(GetIsObjectValid(spInfo.oTarget)){
           if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_SONIC_BLAST));
                fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20.0;
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    iBullRushSTRMod =(iDamage-10)/2;  // get the equivalent STR mod for check
                    iBullRushDC += iBullRushSTRMod;    // add to Bull Rush DC
                    eDamage = EffectDamage(iDamage, iEnergyType);
                    eLink = EffectLinkEffects(eDamage, eLink);
                    if(iDamage>0) {
                        if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                        DelayCommand(1.3f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                        if(!GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster)) {
                            int iTargetSTRCheck=GetAbilityModifier(ABILITY_STRENGTH, spInfo.oTarget) + d20();
                            switch(GetCreatureSize(spInfo.oTarget)) {
                                case CREATURE_SIZE_HUGE:
                                    iTargetSTRCheck += 8;
                                    break;
                                case CREATURE_SIZE_LARGE:
                                    iTargetSTRCheck += 4;
                                    break;
                                case CREATURE_SIZE_SMALL:
                                    iTargetSTRCheck -= 4;
                                    break;
                                case CREATURE_SIZE_TINY:
                                    iTargetSTRCheck -= 8;
                                    break;
                            }
                            if(iTargetSTRCheck<iBullRushDC) {
                                int iDist = 5 + iBullRushDC - iTargetSTRCheck;  // 5ft+1 for each point lost check by
                                float fDistToMove = IntToFloat(iDist);
                                float fDistBetween = GetDistanceBetween(spInfo.oTarget, oCaster);
                                float fMaxRange = IntToFloat(25+5*spInfo.iCasterLevel);
                                if(fDistBetween<fMaxRange) {            //can only push to maximum range of spell
                                    if(fDistBetween + fDistToMove>fMaxRange) {
                                        fDistToMove = fMaxRange - fDistBetween;
                                    }
                                    float fFacing = GetFacing(spInfo.oTarget);
                                    if(fDistToMove>=DISTANCE_HUGE) {
                                        fDistToMove = DISTANCE_HUGE;
                                    } else if(fDistToMove>=DISTANCE_LARGE) {
                                        fDistToMove = DISTANCE_LARGE;
                                    } else if(fDistToMove>=DISTANCE_MEDIUM) {
                                        fDistToMove = DISTANCE_MEDIUM;
                                    } else if(fDistToMove>=DISTANCE_SHORT) {
                                        fDistToMove = DISTANCE_SHORT;
                                    } else {
                                        fDistToMove = DISTANCE_TINY;
                                    }
                                    lMoveToTarget = GenerateNewLocationFromLocation(GetLocation(spInfo.oTarget), fDistToMove,
                                                        GetOppositeDirection(fFacing), fFacing);
                                    AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
                                    DelayCommand(1.0f, AssignCommand(spInfo.oTarget, JumpToLocation(lMoveToTarget)));
                                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, spInfo.oTarget, 4.0f);
                                }
                            }
                        }
                    }
                }
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, spInfo.oTarget,1.0);
                oNextTarget = spInfo.oTarget;
                eBeam = EffectBeam(iBeamType, oNextTarget, BODY_NODE_CHEST);
           }
           spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, iObjectFilter, GetPosition(OBJECT_SELF));
        }
        iCnt++;
        oTarget2 = GetNearestObject(iObjectFilter, OBJECT_SELF, iCnt);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
