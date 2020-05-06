//*:**************************************************************************
//*:*  GR_IN_EFFECTS.NSS
//*:**************************************************************************
//*:*
//*:* Functions applying to effect creation, application
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 10, 2004
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
//#include "GR_IC_NAMES" -- included in GR_IN_LIB
#include "GR_IN_LIB"

//*:**************************************************************************
//*:* Constant Declarations
//*:**************************************************************************
const int SPECIALEFFECT_TYPE_FATIGUE = 200;
const int SPECIALEFFECT_TYPE_EXHAUSTION = 201;
const int SPECIALEFFECT_TYPE_WATER_BREATHING = 202;
const int SPECIALEFFECT_TYPE_UNDERWATER_FREE_MOVEMENT = 203;

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void    GRApplyEffectToObject(int iDurationType, effect eEffect, object oTarget, float fDuration = 0.0f);
void    GRApplyEffectAtLocation(int iDurationType, effect eEffect, location lTarget, float fDuration = 0.0f);

int     GRGetHasEffectTypeFromSpell(int iEffectType, object oTarget, int iSpellID, object oCaster = OBJECT_INVALID);
int     GRGetHasEffectTypeFromCaster(int iEffectType, object oTarget, object oCaster);
int     GRGetHasSpellEffect(int iSpellID, object oTarget, object oCaster = OBJECT_INVALID);

effect  GREffectAbilityCheckDecrease(int iPenalty=1);
effect  GREffectAbilityCheckIncrease(int iBonus=1);
effect  GREffectAlignmentSpellImmunity();
effect  GREffectAreaOfEffect(int iAreaEffectId, string sOnEnterScript = "", string sHeartbeatScript = "", string sOnExitScript = "", string sNewTag="");
effect  GREffectArmorCheckPenalty(int iPenalty=1);
effect  GREffectProtectionFromAlignment(int nAlignment, int nPower = 1);
effect  GREffectFatigue();
effect  GREffectExhausted();
effect  GREffectCowering();
effect  GREffectShaken();
effect  GREffectSickened();
effect  GREffectAbilityBasedSkillIncrease(int iAbility, int iIncrease = 1);
effect  GREffectAbilityBasedSkillDecrease(int iAbility, int iDecrease = 1);

void    GRRemoveEffectTypeBySpellId(int iEffectType, int iSpellID, object oTarget);
void    GRRemoveEffectTypeFromSpell(int iEffectType, object oTarget, int iSpellID, object oCaster = OBJECT_INVALID, int bSingleEffect = FALSE);
void    GRRemoveSpellEffects(int iSpellId, object oTarget, object oCaster = OBJECT_INVALID, int bMagicalEffectsOnly = TRUE);
void    GRRemoveAllSpellEffects(int nID, object oTarget, int bMagicalEffectsOnly = TRUE);
void    GRRemoveMultipleSpellEffects(int iSpellID1, int iSpellID2, object oTarget, int bMagicalEffectsOnly = TRUE, int iSpellID3=-1, int iSpellID4=-1);
void    GRRemoveEffect(effect eEff, object oTarget, object oCaster = OBJECT_INVALID);
void    GRRemoveEffects(int iEffectType, object oTarget, object oCaster = OBJECT_INVALID);
void    GRRemoveAllEffects(object oTarget, int iEffectSubType = 0, int iExcludeEffectType1 = EFFECT_TYPE_INVALIDEFFECT,
            int iExcludeEffectType2 = EFFECT_TYPE_INVALIDEFFECT, int iExcludeEffectType3 = EFFECT_TYPE_INVALIDEFFECT);
void    GRRemoveMagicalSpellEffects(object oTarget, int bRemoveBeneficial = FALSE, object oCaster = OBJECT_SELF);
void    GRRemoveMultipleEffects(int iEffectType1, int iEffectType2, object oTarget, object oCaster = OBJECT_INVALID,
            int iEffectType3 = EFFECT_TYPE_INVALIDEFFECT);
void    GRSafeRemoveAbilityDecrease(effect eEff, object oTarget, object oCaster = OBJECT_INVALID);

void GRApplySpecialEffectToObject(int iDurationType, int iEffectType, object oTarget, float fDuration=0.0f, int iSubType=SUBTYPE_MAGICAL);
void GRDoSpecialEffectHeartbeat(int iEffectType, object oTarget);
void GRRemoveSpecialEffect(int iEffectType, object oTarget, object oCreator=OBJECT_INVALID, int iEffSubType=0);
int GRGetSpecialEffectSubType(int iEffectType, object oTarget);
int GRGetHasSpecialEffect(int iEffectType, object oTarget);
//*:**************************************************************************


//*:**********************************************
//*:* GRApplyEffectToObject
//*:**********************************************
//*:*
//*:* Applies spell effects to object
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRApplyEffectToObject(int iDurationType, effect eEffect, object oTarget, float fDuration = 0.0f) {

    int iEffSubType = GetEffectSubType(eEffect);
    int iEffFilter = SUBTYPE_MAGICAL | SUBTYPE_SUPERNATURAL;

    int bMagicBlocked = GRGetMagicBlocked(oTarget) && ((iEffSubType & iEffFilter)>0);

    if(!bMagicBlocked) {
        if(iDurationType==DURATION_TYPE_TEMPORARY) {
            ApplyEffectToObject(iDurationType, eEffect, oTarget, fDuration);
        } else {
            ApplyEffectToObject(iDurationType, eEffect, oTarget);
        }
        if(GetHasSpellEffect(SPELL_GR_BLADE_BROTHERS, oTarget)) {
            if(GetLocalInt(oTarget, BLADEBROTHERS_APPLYDOUBLE)) {
                oTarget = GetLocalObject(oTarget, BLADEBROTHERS_OBJECT);
                if(!bMagicBlocked) {
                    if(iDurationType==DURATION_TYPE_TEMPORARY) {
                        ApplyEffectToObject(iDurationType, eEffect, oTarget, fDuration);
                    } else {
                        ApplyEffectToObject(iDurationType, eEffect, oTarget);
                    }
                } else {
                    FloatingTextStrRefOnCreature(16939274, GetEffectCreator(eEffect));
                }
            }
        }
    } else {
        FloatingTextStrRefOnCreature(16939274, GetEffectCreator(eEffect));
    }
}

//*:**********************************************
//*:* GRApplyEffectAtLocation
//*:**********************************************
//*:*
//*:*  Applies spell effects at a location
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRApplyEffectAtLocation(int iDurationType, effect eEffect, location lTarget, float fDuration = 0.0f) {

    int iEffSubType = GetEffectSubType(eEffect);
    int iEffFilter = SUBTYPE_MAGICAL | SUBTYPE_SUPERNATURAL;
    object oTarget = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, lTarget);

    int bMagicBlocked = GetDistanceBetweenLocations(GetLocation(oTarget), lTarget)<5.0f && GRGetMagicBlocked(oTarget) &&
            ((iEffSubType & iEffFilter)>0);

    if(!bMagicBlocked) {
        if(iDurationType==DURATION_TYPE_TEMPORARY) {
            ApplyEffectAtLocation(iDurationType, eEffect, lTarget, fDuration);
        } else {
            ApplyEffectAtLocation(iDurationType, eEffect, lTarget);
        }
    } else {
        FloatingTextStrRefOnCreature(16939274, GetEffectCreator(eEffect));
    }
}

