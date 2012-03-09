//*:**************************************************************************
//*:*  GR_S3_PSTONE.NSS
//*:**************************************************************************
//*:* Powerstone Copyright (c) 2001 Bioware Corp.
//*:* Created By: Yaron  Created On: 28/3/2003
//*:**************************************************************************
//*:* Updated On: December 10, 2007
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
void DoStorm(object oCaster, int iD6Dice, int iCap, int iSpell, int iMIRV = VFX_IMP_MIRV, int iVIS = VFX_IMP_MAGBLUE, int iDAMAGETYPE = DAMAGE_TYPE_MAGICAL, int iONEHIT = FALSE) {

    object  oTarget = OBJECT_INVALID;
    int     iCasterLevel= 15;
    int     iDamage = 0;
    int     iCount = 0;
    effect  eMissile = EffectVisualEffect(iMIRV);
    effect  eVis = EffectVisualEffect(iVIS);
    float   fDist = 0.0;
    float   fDelay = 0.0;
    float   fDelay2, fTime;
    location lTarget = GetLocation(oCaster); // missile spread centered around caster
    int     iMissiles = iCasterLevel;

    if(iMissiles > iCap) {
        iMissiles = iCap;
    }

        /* New Algorithm
            1. Count # of targets
            2. Determine number of missiles
            3. First target gets a missile and all Excess missiles
            4. Rest of targets (max nMissiles) get one missile
       */
    int iEnemies = 0;

    oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while(GetIsObjectValid(oTarget)) {
        // * caster cannot be harmed by this spell
        if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, OBJECT_SELF, NO_CASTER)) {
            iEnemies++;
        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
     }
     if(iEnemies>0) {
         if(iEnemies > iMissiles) {
            iMissiles = iEnemies;
         }

         int nRemainder = 0;

        oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        //Cycle through the targets within the spell shape until an invalid object is captured.
        while(GetIsObjectValid(oTarget) && iEnemies>0) {
            // * caster cannot be harmed by this spell
            if(GetIsEnemy(oTarget)) {
                // * recalculate appropriate distances
                fDist = GetDistanceBetween(OBJECT_SELF, oTarget);
                fDelay = fDist/(3.0 * log(fDist) + 2.0);
                int iDam = d6(iD6Dice);

                fTime = fDelay;
                fDelay2 += 0.1;
                fTime += fDelay2;

                effect eDam = EffectDamage(iDam, iDAMAGETYPE);
                //Apply the MIRV and damage effect
                DelayCommand(fTime, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget));
                DelayCommand(fDelay2, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget));
                DelayCommand(fTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                if(GetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, oTarget) && (iDAMAGETYPE==DAMAGE_TYPE_FIRE)) {
                    GRDoIncendiarySlimeExplosion(oTarget);
                }

                iEnemies--;
            }
            oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

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
    //GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    //*:* int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    //*:* int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    //*:* spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    /*if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);*/

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* offensive powers:
    switch(GetCampaignInt("dbItems", "Q3B_POWERSTONE_OFF")) {
        case 1:
            DoStorm(oCaster, 10, 1, SPELL_FIREBRAND, VFX_IMP_MIRV_FLAME, VFX_IMP_FLAME_M, DAMAGE_TYPE_FIRE, TRUE);
            break;
        case 2:
            DoStorm(oCaster, 10, 10, SPELL_FIREBRAND, VFX_IMP_MIRV_FLAME, VFX_IMP_FLAME_M, DAMAGE_TYPE_FIRE, TRUE);
            break;
        case 3:
            object oCreature = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
            ActionCastSpellAtObject(SPELL_SLOW, oCaster, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        case 4:
            spInfo.iCasterLevel = 20;
            effect eExplode = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
            effect eVisual = EffectVisualEffect(VFX_IMP_PULSE_WIND);
            effect eDam;
            int iRandom;
            spInfo.lTarget = GetLocation(oCaster);
            GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);

            spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_AREA_OF_EFFECT);
            while(GetIsObjectValid(spInfo.oTarget)) {
                if(GetObjectType(spInfo.oTarget)==OBJECT_TYPE_AREA_OF_EFFECT && GRAOEAffectedByGoW(spInfo.oTarget)) {
                    DestroyObject(spInfo.oTarget);
                } else if (spInfo.oTarget!=oCaster && GetIsEnemy(spInfo.oTarget)) {
                    fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20;

                    // * unlocked doors will reverse their open state
                    if(GetObjectType(spInfo.oTarget) == OBJECT_TYPE_DOOR) {
                        if(GetLocked(spInfo.oTarget) == FALSE) {
                            if(GetIsOpen(spInfo.oTarget) == FALSE) {
                                AssignCommand(spInfo.oTarget, ActionOpenDoor(spInfo.oTarget));
                            } else
                                AssignCommand(spInfo.oTarget, ActionCloseDoor(spInfo.oTarget));
                        }
                    }
                    if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, 20)) {
                        iRandom = d4(1) + 2;
                        effect eKnockdown = EffectKnockdown();
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, spInfo.oTarget, GRGetDuration(iRandom));
                        // Apply effects to the currently selected target.
                        iRandom = d6(2);
                        eDam = EffectDamage(iRandom);
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                        //This visual effect is applied to the target object not the location as above.  This visual effect
                        //represents the flame that erupts on the target not on the ground.
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spInfo.oTarget));
                    }
                }
                //Select the next target within the spell shape.
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE |OBJECT_TYPE_AREA_OF_EFFECT);
            }
            break;
        case 5:
            object oLowest;
            effect eDeath =  EffectDeath();
            effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
            effect eFNF = EffectVisualEffect(VFX_FNF_LOS_EVIL_20);
            int bContinueLoop = FALSE; //Used to determine if we have a next valid target
            int nHD = d4(12); //Roll to see how many HD worth of creature will be killed
            int nCurrentHD;
            int bAlreadyAffected;
            int nMax = 10;// maximun hd creature affected, set this to 9 so that a lower HD creature is chosen automatically
            //Also 9 is the maximum HD a creature can have and still be affected by the spell
            string sIdentifier = GetTag(oCaster);

            GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFNF, GetSpellTargetLocation());
            //Check for at least one valid object to start the main loop
            spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetSpellTargetLocation());
            if(GetIsObjectValid(spInfo.oTarget)) {
                bContinueLoop = TRUE;
            }
            // The above checks to see if there is at least one valid target.  If no value target exists we do not enter
            // the loop.

            while((nHD > 0) && (bContinueLoop)) {
                int nLow = nMax; //Set nLow to the lowest HD creature in the last pass through the loop
                bContinueLoop = FALSE; //Set this to false so that the loop only continues in the case of new low HD creature
                //Get first target creature in loop
                spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetSpellTargetLocation());
                while(GetIsObjectValid(spInfo.oTarget)) {
                    //Make sure the currect target is not an enemy
                    if(GetIsEnemy(spInfo.oTarget) && spInfo.oTarget!=OBJECT_SELF) {
                        //Get a local set on the creature that checks if the spell has already allowed them to save
                        bAlreadyAffected = GetLocalInt(spInfo.oTarget, "bDEATH" + sIdentifier);
                        if(!bAlreadyAffected) {
                             nCurrentHD = GetHitDice(spInfo.oTarget);
                             //If the selected creature is of lower HD then the current nLow value and
                             //the HD of the creature is of less HD than the number of HD available for
                             //the spell to affect then set the creature as the currect primary target
                             if(nCurrentHD < nLow && nCurrentHD <= nHD) {
                                 nLow = nCurrentHD;
                                 oLowest = spInfo.oTarget;
                                 bContinueLoop = TRUE;
                             }
                        }
                    }
                    //Get next target in shape to test for a new
                    spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetSpellTargetLocation());
                }
                //Check to make sure that oLowest has changed
                if(bContinueLoop == TRUE) {
                    //Make a Fort Save versus death effects
                    if(!GRGetSaveResult(SAVING_THROW_FORT, oLowest, GRGetSpellSaveDC(oCaster,oLowest), SAVING_THROW_TYPE_DEATH, OBJECT_SELF, fDelay)) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oLowest));
                        //DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oLowest));
                    }
                    //Even if the target made their save mark them as having been affected by the spell
                    SetLocalInt(oLowest, "bDEATH" + sIdentifier, TRUE);
                    //Destroy the local after 1/4 of a second in case other Circles of Death are cast on
                    //the creature laster
                    DelayCommand(fDelay + 0.25, DeleteLocalInt(oLowest, "bDEATH" + sIdentifier));
                    //Adjust the number of HD that have been affected by the spell
                    nHD = nHD - GetHitDice(oLowest);
                    oLowest = OBJECT_INVALID;
                }
            }
            break;
        case 6:
            int n = 1;
            effect eStun = EffectStunned();
            effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
            effect eLink = EffectLinkEffects(eMind, eStun);
            effect eVisual1 = EffectVisualEffect(VFX_IMP_STUN);
            effect eWord = EffectVisualEffect(VFX_FNF_PWSTUN);
            object oSubjectCreature = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oCaster, n);
            while(oSubjectCreature != OBJECT_INVALID) {
                if(GRGetIsSpellTarget(oSubjectCreature, SPELL_TARGET_SELECTIVEHOSTILE, oCaster, NO_CASTER)) {
                    if(!GRGetSaveResult(SAVING_THROW_WILL, oSubjectCreature, 18)) {
                         GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eWord, GetLocation(oSubjectCreature));
                         GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual1, oSubjectCreature);
                         GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oSubjectCreature, 6.0);
                    }
                }
                n++;
                oSubjectCreature = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCaster, n);
            }
            break;
    }


    //defensive powers:
    switch(GetCampaignInt("dbItems", "Q3B_POWERSTONE_DEF")) {
        case 1:
            ActionCastSpellAtObject(SPELL_SPELL_MANTLE, oCaster, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        case 2:
            ActionCastSpellAtObject(SPELL_GREATER_SPELL_MANTLE, oCaster, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        case 3:
            ActionCastSpellAtObject(SPELL_HASTE, oCaster, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        case 4:
            ActionCastSpellAtObject(SPELL_GREATER_STONESKIN, oCaster, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        case 5:
            ActionCastSpellAtObject(SPELL_ENERGY_BUFFER, oCaster, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        case 6:
            ActionCastSpellAtObject(SPELL_GREATER_INVISIBILITY, oCaster, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    //GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
