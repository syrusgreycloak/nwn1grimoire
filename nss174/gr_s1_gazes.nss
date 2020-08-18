//*:**************************************************************************
//*:*  SPELL_TEMPLATE.NSS
//*:**************************************************************************
//*:*
//*:* Master script for various gaze attack abilities/spells
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**************************************************************************
//*:* Updated On: November 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
#include "X2_INC_SHIFTER"

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

    //*:**********************************************
    //*:* If blinded, I am not able to use this attack
    //*:**********************************************
    if(GZCanNotUseGazeAttackCheck(oCaster)) {
        return;
    }

    //*:* int     iDieType          = 0;
    int     iNumDice          = (spInfo.iCasterLevel/3)+1;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;
    switch(spInfo.iSpellID) {
        case 800:       // Shifter Vampire Domination gaze
            spInfo.iDC = ShifterGetSaveDC(oCaster, SHIFTER_DC_VERY_EASY) + GetAbilityModifier(ABILITY_WISDOM, oCaster);
            iNumDice = Random(MaxInt(1, GetAbilityModifier(ABILITY_WISDOM)))+d4();
            break;
        default:
            spInfo.iDC = 10 + spInfo.iCasterLevel/2;
            break;
    }

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

    float   fDelay;
    int     iVisual         = -1;
    int     iSpellTarget    = SPELL_TARGET_STANDARDHOSTILE;
    int     iSaveType       = SAVING_THROW_TYPE_MIND_SPELLS;
    int     iDurationType   = DURATION_TYPE_TEMPORARY;
    int     iObjectFilter   = OBJECT_TYPE_CREATURE;
    int     bAlignSpell     = FALSE;
    float   fDuration       = GRGetDuration(iNumDice);
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eVis;
    effect eGaze;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);;
    effect eDurVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eSaves;
    effect eAttack;
    effect eDamage;
    effect eSkill;

    switch(spInfo.iSpellID) {
        case 250:  // Gaze - Charm
            iVisual = VFX_IMP_CHARM;
            eGaze = EffectCharmed();
            eDurVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
            break;
        case 251:  // Gaze - Confuse
            iVisual = VFX_IMP_CONFUSION_S;
            eGaze = EffectConfused();
            break;
        case 252:  // Gaze - Daze
            iVisual = VFX_IMP_DAZED_S;
            eGaze = EffectDazed();
            break;
        case 254:  // Gaze - Destroy Chaos
        case 255:  // Gaze - Destroy Evil
        case 256:  // Gaze - Destroy Good
        case 257:  // Gaze - Destroy Law
            bAlignSpell = TRUE;
        case 253:  // Gaze - Death
            iVisual = VFX_IMP_DEATH;
            eGaze = EffectDeath();
            iSaveType = SAVING_THROW_TYPE_DEATH;
            iDurationType = DURATION_TYPE_INSTANT;
            break;
        case 258:  // Gaze - Dominate
        case 800:  // Shifter Vampire Domination Gaze
            iVisual = VFX_IMP_DOMINATE_S;
            eGaze = EffectDominated();
            eDurVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
            break;
        case 259:  // Gaze - Doom
            iVisual = VFX_IMP_DOOM;
            eSaves = EffectSavingThrowDecrease(SAVING_THROW_ALL, 2);
            eAttack = EffectAttackDecrease(2);
            eDamage = EffectDamageDecrease(2);
            eSkill = EffectSkillDecrease(SKILL_ALL_SKILLS, 2);
            eGaze = EffectLinkEffects(eAttack, eDamage);
            eGaze = EffectLinkEffects(eGaze, eSaves);
            eGaze = EffectLinkEffects(eGaze, eSkill);
            eGaze = EffectLinkEffects(eGaze, eDur);
            iSaveType = SAVING_THROW_TYPE_NONE;
            break;
        case 276:  // Krenshar Fear Gaze
            spInfo.iDC = 12;
            iSpellTarget = SPELL_TARGET_SELECTIVEHOSTILE;
            fDuration = GRGetDuration(3);
        case 260:  // Gaze - Fear
            iVisual = VFX_IMP_FEAR_S;
            eGaze = EffectFrightened();
            eDurVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
            iSaveType = SAVING_THROW_TYPE_FEAR;
            break;
        case 261:  // Gaze - Paralyze
            eGaze = EffectParalyze();
            eDurVis = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
            iSaveType = SAVING_THROW_TYPE_NONE;
            break;
        case 262:  // Gaze - Stun
            iVisual = VFX_IMP_STUN;
            eGaze = EffectStunned();
            break;
    }

    if(iVisual!=-1)
        eVis = EffectVisualEffect(iVisual);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //SendDebugString("Acquiring First Target",GetFirstPC());
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, 10.0, spInfo.lTarget, TRUE, iObjectFilter, GetPosition(oCaster));
    while(GetIsObjectValid(spInfo.oTarget)) {
        //SendDebugString("Target is valid.  Target is "+ObjectToString(oTarget),GetFirstPC());
        if(GRGetIsSpellTarget(spInfo.oTarget, iSpellTarget, oCaster, NO_CASTER)) {
            //SendDebugString("Done with GRGetIsSpellTarget",GetFirstPC());
            if(!bAlignSpell || (bAlignSpell && (
                    (spInfo.iSpellID==254 && GetAlignmentLawChaos(spInfo.oTarget)==ALIGNMENT_CHAOTIC) ||
                    (spInfo.iSpellID==255 && GetAlignmentGoodEvil(spInfo.oTarget)==ALIGNMENT_EVIL) ||
                    (spInfo.iSpellID==256 && GetAlignmentGoodEvil(spInfo.oTarget)==ALIGNMENT_GOOD) ||
                    (spInfo.iSpellID==257 && GetAlignmentLawChaos(spInfo.oTarget)==ALIGNMENT_LAWFUL) ))
            ) {
                if(spInfo.iSpellID<=252 || spInfo.iSpellID==258 || spInfo.iSpellID>=260) {  /* 800: Shifter Vampire Domination should be included IF
                                                                            >=260 ever needs to be changed*/
                    fDuration = GRGetDuration(GetScaledDuration(iNumDice, spInfo.oTarget));
                    eGaze = GetScaledEffect(eGaze, spInfo.oTarget);
                    eGaze = EffectLinkEffects(eGaze, eDur);
                    eGaze = EffectLinkEffects(eGaze, eDurVis);
                }

                //SendDebugString("Begin applying effects",GetFirstPC());
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster, fDelay)) {
                    if(iVisual!=-1)
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    if(iDurationType!=DURATION_TYPE_TEMPORARY) {
                        DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eGaze, spInfo.oTarget));
                    } else {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGaze, spInfo.oTarget, fDuration));
                    }
                }
            }
        }
        //SendDebugString("Getting Next Target",GetFirstPC());
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, 10.0, spInfo.lTarget, TRUE, iObjectFilter, GetPosition(oCaster));
    }

    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