//*:**********************************************
//*:* GRGetHasEffectTypeFromSpell
//*:**********************************************
//*:*
//*:* Determines if a particular effect type was
//*:* created by a particular spell.  Allows for
//*:* checking by caster as well.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 7, 2007
//*:**********************************************
int GRGetHasEffectTypeFromSpell(int iEffectType, object oTarget, int iSpellID, object oCaster = OBJECT_INVALID) {

    effect eEffect = GetFirstEffect(oTarget);
    int iHasEffectFromSpell = FALSE;

    while(GetIsEffectValid(eEffect) && !iHasEffectFromSpell) {
        if(GetEffectType(eEffect)==iEffectType && GetEffectSpellId(eEffect)==iSpellID) {
            if(oCaster!=OBJECT_INVALID) {
                if(GetEffectCreator(eEffect)==oCaster) {
                    iHasEffectFromSpell = TRUE;
                }
            } else {
                iHasEffectFromSpell = TRUE;
            }
        }
        eEffect = GetNextEffect(oTarget);
    }

    return iHasEffectFromSpell;
}

//*:**********************************************
//*:* GRGetHasEffectTypeFromCaster
//*:**********************************************
//*:*
//*:* Determines if a particular effect type was
//*:* created by a particular creature/caster.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 30, 2008
//*:**********************************************
int GRGetHasEffectTypeFromCaster(int iEffectType, object oTarget, object oCaster) {

    effect eEffect = GetFirstEffect(oTarget);
    int iHasEffectFromCaster = FALSE;

    while(GetIsEffectValid(eEffect) && !iHasEffectFromCaster) {
        if(GetEffectType(eEffect)==iEffectType && GetEffectCreator(eEffect)==oCaster) {
            iHasEffectFromCaster = TRUE;
        }
        eEffect = GetNextEffect(oTarget);
    }

    return iHasEffectFromCaster;
}

//*:**********************************************
//*:* GRGetHasSpellEffect
//*:**********************************************
//*:*
//*:* Determines if the target has a particular
//*:* spell effect.  Allows for checking by caster
//*:* as well.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 15, 2007
//*:**********************************************
int GRGetHasSpellEffect(int iSpellID, object oTarget, object oCaster = OBJECT_INVALID) {

    if(iSpellID==SPELL_GR_INCENDIARY_SLIME && GetLocalInt(oTarget, INCENDIARY_SLIME) && oCaster==OBJECT_INVALID) {
        return TRUE;
    }
    int iHasEffect = GetHasSpellEffect(iSpellID, oTarget);

    if(iHasEffect && oCaster!=OBJECT_INVALID) {
        iHasEffect = FALSE;
        effect eEffect = GetFirstEffect(oTarget);
        while(GetIsEffectValid(eEffect) && !iHasEffect) {
            if(GetEffectSpellId(eEffect)==iSpellID) {
                if(GetEffectCreator(eEffect)==oCaster) {
                    iHasEffect=TRUE;
                }
            }
            eEffect = GetNextEffect(oTarget);
        }
    }

    return iHasEffect;
}

//*:**********************************************
//*:* GREffectAbilityCheckDecrease
//*:**********************************************
//*:*
//*:*    Reduces ability scores to effectively reduce modifiers
//*:*    by the amount of the ability check decrease
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 15, 2004
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
effect GREffectAbilityCheckDecrease(int iPenalty=1) {
    //*:**********************************************
    //*:* ability must be decreased by two for each 1 pt of penalty
    //*:**********************************************
    iPenalty*=2;
    effect eStr = EffectAbilityDecrease(ABILITY_STRENGTH, iPenalty);
    effect eDex = EffectAbilityDecrease(ABILITY_DEXTERITY, iPenalty);
    effect eCon = EffectAbilityDecrease(ABILITY_CONSTITUTION, iPenalty);
    effect eInt = EffectAbilityDecrease(ABILITY_INTELLIGENCE, iPenalty);
    effect eWis = EffectAbilityDecrease(ABILITY_WISDOM, iPenalty);
    effect eCha = EffectAbilityDecrease(ABILITY_CHARISMA, iPenalty);
    effect eLink = EffectLinkEffects(eStr, eDex);
    eLink = EffectLinkEffects(eLink, eCon);
    eLink = EffectLinkEffects(eLink, eInt);
    eLink = EffectLinkEffects(eLink, eWis);
    eLink = EffectLinkEffects(eLink, eCha);

    return eLink;
}

//*:**********************************************
//*:* GREffectAbilityCheckIncrease
//*:**********************************************
//*:*
//*:*    Increases ability scores to effectively increase modifiers
//*:*    by the amount of the ability check increase
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 15, 2004
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
effect GREffectAbilityCheckIncrease(int iBonus=1) {
    //*:**********************************************
    //*:* ability must be increased by two for each 1 pt of bonus
    //*:**********************************************
    iBonus*=2;
    effect eStr = EffectAbilityIncrease(ABILITY_STRENGTH, iBonus);
    effect eDex = EffectAbilityIncrease(ABILITY_DEXTERITY, iBonus);
    effect eCon = EffectAbilityIncrease(ABILITY_CONSTITUTION, iBonus);
    effect eInt = EffectAbilityIncrease(ABILITY_INTELLIGENCE, iBonus);
    effect eWis = EffectAbilityIncrease(ABILITY_WISDOM, iBonus);
    effect eCha = EffectAbilityIncrease(ABILITY_CHARISMA, iBonus);
    effect eLink = EffectLinkEffects(eStr, eDex);
    eLink = EffectLinkEffects(eLink, eCon);
    eLink = EffectLinkEffects(eLink, eInt);
    eLink = EffectLinkEffects(eLink, eWis);
    eLink = EffectLinkEffects(eLink, eCha);

    return eLink;
}

