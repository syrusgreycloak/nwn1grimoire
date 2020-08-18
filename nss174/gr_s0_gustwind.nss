//*:**************************************************************************
//*:*  GR_S0_GUSTWIND.NSS
//*:**************************************************************************
//*:* Gust of Wind [x0_s0_gustwind.nss] Copyright (c) 2002 Bioware Corp.
//*:* Created By: Brent   Created On: September 7, 2002
//*:* 3.5 Player's Handbook (p. 238)
//*:**************************************************************************
//*:* Boreal Wind
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: May 8, 2008
//*:* Frostburn (p. 89)
//*:**************************************************************************
//*:* Updated On: May 8, 2008
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

    int     iDieType          = 4;
    int     iNumDice          = MinInt(15, spInfo.iCasterLevel);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 1+spInfo.iCasterLevel/2;
    int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = (spInfo.iSpellID==SPELL_GUST_OF_WIND ? FeetToMeters(60.0) : FeetToMeters(400.0+40.0*spInfo.iCasterLevel));
    float   fDelay;
    int     iAOEType        = AOE_MOB_BOREAL_WIND;
    string  sAOEType        = AOE_TYPE_BOREAL_WIND;

    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);

    int     iSaveType   = (spInfo.iSpellID==SPELL_GUST_OF_WIND ? SAVING_THROW_TYPE_NONE : GRGetEnergySaveType(iEnergyType));
    /*** NWN1 SINGLE ***/ int     iVisualType = (spInfo.iSpellID==SPELL_GUST_OF_WIND ? VFX_IMP_PULSE_WIND : GRGetEnergyVisualType(VFX_IMP_FROST_S, iEnergyType));
    //*** NWN2 SINGLE ***/ int     iVisualType = (spInfo.iSpellID==SPELL_GUST_OF_WIND ? VFX_HIT_SPELL_SONIC : GRGetEnergyVisualType(VFX_IMP_FROST_S, iEnergyType));

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SINGLE ***/ if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eExplode     = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    effect eVis         = EffectVisualEffect(iVisualType);
    effect eKnockdown   = EffectKnockdown();

    effect eAOE         = GREffectAreaOfEffect(iAOEType, "", "", "", sAOEType);
    /*** NWN1 SINGLE ***/ effect eDur         = EffectVisualEffect(VFX_DUR_CONECOLD_HEAD);
    //*** NWN2 SINGLE ***/ effect eDur         = EffectVisualEffect(GRGetEnergyConeType(VFX_DUR_CONE_ICE, iEnergyType));
    effect eDamage;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
        OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_AREA_OF_EFFECT);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GetObjectType(spInfo.oTarget) == OBJECT_TYPE_AREA_OF_EFFECT) {
            //Why are we destroying ALL aoe effects instead of just those affected by wind?
            //Check AOE versus known list of AOE effects affected by GoW
            if(GRAOEAffectedByGoW(spInfo.oTarget)) {
                DestroyObject(spInfo.oTarget);
            }
        } else if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20;
            if(GetObjectType(spInfo.oTarget) == OBJECT_TYPE_DOOR) {
                if(GetLocked(spInfo.oTarget) == FALSE) {
                    if(GetIsOpen(spInfo.oTarget) == FALSE) {
                        AssignCommand(spInfo.oTarget, ActionOpenDoor(spInfo.oTarget));
                    } else {
                        AssignCommand(spInfo.oTarget, ActionCloseDoor(spInfo.oTarget));
                    }
                }
            }
            spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget) && !GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster, fDelay)) {
                if(spInfo.iSpellID==SPELL_GUST_OF_WIND) {
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, spInfo.oTarget, GRGetDuration(3)));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                } else if(spInfo.iSpellID==SPELL_GR_BOREAL_WIND) {
                    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    eDamage = EffectDamage(iDamage, iEnergyType);
                    if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    eLink = EffectLinkEffects(eDamage, eVis);
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                    DelayCommand(fDelay, AssignCommand(spInfo.oTarget, ClearAllActions(TRUE)));
                    location lCaster = GetLocation(oCaster);
                    location lTarget = GetLocation(spInfo.oTarget);
                    float fDistToMove = FeetToMeters(3.0*spInfo.iCasterLevel);
                    location lNewTarget = GenerateNewLocationFromLocation(lTarget, fDistToMove, GetAngleBetweenLocations(lCaster, lTarget), GetFacing(spInfo.oTarget));
                    DelayCommand(fDelay+0.2, AssignCommand(spInfo.oTarget, ActionDoCommand(JumpToLocation(lNewTarget))));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
            OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_AREA_OF_EFFECT);
    }

    if(spInfo.iSpellID==SPELL_GR_BOREAL_WIND) {
        SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_BOREAL_WIND, FALSE));
        eLink = EffectLinkEffects(eAOE, eDur);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);

        /*** NWN1 SINGLE ***/ object oAOE = GRGetAOEOnObject(oCaster, sAOEType, oCaster);
        //*** NWN2 SINGLE ***/ object oAOE = GetObjectByTag(sAOEType);
        GRSetAOESpellId(spInfo.iSpellID, oAOE);
        GRSetSpellInfo(spInfo, oAOE);

        SetLocalInt(oCaster, "GR_L_CREATURE_NEEDS_CONCENTRATION", TRUE);
    }


    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
