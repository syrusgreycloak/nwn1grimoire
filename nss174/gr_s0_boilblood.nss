//*:**************************************************************************
//*:*  GR_S0_BOILBLOOD.NSS
//*:**************************************************************************
//*:* Boiling Blood
//*:* Created By: Karl Nickels (Syrus Greycloak)  
//*:* Created On: April 16, 2008
//*:* Complete Mage (p. 97)
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

#include "GR_IN_DEBUG"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void DoBoilingBlood(object oTarget, struct SpellStruct spInfo, int iRemainingRounds, int iVisualType) {
    AutoDebugString("DoBoilingBlood");
    AutoDebugString("Target: " + GetName(oTarget));
    AutoDebugString("Remaining Rounds: " + IntToString(iRemainingRounds));

    int     iDamage         = 0;
    int     iSecDamage      = 0;
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, spInfo.oCaster));

    GRSetSpellInfo(spInfo, spInfo.oCaster);
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, spInfo.oCaster);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, spInfo.oCaster);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDamage  = EffectDamage(iDamage, iEnergyType);
    effect eLink    = EffectLinkEffects(eVis, eDamage);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(spInfo.oCaster, SPELL_GR_BOILING_BLOOD));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
    iRemainingRounds--;
    if(iRemainingRounds>0) {
        DelayCommand(GRGetDuration(1), DoBoilingBlood(spInfo.oTarget, spInfo, iRemainingRounds, iVisualType));
    }

    GRClearSpellInfo(spInfo.iSpellID, spInfo.oCaster);
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
    int     iDurAmount        = MinInt(7, 1+spInfo.iCasterLevel/3);
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iVisualType     = GRGetEnergyVisualType(VFX_COM_HIT_FIRE, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) iDurAmount *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDamage  = EffectDamage(iDamage, iEnergyType);
    effect eLink    = EffectLinkEffects(eVis, eDamage);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    AutoDebugString("Applying Boiling Blood effects");
    AutoDebugString("Target: " + GetName(spInfo.oTarget));
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_BOILING_BLOOD));
    if(GRGetIsLiving(spInfo.oTarget) && !GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_CRITICAL_HIT)) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, iSaveType)) {
                AutoDebugString("Saving throw success - duration set to 1");
                iDurAmount = 1;
            }
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                AutoDebugString("Incendiary Slime explosion");
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }
            iDurAmount--;
            if(iDurAmount>0) {
                AutoDebugString("Duration remaining: " + IntToString(iDurAmount));
                DelayCommand(GRGetDuration(1), DoBoilingBlood(spInfo.oTarget, spInfo, iDurAmount, iVisualType));
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
