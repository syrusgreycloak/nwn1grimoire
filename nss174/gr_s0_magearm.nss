//*:**************************************************************************
//*:*  GR_S0_MAGEARM.NSS
//*:**************************************************************************
//*:* Mage Armor [NW_S0_MageArm.nss] Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 12, 2001
//*:* 3.5 Player's Handbook (p. 249)
//*:*
//*:* Deflecting Force (Su) (x2_s1_defforce) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: Aug 19, 2003
//*:* Prismatic Dragon Supernatural Ability
//*:*
//*:* Epic Mage Armor (X2_S2_EpMageArm) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Feb 07, 2003
//*:* Epic Level Handbook (p. 79)
//*:**************************************************************************
//*:* Mage Armor, Greater - Spell Compendium (p. 136)
//*:* Mage Armor, Mass - Spell Compendium (p. 136)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: July 16, 2007
//*:**************************************************************************
//*:* Updated On: November 2, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
#include "nwn2_inc_spells"
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
    int     iBonus;            //= (spInfo.iSpellID==SPELL_GR_GREATER_MAGE_ARMOR ? 6 : 4);
    switch(spInfo.iSpellID) {
        case SPELL_EPIC_MAGE_ARMOR:
            iBonus = 20;
            break;
        case SPELL_GR_GREATER_MAGE_ARMOR:
            iBonus = 6;
            break;
        case 774:       // Prismatic Dragon Deflecting Force ability
            iBonus = GetAbilityModifier(ABILITY_CHARISMA);
            break;
        default:
            iBonus = 4;
            break;
    }

    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = (spInfo.iSpellID==SPELL_EPIC_MAGE_ARMOR ? 24 : spInfo.iCasterLevel);
    int     iDurType          = (spInfo.iSpellID==774 ? DUR_TYPE_ROUNDS : DUR_TYPE_HOURS);

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
    float   fRange          = FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;
    int     iDurVisType     = (spInfo.iSpellID==SPELL_EPIC_MAGE_ARMOR ? VFX_DUR_SANCTUARY : VFX_DUR_CESSATE_POSITIVE);

    //*** NWN2 SINGLE ***/ if(spInfo.iSpellID!=774 && spInfo.iSpellID!=SPELL_EPIC_MAGE_ARMOR) iDurVisType = VFX_DUR_SPELL_MAGE_ARMOR;

    int     bMultiTarget    = (spInfo.iSpellID==SPELL_GR_MASS_MAGE_ARMOR);
    int     iNumTargets     = spInfo.iCasterLevel;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration     = ApplyMetamagicDurationMods(fDuration);
        iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
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
    /*** NWN1 SPECIFIC ***/
        effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
        effect eVis     = EffectVisualEffect(VFX_IMP_AC_BONUS);
    /*** END NWN1 SPECIFIC ***/
    effect eAC1     = EffectACIncrease(iBonus, AC_DEFLECTION_BONUS);
    effect eDur     = EffectVisualEffect(iDurVisType);

    effect eLink    = EffectLinkEffects(eAC1, eDur);
    if(spInfo.iSpellID==774) eLink = SupernaturalEffect(eLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, TRUE)) {
                if(spInfo.iSpellID!=SPELL_GR_GREATER_MAGE_ARMOR && GRGetHasSpellEffect(SPELL_GR_GREATER_MAGE_ARMOR, spInfo.oTarget)) {
                    FloatingTextStringOnCreature(GetName(spInfo.oTarget) + GetStringByStrRef(16939266), oCaster, FALSE);
                } else {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));

                    //*:**********************************************
                    //*:* Prevent stacking
                    //*:**********************************************
                    /*** NWN1 SPECIFIC ***/
                        if(GetHasSpellEffect(774, spInfo.oTarget) && spInfo.iSpellID==774) {
                            GRRemoveSpellEffects(774, spInfo.oTarget);
                        } else {
                            GRRemoveMultipleSpellEffects(SPELL_MAGE_ARMOR, SPELL_GR_LSC_MAGE_ARMOR, spInfo.oTarget, TRUE, SPELL_GR_MASS_MAGE_ARMOR,
                                SPELL_GR_GREATER_MAGE_ARMOR);
                            GRRemoveSpellEffects(SPELL_EPIC_MAGE_ARMOR, spInfo.oTarget);
                        }
                    /*** END NWN1 SPECIFIC ***/

                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                }
                iNumTargets--;
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumTargets>0);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