//*:**********************************************
//*:* GREffectAlignmentSpellImmunity
//*:**********************************************
//*:*
//*:*    Returns an effect for the spell immunity of the
//*:*    alignment spells
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 4, 2006
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
effect GREffectAlignmentSpellImmunity() {

    effect eImmunity;

    // Compulsion spells
    eImmunity = EffectSpellImmunity(SPELL_GR_ANIMAL_TRANCE);
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_BANE));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_BEASTLAND_FEROCITY));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_CALM_ANIMALS));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_CALM_EMOTIONS));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_CATERWAUL));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_APPROACH));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_DROP));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_FALL));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_FLEE));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_HALT));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_GREATER));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_GREATER_APPROACH));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_GREATER_DROP));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_GREATER_FALL));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_GREATER_FLEE));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMMAND_GREATER_HALT));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_COMP_STRIFE));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_CONFUSION));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_LESSER_CONFUSION));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_CRUSHING_DESPAIR));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_DAZE));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_DAZE_MONSTER));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_DEEP_SLUMBER));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_DIRGE_OF_DISCORD));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_DISTRACT));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_DIVINE_PROTECTION));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_DOLOROUS_MOTES));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_DOMINATE_ANIMAL));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_DOMINATE_MONSTER));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_DOMINATE_PERSON));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_DOOM));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_FEAR));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_FEEBLEMIND));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_HARMONIC_CHORUS));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_HAUNTING_TUNE));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_HERALDS_CALL));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_HISS_OF_SLEEP));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_HOLD_ANIMAL));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_HOLD_MONSTER));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_HOLD_PERSON));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_INSANITY));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_INSIDIOUS_RHYTHM));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_INSPIRATIONAL_BOOST));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_LOVES_LAMENT));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_LULLABY));
    //eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_MASS_DOMINATION));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_MASS_HOLD_MONSTER));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_MASS_HOLD_PERSON));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_MIND_FOG));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_NYBORS_MILD_ADMONISHMENT));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_NYBORS_GENTLE_REMINDER));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_NYBORS_STERN_REPROOF));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_NYBORS_WRATHFUL_CASTIGATION));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_POWORD_BLIND));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_POWER_WORD_DISABLE));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_POWER_WORD_KILL));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_POWORD_MALADROIT));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_POWORD_PETRIFY));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_POWER_WORD_STUN));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_POWORD_WEAKEN));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_RAGE));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_RAY_OF_HOPE));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_RAY_OF_STUPIDITY));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_SLEEP));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_SNOWSONG));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_SONG_OF_DISCORD));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_SORROW));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_STING_RAY));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_SUPPRESS_BREATH_WEAPON));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_TORRENT_OF_TEARS));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_TOUCH_OF_IDIOCY));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_VECNAS_MALEVOLENT_WHISPER));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_WARCRY));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_WAR_CRY));

    // Charm Spells
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_CHARM_PERSON_OR_ANIMAL));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_CHARM_PERSON));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_CHARM_MONSTER));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_MASS_CHARM));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_MASS_CHARM_PERSON));
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(SPELL_GR_STAY_THE_HAND));

    // Monster abilities
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(198)); // Aura_Fear
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(203)); // Aura_Unearthly_Visage
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(212)); // Bolt_charm
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(214)); // Bolt_confuse
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(215)); // Bolt_daze
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(218)); // Bolt_dominate
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(238)); // Dragon_breath_fear
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(250)); // Gaze_charm
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(251)); // Gaze_confuse
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(252)); // Gaze_daze
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(258)); // Gaze_dominate
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(259)); // Gaze_doom
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(260)); // Gaze_fear
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(265)); // Howl_confuse
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(266)); // Howl_daze
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(268)); // howl_doom
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(269)); // howl_fear
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(412)); // aura_fear_dragon
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(686)); // Harpy_song
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(779)); // Behold_ray_charm
    eImmunity = EffectLinkEffects(eImmunity, EffectSpellImmunity(800)); // Vampire_dominationgaze

    return eImmunity;
}

//*:**********************************************
//*:* GREffectAreaOfEffect
//*:**********************************************
//*:*
//*:*    Compatibility wrapper for NWN2
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 4, 2008
//*:**********************************************
effect GREffectAreaOfEffect(int iAreaEffectId, string sOnEnterScript = "", string sHeartbeatScript = "", string sOnExitScript = "", string sNewTag="") {

    effect eAOE;

    if(sOnEnterScript=="" && sHeartbeatScript=="" && sOnExitScript=="") {
        eAOE = EffectAreaOfEffect(iAreaEffectId);
    } else {
        eAOE = EffectAreaOfEffect(iAreaEffectId, sOnEnterScript, sHeartbeatScript, sOnExitScript);
    }

    return eAOE;
}

//*:**********************************************
//*:* GREffectArmorCheckPenalty
//*:**********************************************
//*:*
//*:*    Creates an Armor Check Penalty effect.
//*:*
//*:*    Armor itself is already accounted for in the
//*:*    skills.2da file.  This is only for spells applying
//*:*    a armor check penalty modifier.
//*:*
//*:*    Skills affected were retrieved from skills.2da which
//*:*    had a "1" in the ArmorCheckPenalty column.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 10, 2004
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
effect GREffectArmorCheckPenalty(int iPenalty=1) {

    effect eSkill1 = EffectSkillDecrease(SKILL_HIDE, iPenalty);
    effect eSkill2 = EffectSkillDecrease(SKILL_MOVE_SILENTLY, iPenalty);
    effect eSkill3 = EffectSkillDecrease(SKILL_PARRY, iPenalty);
    effect eSkill4 = EffectSkillDecrease(SKILL_PICK_POCKET, iPenalty);
    effect eSkill5 = EffectSkillDecrease(SKILL_SET_TRAP, iPenalty);
    effect eSkill6 = EffectSkillDecrease(SKILL_TUMBLE, iPenalty);
    effect eLink = EffectLinkEffects(eSkill1, eSkill2);
    eLink = EffectLinkEffects(eLink, eSkill3);
    eLink = EffectLinkEffects(eLink, eSkill4);
    eLink = EffectLinkEffects(eLink, eSkill5);
    eLink = EffectLinkEffects(eLink, eSkill6);

    return eLink;
}

//*:**********************************************
//*:* GREffectProtectionFromAlignment
//*:**********************************************
//*:*
//*:*    Protection from Alignment Effect Constructor -
//*:*    replaces Bioware version
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 4, 2006
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
effect GREffectProtectionFromAlignment(int iAlignment, int iPower = 1) {

    int iFinal = iPower * 2;
    effect eAC = EffectACIncrease(iFinal, AC_DEFLECTION_BONUS);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, iFinal);
    effect eImmune = GREffectAlignmentSpellImmunity();

    if(iAlignment==ALIGNMENT_GOOD || iAlignment==ALIGNMENT_EVIL) {
        eAC = VersusAlignmentEffect(eAC, ALIGNMENT_ALL, iAlignment);
        eSave = VersusAlignmentEffect(eSave,ALIGNMENT_ALL, iAlignment);
        eImmune = VersusAlignmentEffect(eImmune,ALIGNMENT_ALL, iAlignment);
    } else {
        eAC = VersusAlignmentEffect(eAC, iAlignment, ALIGNMENT_ALL);
        eSave = VersusAlignmentEffect(eSave, iAlignment, ALIGNMENT_ALL);
        eImmune = VersusAlignmentEffect(eImmune, iAlignment, ALIGNMENT_ALL);
    }

    effect eDur;
    if(iAlignment == ALIGNMENT_EVIL || iAlignment == ALIGNMENT_CHAOTIC) {
        eDur = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MINOR);
    } else if(iAlignment == ALIGNMENT_GOOD) {
        eDur = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MINOR);
    }

    effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eImmune, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eDur2);

    return eLink;
}

