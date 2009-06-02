//*:**************************************************************************
//*:*  GR_S0_ACIDSPIT.NSS
//*:**************************************************************************
//*:*
//*:* Acid Spittle
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: 2005
//*:**************************************************************************
//*:* Updated On: February 21, 2007
//*:* Bug fixed: Splash damage was always acid instead of converted energy type
//*:**************************************************************************
//*:* Updated On: February 21, 2008
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

    int     iDieType          = 6;
    int     iNumDice          = 1;
    int     iBonus            = MinInt(20, spInfo.iCasterLevel);
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

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    float   fDelay          = GetRandomDelay(0.4, 1.1);
    float   fRange          = FeetToMeters(5.0);

    location lSpCenter      = GetLocation(spInfo.oTarget);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_ACID_S, iEnergyType);
    int     iMirvType       = GRGetEnergyMirvType(iEnergyType);
    object  oOrigTarget     = spInfo.oTarget;
    int     iAttackResult   = GRTouchAttackRanged(spInfo.oTarget);

    int     iSplashDmg      = MinInt(10, 1 + iBonus/2);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay)*iAttackResult;
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay)*iAttackResult;
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(iMirvType);
    effect eImp     = EffectVisualEffect(iVisualType);
    effect eDamage  = EffectDamage(iDamage, iEnergyType);
    effect eMain    = EffectLinkEffects(eDamage, eImp);
    effect eSpDmg;
    effect eSplash;
    effect eSave    = EffectVisualEffect(VFX_IMP_REFLEX_SAVING_THROW_USE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_ACID_SPITTLE));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,spInfo.oTarget);
    if(iDamage>0) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eMain, spInfo.oTarget));
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }
        }

        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, lSpCenter, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        while (GetIsObjectValid(spInfo.oTarget)) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, TRUE) && spInfo.oTarget!=oOrigTarget) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_GR_ACID_SPITTLE));
                fDelay = GetDistanceBetweenLocations(lSpCenter, GetLocation(spInfo.oTarget))/5;
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    iSplashDmg = GRGetReflexAdjustedDamage(iSplashDmg, spInfo.oTarget, spInfo.iDC, iSaveType);
                    eSpDmg = EffectDamage(iSplashDmg, iEnergyType);
                    eSplash = EffectLinkEffects(eSpDmg,eImp);
                    if(iSplashDmg > 0) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT,eSplash,spInfo.oTarget));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                    } else {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSave, spInfo.oTarget));
                    }
                }
            }
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, lSpCenter, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        }
    } else {
        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSave, spInfo.oTarget));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
