//*:**************************************************************************
//*:*  GR_IN_CREATURE.NSS
//*:**************************************************************************
//*:*
//*:* Functions to implement various creature powers
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IN_SPELLS"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************

//*:**********************************************
//*:* Gelatinous Cube
//*:**********************************************
int     GRDoCubeParalyze(object oTarget, object oSource, int iSaveDC = 16);
void    GREngulfAndDamage(object oTarget, object oSource);
//*:**********************************************
//*:* Mind Flayer
//*:**********************************************
void    GRDoMindBlast(int iDC, int iDuration, float fRange);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* Gelatinous Cube
//*:**********************************************
//*:* GRDoCubeParalyze
//*:*   (formerly SGDoCubeParalyze)
//*:**********************************************
//*:*
//*:* Gelatinous Cube Paralyze Attack
//*:*
//*:**********************************************
//*:* Bioware function
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRDoCubeParalyze(object oTarget, object oSource, int iSaveDC = 16) {

    if(GetIsImmune(oTarget,IMMUNITY_TYPE_PARALYSIS)) {
        return FALSE;
    }

    if(FortitudeSave(oTarget, iSaveDC, SAVING_THROW_TYPE_POISON, oSource) == 0) {
        effect ePara =  EffectParalyze();
        effect eDur = EffectVisualEffect(VFX_DUR_PARALYZED);
        ePara = EffectLinkEffects(eDur, ePara);
        ePara = EffectLinkEffects(EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION), ePara);

        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePara, oTarget, GRGetDuration(3+d3())); // not 3 d6, thats not fun
        return TRUE;
    } else {
        effect eSave = EffectVisualEffect(VFX_IMP_FORTITUDE_SAVING_THROW_USE);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSave, oTarget);
    }

    return FALSE;
}

//*:**********************************************
//*:* GREngulfAndDamage
//*:*   (formerly SGEngulfAndDamage)
//*:**********************************************
//*:*
//*:* GZ: Gel. Cube special abilities
//*:*
//*:**********************************************
//*:* Bioware function
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
void GREngulfAndDamage(object oTarget, object oSource) {

    if(ReflexSave(oTarget, 13 + GetHitDice(oSource) - 4, SAVING_THROW_TYPE_NONE, oSource) == 0) {

        int iDamage = d6();
        effect eDamage = EffectDamage(iDamage, DAMAGE_TYPE_ACID);
        effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);

        FloatingTextStrRefOnCreature(84610, oTarget); // * Engulfed
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        if(!GetIsImmune(oTarget,IMMUNITY_TYPE_PARALYSIS)) {
            if(GRDoCubeParalyze(oTarget,oSource,16)) {
                FloatingTextStrRefOnCreature(84609, oTarget);
            }
        }
    } else {
        effect eSave = EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSave, oTarget);
    }
}

//*:**********************************************
//*:* Mind Flayer
//*:**********************************************
//*:* GRDoMindBlast
//*:*   (formerly GRDoMindBlast)
//*:**********************************************
//*:*
//*:* Keith Warner
//*:*   Do a mind blast
//*:*   iHitDice - HitDice/Caster Level of the creator
//*:*   iDC      - DC of the Save to resist
//*:*   iRounds  - Rounds the stun effect holds
//*:*   fRange   - Range of the EffectCone
//*:*
//*:**********************************************
//*:* Bioware function
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
void GRDoMindBlast(int iDC, int iDuration, float fRange) {

    int iStunTime;
    float fDelay;

    location lTargetLocation = GetSpellTargetLocation();
    object oTarget;
    effect eCone;
    effect eVis = EffectVisualEffect(VFX_IMP_SONIC);

    oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, fRange, lTargetLocation, TRUE);

    while(GetIsObjectValid(oTarget)) {
        int iApp = GetAppearanceType(oTarget);
        int bImmune = FALSE;
        //*:**********************************************
        //*:* Hack to make mind flayers immune to their psionic attacks...
        //*:**********************************************
        if (iApp == 413 || iApp== 414 || iApp == 415) {
            bImmune = TRUE;
        }

        if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF) && !bImmune ) {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            //*:**********************************************
            //*:* already stunned
            //*:**********************************************
            if(GRGetHasSpellEffect(GetSpellId(),oTarget)) {
                //*:**********************************************
                //*:* only affects the targeted object
                //*:**********************************************
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_STUN), oTarget);
                int iDamage;
                if(GRGetLevelByClass(CLASS_TYPE_SHIFTER,OBJECT_SELF)>0) {
                    iDamage = d6(GRGetLevelByClass(CLASS_TYPE_SHIFTER,OBJECT_SELF)/3);
                } else {
                    iDamage = d6(GetHitDice(OBJECT_SELF)/2);
                }
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(iDamage), oTarget);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BIGBYS_FORCEFUL_HAND), oTarget);
            } else if(WillSave(oTarget, iDC) < 1) {
                //*:**********************************************
                //*:* Calculate the length of the stun
                //*:**********************************************
                iStunTime = iDuration;
                //*:**********************************************
                //*:* Set stunned effect
                //*:**********************************************
                eCone = EffectStunned();
                //*:**********************************************
                //*:* Apply the VFX impact and effects
                //*:**********************************************
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCone, oTarget, GRGetDuration(iStunTime)));
            }
        }
        //*:**********************************************
        //*:* Get next target in spell area
        //*:**********************************************
        oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, fRange, lTargetLocation, TRUE);
    }
}

//*:**************************************************************************
//*:**************************************************************************
