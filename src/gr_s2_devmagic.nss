//*:**************************************************************************
//*:*  GR_S2_DEVMAGIC.NSS
//*:**************************************************************************
//*:* Devour Magic
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 23, 2008
//*:* Complete Arcane (p. 133)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"   - INCLUDED IN GR_IN_BREACH
#include "GR_IN_SPELLHOOK"
#include "GR_IN_BREACH"

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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = 0;
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

    float   fDuration       = GRGetDuration(1, DUR_TYPE_TURNS);
    //*:* float   fRange          = FeetToMeters(20.0);

    int     iCheckLevel     = 20;
    int     iVisual         = VFX_IMP_BREACH;
    int     iImpact         = VFX_FNF_DISPEL;

    iBonus = (spInfo.iCasterLevel>iCheckLevel ? iCheckLevel : spInfo.iCasterLevel);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eVis         = EffectVisualEffect(iVisual);
    effect eImpact      = EffectVisualEffect(iImpact);
    effect eTempHP;
    effect eCasterVis   = EffectVisualEffect(VFX_IMP_HOLY_AID);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_I_DEVOUR_MAGIC));
    if(TouchAttackMelee(spInfo.oTarget)) {
        int iTempHP = GRDevourMagic(spInfo.oTarget, iBonus, eVis, eImpact) * 5;
        if(iTempHP>0) {
            SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_I_DEVOUR_MAGIC, FALSE));
            eTempHP = EffectTemporaryHitpoints(iTempHP);
            if(GetHasEffect(EFFECT_TYPE_TEMPORARY_HITPOINTS, oCaster)) {
                GRRemoveEffects(EFFECT_TYPE_TEMPORARY_HITPOINTS, oCaster);
            }
            eLink = EffectLinkEffects(eDur, eTempHP);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eCasterVis, oCaster);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);
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
