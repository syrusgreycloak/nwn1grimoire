//*:**************************************************************************
//*:*  GR_S0_LVL4ORBS.NSS
//*:**************************************************************************
//*:* Orb of Acid (SG_S0_AcidOrb.nss)  2003 Karl Nickels (Syrus Greycloak)
//*:* Orb of Cold
//*:* Orb of Electricity
//*:* Orb of Fire
//*:* Orb of Sound
//*:* Spell Compendium (p. 150-151)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 15, 2003
//*:**************************************************************************
//*:* Updated On: February 27, 2008
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

    int     iDieType          = (spInfo.iSpellID!=SPELL_GR_SONIC_ORB ? 6 : 4);
    int     iNumDice          = MinInt(15, spInfo.iCasterLevel);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;
    float   fDurOverride      = 9.0f;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType, fDurOverride);

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
    float   fRange          = FeetToMeters(20.0);

    int     iVisualType;
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iSave;
    int     iAttackResult   = GRTouchAttackRanged(spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay)*iAttackResult;
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster)*iAttackResult;
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eSpecial;

    switch(spInfo.iSpellID) {
        case SPELL_GR_ACID_ORB:
            iVisualType = VFX_IMP_ACID_S;
            eSpecial = EffectLinkEffects(EffectDazed(), eDur);
            break;
        case SPELL_GR_COLD_ORB:
            iVisualType = VFX_IMP_FROST_S;
            eSpecial = EffectLinkEffects(EffectBlindness(), eDur);
            break;
        case SPELL_GR_ELECTRIC_ORB:
            iVisualType = VFX_IMP_LIGHTNING_S;
            eSpecial = EffectLinkEffects(EffectEntangle(), eDur);
            break;
        case SPELL_GR_FIRE_ORB:
            iVisualType = VFX_IMP_FLAME_S;
            eSpecial = EffectLinkEffects(EffectDazed(), eDur);
            break;
        case SPELL_GR_SONIC_ORB:
            iVisualType = VFX_IMP_SONIC;
            eSpecial = EffectLinkEffects(EffectDeaf(), eDur);
            break;
    }

    effect eImp     = EffectVisualEffect(GRGetEnergyVisualType(iVisualType, iEnergyType));
    effect eDamage  = EffectDamage(iDamage, iEnergyType);
    effect eLink    = EffectLinkEffects(eImp, eDamage);

    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    if(iAttackResult>0) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, iSaveType)) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSpecial, spInfo.oTarget, fDuration);
            }
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);


            if(GRGetIsUnderwater(oCaster) && iEnergyType==DAMAGE_TYPE_ELECTRICAL) {
                object oFirstTarget = spInfo.oTarget;
                effect eVis = EffectVisualEffect(GRGetEnergyExplodeType(iEnergyType));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, GetLocation(oFirstTarget));
                while(GetIsObjectValid(spInfo.oTarget)) {
                    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster) && spInfo.oTarget!=oFirstTarget) {
                        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                            spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                            fDelay = GetDistanceBetween(oFirstTarget, spInfo.oTarget)/20.0;
                            iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                    iDamage = iSecDamage;
                                }
                            }

                            if(iDamage>0) {
                                eDamage = EffectDamage(iDamage, iEnergyType);
                                eLink = EffectLinkEffects(eImp, eDamage);
                                if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                                if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                                }
                            }
                        }
                    }
                    spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, GetLocation(oFirstTarget));
                }
            }
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
