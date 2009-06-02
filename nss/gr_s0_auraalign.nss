//*:**************************************************************************
//*:*  GR_S0_AURAALIGN.NSS
//*:**************************************************************************
//*:*
//*:* Master script for
//*:* Cloak of Chaos
//*:* Holy Aura
//*:* Shield of Law
//*:* Unholy Aura
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: October 1, 2003
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
#include "GR_IN_ITEMPROP"

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(20.0);

    int     iAlign               = spInfo.iSpellID;
    int     iVersusAlign;
    int     iBenefitAlign;
    int     iCreaturesAffected   = 0;
    int     iOnHitCastSpell      = IP_CONST_ONHIT_CASTSPELL_HOLY_AURA_HIT;
    object  oPCHide;
    int     iImpVisualEffect;
    int     iDurVisualEffect1;
    int     iDurVisualEffect2;
    int     iCreaturesTotal     = spInfo.iCasterLevel;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eAC      = EffectACIncrease(4, AC_DEFLECTION_BONUS);
    effect eSave    = EffectSavingThrowIncrease(SAVING_THROW_ALL, 4);
    effect eImmune1 = EffectImmunity(IMMUNITY_TYPE_CHARM);
    effect eImmune2 = EffectImmunity(IMMUNITY_TYPE_CONFUSED);
    effect eImmune3 = EffectImmunity(IMMUNITY_TYPE_DOMINATE);
    effect eImmune4 = EffectImmunity(IMMUNITY_TYPE_FEAR);
    effect eImmune5 = EffectImmunity(IMMUNITY_TYPE_SLEEP);
    effect eImmune6 = EffectImmunity(IMMUNITY_TYPE_STUN);
    effect eImmune7 = EffectImmunity(IMMUNITY_TYPE_DAZED);
    effect eImmuneLink = EffectLinkEffects(eImmune1, eImmune2);
    eImmuneLink     = EffectLinkEffects(eImmuneLink, eImmune3);
    eImmuneLink     = EffectLinkEffects(eImmuneLink, eImmune4);
    eImmuneLink     = EffectLinkEffects(eImmuneLink, eImmune5);
    eImmuneLink     = EffectLinkEffects(eImmuneLink, eImmune6);
    eImmuneLink     = EffectLinkEffects(eImmuneLink, eImmune7);
    effect eSR      = EffectSpellResistanceIncrease(25); //Check if this is a bonus or a setting.
    effect eImp;
    effect eDur;
    effect eDur2;

    if(iAlign==323) {
       switch(GetAlignmentGoodEvil(oCaster)) {
           case ALIGNMENT_GOOD:
               iAlign=SPELL_HOLY_AURA;
               break;
           case ALIGNMENT_EVIL:
               iAlign=SPELL_UNHOLY_AURA;
               break;
           case ALIGNMENT_NEUTRAL:
               switch(GetAlignmentLawChaos(oCaster)) {
                   case ALIGNMENT_LAWFUL:
                       iAlign=SPELL_SHIELD_OF_LAW;
                       break;
                   case ALIGNMENT_CHAOTIC:
                       iAlign=SPELL_CLOAK_OF_CHAOS;
                       break;
                   case ALIGNMENT_NEUTRAL:
                       iAlign=SPELL_HOLY_AURA;
                       break;
               }
               break;
       }
    }

    switch(iAlign) {
        case SPELL_HOLY_AURA:
            /*** NWN1 SPECIFIC ***/
                iImpVisualEffect    = VFX_IMP_GOOD_HELP;
                iDurVisualEffect1   = VFX_DUR_PROTECTION_GOOD_MAJOR;
                iDurVisualEffect2   = VFX_DUR_CESSATE_POSITIVE;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iImpVisualEffect    = VFX_NONE;
                iDurVisualEffect1   = VFX_DUR_SPELL_GOOD_AURA;
            /*** END NWN2 SPECIFIC ***/
            eAC=VersusAlignmentEffect(eAC, ALIGNMENT_ALL, ALIGNMENT_EVIL);
            eSave=VersusAlignmentEffect(eSave, ALIGNMENT_ALL, ALIGNMENT_EVIL);
            eImmuneLink=VersusAlignmentEffect(eImmuneLink, ALIGNMENT_ALL, ALIGNMENT_EVIL);
            iVersusAlign        = ALIGNMENT_EVIL;
            iBenefitAlign       = ALIGNMENT_GOOD;
            iOnHitCastSpell     = IP_CONST_ONHIT_CASTSPELL_HOLY_AURA_HIT;
            break;
        case SPELL_UNHOLY_AURA:
            /*** NWN1 SPECIFIC ***/
                iImpVisualEffect    = VFX_IMP_EVIL_HELP;
                iDurVisualEffect1   = VFX_DUR_PROTECTION_EVIL_MAJOR;
                iDurVisualEffect2   = VFX_DUR_CESSATE_NEGATIVE;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iImpVisualEffect    = VFX_NONE;
                iDurVisualEffect1   = VFX_DUR_SPELL_EVIL_AURA;
            /*** END NWN2 SPECIFIC ***/
            eAC=VersusAlignmentEffect(eAC, ALIGNMENT_ALL, ALIGNMENT_GOOD);
            eSave=VersusAlignmentEffect(eSave, ALIGNMENT_ALL, ALIGNMENT_GOOD);
            eImmuneLink=VersusAlignmentEffect(eImmuneLink, ALIGNMENT_ALL, ALIGNMENT_GOOD);
            iVersusAlign        = ALIGNMENT_GOOD;
            iBenefitAlign       = ALIGNMENT_EVIL;
            iOnHitCastSpell     = IP_CONST_ONHIT_CASTSPELL_UNHOLY_AURA_HIT;
            break;
        case SPELL_CLOAK_OF_CHAOS:
            /*** NWN1 SPECIFIC ***/
                iImpVisualEffect    = VFX_IMP_EVIL_HELP;
                iDurVisualEffect1   = VFX_DUR_PROTECTION_EVIL_MAJOR;
                iDurVisualEffect2   = VFX_DUR_CESSATE_NEGATIVE;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iImpVisualEffect    = VFX_NONE;
                iDurVisualEffect1   = VFX_DUR_SPELL_EVIL_AURA;
            /*** END NWN2 SPECIFIC ***/
            eAC=VersusAlignmentEffect(eAC, ALIGNMENT_LAWFUL, ALIGNMENT_ALL);
            eSave=VersusAlignmentEffect(eSave, ALIGNMENT_LAWFUL, ALIGNMENT_ALL);
            eImmuneLink=VersusAlignmentEffect(eImmuneLink, ALIGNMENT_LAWFUL, ALIGNMENT_ALL);
            iVersusAlign        = ALIGNMENT_LAWFUL;
            iBenefitAlign       = ALIGNMENT_CHAOTIC;
            iOnHitCastSpell     = IP_CONST_ONHIT_CASTSPELL_CLOAK_CHAOS_HIT;
            break;
        case SPELL_SHIELD_OF_LAW:
            /*** NWN1 SPECIFIC ***/
                iImpVisualEffect    = VFX_IMP_GOOD_HELP;
                iDurVisualEffect1   = VFX_DUR_PROTECTION_GOOD_MAJOR;
                iDurVisualEffect2   = VFX_DUR_CESSATE_POSITIVE;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iImpVisualEffect    = VFX_NONE;
                iDurVisualEffect1   = VFX_DUR_SPELL_GOOD_AURA;
            /*** END NWN2 SPECIFIC ***/
            eAC=VersusAlignmentEffect(eAC, ALIGNMENT_CHAOTIC, ALIGNMENT_ALL);
            eSave=VersusAlignmentEffect(eSave, ALIGNMENT_CHAOTIC, ALIGNMENT_ALL);
            eImmuneLink=VersusAlignmentEffect(eImmuneLink, ALIGNMENT_CHAOTIC, ALIGNMENT_ALL);
            iVersusAlign        = ALIGNMENT_CHAOTIC;
            iBenefitAlign       = ALIGNMENT_LAWFUL;
            iOnHitCastSpell     = IP_CONST_ONHIT_CASTSPELL_SHIELD_LAW_HIT;
            break;
    }

    /*** NWN1 SINGLE ***/ eImp    = EffectVisualEffect(iImpVisualEffect);
    eDur    = EffectVisualEffect(iDurVisualEffect1);
    /*** NWN1 SINGLE ***/ eDur2   = EffectVisualEffect(iDurVisualEffect2);

    itemproperty ipOnHitCastSpell = ItemPropertyOnHitCastSpell(iOnHitCastSpell, spInfo.iCasterLevel);

    //Link effects
    effect eLink = EffectLinkEffects(eImmuneLink, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eSR);
    eLink = EffectLinkEffects(eLink, eDur);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur2);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, oCaster);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);

    while(GetIsObjectValid(spInfo.oTarget) && (iCreaturesAffected<iCreaturesTotal)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
            iCreaturesAffected++;
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, iAlign, FALSE));
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);

            //*:**********************************************
            //*:*  This section implements adding a temp item
            //*:* property to activate fourth spell property
            //*:**********************************************
            oPCHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, spInfo.oTarget);
            if(!GetIsObjectValid(oPCHide)) {
                oPCHide = CreateItemOnObject("x2_it_emptyskin", spInfo.oTarget);
            }
            GRIPSafeAddItemProperty(oPCHide, ipOnHitCastSpell, fDuration);
            AssignCommand(spInfo.oTarget, ActionEquipItem(oPCHide, INVENTORY_SLOT_CARMOUR));
            //*:**********************************************
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
