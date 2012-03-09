//*:**************************************************************************
//*:*  SPELL_TEMPLATE.NSS
//*:**************************************************************************
/*
    Grenade.
    Fires at a target. If hit, the target takes
    direct damage. If missed, all enemies within
    an area of effect take splash damage.

    HOWTO:
    - If target is valid attempt a hit
       - If miss then MISS
       - If hit then direct damage
    - If target is invalid or MISS
       - have area of effect near target
       - everyone in area takes splash damage
*/
//*:**************************************************************************
//:: Created By: Brent
//:: Created On: September 10, 2002
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
    int     iNumDice          = 1;
    int     iBonus            = 0;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount;        //= spInfo.iCasterLevel;
    //*:*int     iDurType          = DUR_TYPE_ROUNDS;

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
    //*:* if(!GRSpellhookAbortSpell()) return;
    //*:* spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iRacialType         = RACIAL_TYPE_ALL;
    int     iSplashDamage       = 1;
    int     vSmallHit           = -1;
    int     vRingHit            = -1;
    int     iDamageType         = -1;
    int     iSavingThrow        = -1;
    int     iSaveType           = SAVING_THROW_TYPE_NONE;
    int     iDurationType       = DURATION_TYPE_INSTANT;
    float   fExplosionRadius    = RADIUS_SIZE_HUGE;
    int     iObjectFilter       = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    int     iCount;
    int     iTouchAttack;
    float   fDist               = GetDistanceBetween(OBJECT_SELF, spInfo.oTarget);
    float   fDelay;
    int     bAlreadyAffected    = FALSE;
    string  sAOEType;

    switch(spInfo.iSpellID) {
        case 464:  // Alchemist's Fire
        case 470:  // Chicken Grenade used old alchemist's fire script (ie no application to items)
                   // - probably not used anywhere, but I'll include it just in case
            vSmallHit = VFX_IMP_FLAME_M;
            vRingHit = VFX_FNF_FIREBALL;
            iDamageType = DAMAGE_TYPE_FIRE;
            break;
        case 466:  // Holy Water
            iDieType = 4;
            iNumDice = 2;
            vSmallHit = VFX_IMP_HEAD_HOLY;
            vRingHit = VFX_FNF_LOS_NORMAL_20;
            iDamageType = DAMAGE_TYPE_DIVINE;
            iRacialType = RACIAL_TYPE_UNDEAD;
            break;
        case 469: // Acid Oil
            vSmallHit = VFX_IMP_ACID_L;
            vRingHit = VFX_FNF_GAS_EXPLOSION_ACID;
            iDamageType = DAMAGE_TYPE_ACID;
            break;
        case 744: // Fire Bomb
            vSmallHit = VFX_IMP_FLAME_M;
            vRingHit = VFX_FNF_FIREBALL;
            iDamageType = DAMAGE_TYPE_FIRE;
            iDurAmount = 5;
            fDuration = GRGetDuration(iDurAmount);
            iNumDice = 10;
            break;
        case 745: // Acid Bomb
            vSmallHit = VFX_IMP_ACID_L;
            vRingHit = VFX_FNF_GAS_EXPLOSION_ACID;
            iDamageType = DAMAGE_TYPE_ACID;
            iDurAmount = 5;
            fDuration = GRGetDuration(iDurAmount);
            iNumDice = 10;
            break;
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        if(GetObjectType(spInfo.oTarget)==OBJECT_TYPE_ITEM) {
            if(spInfo.iSpellID==464) {
                GRAddFlameWeaponEffectToWeapon(spInfo.oTarget, fDuration, spInfo.iCasterLevel);
                return;
            }
        } else {
            iTouchAttack = TouchAttackRanged(spInfo.oTarget);
            spInfo.lTarget = GetLocation(spInfo.oTarget);
        }
    } else {
        iTouchAttack = -1; // * this means that target was the ground, so the user
                    // * intended to splash
    }

    if(iTouchAttack >= 1) {
        iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, iBonus);
        if(iTouchAttack == 2) iDamage *= 2;
    }

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eGrenade;
    effect eVis;
    effect eExplode;
    effect eDam;
    effect eShake = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
    effect eAOE;
    effect eLink;

    switch(spInfo.iSpellID) {
        case 465: // Tanglefoot Bag
            spInfo.iDC = 15;
            iSavingThrow = SAVING_THROW_REFLEX;
            eGrenade = EffectLinkEffects(EffectEntangle(), EffectVisualEffect(VFX_DUR_ENTANGLE));
            fDuration = GRGetDuration(2);
            iDurationType = DURATION_TYPE_TEMPORARY;
            break;
        case 467: // Choking powder
            eGrenade = GREffectAreaOfEffect(AOE_PER_FOGSTINK, "gr_s3_chokeen", "gr_s3_chokeHB", "");
            vRingHit = 259;
            fDuration = GRGetDuration(5);
            iDurationType = DURATION_TYPE_TEMPORARY;
            sAOEType = AOE_TYPE_FOGSTINK;
            break;
        case 468: // Thunderstone
            spInfo.iDC = 15;
            iSavingThrow = SAVING_THROW_FORT;
            vRingHit = VFX_FNF_LOS_NORMAL_30;
            vSmallHit = VFX_IMP_HEAD_NATURE;
            eGrenade = EffectDeaf();
            fDuration = GRGetDuration(5);
            break;
        case 471: // Caltrops
            eGrenade = GREffectAreaOfEffect(37, "gr_s3_calEN", "gr_s3_calHB", "");
            sAOEType = "VFX_CUSTOM";
            vRingHit = VFX_DUR_CALTROPS;
            iDurationType = DURATION_TYPE_PERMANENT;
            break;
        case 744: // Fire Bomb
            eGrenade = GREffectAreaOfEffect(AOE_PER_FOGFIRE);
            sAOEType = AOE_TYPE_FOGFIRE;
            iDurationType = DURATION_TYPE_TEMPORARY;
            break;
        case 745: // Acid Bomb
            eGrenade = GREffectAreaOfEffect(AOE_PER_FOGACID);
            sAOEType = AOE_TYPE_FOGACID;
            iDurationType = DURATION_TYPE_TEMPORARY;
            break;
    }

    eDam = EffectDamage(iDamage, iDamageType);
    if(vSmallHit!=-1) eVis     = EffectVisualEffect(vSmallHit);
    if(vRingHit!=-1)  eExplode = EffectVisualEffect(vRingHit);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.iSpellID==468) {
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eShake, spInfo.lTarget, GRGetDuration(3));
    }

    if(iDamageType!=-1) {
        if(iDamage>0) { // direct target
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                // * must be the correct racial type (only used with Holy Water)
                if((iRacialType!=RACIAL_TYPE_ALL) && (iRacialType==GRGetRacialType(spInfo.oTarget))) {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget);
                    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget); VISUALS outrace the grenade, looks bad
                } else {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget);
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iDamageType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget); VISUALS outrace the grenade, looks bad
                }
            }
            SetLocalInt(spInfo.oTarget, "GR_GREN"+IntToString(spInfo.iSpellID), TRUE);
        }
    }

    if(vRingHit!=-1) {
        if(spInfo.iSpellID!=471) {
            GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);
        } else {
            GRApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eExplode, spInfo.lTarget);
        }
    }

    if(GetEffectType(eGrenade)==EFFECT_TYPE_AREA_OF_EFFECT) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, TRUE));
        if(iDurationType==DURATION_TYPE_TEMPORARY) {
            GRApplyEffectAtLocation(iDurationType, eGrenade, spInfo.lTarget, fDuration);
        } else {
            GRApplyEffectAtLocation(iDurationType, eGrenade, spInfo.lTarget);
            if(spInfo.iSpellID==471) { // Caltrops - really above line is too, but just want to keep this separate
                object oVisual = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_invisobj", spInfo.lTarget);
                object oArea = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, spInfo.lTarget);
                if(GetIsObjectValid(oArea) == TRUE) {
                    SetLocalObject(oArea, "X0_L_IMPACT", oVisual);
                }
            }
        }
        object oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
        GRSetAOESpellId(spInfo.iSpellID, oAOE);
        GRSetSpellInfo(spInfo, oAOE);
    }


    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fExplosionRadius, spInfo.lTarget, TRUE, iObjectFilter);
    while(GetIsObjectValid(spInfo.oTarget)) {
        bAlreadyAffected = GetLocalInt(spInfo.oTarget, "GR_GREN"+IntToString(spInfo.iSpellID));
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster) && !bAlreadyAffected) {
            fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20;
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));

            if(iDamageType!=-1) {
                iDamage = iSplashDamage;
                eDam = EffectDamage(iDamage, iDamageType);
                if(iDamage > 0) {
                    // * must be the correct racial type (only used with Holy Water)
                    if((iRacialType != RACIAL_TYPE_ALL) && (iRacialType == GetRacialType(spInfo.oTarget))) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    } else if(iRacialType == RACIAL_TYPE_ALL) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iDamageType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                    }
                }
            }
            if(GetIsEffectValid(eGrenade) && GetEffectType(eGrenade)!=EFFECT_TYPE_AREA_OF_EFFECT) {
                if(iSavingThrow!=-1) {
                    if(!GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster, fDelay)) {
                        if(vSmallHit!=-1)
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                        DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eGrenade, spInfo.oTarget, fDuration));
                    }
                }
            }
        }
        if(bAlreadyAffected) {
            DeleteLocalInt(spInfo.oTarget, "GR_GREN"+IntToString(spInfo.iSpellID));
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fExplosionRadius, spInfo.lTarget, TRUE, iObjectFilter);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
