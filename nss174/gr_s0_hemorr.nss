//*:**************************************************************************
//*:*  GR_S0_HEMORR.NSS
//*:**************************************************************************
//*:* Hemorrhage (sg_s0_Hemorr.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 30, 2004
//*:* WotC Website
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = 3;
    int     iNumDice          = 1;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = MinInt(5, MaxInt(1, spInfo.iCasterLevel/2));
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAttackResult       = TouchAttackMelee(spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, WILL_NEGATES, oCaster)*iAttackResult;
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, WILL_NEGATES, oCaster)*iAttackResult;
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eAOE     = GREffectAreaOfEffect(AOE_MOB_HEMORRHAGE);
    effect eDamage  = EffectDamage(iDamage);
    effect eDamVis  = EffectVisualEffect(VFX_COM_BLOOD_REG_RED);
    effect eDurVis  = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_HEMORRHAGE));
    if(iAttackResult>0) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget) && GRGetIsLiving(spInfo.oTarget)) {
            if(iDamage>0) {
                if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDurVis, spInfo.oTarget, fDuration);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);

                object oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_HEMORRHAGE, oCaster);
                GRSetAOESpellId(spInfo.iSpellID, oAOE);
                GRSetSpellInfo(spInfo, oAOE);
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
