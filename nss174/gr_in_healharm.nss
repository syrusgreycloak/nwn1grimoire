//*:**************************************************************************
//*:*  GR_IN_HEALHARM.NSS
//*:**************************************************************************
//*:*
//*:* Functions called by healing and inflict/harm spells
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 17, 2008
//*:**************************************************************************
//*:* Updated From: GR_IN_CURE, GR_IN_INFLICT
//*:**************************************************************************
//*:* Brought the above includes together to mimic the way OEI updated and
//*:* combined the functions for NWN2.  Copyright OEI and Bioware Corp.
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IN_SPELLS"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void    GRDoSynostodweomer(struct SpellStruct spInfo, object oCaster = OBJECT_SELF);
void    GRCureWounds(int iDamage, int iMaxExtraDamage, int iMaximized, int vfx_impactHurt, int vfx_impactHeal, int iSpellID);
void    GRInflictWounds(int iDamage, int iMaxExtraDamage, int iMaximized, int vfx_impactHurt, int vfx_impactHeal, int iSpellID);
int     GRGetCureDamageTotal(object oTarget, int iDamage, int iMaxExtraDamage, int iMaximized, int iSpellID);
int     GRGetInflictDamageTotal(object oTarget, int iDamage, int iMaxExtraDamage, int iMaximized, int iSpellID);
void    GRApplyHealingEffect(object oTarget, int iDamageTotal, int vfx_impactHeal);
void    GRApplyHarmingEffect(object oTarget, int iDamageTotal, int iDamageType, int vfx_impactHurt, int bTouchAttack);
void    GRHealOrHarmTarget(object oTarget, int nDamageTotal, int vfx_impactNormalHurt, int vfx_impactUndeadHurt, int vfx_impactHeal,
                            int nSpellID, int bIsHealingSpell=TRUE, int bHarmTouchAttack=TRUE);

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************
//*:**********************************************
//*:* Special code for (Simbul's) Synostodweomer
//*:**********************************************
void GRDoSynostodweomer(struct SpellStruct spInfo, object oCaster = OBJECT_SELF) {

    int iSpellLevel = GRGetSpellSlotLevel(spInfo.iSpellLevel, spInfo.iMetamagic);

    GRRemoveSpellEffects(SPELL_GR_SIMBULS_SYNOSTODWEOMER, oCaster);
    GRCureWounds(d8(iSpellLevel), 0, 8*iSpellLevel, VFX_IMP_SUNSTRIKE, VFX_IMP_HEALING_G, SPELL_GR_SIMBULS_SYNOSTODWEOMER);
}

//*:**********************************************
//*:* Grimoire replacement for spellsCure
//*:**********************************************
//*:* Parameters:
//*:*  int nDamage         - base amount of damage to heal (or cause)
//*:*  int nMaxExtraDamage - an extra amount equal to the Caster's Level is applied, cappen by nMaxExtraDamage
//*:*  int nMaximized      - This is the max base amount.  (Do not include nMaxExtraDamage)
//*:*  int vfx_impactHurt  - Impact effect to use for when a creature is harmed
//*:*  int vfx_impactHeal  - Impact effect to use for when a creature is healed
//*:*  int nSpellID        - The SpellID that is being cast (Spell cast event will be triggered on target).
//*:**********************************************
void GRCureWounds(int iDamage, int iMaxExtraDamage, int iMaximized, int vfx_impactHurt, int vfx_impactHeal, int iSpellID) {

    object oCaster          = OBJECT_SELF;
    struct SpellStruct spInfo = GRGetSpellInfoFromObject(iSpellID, oCaster);

    int iDamageTotal;        //= GRGetCureDamageTotal(spInfo.oTarget, iDamage, iMaxExtraDamage, iMaximized, iSpellID);
    int bIsHealingSpell     = TRUE;
    int bMultiTarget        = (spInfo.iSpellID==SPELL_MASS_CURE_LIGHT_WOUNDS || spInfo.iSpellID==SPELL_MASS_CURE_MODERATE_WOUNDS ||
                                spInfo.iSpellID==SPELL_MASS_CURE_SERIOUS_WOUNDS || spInfo.iSpellID==SPELL_MASS_CURE_CRITICAL_WOUNDS);
    int bHarmTouchAttack    = (TRUE && !bMultiTarget);
    int iNumCreatures       = spInfo.iCasterLevel;
    float fRange            = FeetToMeters(15.0);
    /*** NWN1 SINGLE ***/ if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;


    if(bMultiTarget) {
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
                iDamageTotal = GRGetCureDamageTotal(spInfo.oTarget, iDamage, iMaxExtraDamage, iMaximized, iSpellID);
                GRHealOrHarmTarget(spInfo.oTarget, iDamageTotal, vfx_impactHurt, vfx_impactHurt, vfx_impactHeal, iSpellID, bIsHealingSpell, bHarmTouchAttack);
                iNumCreatures--;
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumCreatures>0);
    }

    if(iSpellID==SPELL_GR_HEALING_TOUCH) {
        GRHealOrHarmTarget(OBJECT_SELF, iDamageTotal/2, vfx_impactHurt, vfx_impactHurt, vfx_impactHeal, iSpellID, FALSE, FALSE);
    }
}

