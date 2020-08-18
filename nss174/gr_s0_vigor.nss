//*:**************************************************************************
//*:*  GR_S0_VIGOR.NSS
//*:**************************************************************************
//*:* Lesser Vigor
//*:* Vigor
//*:* Greator Vigor (Monstrous Regeneration)
//*:* Mass Lesser Vigor
//*:* Vigorous Circle
//*:* Spell Compendium (p. 229)
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: December 17, 2007
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
    int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 10+spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;
    int     bMultiTarget;

    switch(spInfo.iSpellID) {
        case SPELL_LESSER_VIGOR:
            iBonus = 1;
            iDurAmount = MinInt(15, iDurAmount);
            break;
        case SPELL_VIGOR:
            iBonus = 2;
            iDurAmount = MinInt(25, iDurAmount);
            break;
        case SPELL_MONSTROUS_REGENERATION:
            iBonus = 4;
            iDurAmount = MinInt(35, iDurAmount);
            break;
        case SPELL_GR_VIGOROUS_CIRCLE:
        case SPELL_MASS_LESSER_VIGOR:
            bMultiTarget = TRUE;
            if(spInfo.iSpellID==SPELL_MASS_LESSER_VIGOR) {
                iBonus = 1;
                iDurAmount = MinInt(25, iDurAmount);
            } else {
                iBonus = 3;
                iDurAmount = MinInt(40, 10 + spInfo.iCasterLevel);
            }
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
    int     iNumCreatures   = spInfo.iCasterLevel/2;

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
    effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eRegen   = EffectRegenerate(iBonus, GRGetDuration(1));
    effect eVis     = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink    = EffectLinkEffects(eRegen, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
                if(GRGetIsLiving(spInfo.oTarget)) {
                    int bHasHigherEffect = FALSE;
                    switch(spInfo.iSpellID) {
                        case SPELL_MONSTROUS_REGENERATION:
                            GRRemoveMultipleSpellEffects(SPELL_MONSTROUS_REGENERATION, SPELL_VIGOR, spInfo.oTarget, TRUE, SPELL_MASS_LESSER_VIGOR,
                                SPELL_LESSER_VIGOR);
                            break;
                        case SPELL_VIGOR:
                            if(GetHasSpellEffect(SPELL_MONSTROUS_REGENERATION, spInfo.oTarget)) {
                                bHasHigherEffect = TRUE;
                            } else {
                                GRRemoveMultipleSpellEffects(SPELL_VIGOR, SPELL_MASS_LESSER_VIGOR, spInfo.oTarget, TRUE, SPELL_LESSER_VIGOR);
                            }
                            break;
                        case SPELL_MASS_LESSER_VIGOR:
                            if(GetHasSpellEffect(SPELL_MONSTROUS_REGENERATION, spInfo.oTarget) ||
                                GetHasSpellEffect(SPELL_VIGOR, spInfo.oTarget)) {
                                bHasHigherEffect = TRUE;
                            } else {
                                GRRemoveMultipleSpellEffects(SPELL_MASS_LESSER_VIGOR, SPELL_LESSER_VIGOR, spInfo.oTarget);
                            }
                            break;
                        case SPELL_LESSER_VIGOR:
                            if(GetHasSpellEffect(SPELL_MONSTROUS_REGENERATION, spInfo.oTarget) ||
                                GetHasSpellEffect(SPELL_VIGOR, spInfo.oTarget) ||
                                GetHasSpellEffect(SPELL_MASS_LESSER_VIGOR, spInfo.oTarget)) {
                                bHasHigherEffect = TRUE;
                            } else if(GetHasSpellEffect(SPELL_LESSER_VIGOR, spInfo.oTarget)) {
                                GRRemoveSpellEffects(SPELL_LESSER_VIGOR, spInfo.oTarget);
                            }
                            break;
                    }
                    if(!bHasHigherEffect) {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget);
                        iNumCreatures--;
                    } else {
                        FloatingTextStringOnCreature(GetName(spInfo.oTarget) + GetStringByStrRef(16939266), oCaster, FALSE);
                    }
                }
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumCreatures>0);
    }


    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
