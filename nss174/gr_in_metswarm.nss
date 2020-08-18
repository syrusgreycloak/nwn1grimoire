//*:**************************************************************************
//*:*  GR_IN_METSWARM.NSS
//*:**************************************************************************
//*:* Include file for all the different functions OEI uses for the NWN2
//*:* version of Meteor Swarm.
//*:* Copyright OEI
//*:**************************************************************************
//*:* Edited By: Karl Nickels (Syrus Greycloak)
//*:* Edited On: June 26, 2008
//*:**************************************************************************
//*:* Major changes made to include Energy Substitution, secondary damage, and
//*:* check for Incendiary Slime spell.  Basically the "little helper" functions
//*:* for the Creature version had to get wiped out.
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/**** NWN2 SPECIFIC ****
#include "NWN2_INC_SPELLS"

//*:**********************************************
//*:* Custom Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void    GRHandleTargetCreature(object oTarget, struct SpellStruct spInfo);
void    GRHandleTargetLocation(location lSpellTargetLocation, struct SpellStruct spInfo);
void    GRHandleTargetSelf(struct SpellInfo spInfo);

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************
void GRHandleTargetCreature(object oTarget, struct SpellStruct spInfo) {

    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    int iFireDamage;
    int iBluntDamage;
    int iSecDamage;
    effect eBlunt;
    effect eFire;

    effect eVis = EffectNWN2SpecialEffectFile("sp_meteor_swarm_tiny_imp.sef");  // makes use of NWN2 VFX
    effect eVis2 = EffectVisualEffect(VFX_HIT_SPELL_METEOR_SWARM_LRG);  // makes use of NWN2 VFX
    effect eShake = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);

    //Get first object in the spell area
    location    lSourceLoc  = GetLocation(OBJECT_SELF);
    location    lTargetLoc  = GetLocation(oTarget);
    int     iPathType       = PROJECTILE_PATH_TYPE_DEFAULT;
    int     iCounter;
    int     i;
    int     iTouchAttack;
    float   fDelay          = 6.0 / 4;
    object  oTarget2;
    float   fDelay2         = 2.0f;
    int     iSpellSave;

    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, spInfo.oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    // SetLocalInt(oTarget, "MeteorSwarmPrimaryTarget", 1);

    //Travel Time Calculation for Main Target
    float fTravelTime = GetProjectileTravelTime(lSourceLoc, lTargetLoc, iPathType);

    // Check for Spell Resistance on Main Target
    if(!GRGetSpellResisted(OBJECT_SELF, oTarget, 0.5)) {
        for(i=1; i<=4; i++) {
            iTouchAttack = GRTouchAttackRanged(oTarget, TRUE);
            spInfo.iDmgDieType = 6;
            spInfo.iDmgNumDice = 6;
            iSpellSave = (iTouchAttack<1 ? REFLEX_HALF : SPELL_SAVE_NONE);
            iFireDamage = GRGetSpellDamageAmount(spInfo, iSpellSave, spInfo.oCaster, iSaveType, (fDelay * i));
            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                iSecDamage = GRGetSpellSecondaryDamageAmount(iFireDamage, spInfo, iSpellSave, spInfo.oCaster, iSaveType, (fDelay * i));
                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                    iFireDamage = iSecDamage;
                }
            }
            eFire = EffectDamage(iFireDamage, iEnergyType, DAMAGE_TYPE_ENERGY);
            if(iSecDamage>0) eFire = EffectLinkEffects(eFire, EffectDamage(iSecDamage, spInfo.iSecDmgType));
            spInfo.iDmgNumDice = 2;
            iBluntDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, spInfo.oCaster, iSaveType, (fDelay * i));
            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                iSecDamage = GRGetSpellSecondaryDamageAmount(iBluntDamage, spInfo, iSpellSave, oCaster, iSaveType, (fDelay * i));
                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                    iBluntDamage = iSecDamage;
                }
            }
            eBlunt = EffectDamage(iBluntDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_ENERGY);
            if(iSecDamage>0) eBlunt = EffectLinkEffects(eBlunt, EffectDamage(iSecDamage, spInfo.iSecDmgType));

            DelayCommand((fDelay * i) + fTravelTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eFire, oTarget));
            DelayCommand((fDelay * i) + fTravelTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBlunt, oTarget));
            DelayCommand((fDelay * i) + fTravelTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
            DelayCommand((fDelay * i) + fTravelTime, GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eShake, lTargetLoc));
            DelayCommand((fDelay * i), SpawnSpellProjectile(OBJECT_SELF, oTarget, lSourceLoc, lTargetLoc, SPELL_METEOR_SWARM_TARGET_CREATURE, iPathType));
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                DelayCommand((fDelay * i), GRDoIncendiarySlimeExplosion(oTarget));
            }
        }
    }

    // Find the first object aside from the main target in blast radius.
    oTarget2 = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_TREMENDOUS, lTargetLoc);
    spInfo.iDmgDieType = 6;
    spInfo.iDmgNumDice = 6;

    while(GetIsObjectValid(oTarget2)) {
        //if (GetLocalInt(oTarget2, "MeteorSwarmPrimaryTarget") == 0)
        if(oTarget2!=oTarget) {
            if(GRGetIsSpellTarget(oTarget2, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF)) {
                SignalEvent(oTarget2, EventSpellCastAt(OBJECT_SELF, SPELL_METEOR_SWARM));
                if(!GRGetSpellResisted(OBJECT_SELF, oTarget2, 0.5)) {
                    for(i=1; i<=4; i++) {
                        iFireDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, spInfo.oCaster, iSaveType, (fDelay * i));
                        if(GRGetSpellHasSecondaryDamage(spInfo)) {
                            iSecDamage = GRGetSpellSecondaryDamageAmount(iFireDamage, spInfo, iSpellSave, spInfo.oCaster, iSaveType, (fDelay * i));
                            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                iFireDamage = iSecDamage;
                            }
                        }
                        eFire = EffectDamage(iFireDamage, iEnergyType, DAMAGE_TYPE_ENERGY);
                        if(iSecDamage>0) eFire = EffectLinkEffects(eFire, EffectDamage(iSecDamage, spInfo.iSecDmgType));

                        DelayCommand((fDelay * i) + fTravelTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eFire, oTarget2));
                        DelayCommand((fDelay * i) + fTravelTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget2));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, oTarget2) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            DelayCommand((fDelay * i), GRDoIncendiarySlimeExplosion(oTarget2));
                        }
                    }
                }
            }
        }
        oTarget2 = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_TREMENDOUS, lTargetLoc);
    }

//  SetLocalInt(oTarget, "MeteorSwarmPrimaryTarget", 0);
}

void GRHandleTargetLocation(location lSpellTargetLocation, struct SpellStruct spInfo) {

    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    int iDamage;
    int iSecDamage;
    effect eFire;
    effect eVis;
    effect eBump = EffectVisualEffect(VFX_FNF_SCREEN_BUMP);
    //Get first object in the spell area

    location lSourceLoc = GetLocation(spInfo.oCaster);
    location lTargetLoc;
    int iPathType = PROJECTILE_PATH_TYPE_DEFAULT;
    int iCounter = 0;
    int i;
    float fDelay = 6.0f / IntToFloat(GetNumMeteorSwarmProjectilesToSpawnA(lSpellTargetLocation));
    float fDelay2 = 0.0f;
    float fDelay3;
    float fTravelTime;
    float fRadiusSize;
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, spInfo.oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_VAST, lSpellTargetLocation);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(spInfo.oCaster, SPELL_METEOR_SWARM));
            if(!GRGetSpellResisted(spInfo.oCaster, spInfo.oTarget, 0.5)) {
                lTargetLoc = GetLocation(spInfo.oTarget);
        fTravelTime = GetProjectileTravelTime(lSourceLoc, lTargetLoc, iPathType);

                if(GetLocalInt(spInfo.oTarget, "MeteorSwarmCentralTarget") == 1) {
                    i = 3;
                    eVis = EffectVisualEffect(VFX_HIT_SPELL_METEOR_SWARM_SML);  // makes use of NWN2 VFX
                } else if(GetLocalInt(spInfo.oTarget, "MeteorSwarmNormalTarget") == 1) {
                    i = 4;
                    eVis = EffectVisualEffect(VFX_HIT_SPELL_METEOR_SWARM_SML);  // makes use of NWN2 VFX
                } else  {
                    i = 4;
                    eVis = EffectVisualEffect(VFX_HIT_SPELL_METEOR_SWARM);  // makes use of NWN2 VFX
                }

                for(i; i <= 4; i++) {
                    if(GetLocalInt(spInfo.oTarget, "MeteorSwarmCentralTarget")==1 || GetLocalInt(spInfo.oTarget, "MeteorSwarmNormalTarget")==1) {
                        spInfo.iDmgNumDice = 12;
                    } else {
                        spInfo.iDmgNumDice = 6;
                    }
                    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, spInfo.oCaster, iSaveType, fDelay2);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, spInfo.oCaster, iSaveType, fDelay2);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }

                    eFire = EffectDamage(iDamage, iEnergyType, DAMAGE_POWER_ENERGY);
                    if(iDamage>0) {
                        if(iSecDamage>0) eFire = EffectLinkEffects(eFire, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                        //Apply damage effect and VFX impact.
                        DelayCommand(fDelay2 + fTravelTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eFire, spInfo.oTarget));
                        DelayCommand(fDelay2 + fTravelTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                        DelayCommand(fDelay2 + fTravelTime, GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eBump, lTargetLoc));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            DelayCommand((fDelay2 + fTravelTime), GRDoIncendiarySlimeExplosion(spInfo.oTarget));
                        }
                    }

                    DelayCommand( fDelay2, SpawnSpellProjectile(OBJECT_SELF, spInfo.oTarget, lSourceLoc, lTargetLoc, SPELL_METEOR_SWARM, iPathType) );
                    fDelay2 += fDelay;
                }

                SetLocalInt(spInfo.oTarget, "MeteorSwarmCentralTarget", 0);
                SetLocalInt(spInfo.oTarget, "MeteorSwarmNormalTarget", 0);
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_VAST, lSpellTargetLocation);
    }
}

void GRHandleTargetSelf(struct SpellInfo spInfo) {
    object oCaster = spInfo.oCaster;

    int     iDamage;
    int     iSecDamage;
    effect  eFire;
    effect  eVis        = EffectVisualEffect(VFX_HIT_SPELL_METEOR_SWARM);   // makes use of NWN2 VFX
    effect  eBump       = EffectVisualEffect(VFX_FNF_SCREEN_BUMP);

    location lSourceLoc = GetLocation(oCaster);
    int iPathType = PROJECTILE_PATH_TYPE_DEFAULT;

    int nCounter = 0;
    float fDelay = 6.0f / IntToFloat( GetNumMeteorSwarmProjectilesToSpawnB(lSourceLoc) );
    float fDelay2 = 0.0f;
    float fTravelTime;

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_ASTRONOMIC, lSourceLoc);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_METEOR_SWARM) );
            //Make sure the target is outside the 2m safe zone
            if(GetDistanceBetween(spInfo.oTarget, oCaster)>2.0) {
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget, 0.5)) {
                    spInfo.lTarget = GetLocation(spInfo.oTarget);
                    fTravelTime = GetProjectileTravelTime(lSourceLoc, spInfo.lTarget, iPathType);

                    spInfo.iDmgNumDice = 6;
                    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, spInfo.oCaster, iSaveType, fDelay2);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, spInfo.oCaster, iSaveType, fDelay2);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }

                    eFire = EffectDamage(iDamage, iEnergyType, DAMAGE_POWER_ENERGY);
                    if(iDamage>0) {
                        if(iSecDamage>0) eFire = EffectLinkEffects(eFire, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                        DelayCommand(fDelay2 + fTravelTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eFire, oTarget));
                        DelayCommand(fDelay2 + fTravelTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                        DelayCommand(fDelay2 + fTravelTime, GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eBump, lTargetLoc));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            DelayCommand((fDelay2 + fTravelTime), GRDoIncendiarySlimeExplosion(spInfo.oTarget));
                        }
                    }
                    DelayCommand(fDelay2, SpawnSpellProjectile(oCaster, spInfo.oTarget, lSourceLoc, spInfo.lTarget, SPELL_METEOR_SWARM, iPathType));
                    fDelay2 += fDelay;
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_ASTRONOMIC, lSourceLoc);
    }
}
/**** END NWN2 SPECIFIC ****/
/*:**************************************************************************
void main() { }
//*:*************************************************************************/
