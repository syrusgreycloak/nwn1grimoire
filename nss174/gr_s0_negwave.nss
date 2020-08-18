//*:**************************************************************************
//*:*  GR_S0_NEGWAVE.NSS
//*:**************************************************************************
//*:* Negative Energy Wave (sg_s0_negwave.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 30, 2003
//*:* Tome & Blood (p. 94)
//*:**************************************************************************
//*:* Updated On: February 28, 2008
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
    object  oCaster             = OBJECT_SELF;
    struct  SpellStruct spInfo  = GRGetSpellStruct(GetSpellId(), oCaster);

    spInfo.lTarget              = GetLocation(oCaster);

    int     iDieType            = 6;
    int     iNumDice            = MinInt(15, spInfo.iCasterLevel);
    int     iBonus              = 0;
    int     iDamage             = 0;
    //*:* int     iSecDamage          = 0;
    int     iDurAmount          = 10;
    int     iDurType            = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(50.0);

    int     iTurnResist;
    int     iCHAMod         = MaxInt(1, GetAbilityModifier(ABILITY_CHARISMA, oCaster));
    float   fDistBetween;
    int     iCount          = 1;
    int     iHDAffected     = spInfo.iCasterLevel*2;
    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    iTurnResist = GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic, iCHAMod);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eImp         = EffectVisualEffect(VFX_FNF_HOWL_ODD);
    effect eStunVis     = EffectVisualEffect(VFX_IMP_STUN);
    effect eStunDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eStun        = SupernaturalEffect(EffectStunned());
    effect eStunLink    = EffectLinkEffects(eStun, eStunDur);
    effect eTurnVis     = EffectVisualEffect(VFX_IMP_EVIL_HELP);
    effect eTurn        = EffectTurnResistanceIncrease(iTurnResist);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, oCaster);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
    while(GetIsObjectValid(spInfo.oTarget) && iHDAffected>0) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER) && GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
            GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget);

            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, (spInfo.iSpellID==SPELL_GR_NEG_ENERGY_WAVE_BOLSTER)));
            fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20.0;
            if(GetHitDice(spInfo.oTarget)<=iHDAffected) {
                switch(spInfo.iSpellID) {
                    case SPELL_GR_NEG_ENERGY_WAVE_REBUKE:
                        if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                            if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NEGATIVE)) {
                                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eStunVis, spInfo.oTarget);
                                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStunLink, spInfo.oTarget, fDuration);
                            }
                        }
                        break;
                    case SPELL_GR_NEG_ENERGY_WAVE_BOLSTER:
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eTurnVis, spInfo.oTarget);
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTurn, spInfo.oTarget, fDuration);
                        break;
                }
                iHDAffected -= GetHitDice(spInfo.oTarget);
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