//*:**********************************************
//*:* GREffectAbilityBasedSkillIncrease
//*:**********************************************
//*:*
//*:* Creates skill bonus for all skills based on
//*:* particular ability
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: December 19, 2008
//*:**********************************************
effect  GREffectAbilityBasedSkillIncrease(int iAbility, int iIncrease = 1) {

    effect retEffect, eTrap;

    switch(iAbility) {
        case ABILITY_STRENGTH:
            retEffect = EffectSkillIncrease(SKILL_DISCIPLINE, iIncrease);
            break;
        case ABILITY_DEXTERITY:
            effect eHide = EffectSkillIncrease(SKILL_HIDE, iIncrease);
            effect eMove = EffectSkillIncrease(SKILL_MOVE_SILENTLY, iIncrease);
            effect eOpen = EffectSkillIncrease(SKILL_OPEN_LOCK, iIncrease);
            effect eParry = EffectSkillIncrease(SKILL_PARRY, iIncrease);
            eTrap = EffectSkillIncrease(SKILL_SET_TRAP, iIncrease);
            effect eTumb = EffectSkillIncrease(SKILL_TUMBLE, iIncrease);
            retEffect = EffectLinkEffects(eHide, eMove);
            retEffect = EffectLinkEffects(retEffect, eOpen);
            retEffect = EffectLinkEffects(retEffect, eParry);
            retEffect = EffectLinkEffects(retEffect, eTrap);
            retEffect = EffectLinkEffects(retEffect, eTumb);
            break;
        case ABILITY_CONSTITUTION:
            retEffect = EffectSkillIncrease(SKILL_CONCENTRATION, iIncrease);
            break;
        case ABILITY_INTELLIGENCE:
            eTrap = EffectSkillIncrease(SKILL_DISABLE_TRAP, iIncrease);
            effect eLore = EffectSkillIncrease(SKILL_LORE, iIncrease);
            effect eSearch = EffectSkillIncrease(SKILL_SEARCH, iIncrease);
            effect eSpell = EffectSkillIncrease(SKILL_SPELLCRAFT, iIncrease);
            effect eApp = EffectSkillIncrease(SKILL_APPRAISE, iIncrease);
            effect eCTrap = EffectSkillIncrease(SKILL_CRAFT_TRAP, iIncrease);
            effect eCArmor = EffectSkillIncrease(SKILL_CRAFT_ARMOR, iIncrease);
            effect eCWeap = EffectSkillIncrease(SKILL_CRAFT_WEAPON, iIncrease);
            retEffect = EffectLinkEffects(eTrap, eLore);
            retEffect = EffectLinkEffects(retEffect, eSearch);
            retEffect = EffectLinkEffects(retEffect, eSpell);
            retEffect = EffectLinkEffects(retEffect, eApp);
            retEffect = EffectLinkEffects(retEffect, eCTrap);
            retEffect = EffectLinkEffects(retEffect, eCArmor);
            retEffect = EffectLinkEffects(retEffect, eCWeap);
            break;
        case ABILITY_WISDOM:
            effect eHeal = EffectSkillIncrease(SKILL_HEAL, iIncrease);
            effect eList = EffectSkillIncrease(SKILL_LISTEN, iIncrease);
            effect eSpot = EffectSkillIncrease(SKILL_SPOT, iIncrease);
            retEffect = EffectLinkEffects(eHeal, eList);
            retEffect = EffectLinkEffects(retEffect, eSpot);
            break;
        case ABILITY_CHARISMA:
            effect eEmp = EffectSkillIncrease(SKILL_ANIMAL_EMPATHY, iIncrease);
            effect ePerform = EffectSkillIncrease(SKILL_PERFORM, iIncrease);
            effect ePersuade = EffectSkillIncrease(SKILL_PERSUADE, iIncrease);
            effect eTaunt = EffectSkillIncrease(SKILL_TAUNT, iIncrease);
            effect eUseDev = EffectSkillIncrease(SKILL_USE_MAGIC_DEVICE, iIncrease);
            effect eBluff = EffectSkillIncrease(SKILL_BLUFF, iIncrease);
            effect eIntimidate = EffectSkillIncrease(SKILL_INTIMIDATE, iIncrease);
            retEffect = EffectLinkEffects(eEmp, ePerform);
            retEffect = EffectLinkEffects(retEffect, ePersuade);
            retEffect = EffectLinkEffects(retEffect, eTaunt);
            retEffect = EffectLinkEffects(retEffect, eUseDev);
            retEffect = EffectLinkEffects(retEffect, eBluff);
            retEffect = EffectLinkEffects(retEffect, eIntimidate);
            break;
    }

    return retEffect;
}

