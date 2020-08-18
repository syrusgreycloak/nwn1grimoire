//*:**************************************************************************
//*:*  GR_S0_DEADLAHAR.NSS
//*:**************************************************************************
//*:* Deadly Lahar
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 16, 2008
//*:* Complete Mage (p. 101)
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
//*:* Supporting functions
//*:**************************************************************************
void DoStickyFireDamage(object oTarget, struct SpellStruct spInfo, int iRoundsRemaining, int iVisualType) {

    spInfo.iDmgDieType  = 5;
    int     iDamage     = 0;
    int     iSecDamage  = 0;
    int     iEnergyType = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, spInfo.oCaster));

    iDamage = GRGetSpellDamageAmount(spInfo);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDamage  = EffectDamage(iDamage, iEnergyType);
    if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
    effect eLink    = EffectLinkEffects(eVis, eDamage);

    SignalEvent(oTarget, EventSpellCastAt(spInfo.oCaster, SPELL_GR_DEADLY_LAHAR));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget);
    iRoundsRemaining--;
    if(iRoundsRemaining==0) {
        DelayCommand(GRGetDuration(1), DoStickyFireDamage(oTarget, spInfo, iRoundsRemaining, iVisualType));
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

    int     iDieType          = 0;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 3;
    int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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
    //*** NWN2 SINGLE ***/ float fMaxDelay = 0.0f;
    float   fRange          = FeetToMeters(60.0);

    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iVisualType;
    /*** NWN1 SINGLE ***/ iVisualType = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);
    /*** NWN2 SPECIFIC ***
        iVisualType = GRGetEnergyVisualType(VFX_HIT_SPELL_FIRE, iEnergyType);
        int iConeType = GRGetEnergyConeType(VFX_DUR_CONE_FIRE, iEnergyType);
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) {
        fDuration *= 2;
        iDurAmount *= 2;
    }
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
    effect eDamage;
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eSlow    = EffectSlow();
    //*** NWN2 SINGLE ***/ effect eCone = EffectVisualEffect(iConeType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
            fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20.0;
            //*** NWN2 SINGLE ***/ if(fDelay>fMaxDelay) fMaxDelay = fDelay;
            iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                    iDamage = iSecDamage;
                }
            }
            if(iDamage>0) {
                eDamage = EffectDamage(iDamage, iEnergyType);
                if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget));
                if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                }
                if(!GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster)) {
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, spInfo.oTarget, fDuration));
                    DelayCommand(fDelay+GRGetDuration(1), DoStickyFireDamage(spInfo.oTarget, spInfo, iDurAmount, iVisualType));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }

    //*** NWN2 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCone, OBJECT_SELF, fMaxDelay);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
