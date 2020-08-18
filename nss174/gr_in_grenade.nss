//*:**************************************************************************
//*:*  GR_IN_GRENADE.NSS
//*:**************************************************************************
//*:*
//*:* Wrapper for Bio DoGrenade function
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**************************************************************************
//*:* Updated On: September 7, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IN_SPELLHOOK"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void        GRDoGrenade(int iDirectDamage, int iSplashDamage, int vSmallHit, int vRingHit, int iDamageType, float fExplosionRadius ,
                int iObjectFilter, int nRacialType=RACIAL_TYPE_ALL);

//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************


//*:**********************************************
//*:* GRDoGrenade
//*:* Copyright (c) 2001 Bioware Corp.
//*:**********************************************
//*:*
//*:* Does a damage type grenade (direct or splash on miss)
//*:*
//*:**********************************************
//*:* Created By:
//*:* Created On:
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRDoGrenade(int iDirectDamage, int iSplashDamage, int vSmallHit, int vRingHit, int iDamageType, float fExplosionRadius,
        int iObjectFilter, int iRacialType=RACIAL_TYPE_ALL) {


    //Declare major variables  ( fDist / (3.0f * log( fDist ) + 2.0f) )
    object oTarget = GetSpellTargetObject();
    int iCasterLevel = GRGetCasterLevel(OBJECT_SELF);
    int iDamage = 0;
    int iMetamagic = GRGetMetamagicFeat();
    int iCnt;
    effect eMissile;
    effect eVis = EffectVisualEffect(vSmallHit);
    location lTarget = GetSpellTargetLocation();

    float fDist = GetDistanceBetween(OBJECT_SELF, oTarget);
    int iTouch;


    if(GetIsObjectValid(oTarget)) {
        iTouch = GRTouchAttackRanged(oTarget);
    } else {
        iTouch = -1;
        //*:**********************************************
        //*:* this means that target was the ground, so the user
        //*:* intended to splash
        //*:**********************************************
    }

    if(iTouch > 0) {
        int iDam = iDirectDamage * iTouch;

        //*:**********************************************
        //*:* Set damage effect
        //*:**********************************************
        effect eDam = EffectDamage(iDam, iDamageType);

        //*:**********************************************
        //*:* Apply the MIRV and damage effect
        //*:* only damage enemies
        //*:**********************************************
        if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF, TRUE)) {
            //*:**********************************************
            //*:* must be the correct racial type (only used with Holy Water)
            //*:**********************************************
            if((iRacialType!=RACIAL_TYPE_ALL) && (iRacialType == GRGetRacialType(oTarget))) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
            } else if((nRacialType == RACIAL_TYPE_ALL)) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
            }
        }
    }

    //*:**********************************************
    //*:* Splash damage always happens as well now
    //*:**********************************************
    effect eExplode = EffectVisualEffect(vRingHit);

    //*:**********************************************
    //*:* Apply the fireball explosion at the location captured above.
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);
    object oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fExplosionRadius, lTarget, TRUE, iObjectFilter);

    //*:**********************************************
    //*:* Cycle through the targets within the spell shape
    //*:* until an invalid object is captured.
    //*:**********************************************
    while(GetIsObjectValid(oTarget)) {
        if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF, TRUE)) {
            float fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget))/20;
            //*:**********************************************
            //*:* Roll damage for each target
            //*:**********************************************
            iDamage = iSplashDamage;

            //*:**********************************************
            //*:* Set the damage effect
            //*:**********************************************
            effect eDam = EffectDamage(iDamage, iDamageType);
            if(iDamage > 0) {
                //*:**********************************************
                //*:* must be the correct racial type (only used with Holy Water)
                //*:**********************************************
                if((iRacialType!=RACIAL_TYPE_ALL) && (iRacialType==GRGetRacialType(oTarget))) {
                    //*:**********************************************
                    //*:* Apply effects to the currently selected target.
                    //*:**********************************************
                    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    //*:**********************************************
                    //This visual effect is applied to the target object not the location as above.  This visual effect
                    //represents the flame that erupts on the target not on the ground.
                    //*:**********************************************
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                } else if((iRacialType == RACIAL_TYPE_ALL)) {
                    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fExplosionRadius, lTarget, TRUE, iObjectFilter);
    }
}
//*:**************************************************************************
//*:**************************************************************************
