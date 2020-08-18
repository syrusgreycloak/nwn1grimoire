//*:**************************************************************************
//*:*  GR_S0_ENLARGE.NSS
//*:**************************************************************************
//*:* Enlarge Person - 3.5 Player's Handbook (p. 226)
//*:* Reduce Person - 3.5 Player's Handbook (p. 269)
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: August 10, 2004
//*:**************************************************************************
//*:* added:
//*:* Enlarge Person, Greater - Spell Compendium (p. 82)
//*:* Enlarge Person, Mass - 3.5 Player's Handbook (p. 227)
//*:* Reduce Person, Greater - Spell Compendium (p. 171)
//*:* Reduce Person, Mass - 3.5 Player's Handbook (p. 269)
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
//*:**************************************************************************
//*:* Updated On: March 3, 2008
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
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

    int     bMultiTarget       = (spInfo.iSpellID==SPELL_GR_MASS_ENLARGE || spInfo.iSpellID==SPELL_GR_MASS_REDUCE);

    switch(spInfo.iSpellID){
        case SPELL_GR_GREATER_ENLARGE:
            iDurType = DUR_TYPE_HOURS;
            break;
        case SPELL_GR_GREATER_REDUCE:
            iDurAmount *= 10;
            break;
    }

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(15.0);

    int     iNumTargets     = spInfo.iCasterLevel;
    int     bIsTarget;
    int     bHostile;
    int     bDispel;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eImpVis;
    effect eStrength;
    effect eDexterity;
    effect eAttack;
    effect eAC;

    switch(spInfo.iSpellID) {
        case SPELL_ENLARGE_PERSON:
        case SPELL_GR_GREATER_ENLARGE:
            bIsTarget = !GetHasSpellEffect(SPELL_RIGHTEOUS_MIGHT, spInfo.oTarget);
        case SPELL_GR_MASS_ENLARGE:
            eImpVis = EffectVisualEffect(VFX_IMP_DEATH);
            eStrength = EffectAbilityIncrease(ABILITY_STRENGTH, 2);
            eDexterity = EffectAbilityDecrease(ABILITY_DEXTERITY, 2);
            eAttack = EffectAttackDecrease(1);
            eAC = EffectACDecrease(1);
            break;
        case SPELL_GR_REDUCE:
        case SPELL_GR_GREATER_REDUCE:
            bIsTarget = !GetHasSpellEffect(SPELL_RIGHTEOUS_MIGHT, spInfo.oTarget);
        case SPELL_GR_MASS_REDUCE:
            eImpVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
            eStrength = EffectAbilityDecrease(ABILITY_STRENGTH, 2);
            eDexterity = EffectAbilityIncrease(ABILITY_DEXTERITY, 2);
            eAttack = EffectAttackIncrease(1);
            eAC = EffectACIncrease(1);
            break;
    }

    effect eLink = EffectLinkEffects(eStrength, eDexterity);
    eLink = EffectLinkEffects(eLink, eAttack);
    eLink = EffectLinkEffects(eLink, eAC);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        if(GetIsObjectValid(spInfo.oTarget)) {
            bHostile = GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster);
        } else if(spInfo.iSpellID==SPELL_GR_MASS_REDUCE) {
            bHostile = TRUE;
        }
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            switch(spInfo.iSpellID) {
                case SPELL_GR_MASS_ENLARGE:
                    bIsTarget = GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster) && !GetHasSpellEffect(SPELL_RIGHTEOUS_MIGHT, spInfo.oTarget);
                    break;
                case SPELL_GR_MASS_REDUCE:
                    if(bHostile) {
                        bIsTarget = GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster) && !GetHasSpellEffect(SPELL_RIGHTEOUS_MIGHT, spInfo.oTarget);
                    } else {
                        bIsTarget = GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster) && !GetHasSpellEffect(SPELL_RIGHTEOUS_MIGHT, spInfo.oTarget);
                    }
                    break;
            }
            if(bIsTarget && GRGetIsHumanoid(spInfo.oTarget)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, bHostile));
                //*:**********************************************
                //*:* Prevent stacking & dispel opposites
                //*:**********************************************
                switch(spInfo.iSpellID) {
                    case SPELL_GR_GREATER_ENLARGE:
                        if(GRGetHasSpellEffect(SPELL_GR_GREATER_REDUCE, spInfo.oTarget)) {
                            bDispel = TRUE;
                            GRRemoveSpellEffects(SPELL_GR_GREATER_REDUCE, spInfo.oTarget);
                        } else if(GRGetHasSpellEffect(SPELL_GR_GREATER_ENLARGE, spInfo.oTarget)) {
                            GRRemoveSpellEffects(SPELL_GR_GREATER_ENLARGE, spInfo.oTarget);
                        }
                    case SPELL_GR_MASS_ENLARGE:
                    case SPELL_ENLARGE_PERSON:
                        if(GRGetHasSpellEffect(SPELL_GR_MASS_REDUCE, spInfo.oTarget)) {
                            bDispel = TRUE;
                            GRRemoveSpellEffects(SPELL_GR_MASS_REDUCE, spInfo.oTarget);
                        } else if(GRGetHasSpellEffect(SPELL_GR_REDUCE, spInfo.oTarget)) {
                            bDispel = TRUE;
                            GRRemoveSpellEffects(SPELL_GR_REDUCE, spInfo.oTarget);
                        } else if(GRGetHasSpellEffect(SPELL_GR_MASS_ENLARGE, spInfo.oTarget)) {
                            GRRemoveSpellEffects(SPELL_GR_MASS_ENLARGE, spInfo.oTarget);
                        } else if(GRGetHasSpellEffect(SPELL_ENLARGE_PERSON, spInfo.oTarget)) {
                            GRRemoveSpellEffects(SPELL_ENLARGE_PERSON, spInfo.oTarget);
                        }
                        break;
                    case SPELL_GR_GREATER_REDUCE:
                        if(GRGetHasSpellEffect(SPELL_GR_GREATER_REDUCE, spInfo.oTarget)) {
                            GRRemoveSpellEffects(SPELL_GR_GREATER_REDUCE, spInfo.oTarget);
                        } else if(GRGetHasSpellEffect(SPELL_GR_GREATER_ENLARGE, spInfo.oTarget)) {
                            bDispel = TRUE;
                            GRRemoveSpellEffects(SPELL_GR_GREATER_ENLARGE, spInfo.oTarget);
                        }
                    case SPELL_GR_MASS_REDUCE:
                    case SPELL_GR_REDUCE:
                        if(GRGetHasSpellEffect(SPELL_GR_MASS_REDUCE, spInfo.oTarget)) {
                            GRRemoveSpellEffects(SPELL_GR_MASS_REDUCE, spInfo.oTarget);
                        } else if(GRGetHasSpellEffect(SPELL_GR_REDUCE, spInfo.oTarget)) {
                            GRRemoveSpellEffects(SPELL_GR_REDUCE, spInfo.oTarget);
                        } else if(GRGetHasSpellEffect(SPELL_GR_MASS_ENLARGE, spInfo.oTarget)) {
                            bDispel = TRUE;
                            GRRemoveSpellEffects(SPELL_GR_MASS_ENLARGE, spInfo.oTarget);
                        } else if(GRGetHasSpellEffect(SPELL_ENLARGE_PERSON, spInfo.oTarget)) {
                            bDispel = TRUE;
                            GRRemoveSpellEffects(SPELL_ENLARGE_PERSON, spInfo.oTarget);
                        }
                        break;
                }
                //*:**********************************************
                //*:* Apply effects
                //*:**********************************************
                if(!bDispel) {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                }
                iNumTargets--;
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumTargets>0);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