//*:**********************************************
//*:* Grimoire replacement for Bioware spellsInflict
//*:**********************************************
//*:* Parameters:
//*:*  int nDamage         - base amount of damage to heal (or cause)
//*:*  int nMaxExtraDamage - an extra amount equal to the Caster's Level is applied, cappen by nMaxExtraDamage
//*:*  int nMaximized      - This is the max base amount.  (Do not include nMaxExtraDamage)
//*:*  int vfx_impactHurt  - Impact effect to use for when a creature is harmed
//*:*  int vfx_impactHeal  - Impact effect to use for when a creature is healed
//*:*  int nSpellID        - The SpellID that is being cast (Spell cast event will be triggered on target).
//*:**********************************************
void GRInflictWounds(int iDamage, int iMaxExtraDamage, int iMaximized, int vfx_impactHurt, int vfx_impactHeal, int iSpellID) {

    object oCaster          = OBJECT_SELF;
    struct SpellStruct spInfo = GRGetSpellInfoFromObject(iSpellID, oCaster);

    int iDamageTotal;
    int bIsHealingSpell     = FALSE;
    int bMultiTarget        = (spInfo.iSpellID==SPELL_MASS_INFLICT_LIGHT_WOUNDS || spInfo.iSpellID==SPELL_MASS_INFLICT_MODERATE_WOUNDS ||
                                spInfo.iSpellID==SPELL_MASS_INFLICT_SERIOUS_WOUNDS || spInfo.iSpellID==SPELL_MASS_INFLICT_CRITICAL_WOUNDS);
    int bHarmTouchAttack    = (TRUE && !bMultiTarget);
    int iNumCreatures       = spInfo.iCasterLevel;
    float fRange            = FeetToMeters(15.0);
    /*** NWN1 SINGLE ***/ if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;


    if(bMultiTarget) {
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                iDamageTotal = GRGetInflictDamageTotal(spInfo.oTarget, iDamage, iMaxExtraDamage, iMaximized, iSpellID);
                GRHealOrHarmTarget(spInfo.oTarget, iDamageTotal, vfx_impactHurt, vfx_impactHurt, vfx_impactHeal, iSpellID, bIsHealingSpell, bHarmTouchAttack);
                iNumCreatures--;
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumCreatures>0);
    }
}

//*:**********************************************
//*:* Grimoire replacement for GetCureDamageTotal
//*:**********************************************
int GRGetCureDamageTotal(object oTarget, int iDamage, int iMaxExtraDamage, int iMaximized, int iSpellID) {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct SpellStruct spInfo;
    if(iSpellID!=SPELL_GR_SIMBULS_SYNOSTODWEOMER) {
        GRGetSpellInfoFromObject(iSpellID, oCaster);
    } else {
        GRGetSpellInfoFromObject(GetSpellId(), oCaster);
        spInfo.iMetamagic = GetLocalInt(oCaster, "SIMBULS_SYNOST_MM");
    }

    int iExtraDamage = MinInt(spInfo.iCasterLevel, iMaxExtraDamage); // * figure out the bonus damage

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GetGameDifficulty()<GAME_DIFFICULTY_NORMAL) {
        iDamage = iMaximized;
    }

    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_MAXIMIZE)) {
        iDamage = iMaximized;
    } else if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EMPOWER)) {
        iDamage = iDamage + iDamage/2;
    }

    iDamage += iExtraDamage;

    if(iSpellID==SPELL_GR_HEALING_TOUCH) {
        iDamage = MinInt(GetMaxHitPoints(oTarget)-GetCurrentHitPoints(oTarget), 2*GetCurrentHitPoints(oCaster)+10);
    }

    //*:**********************************************
    //*:* JLR - OEI 06/06/05 NWN2 3.5
    //*:* KN - added to NWN1, plus included check for
    //*:* Conjuration (Healing) spell
    //*:**********************************************
    if(GetHasFeat(FEAT_AUGMENT_HEALING) && spInfo.iSpellSchool==SPELL_SCHOOL_CONJURATION && spInfo.iSpellSubschool==SPELL_SUBSCHOOL_HEALING) {
        iDamage += 2*spInfo.iSpellLevel;
    }

    return iDamage;
}

