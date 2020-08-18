//*:**************************************************************************
//*:*  GR_S0_LOVTORM.NSS
//*:**************************************************************************
//*:* Loviatar's Torments (sg_s0_lovtorm.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 25, 2003
//*:*
//*:**************************************************************************
//*:* Updated On: February 26, 2008
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

    int     iDieType          = 0;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = MinInt(10, spInfo.iCasterLevel);
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
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_NEGATES, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, FORTITUDE_NEGATES, oCaster);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eDamage  = EffectDamage(iDamage, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY);
    effect eVis     = EffectVisualEffect(VFX_FNF_LOS_EVIL_20);
    effect eImp     = EffectVisualEffect(VFX_IMP_HEAD_EVIL);
    effect eLink    = EffectLinkEffects(eDamage, eImp);
    effect eAOE     = GREffectAreaOfEffect(AOE_MOB_LOV_TORM);
    effect eAttDec  = EffectAttackDecrease(2);
    effect eSaveDec = EffectSavingThrowDecrease(SAVING_THROW_ALL,2);
    effect eSkillDec= EffectSkillDecrease(SKILL_ALL_SKILLS, 2);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eTmpLink = EffectLinkEffects(eAttDec, eSaveDec);
    eTmpLink = EffectLinkEffects(eTmpLink, eSkillDec);

    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_LOV_TORMENTS));
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(iDamage>0) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTmpLink, spInfo.oTarget, fDuration);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);

            object oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_LOV_TORM, oCaster);
            GRSetAOESpellId(spInfo.iSpellID, oAOE);
            GRSetSpellInfo(spInfo, oAOE);
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
