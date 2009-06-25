//*:**************************************************************************
//*:*  GR_S0_BLKLIGHTA.NSS
//*:**************************************************************************
//*:*
//*:* Blacklight: On Enter
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 16, 2003
//*:**************************************************************************
//*:* Updated On: October 25, 2007
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
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    spInfo.oTarget         = GetEnteringObject();
    spInfo.iDC             = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eInvis       = EffectInvisibility(INVISIBILITY_TYPE_DARKNESS);
    effect eAntiLight   = EffectVisualEffect(VFX_DUR_ANTI_LIGHT_10);
    effect eSee         = EffectUltravision();
    effect eDark        = EffectDarkness();
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink        = EffectLinkEffects(eDark, eDur);

    effect eLink2       = EffectLinkEffects(eInvis, eAntiLight);
    eLink2 = EffectLinkEffects(eLink2, eSee);
    eLink2 = EffectLinkEffects(eLink2, eLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetHasEffect(EFFECT_TYPE_DARKNESS, spInfo.oTarget) == TRUE) {
        return;
    }

    if(GetIsObjectValid(spInfo.oTarget) && spInfo.oTarget!=oCaster) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_GR_BLACKLIGHT));
        } else {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_GR_BLACKLIGHT, FALSE));
        }
        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
    } else if (spInfo.oTarget==oCaster) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_GR_BLACKLIGHT, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink2, spInfo.oTarget);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