//*:**********************************************
//*:* Grimoire equivalent for GetCureDamageTotal for Inflict spells
//*:**********************************************
int GRGetInflictDamageTotal(object oTarget, int iDamage, int iMaxExtraDamage, int iMaximized, int iSpellID) {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct SpellStruct spInfo;

    int iExtraDamage = MinInt(spInfo.iCasterLevel, iMaxExtraDamage); // * figure out the bonus damage

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_MAXIMIZE)) {
        iDamage = iMaximized;
    } else if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EMPOWER)) {
        iDamage = iDamage + iDamage/2;
    }

    iDamage += iExtraDamage;

    return iDamage;
}

//*:**********************************************
//*:* Grimoire replacement for DoHealing
//*:**********************************************
void GRApplyHealingEffect(object oTarget, int iDamageTotal, int vfx_impactHeal) {

    effect eHeal = EffectHeal(iDamageTotal);
    effect eVis2 = EffectVisualEffect(vfx_impactHeal);

    //*** NWN2 SINGLE ***/ GRRemoveEffects(EFFECT_TYPE_WOUNDING, oTarget);

    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget);
}

//*:**********************************************
//*:* Grimoire replacement for DoHarming
//*:**********************************************
void GRApplyHarmingEffect(object oTarget, int iDamageTotal, int iDamageType, int vfx_impactHurt, int bTouchAttack) {

    if(bTouchAttack) {
        // Returns 0 on a miss, 1 on a hit, and 2 on a critical hit.
        int iAttackResult = TouchAttackMelee(oTarget);
        if(iAttackResult == 0) {
            return;
        }
    }

    if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF)) {
        if(!GRGetSpellResisted(OBJECT_SELF, oTarget)) {
            // Returns 0 if the saving throw roll failed, 1 if the saving throw roll succeeded and 2 if the target was immune
            int iSaveResult = WillSave(oTarget, GRGetSpellSaveDC(OBJECT_SELF, oTarget), SAVING_THROW_TYPE_NONE, OBJECT_SELF);
            if(iSaveResult!=2) {
                // successful save = half damage
                if(iSaveResult == 1)
                    iDamageTotal = iDamageTotal/2;

                effect eDam = EffectDamage(iDamageTotal, iDamageType);
                //Apply the VFX impact and effects
                DelayCommand(1.0, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                effect eVis = EffectVisualEffect(vfx_impactHurt);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
        }
    }
}

//*:**********************************************
//*:* Grimoire replacement for spellsHealOrHarmTarget
//*:* This function handles all healing/harming
//*:* by spells, including rules for racial type
//*:**********************************************
void GRHealOrHarmTarget(object oTarget, int iDamageTotal, int vfx_impactNormalHurt, int vfx_impactUndeadHurt, int vfx_impactHeal,
                int iSpellID, int bIsHealingSpell=TRUE, int bHarmTouchAttack=TRUE) {

    int bUndead  = GRGetRacialType(oTarget)==RACIAL_TYPE_UNDEAD;
    int bHarmful = GRXor(bUndead, bIsHealingSpell);

    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, iSpellID, bHarmful));

    //*:**********************************************
    //*:* abort for creatures immune to heal.
    //*:**********************************************
    if(GRGetIsImmuneToMagicalHealing(oTarget))
        return;

    //*:**********************************************
    //*:* if target is undead
    //*:**********************************************
    if(bUndead) {
        if(bIsHealingSpell) { //*:* healing spells harm undead
            GRApplyHarmingEffect(oTarget, iDamageTotal, DAMAGE_TYPE_POSITIVE, vfx_impactUndeadHurt, bHarmTouchAttack);
        } else {
            GRApplyHealingEffect(oTarget, iDamageTotal, vfx_impactHeal);
        }
    } else if(GRGetIsLiving(oTarget)) {
        //*:**********************************************
        //*:* target is living target (not undead, NOT CONSTRUCT)
        //*:**********************************************
        if(bIsHealingSpell) {
            GRApplyHealingEffect(oTarget, iDamageTotal, vfx_impactHeal);
        } else {
            GRApplyHarmingEffect(oTarget, iDamageTotal, DAMAGE_TYPE_POSITIVE, vfx_impactNormalHurt, bHarmTouchAttack);
        }
    }
}
/*:**************************************************************************
void main() {}
/*:**************************************************************************/