//*:**********************************************
//*:* GREffectAbilityBasedSkillDecrease
//*:**********************************************
//*:*
//*:* Creates skill penalty for all skills based on
//*:* particular ability
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: December 19, 2008
//*:**********************************************
effect  GREffectAbilityBasedSkillDecrease(int iAbility, int iDecrease = 1) {

    effect retEffect, eTrap;

    switch(iAbility) {
        case ABILITY_STRENGTH:
            retEffect = EffectSkillDecrease(SKILL_DISCIPLINE, iDecrease);
            break;
        case ABILITY_DEXTERITY:
            effect eHide = EffectSkillDecrease(SKILL_HIDE, iDecrease);
            effect eMove = EffectSkillDecrease(SKILL_MOVE_SILENTLY, iDecrease);
            effect eOpen = EffectSkillDecrease(SKILL_OPEN_LOCK, iDecrease);
            effect eParry = EffectSkillDecrease(SKILL_PARRY, iDecrease);
            eTrap = EffectSkillDecrease(SKILL_SET_TRAP, iDecrease);
            effect eTumb = EffectSkillDecrease(SKILL_TUMBLE, iDecrease);
            retEffect = EffectLinkEffects(eHide, eMove);
            retEffect = EffectLinkEffects(retEffect, eOpen);
            retEffect = EffectLinkEffects(retEffect, eParry);
            retEffect = EffectLinkEffects(retEffect, eTrap);
            retEffect = EffectLinkEffects(retEffect, eTumb);
            break;
        case ABILITY_CONSTITUTION:
            retEffect = EffectSkillDecrease(SKILL_CONCENTRATION, iDecrease);
            break;
        case ABILITY_INTELLIGENCE:
            eTrap = EffectSkillDecrease(SKILL_DISABLE_TRAP, iDecrease);
            effect eLore = EffectSkillDecrease(SKILL_LORE, iDecrease);
            effect eSearch = EffectSkillDecrease(SKILL_SEARCH, iDecrease);
            effect eSpell = EffectSkillDecrease(SKILL_SPELLCRAFT, iDecrease);
            effect eApp = EffectSkillDecrease(SKILL_APPRAISE, iDecrease);
            effect eCTrap = EffectSkillDecrease(SKILL_CRAFT_TRAP, iDecrease);
            effect eCArmor = EffectSkillDecrease(SKILL_CRAFT_ARMOR, iDecrease);
            effect eCWeap = EffectSkillDecrease(SKILL_CRAFT_WEAPON, iDecrease);
            retEffect = EffectLinkEffects(eTrap, eLore);
            retEffect = EffectLinkEffects(retEffect, eSearch);
            retEffect = EffectLinkEffects(retEffect, eSpell);
            retEffect = EffectLinkEffects(retEffect, eApp);
            retEffect = EffectLinkEffects(retEffect, eCTrap);
            retEffect = EffectLinkEffects(retEffect, eCArmor);
            retEffect = EffectLinkEffects(retEffect, eCWeap);
            break;
        case ABILITY_WISDOM:
            effect eHeal = EffectSkillDecrease(SKILL_HEAL, iDecrease);
            effect eList = EffectSkillDecrease(SKILL_LISTEN, iDecrease);
            effect eSpot = EffectSkillDecrease(SKILL_SPOT, iDecrease);
            retEffect = EffectLinkEffects(eHeal, eList);
            retEffect = EffectLinkEffects(retEffect, eSpot);
            break;
        case ABILITY_CHARISMA:
            effect eEmp = EffectSkillDecrease(SKILL_ANIMAL_EMPATHY, iDecrease);
            effect ePerform = EffectSkillDecrease(SKILL_PERFORM, iDecrease);
            effect ePersuade = EffectSkillDecrease(SKILL_PERSUADE, iDecrease);
            effect eTaunt = EffectSkillDecrease(SKILL_TAUNT, iDecrease);
            effect eUseDev = EffectSkillDecrease(SKILL_USE_MAGIC_DEVICE, iDecrease);
            effect eBluff = EffectSkillDecrease(SKILL_BLUFF, iDecrease);
            effect eIntimidate = EffectSkillDecrease(SKILL_INTIMIDATE, iDecrease);
            retEffect = EffectLinkEffects(eEmp, ePerform);
            retEffect = EffectLinkEffects(retEffect, ePersuade);
            retEffect = EffectLinkEffects(retEffect, eTaunt);
            retEffect = EffectLinkEffects(retEffect, eUseDev);
            retEffect = EffectLinkEffects(retEffect, eBluff);
            retEffect = EffectLinkEffects(retEffect, eIntimidate);
            break;
    }

    return retEffect;
}

// Simulates a fatigue effect.  Can't be dispelled.
effect GREffectFatigue() {
    // Create the fatigue penalty
    effect eStrPenalty = EffectAbilityDecrease(ABILITY_STRENGTH, 2);
    effect eDexPenalty = EffectAbilityDecrease(ABILITY_DEXTERITY, 2);
    effect eMovePenalty = EffectMovementSpeedDecrease(10);  // 10% decrease

    effect eRet = EffectLinkEffects(eStrPenalty, eDexPenalty);
    eRet = EffectLinkEffects(eRet, eMovePenalty);
    eRet = ExtraordinaryEffect(eRet);

    return (eRet);
}

// Simulates an Exhausted effect.  Can't be dispelled.
effect GREffectExhausted() {
    effect eStrPenalty = EffectAbilityDecrease(ABILITY_STRENGTH, 6);
    effect eDexPenalty = EffectAbilityDecrease(ABILITY_DEXTERITY, 6);
    effect eMovePenalty = EffectMovementSpeedDecrease(50);  // 50% decrease

    effect eRet = EffectLinkEffects (eStrPenalty, eDexPenalty);
    eRet = EffectLinkEffects(eRet, eMovePenalty);
    eRet = ExtraordinaryEffect(eRet);

    return (eRet);
}

effect GREffectCowering() {
    int     iPenalty    = 2;
    effect  eDaze       = EffectDazed();  // takes no actions
    effect  eAC         = EffectACDecrease(iPenalty);
    effect  eLink       = EffectLinkEffects(eDaze, eAC);

    return eLink;
}

//*:**********************************************
//*:* GREffectShaken
//*:**********************************************
//*:*
//*:* Creates a Shaken effect
//*:* -2 to attacks, saves, and skills
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: October 2, 2007
//*:**********************************************
effect  GREffectShaken() {
    int     iPenalty    = 2;
    effect  eAttack     = EffectAttackDecrease(iPenalty);
    effect  eSave       = EffectSavingThrowDecrease(SAVING_THROW_ALL, iPenalty);
    effect  eSkill      = EffectSkillDecrease(SKILL_ALL_SKILLS, iPenalty);

    effect  eLink       = EffectLinkEffects(eAttack, eSave);
    eLink = EffectLinkEffects(eLink, eSkill);

    return eLink;
}

//*:**********************************************
//*:* GREffectSickened
//*:**********************************************
//*:*
//*:* Creates a Sickened effect
//*:* -2 to attacks, damage, saves, skills, and
//*:* ability checks
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 22, 2008
//*:**********************************************
effect  GREffectSickened() {
    //*:* Sickened is basically the same as Shaken, plus Damage penalty
    //*:* I moved the Ability Check here as the EffectFrightened doesn't 'seem' to
    //*:* implement it, so I didn't want Shaken to be more than Frightened
    int     iPenalty    = 2;
    effect  eShaken     = GREffectShaken();
    effect  eDamage     = EffectDamageDecrease(iPenalty);
    effect  eAbilities  = GREffectAbilityCheckDecrease(iPenalty);

    effect  eLink       = EffectLinkEffects(eShaken, eDamage);
    eLink = EffectLinkEffects(eLink, eAbilities);
    eLink = ExtraordinaryEffect(eLink);


    return eLink;
}

//*:**********************************************
//*:* GRRemoveEffectTypeFromSpell
//*:**********************************************
//*:*
//*:* Removes a particular effect type that was
//*:* created by a particular spell.  Allows for
//*:* checking by caster as well.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 31, 2007
//*:**********************************************
void GRRemoveEffectTypeFromSpell(int iEffectType, object oTarget, int iSpellID,
        object oCaster = OBJECT_INVALID, int bSingleEffect = FALSE) {

    effect  eEffect = GetFirstEffect(oTarget);
    int     bDone   = FALSE;
    int     bRemove;

    while(GetIsEffectValid(eEffect) && !bDone) {
        bRemove = FALSE;
        if(GetEffectType(eEffect)==iEffectType && GetEffectSpellId(eEffect)==iSpellID) {
            if(oCaster!=OBJECT_INVALID) {
                if(GetEffectCreator(eEffect)==oCaster) {
                    GRRemoveEffect(eEffect, oTarget, oCaster);
                    if(bSingleEffect) bDone = TRUE;
                }
            } else {
                GRRemoveEffect(eEffect, oTarget);
                if(bSingleEffect) bDone = TRUE;
            }
        }
        eEffect = (bRemove ? GetFirstEffect(oTarget) : GetNextEffect(oTarget));
    }
}

