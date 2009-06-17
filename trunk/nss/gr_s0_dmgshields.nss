//*:**************************************************************************
//*:*  GR_S0_DMGSHIELDS.NSS
//*:**************************************************************************
//*:*  MASTER SCRIPT FOR MOST DAMAGE SHIELD TYPE SPELLS
//*:**************************************************************************
//*:* Death Armor (X2_S0_DthArm) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Jan 6, 2003
//*:* Spell Compendium (p. 60)
//*:*
//*:* Mestil's Acid Sheath (X2_S0_AcidShth) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:* Acid Sheath - Spell Compendium (p. 7)
//*:*
//*:* Wounding Whispers (x0_s0_WoundWhis.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:* Spell Compendium (p. 242)
//*:**************************************************************************
//*:* Fire Shield (sg_s0_firshld.nss)  2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 3, 2003
//*:* 3.5 Player's Handbook (p. 230)
//*:*
//*:* Fire Shield, Mass
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 25, 2007
//*:* Spell Compendium (p. 92)
//*:*
//*:* Babau Slime (sg_s0_babauslm.nss) 2006 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 16, 2006
//*:* Spell Compendium (p. 22)
//*:**************************************************************************
//*:* Updated On: November 28, 2007
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

#include "GR_IN_ENERGY"
//#include "GR_IN_DEBUG"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void GRPreventDamageShieldStacking(int iSpellID, object oTarget) {

    switch(iSpellID) {
        case SPELL_GR_FIRE_SHIELD_HOT:
        case SPELL_GR_FIRE_SHIELD_COLD:
        case SPELL_GR_MASS_FIRE_SHIELD_HOT:
        case SPELL_GR_MASS_FIRE_SHIELD_COLD:
        case SPELL_ELEMENTAL_SHIELD:
            GRRemoveMultipleSpellEffects(SPELL_GR_FIRE_SHIELD_HOT, SPELL_GR_FIRE_SHIELD_COLD, oTarget, TRUE, SPELL_GR_MASS_FIRE_SHIELD_HOT,
                SPELL_GR_MASS_FIRE_SHIELD_COLD);
            GRRemoveSpellEffects(SPELL_ELEMENTAL_SHIELD, oTarget);
            break;
        default:
            GRRemoveSpellEffects(iSpellID, oTarget);
            break;
    }
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType        = 6;
    int     iNumDice        = 1;
    int     iBonus          = 0;
    int     iDamage         = 0;
    int     iSecDamage      = 0;
    int     iDurAmount      = spInfo.iCasterLevel;
    int     iDurType        = DUR_TYPE_ROUNDS;
    int     iEnergyType     = DAMAGE_TYPE_MAGICAL;
    int     iSpellType      = SPELL_TYPE_GENERAL;
    int     bEnergySpell    = TRUE;

    switch(spInfo.iSpellID) {
        case SPELL_GR_BABAU_SLIME:
            iDurType = DUR_TYPE_TURNS;
            iEnergyType = DAMAGE_TYPE_ACID;
            iDieType = 8;
        case SPELL_DEATH_ARMOR:
        case SPELL_GR_GSC_MESTILS_ACID_SHEATH:
            bEnergySpell = FALSE;
            break;
    }

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    //AutoDebugString("Casting spell " + GRSpellToString(spInfo.iSpellID) +".  bEnergySpell = " + GRBooleanToString(bEnergySpell));
    if(bEnergySpell) {
        iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
        iSpellType      = GRGetEnergySpellType(iEnergyType);

        //AutoDebugString("iEnergyType = " + IntToString(iEnergyType));
        //AutoDebugString("iSpellType = " + IntToString(iSpellType));

        spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);
    }

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo, iEnergyType);
    float   fRange          = FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     bMultiTarget    = (spInfo.iSpellID==SPELL_GR_MASS_FIRE_SHIELD);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    int     iVisualType;
    int     iBonusAmt       = MinInt(15, spInfo.iCasterLevel);
    int     iRandomAmt      = DAMAGE_BONUS_1d6;

    switch(spInfo.iSpellID) {
        case SPELL_GR_BABAU_SLIME:
            iVisualType = VFX_DUR_PARALYZED;
            iBonusAmt = 0;
            iRandomAmt = DAMAGE_BONUS_1d8;
            break;
        case SPELL_DEATH_ARMOR:
            iVisualType = VFX_DUR_DEATH_ARMOR;
            iBonusAmt = MinInt(10, spInfo.iCasterLevel/2);
            iRandomAmt = DAMAGE_BONUS_1d4;
            break;
        case SPELL_GR_FIRE_SHIELD_HOT:
        case SPELL_GR_MASS_FIRE_SHIELD_HOT:
            /*** NWN1 SINGLE ***/ iVisualType = VFX_DUR_FIRE_SHIELD_HOT;
            //*** NWN2 SINGLE ***/ iVisualType = VFX_DUR_ELEMENTAL_SHIELD;
            break;
        case SPELL_GR_FIRE_SHIELD_COLD:
        case SPELL_GR_MASS_FIRE_SHIELD_COLD:
            /*** NWN1 SINGLE ***/ iVisualType = VFX_DUR_FIRE_SHIELD_COLD;
            //*** NWN2 SINGLE ***/ iVisualType = VFX_DUR_ELEMENTAL_SHIELD;
            break;
        case SPELL_MESTILS_ACID_SHEATH:
        case SPELL_GR_GSC_MESTILS_ACID_SHEATH:
            iVisualType = 448; // VFX_DUR_PROT_ACIDSHIELD - for nwn2 is same as elemental shield for now
            iBonusAmt = MinInt(30, spInfo.iCasterLevel*2);
            iRandomAmt = 0;
            break;
        case SPELL_WOUNDING_WHISPERS:
            iVisualType = VFX_DUR_MIND_AFFECTING_POSITIVE;
            iBonusAmt = spInfo.iCasterLevel;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EMPOWER)) {
        switch(iRandomAmt) {
            case DAMAGE_BONUS_1d4:
                iRandomAmt = DAMAGE_BONUS_1d6;
                break;
            case DAMAGE_BONUS_1d6:
                iRandomAmt = DAMAGE_BONUS_1d10; // There isn't a 1d9
                break;
            case DAMAGE_BONUS_1d8:
                iRandomAmt = DAMAGE_BONUS_1d12;
                break;
        }
    }
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_MAXIMIZE)) {
        switch(iRandomAmt) {
            case DAMAGE_BONUS_1d4:
                iRandomAmt = DAMAGE_BONUS_4;
                break;
            case DAMAGE_BONUS_1d6:
                iRandomAmt = DAMAGE_BONUS_6;
                break;
            case DAMAGE_BONUS_1d8:
                iRandomAmt = DAMAGE_BONUS_8;
                break;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eCold;
    effect eFire;
    effect eLink    = eVis;
    effect eShield;
    effect eShield2;

    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            switch(iRandomAmt) {
                case DAMAGE_BONUS_1d4:
                case DAMAGE_BONUS_4:
                    iRandomAmt = DAMAGE_BONUS_2; // no 1d2 option
                    break;
                case DAMAGE_BONUS_6:
                    iRandomAmt = DAMAGE_BONUS_3;
                    break;
                case DAMAGE_BONUS_1d6:
                case DAMAGE_BONUS_1d8:
                    iRandomAmt = DAMAGE_BONUS_1d4; // no 1d3 option for half 1d6
                    break;
                case DAMAGE_BONUS_8:
                    iRandomAmt = DAMAGE_BONUS_4;
                    break;
                case DAMAGE_BONUS_1d10:
                case DAMAGE_BONUS_1d12:
                    iRandomAmt = DAMAGE_BONUS_1d6;
                    break;
            }
        }

        eShield = EffectDamageShield(iBonusAmt/2, iRandomAmt, iEnergyType);
        eShield2 = EffectDamageShield(iBonusAmt/2, iRandomAmt, spInfo.iSecDmgType);
        eLink = EffectLinkEffects(eLink, eShield2);

    } else {
        eShield = EffectDamageShield(iBonusAmt, iRandomAmt, iEnergyType);
        //AutoDebugString("Creating damage shield effect.  Bonus = " + IntToString(iBonusAmt) + " Random = " + IntToString(iRandomAmt) + " energy = " + IntToString(iEnergyType));
    }
    eLink = EffectLinkEffects(eLink, eShield);


    switch(spInfo.iSpellID) {
        case SPELL_GR_MASS_FIRE_SHIELD_HOT:
            bMultiTarget = TRUE;
        case SPELL_GR_FIRE_SHIELD_HOT:
            eCold   = EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, 50);
            eLink   = EffectLinkEffects(eLink, eShield);
            eLink   = EffectLinkEffects(eLink, eCold);
            break;
        case SPELL_GR_MASS_FIRE_SHIELD_COLD:
            bMultiTarget = TRUE;
        case SPELL_GR_FIRE_SHIELD_COLD:
            eFire   = EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, 50);
            eLink   = EffectLinkEffects(eLink, eShield);
            eLink   = EffectLinkEffects(eLink, eFire);
            break;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, TRUE)) {
                GRPreventDamageShieldStacking(spInfo.iSpellID, spInfo.oTarget);

                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE);
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
