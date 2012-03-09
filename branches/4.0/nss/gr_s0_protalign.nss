//*:**************************************************************************
//*:*  GR_S0_PROTALIGN.NSS
//*:**************************************************************************
//*:* Protection From Alignment  2003 Karl Nickels (Syrus Greycloak)
//*:* Master script for Protection from <alignment> spells
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: October 1, 2003
//*:**************************************************************************
//*:* Updated On: November 6, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_HOURS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
    //*:* float   fRange          = FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    if(spInfo.iSpellID==321){
       switch(GetAlignmentGoodEvil(oCaster)) {
           case ALIGNMENT_GOOD:
               spInfo.iSpellID = SPELL_PROTECTION_FROM_EVIL;
               break;
           case ALIGNMENT_EVIL:
               spInfo.iSpellID = SPELL_PROTECTION_FROM_GOOD;
               break;
           case ALIGNMENT_NEUTRAL:
               switch(GetAlignmentLawChaos(oCaster))
               {
                   case ALIGNMENT_LAWFUL:
                       spInfo.iSpellID = SPELL_PROTECTION_FROM_CHAOS;
                       break;
                   case ALIGNMENT_CHAOTIC:
                       spInfo.iSpellID = SPELL_PROTECTION_FROM_LAW;
                       break;
                   case ALIGNMENT_NEUTRAL:
                       spInfo.iSpellID = SPELL_PROTECTION_FROM_EVIL;
                       break;
               }
               break;
       }
    }

    int iImpVisualEffect;
    int iVersusAlign;

    switch(spInfo.iSpellID) {
        case SPELL_PROTECTION_FROM_EVIL:
            /*** NWN1 SINGLE ***/ iImpVisualEffect = VFX_IMP_GOOD_HELP;
            iVersusAlign = ALIGNMENT_EVIL;
            break;
        case SPELL_PROTECTION_FROM_GOOD:
            /*** NWN1 SINGLE ***/ iImpVisualEffect = VFX_IMP_EVIL_HELP;
            iVersusAlign = ALIGNMENT_GOOD;
            break;
        case SPELL_PROTECTION_FROM_LAW:
            /*** NWN1 SINGLE ***/ iImpVisualEffect = VFX_IMP_EVIL_HELP;
            iVersusAlign = ALIGNMENT_LAWFUL;
            break;
        case SPELL_PROTECTION_FROM_CHAOS:
            /*** NWN1 SINGLE ***/ iImpVisualEffect = VFX_IMP_GOOD_HELP;
            iVersusAlign = ALIGNMENT_CHAOTIC;
            break;
    }

    //*** NWN2 SINGLE ***/ iImpVisualEffect = VFX_DUR_SPELL_PROT_ALIGN;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration     = ApplyMetamagicDurationMods(fDuration);
        iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);

        RemovePermanencySpells(spInfo.oTarget);
    /*** END NWN2 SPECIFIC ***/
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
    effect eVis     = EffectVisualEffect(iImpVisualEffect);
    effect eLink    = GREffectProtectionFromAlignment(iVersusAlign);
    //*** NWN2 SINGLE ***/ eLink = EffectLinkEffects(eLink, eVis);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster)));

    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);

    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
        GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
    } else if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
            GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
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