//*:**********************************************
//*:* GRRemoveSpellEffects
//*:**********************************************
//*:*
//*:* Wraps both RemoveSpellEffects and GZRemoveSpellEffects
//*:* such that if no Caster is supplied it removes all
//*:* effects from the spell given, else it removes only
//*:* the effects created by the given caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 16, 2005
//*:**********************************************
//*:* Updated On: February 9, 2007
//*:**********************************************
void GRRemoveSpellEffects(int iSpellId, object oTarget, object oCaster = OBJECT_INVALID, int bMagicalEffectsOnly = TRUE) {

    if(GetIsObjectValid(oCaster)) {
        RemoveSpellEffects(iSpellId, oCaster, oTarget);
    } else {
        GRRemoveAllSpellEffects(iSpellId, oTarget, bMagicalEffectsOnly);
    }
    if(iSpellId==SPELL_GR_INCENDIARY_SLIME) DeleteLocalInt(oTarget, INCENDIARY_SLIME);
    if(GetLocalInt(oTarget, WILL_DISBELIEF + IntToString(iSpellId))) {
        DeleteLocalInt(oTarget, WILL_DISBELIEF + IntToString(iSpellId));
    }
}

//*:**********************************************
//*:* GRRemoveAllSpellEffects
//*:**********************************************
//*:*
//*:* For some reason I suddenly was getting an
//*:* undeclared identifier message on GZRemoveSpellEffects,
//*:* so I copied the script here and renamed it.  It needed to
//*:* use my other functions anyway
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 29, 2005
//*:**********************************************
//*:* Updated On: February 9, 2007
//*:**********************************************
void GRRemoveAllSpellEffects(int nID, object oTarget, int bMagicalEffectsOnly = TRUE) {

    effect eEff = GetFirstEffect(oTarget);
    int bRemove;

    while(GetIsEffectValid(eEff)) {
        bRemove = FALSE;
        if(GetEffectSpellId(eEff) == nID) {
            if(GetEffectSubType(eEff)==SUBTYPE_MAGICAL && bMagicalEffectsOnly) {
                GRRemoveEffect(eEff, oTarget);
                //*** NWN2 SINGLE ***/ bRemove = TRUE;
            }
        }
        eEff = (bRemove ? GetFirstEffect(oTarget) : GetNextEffect(oTarget));
    }
}

//*:**********************************************
//*:* GRRemoveMultipleSpellEffects
//*:**********************************************
//*:*
//*:* Removes multiple spell effects so we don't have
//*:* to run a series of loops all the time
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 9, 2009
//*:**********************************************
void GRRemoveMultipleSpellEffects(int iSpellID1, int iSpellID2, object oTarget, int bMagicalEffectsOnly = TRUE, int iSpellID3=-9, int iSpellID4=-9) {
    //*:* can't use default of -1 for iSpellID3 and iSpellID4 as effects not applied by spells return this value in GetEffectSpellId

    effect eEff = GetFirstEffect(oTarget);
    int bRemove;

    while(GetIsEffectValid(eEff)) {
        bRemove = FALSE;
        if(GetEffectSpellId(eEff)==iSpellID1 || GetEffectSpellId(eEff)==iSpellID2 || GetEffectSpellId(eEff)==iSpellID3 || GetEffectSpellId(eEff)==iSpellID4) {
            if(GetEffectSubType(eEff)==SUBTYPE_MAGICAL && bMagicalEffectsOnly) {
                GRRemoveEffect(eEff, oTarget);
                //*** NWN2 SINGLE ***/ bRemove = TRUE;
            }
        }
        eEff = (bRemove ? GetFirstEffect(oTarget) : GetNextEffect(oTarget));
    }
}

//*:**********************************************
//*:* GRRemoveEffect
//*:**********************************************
//*:*
//*:* Wraps RemoveEffect
//*:* such that if no Caster is supplied it removes the
//*:* effect as normal, else it removes the effect only if
//*:* created by the given caster.  I also transposed the
//*:* call values of target/effect to effect/target
//*:* to match GRRemoveSpellEffects
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 16, 2005
//*:**********************************************
//*:* Updated On: February 9, 2007
//*:**********************************************
void GRRemoveEffect(effect eEff, object oTarget, object oCaster = OBJECT_INVALID) {

    if(GetIsObjectValid(oCaster)) {
        if((GetEffectCreator(eEff) == oCaster)) {
            RemoveEffect(oTarget, eEff);
        }
    } else {
        RemoveEffect(oTarget, eEff);
    }
}

//*:**********************************************
//*:* GRRemoveEffects
//*:**********************************************
//*:*
//*:*    Wraps RemoveEffect
//*:*    such that if no Caster is supplied it removes the
//*:*    effect as normal, else it removes the effect only if
//*:*    created by the given caster.  I also transposed the
//*:*    call values of target/effect to effect/target
//*:*    to match GrRemoveSpellEffects
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 28, 2005
//*:**********************************************
//*:* Updated On: February 9, 2007
//*:**********************************************
void GRRemoveEffects(int iEffectType, object oTarget, object oCaster = OBJECT_INVALID) {

    effect eEff = GetFirstEffect(oTarget);
    int bRemove;

    while(GetIsEffectValid(eEff)) {
        bRemove = FALSE;
        if(GetEffectType(eEff)==iEffectType) {
            if(GetEffectType(eEff)==EFFECT_TYPE_ABILITY_DECREASE) {
                GRSafeRemoveAbilityDecrease(eEff, oTarget, oCaster);
            } else {
                GRRemoveEffect(eEff, oTarget, oCaster);
            }
        }
        eEff = (bRemove ? GetFirstEffect(oTarget) : GetNextEffect(oTarget));
    }
}

void GRRemoveMagicalSpellEffects(object oTarget, int bRemoveBeneficial = FALSE, object oCaster = OBJECT_SELF) {

    //int bAffectItems = GetLocalInt(GetModule(), DISPEL_ITEMS);
    int bRemove;

    effect eEff = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eEff)) {
        bRemove = FALSE;
        if(GetEffectSubType(eEff)==SUBTYPE_MAGICAL && GetEffectSpellId(eEff)>=0) {
            if(!bRemoveBeneficial && GetEffectType(eEff)==EFFECT_TYPE_ABILITY_DECREASE) {
                GRSafeRemoveAbilityDecrease(eEff, oTarget, oCaster);
            } else {
                GRRemoveEffect(eEff, oTarget);
            }
        }
        eEff = (bRemove ? GetFirstEffect(oTarget) : GetNextEffect(oTarget));
    }

    /*if(bAffectItems) {
        object oItem = GetFirstItemInInventory(spInfo.oTarget);
        while(GetIsObjectValid(oItem)) {
            TODO: implement/hook item dispelling code here
        }
    }*/
}

