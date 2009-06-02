//*:**************************************************************************
//*:*  GR_S0_CIRCALIGN.NSS
//*:**************************************************************************
//*:*
//*:* Magic Circle against <alignment>
//*:* 3.5 Player's Handbook (p. 249-250)
//*:*
//*:* Combines all magic circle scripts into one master script plus AOEs
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: October 1, 2003
//*:**************************************************************************
//*:* Updated On: November 2, 2007
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
    int     iAlign          = spInfo.iSpellID;

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel*10;
    int     iDurType          = DUR_TYPE_TURNS;

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

    float   fDelay;
    int     iImpVisualEffect;
    int     iAOEType;
    string  sAOEType;
    int     iAlignAgainst;
    int     iAlignFor;


    if(iAlign==322){
       switch(GetAlignmentGoodEvil(oCaster)) {
           case ALIGNMENT_GOOD:
               iAlign = SPELL_MAGIC_CIRCLE_AGAINST_EVIL;
               break;
           case ALIGNMENT_EVIL:
               iAlign = SPELL_MAGIC_CIRCLE_AGAINST_GOOD;
               break;
           case ALIGNMENT_NEUTRAL:
               switch(GetAlignmentLawChaos(oCaster)) {
                   case ALIGNMENT_LAWFUL:
                       iAlign = SPELL_MAGIC_CIRCLE_AGAINST_CHAOS;
                       break;
                   case ALIGNMENT_CHAOTIC:
                       iAlign = SPELL_MAGIC_CIRCLE_AGAINST_LAW;
                       break;
                   case ALIGNMENT_NEUTRAL:
                       iAlign = SPELL_MAGIC_CIRCLE_AGAINST_EVIL;
                       break;
               }
               break;
       }
    }

    switch(iAlign) {
        case SPELL_MAGIC_CIRCLE_AGAINST_EVIL:
            iImpVisualEffect = VFX_IMP_GOOD_HELP;
            iAOEType = AOE_MOB_CIRCGOOD;
            sAOEType = AOE_TYPE_CIRCGOOD;
            iAlignAgainst = ALIGNMENT_EVIL;
            iAlignFor = ALIGNMENT_GOOD;
            break;
        case SPELL_MAGIC_CIRCLE_AGAINST_GOOD:
            iImpVisualEffect = VFX_IMP_EVIL_HELP;
            iAOEType = AOE_MOB_CIRCEVIL;
            sAOEType = AOE_TYPE_CIRCEVIL;
            iAlignAgainst = ALIGNMENT_GOOD;
            iAlignFor = ALIGNMENT_EVIL;
            break;
        case SPELL_MAGIC_CIRCLE_AGAINST_LAW:
            iImpVisualEffect = VFX_IMP_EVIL_HELP;
            iAOEType = AOE_MOB_CIRCCHAOS;
            sAOEType = AOE_TYPE_CIRCCHAOS;
            iAlignAgainst = ALIGNMENT_LAWFUL;
            iAlignFor = ALIGNMENT_CHAOTIC;
            break;
        case SPELL_MAGIC_CIRCLE_AGAINST_CHAOS:
            iImpVisualEffect = VFX_IMP_GOOD_HELP;
            iAOEType = AOE_MOB_CIRCLAW;
            sAOEType = AOE_TYPE_CIRCLAW;
            iAlignAgainst = ALIGNMENT_CHAOTIC;
            iAlignFor = ALIGNMENT_LAWFUL;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
            switch(spInfo.iSpellID) {
                case SPELL_MAGIC_CIRCLE_AGAINST_EVIL:
                    iAOEType = AOE_MOB_CIRCGOOD_WIDE;
                    sAOEType = AOE_TYPE_CIRCGOOD_WIDE;
                    break;
                case SPELL_MAGIC_CIRCLE_AGAINST_GOOD:
                    iAOEType = AOE_MOB_CIRCEVIL_WIDE;
                    sAOEType = AOE_TYPE_CIRCEVIL_WIDE;
                    break;
                case SPELL_MAGIC_CIRCLE_AGAINST_LAW:
                    iAOEType = AOE_MOB_CIRCCHAOS_WIDE;
                    sAOEType = AOE_TYPE_CIRCCHAOS_WIDE;
                    break;
                case SPELL_MAGIC_CIRCLE_AGAINST_CHAOS:
                    iAOEType = AOE_MOB_CIRCLAW_WIDE;
                    sAOEType = AOE_TYPE_CIRCLAW_WIDE;
                    break;
            }
        }
    /*** END NWN1 SPECIFIC ***/

    //*:* iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eAOE     = GREffectAreaOfEffect(iAOEType, "", "", "", sAOEType);
    effect eVis     = EffectVisualEffect(iImpVisualEffect);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, iAlign, FALSE));
    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);

    /*** NWN1 SINGLE ***/ object oAOE = GRGetAOEOnObject(spInfo.oTarget, sAOEType, oCaster);
    //*** NWN2 SINGLE ***/ object oAOE = GetObjectByTag(sAOEType);
    GRSetAOESpellId(iAlign, oAOE);
    SetLocalInt(oAOE, "GR_L_PROT_ALIGN", iAlignAgainst);
    SetLocalInt(oAOE, "GR_L_ALIGN_FOR", iAlignFor);
    GRSetSpellInfo(spInfo, oAOE);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
