//*:**************************************************************************
//*:*  GR_S0_SHIELDS.NSS
//*:**************************************************************************
//*:* MASTER SCRIPT FOR CERTAIN SHIELDING-TYPE SPELLS
//*:**************************************************************************
//*:* Shield (x0_s0_shield.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Brent Knowles  Created On: July 15, 2002
//*:* 3.5 Player's Handbook (p. 278)
//*:*
//*:* Entropic Shield (x0_s0_entrshield.nss) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Brent Knowles  Created On: July 18, 2002
//*:* 3.5 Player's Handbook (p. 227)
//*:*
//*:* Shield of Faith (x0_s0_ShieldFait.nss) Copyright (c) 2002 Bioware Corp.
//*:* Created By: Brent Knowles  Created On: September 6, 2002
//*:* 3.5 Player's Handbook (p. 278)
//*:**************************************************************************
//*:* Shield of Faith, Mass
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: Septermber 18, 2007
//*:* Spell Compendium (p. 188)
//*:*
//*:* Entropic Warding
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 28, 2008
//*:* Complete Arcane (p. 134)
//*:**************************************************************************
//*:* Updated On: April 28, 2008
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = (spInfo.iSpellID!=SPELL_I_ENTROPIC_WARDING ? spInfo.iCasterLevel : 24);
    int     iDurType          = (spInfo.iSpellID!=SPELL_I_ENTROPIC_WARDING ? DUR_TYPE_TURNS : DUR_TYPE_HOURS);

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

    int     iVisualType     = VFX_IMP_AC_BONUS;
    int     iDurVisType        = VFX_DUR_CESSATE_POSITIVE;
    int     iACBonusType    = AC_SHIELD_ENCHANTMENT_BONUS;
    int     iNumCreatures   = spInfo.iCasterLevel;
    int     bMultiTarget    = spInfo.iSpellID==SPELL_GR_MASS_SHIELD_OF_FAITH;

    switch(spInfo.iSpellID) {
        case SPELL_SHIELD:
            iVisualType = VFX_IMP_MAGIC_PROTECTION;
            iBonus      = 4;
            break;
        case SPELL_ENTROPIC_SHIELD:
            iBonus = 20;
            break;
        case SPELL_SHIELD_OF_FAITH:
        case SPELL_GR_MASS_SHIELD_OF_FAITH:
            iDurVisType        = VFX_DUR_PROTECTION_GOOD_MINOR;
            iACBonusType    = AC_DEFLECTION_BONUS;
            iBonus          = MinInt(5, 2+spInfo.iCasterLevel/6);
            break;
    }
    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eMassVis     = EffectVisualEffect(VFX_IMP_GOOD_HELP);
    effect eVis         = EffectVisualEffect(iVisualType);
    effect eDur         = EffectVisualEffect(iDurVisType);

    //*:**********************************************
    //*:* Shield, Shield of Faith (+ Mass)
    effect eShield      = EffectACIncrease(iBonus, iACBonusType);
    //*:* Shield only
    effect eSpell       = EffectSpellImmunity(SPELL_MAGIC_MISSILE);
    effect eSpell1      = EffectSpellImmunity(SPELL_GR_ARCANE_BOLT);
    effect eSpell2      = EffectSpellImmunity(SPELL_GR_MORDENKAINENS_FORCE_MISSILES);
    effect eSpell3      = EffectSpellImmunity(SPELL_ISAACS_LESSER_MISSILE_STORM);
    effect eSpell4      = EffectSpellImmunity(SPELL_ISAACS_GREATER_MISSILE_STORM);

    //*:**********************************************
    //*:* Entropic Shield
    //*:* Entropic Warding
    if(spInfo.iSpellID==SPELL_ENTROPIC_SHIELD) {
        eShield      = EffectConcealment(iBonus, MISS_CHANCE_TYPE_VS_RANGED);
    }

    //*:**********************************************
    //*:* Link Effects
    effect eLink        = EffectLinkEffects(eDur, eShield);

    if(spInfo.iSpellID==SPELL_SHIELD) {
        eLink = EffectLinkEffects(eLink, eSpell);
        eLink = EffectLinkEffects(eLink, eSpell1);
        eLink = EffectLinkEffects(eLink, eSpell2);
        eLink = EffectLinkEffects(eLink, eSpell3);
        eLink = EffectLinkEffects(eLink, eSpell4);
    }


    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eMassVis, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget);

            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, TRUE)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                iNumCreatures--;
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumCreatures>0);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
