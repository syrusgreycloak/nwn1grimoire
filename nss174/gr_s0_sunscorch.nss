//*:**************************************************************************
//*:*  GR_S0_SUNSCORCH.NSS
//*:**************************************************************************
//*:* Sunscorch (sg_s0_sunscorch.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: September 29, 2004
//*:* 2E Spells & Magic (p. 163)
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

    int     iDieType          = 6;
    int     iNumDice          = 1;
    int     iBonus            = spInfo.iCasterLevel;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic);
    int     iDurType          = DUR_TYPE_ROUNDS;

    if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD || GRGetIsLightSensitive(spInfo.oTarget)) {
        iBonus *= 2;
    }

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = DAMAGE_TYPE_FIRE; //= GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
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
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_NEGATES, oCaster, SAVING_THROW_TYPE_FIRE);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_NEGATES, oCaster);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eImpVis  = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_FIRE);
    effect eDamage  = EffectDamage(iDamage, DAMAGE_TYPE_FIRE);
    effect eBlind   = EffectBlindness();
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDurLink = EffectLinkEffects(eBlind, eDur);
    effect eSmoke   = EffectVisualEffect(VFX_FNF_SMOKE_PUFF);

    if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsDay() && GetIsAreaAboveGround(GetArea(oCaster)) && !GetIsAreaInterior(GetArea(oCaster))) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_SUNSCORCH));
        if(GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_CONSTRUCT) {
            if(GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster)) {
                GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpVis, GRGetMissLocation(spInfo.oTarget));
            } else {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                    DelayCommand(0.2f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget));
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                    if(GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_UNDEAD) {
                        if(!GetHasEffect(EFFECT_TYPE_BLINDNESS, spInfo.oTarget)) {
                            DelayCommand(0.2f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDurLink, spInfo.oTarget, fDuration));
                        }
                    }
                }
            }
        }
    } else {
        FloatingTextStrRefOnCreature(16939284, oCaster, FALSE);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, oCaster);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
