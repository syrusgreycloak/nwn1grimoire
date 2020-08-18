//*:**************************************************************************
//*:*  GR_S0_ACIDSPLSH.NSS
//*:**************************************************************************
//*:*
//*:* Acid Splash
//*:* 3.5 Player's Handbook (p. 196)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 28, 2003
//*:**************************************************************************
//*:* Updated On: November 26, 2007
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

    int     iDieType          = 3;
    int     iNumDice          = 1;
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = GetRandomDelay(0.4, 1.1);
    float   fRange          = FeetToMeters(5.0);

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_ACID_S, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iAttackResult   = TouchAttackRanged(spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SAVING_THROW_NONE, oCaster, iSaveType, fDelay) * iAttackResult;
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SAVING_THROW_NONE, oCaster) * iAttackResult;
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:* Lesser Shadow Conjuration
    if(spInfo.iSpellSchool==SPELL_SCHOOL_ILLUSION) {
        if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
            iDamage = FloatToInt(iDamage*0.2f);
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis = EffectVisualEffect(iVisualType);
    effect eDam = EffectDamage(iDamage, iEnergyType);
    effect eLink= EffectLinkEffects(eVis, eDam);
    effect eSave= EffectVisualEffect(VFX_IMP_REFLEX_SAVING_THROW_USE);

    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(iAttackResult>0) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }

            if(GRGetIsUnderwater(oCaster) && iEnergyType==DAMAGE_TYPE_ELECTRICAL) {
                object oFirstTarget = spInfo.oTarget;
                spInfo.lTarget = GetLocation(oFirstTarget);
                spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
                while(GetIsObjectValid(spInfo.oTarget)) {
                    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, TRUE) && spInfo.oTarget!=oFirstTarget) {
                        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_ACID_SPLASH));
                        spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                        iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
                        iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, iSaveType);
                        if(iDamage>0) {
                            eDam = EffectDamage(iDamage, iEnergyType);
                            eLink = EffectLinkEffects(eVis, eDam);
                            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                    iDamage = iSecDamage;
                                }
                            }
                            if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                        } else {
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSave, spInfo.oTarget));
                        }
                    }
                    spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
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
