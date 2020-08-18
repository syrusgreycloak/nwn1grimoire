//*:**************************************************************************
//*:*  GR_S0_SHRDFLME.NSS
//*:**************************************************************************
//*:* Shroud of Flame
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 2, 2009
//*:* Player's Guide to Faerun (p. 110)
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
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void RunDelayedActions(struct SpellStruct spInfo) {
    if(GetHasSpellEffect(SPELL_SHROUD_OF_FLAME, spInfo.oTarget)) {
        float fDelay = 0.0f;
        int iEnergyType = GetLocalInt(spInfo.oTarget, "GR_SHROUDFLAME_ENERGYTYPE");
        int iVisualType = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);
        int iSaveType   = GRGetEnergySaveType(iEnergyType);
        int iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_NEGATES, spInfo.oCaster, iSaveType, fDelay);
        int iSecDamage = 0;

        if(GRGetSpellHasSecondaryDamage(spInfo)) {
            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_NEGATES, spInfo.oCaster);
            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                iDamage = iSecDamage;
            }
        }

        if(iDamage>0) {
            effect eVis = EffectVisualEffect(iVisualType);
            effect eDam = EffectVisualEffect(iDamage, iEnergyType);
            effect eLink = EffectLinkEffects(eVis, eDam);
            if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
            effect eBeam;

            SignalEvent(spInfo.oTarget, EventSpellCastAt(spInfo.oTarget, SPELL_SHROUD_OF_FLAME));
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }

            float fRange = FeetToMeters(10.0f);
            if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;

            object oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, GetLocation(spInfo.oTarget), TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR);

            while(GetIsObjectValid(oTarget)) {
                if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, spInfo.oCaster)) {
                    SignalEvent(oTarget, EventSpellCastAt(spInfo.oTarget, SPELL_SHROUD_OF_FLAME, FALSE));
                    int iDC = GRGetSpellSaveDC(spInfo.oCaster, oTarget);
                    float fDelay = GetDistanceBetween(spInfo.oTarget, oTarget)/20.0f;
                    int bSave = GRGetSaveResult(SAVING_THROW_REFLEX, oTarget, spInfo.iDC, iSaveType, spInfo.oCaster, fDelay);
                    eBeam = EffectBeam(GRGetEnergyBeamType(iEnergyType), spInfo.oTarget, BODY_NODE_CHEST, bSave);

                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oTarget, 1.7f);
                    if(!GRGetSpellResisted(spInfo.oCaster, oTarget)) {
                        if(!bSave) {
                            iDamage = GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic, 0);
                            eDam = EffectDamage(iDamage, iEnergyType);
                            eLink = EffectLinkEffects(eVis, eDam);
                            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget);
                            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE)) {
                                GRDoIncendiarySlimeExplosion(oTarget);
                            }
                        }
                    }
                }
                oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, GetLocation(spInfo.oTarget), TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR);
            }
            DelayCommand(RoundsToSeconds(1), RunDelayedActions(spInfo));
        } else {
            GRRemoveSpellEffects(SPELL_SHROUD_OF_FLAME, spInfo.oTarget);
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

    int     iDieType          = 6;
    int     iNumDice          = 2;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_NEGATES, oCaster, iSaveType, fDelay);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_NEGATES, oCaster);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDur     = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MAJOR);
    effect eDamage  = EffectDamage(iDamage, iEnergyType);

    effect eLink    = EffectLinkEffects(eVis, eDamage);

    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_SHROUD_OF_FLAME));
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(iDamage>0) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget);
            SetLocalInt(spInfo.oTarget, "GR_SHROUDFLAME_ENERGYTYPE", iEnergyType);
            DelayCommand(RoundsToSeconds(1), RunDelayedActions(spInfo));
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
