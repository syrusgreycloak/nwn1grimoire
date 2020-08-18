//*:**************************************************************************
//*:*  GR_S0_HARM.NSS
//*:**************************************************************************
//*:* Harm [NW_S0_Harm.nss] Copyright (c) 2000 Bioware Corp.
//*:* Created By: Keith Soleski  Created On: Jan 18, 2001
//*:* 3.5 Player's Handbook (p. 239)
//*:*
//*:**************************************************************************
//*:* Harm, Greater (Heroes of Horror p. 130)
//*:* Harm, Mass (Heroes of Horror p. 130)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: November 1, 2007
//*:**************************************************************************
//*:* Updated On: November 1, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS" - INCLUDE IN GR_IN_HEALHARM
#include "GR_IN_SPELLHOOK"
#include "GR_IN_HEALHARM"

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
    int     iDamage           = (spInfo.iSpellID==SPELL_HARM ? MinInt(150, spInfo.iCasterLevel*10) : MinInt(240, spInfo.iCasterLevel*12));
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(20.0);

    int     bMultiTarget    = (spInfo.iSpellID==SPELL_GR_MASS_HARM);
    int     bHarmTouchSpell = (TRUE && !bMultiTarget);
    /*** NWN1 SINGLE ***/ int   vfx_impactNormalHurt = VFX_IMP_SUNSTRIKE;
    //*** NWN2 SINGLE ***/ int   vfx_impactNormalHurt = VFX_HIT_SPELL_INFLICT_6;
    int vfx_impactUndeadHurt    = VFX_IMP_HEALING_G;
    int vfx_impactHeal          = VFX_IMP_HEALING_X;

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
    /*** NWN1 SINGLE ***/ effect eImpact  = EffectVisualEffect(VFX_FNF_LOS_EVIL_20);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
                if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
                    GRHealOrHarmTarget(spInfo.oTarget, iDamage, vfx_impactNormalHurt, vfx_impactUndeadHurt, vfx_impactHeal, spInfo.iSpellID,
                                FALSE, FALSE);
                }
            } else if(GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_CONSTRUCT) {
                if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                    GRHealOrHarmTarget(spInfo.oTarget, iDamage, vfx_impactNormalHurt, vfx_impactUndeadHurt, vfx_impactHeal, spInfo.iSpellID,
                                FALSE, bHarmTouchSpell);
                }
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
