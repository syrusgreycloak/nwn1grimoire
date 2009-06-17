//*:**************************************************************************
//*:*  GR_S0_MISSILES.NSS
//*:**************************************************************************
//*:* Magic Missile (NW_S0_MagMiss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: April 10, 2001
//*:* 3.5 Player's Handbook (p. 250)
//*:**************************************************************************
//*:* Arcane Bolt
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 6, 2004
//*:* from http://www.wizards.com/dnd/article.asp?x=dnd/sb/sb20001001a
//*:*
//*:* Flame Bolt
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 31, 2001
//*:* Swords & Sorcery: Relics & Rituals I
//*:*
//*:* Mordenkainen's Force Missiles
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 6, 2004
//*:* Spell Compendium (p. 98)
//*:*
//*:* Ice Darts
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 8, 2008
//*:* Frostburn (p. 98)
//*:**************************************************************************
//*:* Updated On: May 8, 2008
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

    spInfo.lTarget          = GetLocation(spInfo.oTarget);
    //*** NWN2 SINGLE ***/ location lCasterLoc     = GetLocation(oCaster);

    int     iDieType          = 4;
    int     iNumDice          = 1;
    int     iBonus            = 1;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    /*** NWN1 SINGLE ***/ int     iMirvType       = VFX_IMP_MIRV;
    int     iMissiles       = (spInfo.iCasterLevel + 1)/2;
    float   fDist           = GetDistanceBetween(oCaster, spInfo.oTarget);
    float   fDelay          = fDist/(3.0 * log(fDist) + 2.0);
    float   fDelay2         = 0.0f;
    float   fTime, fTime2, fTravelTime;
    int     iCount;

    int     bIllusion       = FALSE;
    int     bTouchAttack    = FALSE;
    int     bNoSR           = FALSE;
    float   fPercent        = 1.0;
    float   fInitTargetPct  = 1.0;
    int     iSpellSaveType  = SPELL_SAVE_NONE;
    int     bForceMissiles  = FALSE;
    int     iEnergyType;
    int     iPathType       = PROJECTILE_PATH_TYPE_DEFAULT;

    object  oBurstTarget;
    int     iBurstDamage;
    int     iSecDmg;
    string  sSpellID        ="MFM_"+IntToString(GetTimeHour())+IntToString(GetTimeMinute())+IntToString(GetTimeSecond());


    switch(spInfo.iSpellID) {
        case SPELL_GR_ARCANE_BOLT:
            iDieType = 6;
            iEnergyType = DAMAGE_TYPE_MAGICAL;
            iMissiles = MinInt(5, iMissiles);
            iSpellSaveType = REFLEX_HALF;
            break;
        case SPELL_GR_FLAME_BOLT:
            bTouchAttack = TRUE;
            /*** NWN1 SINGLE ***/ iMirvType = GRGetEnergyMirvType(iEnergyType);
            iMissiles = 2 + spInfo.iCasterLevel/2;
            break;
        case SPELL_GR_LSE_MAGIC_MISSILE:
            fPercent = 0.2;
            bIllusion = TRUE;
        case SPELL_MAGIC_MISSILE:
            iEnergyType = DAMAGE_TYPE_MAGICAL;
            iMissiles = MinInt(5, iMissiles);
            break;
        case SPELL_GR_SHAD_EVOC1_MORD_FORCE_MISSILES:
        case SPELL_GR_GSE2_MORDENKAINENS_FORCE_MISSILES:
            fPercent = (spInfo.iSpellID==SPELL_GR_GSE2_MORDENKAINENS_FORCE_MISSILES ? 0.6 : 0.4);
            bIllusion = TRUE;
        case SPELL_GR_MORDENKAINENS_FORCE_MISSILES:
            bForceMissiles = TRUE;
            iDieType = 6;
            iNumDice = 2;
            iBonus = 0;
            iEnergyType = DAMAGE_TYPE_MAGICAL;
            iMissiles = MinInt(4, (spInfo.iCasterLevel/5) + 1);
            break;
        case SPELL_GR_ICE_DARTS:
            bTouchAttack = TRUE;
            bNoSR = TRUE;
            iNumDice = 2;
            iBonus = 0;
            spInfo = GRSetSpellSecondaryDamageInfo(spInfo, DAMAGE_TYPE_PIERCING, SECDMG_TYPE_HALF);
            iMissiles = MaxInt(1, MinInt(5, (spInfo.iCasterLevel+1)/3));
            /*** NWN1 SINGLE ***/ iMirvType = GRGetEnergyMirvType(iEnergyType);
            break;
    }

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    if(iEnergyType!=DAMAGE_TYPE_MAGICAL) {
        spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);
    }

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(5.0);

    int     iAttackResult;

    int     iSaveType;

    if(iEnergyType!=DAMAGE_TYPE_MAGICAL) {
        iSaveType = GRGetEnergySaveType(iEnergyType);
    } else {
        iSaveType = SAVING_THROW_TYPE_SPELL;
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
    /*** NWN1 SINGLE ***/ effect eMissile = EffectVisualEffect(iMirvType);
    effect eVis     = EffectVisualEffect(VFX_IMP_MAGBLUE);
    /*** NWN1 SINGLE ***/ effect eVis2    = EffectVisualEffect(VFX_COM_HIT_FROST);
    effect eDam;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    if(bNoSR || !GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
        if(bIllusion && GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
            fInitTargetPct = fPercent; // *:* saved - illusion disbelief
        }
        for(iCount = 1; iCount <= iMissiles; iCount++) {
            //*:* flame bolt & ice darts require ranged touch attack for each missile
            iAttackResult = (bTouchAttack ? GRTouchAttackRanged(spInfo.oTarget) : 1);
            spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
            iDamage = GRGetSpellDamageAmount(spInfo, iSpellSaveType, oCaster, iSaveType, fDelay) * iAttackResult;
            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, iSpellSaveType, oCaster) * iAttackResult;
                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                    iDamage = iSecDamage;
                }
            }

            fDelay2 += 0.1;     // need this for the burst damage from MFM
            /*** NWN1 SPECIFIC ***/
                fTime = fDelay;
                fTime += fDelay2;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                fTravelTime = GetProjectileTravelTime(lCasterLoc, spInfo.lTarget, iPathType);
                if(iCount==0) fDelay = 0.0f;
                else          fDelay = GetRandomDelay( 0.1f, 0.5f ) + (0.5f * IntToFloat(iCount));
                fTime = fDelay + fTravelTime;
            /*** END NWN2 SPECIFIC ***/

            /*** NWN1 SINGLE ***/ DelayCommand(fDelay2, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, spInfo.oTarget));
            if(iDamage>0) {
                eDam = EffectDamage(FloatToInt(iDamage*fInitTargetPct), iEnergyType);
                if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                DelayCommand(fTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                DelayCommand(fTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
            }

            //*** NWN2 SINGLE ***/ DelayCommand(fDelay, SpawnSpellProjectile(oCaster, spInfo.oTarget, lCasterLoc, spInfo.lTarget, spInfo.iSpellID, iPathType));

            //*:**********************************************
            //*:* Force Missile blast damage
            //*:**********************************************
            if(bForceMissiles) {
                object oBlastTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
                    OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

                while(GetIsObjectValid(oBlastTarget)) {
                    if(GRGetIsSpellTarget(oBlastTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                        SignalEvent(oBlastTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                        // CHECK AT BEGINNING IF RESISTED OR SAVED AS TARGET ONLY NEEDS TO DO THIS ONCE FOR BLAST DAMAGE
                        if(iCount==1 || !GetLocalInt(oBlastTarget, sSpellID+"_AFFECTED")) {
                            SetLocalInt(oBlastTarget, sSpellID+"_AFFECTED", TRUE);
                            SetLocalInt(oBlastTarget, sSpellID+"_RESIST", GRGetSpellResisted(oCaster, oBlastTarget, fTime));

                            if(!GetLocalInt(oBlastTarget, sSpellID+"_RESIST") && oBlastTarget!=spInfo.oTarget) {
                                iBurstDamage = iDamage/2;
                                iSecDmg = iSecDamage/2;
                                spInfo.iDC = GRGetSpellSaveDC(oCaster, oBlastTarget);

                                if(bIllusion && GRGetSaveResult(SAVING_THROW_WILL, oBlastTarget, spInfo.iDC)) {
                                    if(spInfo.iSpellID==SPELL_GR_SHAD_EVOC1_MORD_FORCE_MISSILES) {
                                        fPercent = 0.40;
                                    } else {
                                        fPercent = 0.60;
                                    }
                                } else {
                                    fPercent = 1.0;
                                }

                                // APPLY BLAST DAMAGE EFFECTS
                                eDam = EffectDamage(FloatToInt(iBurstDamage * fPercent), DAMAGE_TYPE_MAGICAL);
                                if(iBurstDamage>0) {
                                    if(iSecDmg>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDmg, spInfo.iSecDmgType));
                                    DelayCommand(fTime + fDelay2, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oBlastTarget));
                                    DelayCommand(fTime + fDelay2, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oBlastTarget));
                                }
                            }
                        }

                        // if last missile, delete local variables on target
                        if(iCount==iMissiles) {
                            DeleteLocalInt(oBlastTarget, sSpellID+"_AFFECTED");
                            DeleteLocalInt(oBlastTarget, sSpellID+"_RESIST");
                        }
                    }
                    oBlastTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
                        OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
                }
            }
        }
    }
    /*** NWN1 SPECIFIC ***/
    else {
        for(iCount = 1; iCount <= iMissiles; iCount++) {
            fDelay2 += 0.1;
            DelayCommand(fDelay2, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, spInfo.oTarget));
        }
    }
    /*** END NWN1 SPECIFIC ***/

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