//*:**********************************************
//*:* GRRemoveMultipleEffects
//*:**********************************************
//*:*
//*:* Wraps RemoveEffect (for multiple effects - like invis/imp invis)
//*:* such that if no Caster is supplied it removes the
//*:* effect as normal, else it removes the effect only if
//*:* created by the given caster.  I also transposed the
//*:* call values of target/effect to effect/target
//*:* to match SGRemoveSpellEffects
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 28, 2005
//*:**********************************************
//*:* Updated On: February 9, 2007
//*:**********************************************
void GRRemoveMultipleEffects(int iEffectType1, int iEffectType2, object oTarget, object oCaster = OBJECT_INVALID,
    int iEffectType3 = EFFECT_TYPE_INVALIDEFFECT) {

    effect  eEff = GetFirstEffect(oTarget);
    int     iEffectType, bRemove;

    while(GetIsEffectValid(eEff)) {
        iEffectType = GetEffectType(eEff);
        bRemove = FALSE;
        if(iEffectType==iEffectType1 || iEffectType==iEffectType2 || iEffectType==iEffectType3) {
            if(iEffectType==EFFECT_TYPE_ABILITY_DECREASE) {
                GRSafeRemoveAbilityDecrease(eEff, oTarget, oCaster);
                //*** NWN2 SINGLE ***/ bRemove = TRUE;
            } else {
                GRRemoveEffect(eEff, oTarget, oCaster);
                //*** NWN2 SINGLE ***/ bRemove = TRUE;
            }
        }
        eEff = (bRemove ? GetFirstEffect(oTarget) : GetNextEffect(oTarget));
    }
}

//*:**********************************************
//*:* GRRemoveEffectTypeBySpellId
//*:**********************************************
//*:*
//*:* Wraps RemoveEffect
//*:* removes a specific EFFECT_TYPE_ that is caused
//*:* by a particular spell
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 16, 2006
//*:**********************************************
//*:* Updated On: February 9, 2007
//*:**********************************************
void GRRemoveEffectTypeBySpellId(int iEffectType, int iSpellID, object oTarget) {

    int bRemove;
    effect eEff = GetFirstEffect(oTarget);

    while(GetIsEffectValid(eEff)) {
        bRemove = FALSE;
        if(GetEffectType(eEff)==iEffectType && GetEffectSpellId(eEff)==iSpellID) {
            GRRemoveEffect(eEff, oTarget);
            //*** NWN2 SINGLE ***/ bRemove = TRUE;
        }
        eEff = (bRemove ? GetFirstEffect(oTarget) : GetNextEffect(oTarget));
    }
}

//*:**********************************************
//*:* GRRemoveAllEffects
//*:**********************************************
//*:*
//*:* Wraps RemoveEffect
//*:* removes all EFFECT_TYPE_(s)
//*:* allows specification of multiple subtypes as bit-mapped value
//*:* int    SUBTYPE_MAGICAL          = 8;
//*:* int    SUBTYPE_SUPERNATURAL     = 16;
//*:* int    SUBTYPE_EXTRAORDINARY    = 24;
//*:* similar to OBJECT_TYPE_ in GetFirstObjectInShape
//*:*
//*:* allows for exclusion of certain effect types
//*:* being removed
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 29, 2008
//*:**********************************************
void GRRemoveAllEffects(object oTarget, int iEffectSubType = 0, int iExcludeEffectType1 = EFFECT_TYPE_INVALIDEFFECT,
        int iExcludeEffectType2 = EFFECT_TYPE_INVALIDEFFECT, int iExcludeEffectType3 = EFFECT_TYPE_INVALIDEFFECT) {

    effect  eEff        = GetFirstEffect(oTarget);
    int     iEffectType, bRemove;

    while(GetIsEffectValid(eEff)) {
        bRemove = FALSE;
        iEffectType = GetEffectType(eEff);  // pulled this out so we only do 1 call per effect, instead of 3
        if(iEffectType!=iExcludeEffectType1 && iEffectType!=iExcludeEffectType2 && iEffectType!=iExcludeEffectType3) {
            if((GetEffectSubType(eEff) & iEffectSubType)>0) {
                GRRemoveEffect(eEff, oTarget);
                //*** NWN2 SINGLE ***/ bRemove = TRUE;
            }
        }
        eEff = (bRemove ? GetFirstEffect(oTarget) : GetNextEffect(oTarget));
    }
}

//*:**********************************************
//*:* GRSafeRemoveAbilityDecrease
//*:**********************************************
//*:*
//*:* Wraps RemoveEffect
//*:*
//*:* removes ability decreases except from spells
//*:* that have greater benefits which would also
//*:* be removed
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 29, 2008
//*:**********************************************
void GRSafeRemoveAbilityDecrease(effect eEff, object oTarget, object oCaster = OBJECT_INVALID) {

    if((GetEffectType(eEff) == EFFECT_TYPE_ABILITY_DECREASE) &&
        GetEffectSpellId(eEff) != SPELL_ENLARGE_PERSON &&
        GetEffectSpellId(eEff) != SPELL_RIGHTEOUS_MIGHT &&
        //*** NWN2 SINGLE ***/ GetEffectSpellId(eEff) != SPELL_STONE_BODY &&
        GetEffectSpellId(eEff) != SPELL_IRON_BODY &&
        GetEffectSpellId(eEff) != 803) {

        GRRemoveEffect(eEff, oTarget, oCaster);
    }
}

//*:**********************************************
//*:* GRGetSpecialEffectString
//*:**********************************************
//*:*
//*:* returns the string used for local variables
//*:* based upon the special effect type
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 3, 2009
//*:**********************************************
string GRGetSpecialEffectString(int iEffectType) {

    string sEffectType;

    switch(iEffectType) {
        case SPECIALEFFECT_TYPE_FATIGUE:
            sEffectType = "GR_SE_FATIGUE";
            break;
        case SPECIALEFFECT_TYPE_EXHAUSTION:
            sEffectType = "GR_SE_EXHAUSTION";
            break;
        case SPECIALEFFECT_TYPE_WATER_BREATHING:
            sEffectType = "GR_SE_WATER_BREATHING";
            break;
        case SPECIALEFFECT_TYPE_UNDERWATER_FREE_MOVEMENT:
            sEffectType = "GR_SE_UNDWATER_FREEMOVE";
            break;
    }

    return sEffectType;
}

//*:**********************************************
//*:* GRGetHasSpecialEffect
//*:**********************************************
//*:*
//*:* returns whether the target has the effect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 3, 2009
//*:**********************************************
int GRGetHasSpecialEffect(int iEffectType, object oTarget) {

    string sEffectType = GRGetSpecialEffectString(iEffectType);

    return GetLocalInt(oTarget, sEffectType);
}

//*:**********************************************
//*:* GRGetSpecialEffectDurationType
//*:**********************************************
//*:*
//*:* returns the duration type of the effect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 3, 2009
//*:**********************************************
int GRGetSpecialEffectDurationType(int iEffectType, object oTarget) {

    string sEffectType = GRGetSpecialEffectString(iEffectType);

    return (GetLocalInt(oTarget, sEffectType+"_PERMANENT")==TRUE ? DURATION_TYPE_PERMANENT : DURATION_TYPE_TEMPORARY);
}

