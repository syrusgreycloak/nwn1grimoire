//*:**************************************************************************
//*:*  GR_S0_HEARTFIRE.NSS
//*:**************************************************************************
//*:* Heartfire
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 24, 2008
//*:* Spell Compendium (p. 112)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_LIGHTDARK"

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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

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
    float   fRange          = FeetToMeters(5.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
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
    effect eImpact  = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect eOutline = EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eLight   = EffectVisualEffect(VFX_DUR_LIGHT_RED_10);
    effect eAOE     = EffectAreaOfEffect(AOE_MOB_HEARTFIRE);

    effect eLink    = EffectLinkEffects(eOutline, eLight);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GRGetHigherLvlDarknessEffectsInArea(SPELL_GR_HEARTFIRE, spInfo.lTarget)) {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        GRRemoveLowerLvlDarknessEffectsInArea(SPELL_GR_HEARTFIRE, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
            OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

        while(GetIsObjectValid(spInfo.oTarget)) {
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                GRRemoveMultipleSpellEffects(SPELL_GR_BLUR, SPELL_DISPLACEMENT, spInfo.oTarget, TRUE, SPELL_INVISIBILITY, SPELL_GREATER_INVISIBILITY);
                    GRRemoveSpellEffects(SPELL_GREATER_INVISIBILITY, spInfo.oTarget);
                GRRemoveSpellEffects(SPELL_GR_INVISIBILITY_SWIFT, spInfo.oTarget);
                if(GetHasEffect(EFFECT_TYPE_CONCEALMENT, spInfo.oTarget))
                    GRRemoveEffects(EFFECT_TYPE_CONCEALMENT,spInfo.oTarget);

                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_HEARTFIRE));
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);

                object oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_HEARTFIRE, oCaster);
                GRSetAOESpellId(spInfo.iSpellID, oAOE);
                GRSetSpellInfo(spInfo, oAOE);
                SetLocalInt(spInfo.oTarget, "GR_HF_SAVE_"+ObjectToString(oCaster), GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, iSaveType));
                SetLocalInt(spInfo.oTarget, "GR_HF_DUR_"+ObjectToString(oCaster), FloatToInt(fDuration/6.0));

            }
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
                OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        }
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
