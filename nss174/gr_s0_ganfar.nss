//*:**************************************************************************
//*:*  GR_S0_GANFAR.NSS
//*:**************************************************************************
//*:*
//*:* Ganest's Farstrike
//*:* Sword & Sorcery:Relics & Rituals I
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 10, 2003
//*:**************************************************************************
//*:* Updated On: February 25, 2008
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

    int     iDieType          = 4;
    int     iNumDice          = MinInt(10, spInfo.iCasterLevel);
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);
    int     iBeamType       = GRGetEnergyBeamType(iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    float   fDelay;

    if(spInfo.iSpellID==SPELL_GR_LSE_GANESTS_FARSTRIKE) {
        iEnergyType = DAMAGE_TYPE_MAGICAL;
        iVisualType = VFX_IMP_FLAME_M;
            /*** NWN1 SPECIFIC ***/
        iBeamType = VFX_BEAM_FIRE;
            /*** END NWN1 SPECIFIC ***/
        iSaveType = SAVING_THROW_TYPE_SPELL;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eVis     = EffectBeam(iBeamType, oCaster, BODY_NODE_HAND, GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster));
    effect eImp     = EffectVisualEffect(iVisualType);
    effect eDamage  = EffectDamage(iDamage, iEnergyType);
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_GANEST_FARSTRIKE));
    if(GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster)) {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, 1.5f);
    } else {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, 1.5f);
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(spInfo.iSpellID==SPELL_GR_LSE_GANESTS_FARSTRIKE && GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                iDamage = FloatToInt(iDamage*0.20); // will disbelief - spell 20% as strong as real thing
            }
            if(iDamage>0) {
                eDamage = EffectDamage(iDamage, iEnergyType);
                if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                eLink = EffectLinkEffects(eImp, eDamage);
                fDelay = GetDistanceBetween(oCaster,spInfo.oTarget)/20.0;
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
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