//*:**********************************************
//*:* GRGetSpecialEffectSpellId
//*:**********************************************
//*:*
//*:* returns the spell id that created the effect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 3, 2009
//*:**********************************************
int GRGetSpecialEffectSpellId(int iEffectType, object oTarget) {

    string sEffectType = GRGetSpecialEffectString(iEffectType);

    return GetLocalInt(oTarget, sEffectType+"_SPELLID");
}

//*:**********************************************
//*:* GRGetSpecialEffectCreator
//*:**********************************************
//*:*
//*:* returns the creator of the effect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 3, 2009
//*:**********************************************
object GRGetSpecialEffectCreator(int iEffectType, object oTarget) {

    string sEffectType = GRGetSpecialEffectString(iEffectType);
    object oCreator = GetLocalObject(oTarget, sEffectType+"_CREATOR");

    if(GetIsObjectValid(oCreator)) {
        return oCreator;
    } else {
        return OBJECT_INVALID;
    }
}

//*:**********************************************
//*:* GRApplySpecialEffectToObject
//*:**********************************************
//*:*
//*:* "applies" the special effect to the target.
//*:* basically, this just sets the tracking variables
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 3, 2009
//*:**********************************************
void GRApplySpecialEffectToObject(int iDurationType, int iEffectType, object oTarget, float fDuration=0.0f, int iSubType=SUBTYPE_MAGICAL) {

    string sEffectType;

    if(iDurationType!=DURATION_TYPE_INSTANT) {
        switch(iEffectType) {
            case SPECIALEFFECT_TYPE_FATIGUE:
                if(!GRGetHasSpecialEffect(SPECIALEFFECT_TYPE_FATIGUE, oTarget) ||
                    (iDurationType==DURATION_TYPE_PERMANENT && GRGetSpecialEffectDurationType(SPECIALEFFECT_TYPE_FATIGUE, oTarget)==DURATION_TYPE_TEMPORARY)) {

                    sEffectType = SPECIALEFFECT_FATIGUE;
                } else {
                    sEffectType = SPECIALEFFECT_EXHAUSTION;
                    iEffectType = SPECIALEFFECT_TYPE_EXHAUSTION;
                }
                break;
            case SPECIALEFFECT_TYPE_EXHAUSTION:
                sEffectType = SPECIALEFFECT_EXHAUSTION;
                break;
            case SPECIALEFFECT_TYPE_WATER_BREATHING:
                sEffectType = SPECIALEFFECT_WATER_BREATHING;
                break;
            case SPECIALEFFECT_TYPE_UNDERWATER_FREE_MOVEMENT:
                sEffectType = SPECIALEFFECT_UNDERWATER_FREE_MOVEMENT;
                break;
        }
        if(iDurationType==DURATION_TYPE_PERMANENT ||
            (iDurationType==DURATION_TYPE_TEMPORARY && GRGetSpecialEffectDurationType(iEffectType, oTarget)!=DURATION_TYPE_PERMANENT)) {

            SetLocalInt(oTarget, sEffectType, TRUE);
            SetLocalInt(oTarget, sEffectType+"_SPELLID", GetSpellId());
            SetLocalInt(oTarget, sEffectType+"_SUBTYPE", iSubType);
            SetLocalObject(oTarget, sEffectType+"_CREATOR", OBJECT_SELF);
            if(iDurationType==DURATION_TYPE_PERMANENT) {
                SetLocalInt(oTarget, sEffectType+"_PERMANENT", TRUE);
            } else {
                SetLocalInt(oTarget, sEffectType+"_PERMANENT", FALSE);
                SetLocalFloat(oTarget, sEffectType+"_DURATION", fDuration);
                DelayCommand(RoundsToSeconds(1), GRDoSpecialEffectHeartbeat(iEffectType, oTarget));
            }
        }
    }
}

//*:**********************************************
//*:* GRRemoveSpecialEffectBySpellId
//*:**********************************************
//*:*
//*:* removes any special effect created by the spell id
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 3, 2009
//*:**********************************************
void GRRemoveSpecialEffectBySpellId(int iSpellID, object oTarget, object oCreator=OBJECT_INVALID) {

    int iEffectType;

    for(iEffectType=SPECIALEFFECT_TYPE_FATIGUE; iEffectType<=SPECIALEFFECT_TYPE_UNDERWATER_FREE_MOVEMENT; iEffectType++) {
        if(GRGetSpecialEffectSpellId(iEffectType, oTarget)==iSpellID) {
            GRRemoveSpecialEffect(iEffectType, oTarget, oCreator);
        }
    }
}

//*:**********************************************
//*:* GRRemoveSpecialEffect
//*:**********************************************
//*:*
//*:* removes a special effect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 3, 2009
//*:**********************************************
void GRRemoveSpecialEffect(int iEffectType, object oTarget, object oCreator=OBJECT_INVALID, int iEffSubType=0) {

    if(oCreator==OBJECT_INVALID || (GRGetSpecialEffectCreator(iEffectType, oTarget)==oCreator)) {
        string sEffectType = GRGetSpecialEffectString(iEffectType);

        if(iEffSubType==0 || (GRGetSpecialEffectSubType(iEffectType, oTarget) & iEffSubType)>0) {
            DeleteLocalInt(oTarget, sEffectType);
            DeleteLocalInt(oTarget, sEffectType+"_PERMANENT");
            DeleteLocalInt(oTarget, sEffectType+"_SPELLID");
            DeleteLocalObject(oTarget, sEffectType+"_CREATOR");
            DeleteLocalInt(oTarget, sEffectType+"_SUBTYPE");
            DeleteLocalFloat(oTarget, sEffectType+"_DURATION");
        }
    }
}

int GRGetSpecialEffectSubType(int iEffectType, object oTarget) {
    string sEffectType = GRGetSpecialEffectString(iEffectType);

    return GetLocalInt(oTarget, sEffectType+"_SUBTYPE");
}

void GRDoSpecialEffectHeartbeat(int iEffectType, object oTarget) {
    string  sEffectType = GRGetSpecialEffectString(iEffectType);
    float   fDuration   = GetLocalFloat(oTarget, sEffectType+"_DURATION");
    int     iDurType    = GRGetSpecialEffectDurationType(iEffectType, oTarget);

    if(iDurType==DURATION_TYPE_TEMPORARY) {
        if(fDuration>0.0) {
            fDuration -= RoundsToSeconds(1);
            SetLocalFloat(oTarget, sEffectType+"_DURATION", fDuration);
            DelayCommand(RoundsToSeconds(1), GRDoSpecialEffectHeartbeat(iEffectType, oTarget));
        } else {
            GRRemoveSpecialEffect(iEffectType, oTarget);
        }
    }
}
//*:**************************************************************************
//*:**************************************************************************
