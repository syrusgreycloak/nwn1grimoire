//*:**************************************************************************
//*:*  GR_S0_HASTE.NSS
//*:**************************************************************************
//*:* Haste (NW_S0_Haste.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 239)
//*:* Mass Haste (nw_s0_mashaste.nss) Copyright (c) 2001 Bioware Corp.
//*:* deleted in 3.5 edition
//*:* Blinding Speed [Epic]
//*:* Epic Level Handbook (p. 51)
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: May 29, 2001
//*:**************************************************************************
//*:* Haste, Swift - Spell Compendium (p. 110)
//*:* Longstrider - 3.5 Player's Handbook (p. 249)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: July 16, 2007
//*:*
//*:* Lively Step
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 29, 2008
//*:* Spell Compendium (p. 133)
//*:*
//*:* Allegro
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 30, 2008
//*:* Spell Compendium (p. 9)
//*:**************************************************************************
//*:* Updated On: December 30, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/
#include "X2_INC_ITEMPROP"

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS" - included in GR_IN_HASTE
#include "GR_IN_HASTE"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_ARRLIST"

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

    int     iDieType          = 4;
    int     iNumDice          = 1;
    int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;
    int     bHasteEffect      = FALSE;
    int     iSpeedIncAmount   = 99;
    int     bMultiTarget      = FALSE;

    switch(spInfo.iSpellID) {
        case 647:
            iDurAmount = 5;
        case SPELL_HASTE:
            bMultiTarget = TRUE;
        case SPELL_GR_HASTE_SWIFT:
            bHasteEffect = TRUE;
            break;
        case SPELL_GR_ALLEGRO:
            bMultiTarget = TRUE;
        case SPELL_EXPEDITIOUS_RETREAT:
            iDurType = DUR_TYPE_TURNS;
            iSpeedIncAmount = (spInfo.bNWN2 ? 150 : 99);
            break;
        case SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT:
            iDurAmount = 2;
            iSpeedIncAmount = (spInfo.bNWN2 ? 150 : 99);
            break;
        case SPELL_GR_LIVELY_STEP:
            iDurAmount = 12;
        case SPELL_GR_LONGSTRIDER:
        case SPELL_GR_MASS_LONGSTRIDER:
            bMultiTarget = (spInfo.iSpellID!=SPELL_GR_LONGSTRIDER);
            iDurType = DUR_TYPE_HOURS;
            iSpeedIncAmount = 33;
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
    float   fRange;
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iNumAffected        = spInfo.iCasterLevel;
    int     iNumExtraAttacks    = 0;

    int     iDurVisType     = VFX_DUR_CESSATE_POSITIVE;

    switch(spInfo.iSpellID) {
        case SPELL_GR_MASS_LONGSTRIDER:
            fRange = FeetToMeters(60.0);
            break;
        case SPELL_GR_ALLEGRO:
            fRange = FeetToMeters(20.0);
            break;
        default:
            fRange = FeetToMeters(15.0);
            break;
    }
    /*** NWN2 SPECIFIC ***
        switch(spInfo.iSpellID) {
            case 647:
            case SPELL_HASTE:
            case SPELL_GR_HASTE_SWIFT:
                iDurVisType = VFX_DUR_SPELL_HASTE;
                break;
            case SPELL_GR_LONGSTRIDER:
            case SPELL_GR_MASS_LONGSTRIDER:
            case SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT:
            case SPELL_EXPEDITIOUS_RETREAT:
                iDurVisType = VFX_DUR_SPELL_EXPEDITIOUS_RETREAT;
                break;
        }
    /*** END NWN2 SPECIFIC ***/

    if(IPGetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND))) iNumExtraAttacks++;
    if(IPGetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_LEFTHAND))) iNumExtraAttacks++;

    if(spInfo.iSpellID==SPELL_GR_HASTE_SWIFT) fDuration = GRGetDuration(GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus));

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
    /*** NWN1 SINGLE ***/ effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eHaste   = EffectMovementSpeedIncrease(iSpeedIncAmount);
    effect eAC      = EffectACIncrease(1);
    effect eAttack  = EffectAttackIncrease(1);
    effect eSave    = EffectSavingThrowIncrease(SAVING_THROW_REFLEX, 1);
    effect eAttacks = EffectModifyAttacks(iNumExtraAttacks);
    /*** NWN1 SINGLE ***/ effect eVis     = (spInfo.iSpellID!=647 ? EffectVisualEffect(VFX_IMP_HASTE) : EffectVisualEffect(460));
    effect eDur     = EffectVisualEffect(iDurVisType);

    effect eLink    = EffectLinkEffects(eHaste, eDur);

    effect eLively  = EffectAreaOfEffect(AOE_MOB_LIVELY_STEP);

    if(bHasteEffect) {
        eLink = EffectLinkEffects(eLink, eAC);
        eLink = EffectLinkEffects(eLink, eAttack);
        eLink = EffectLinkEffects(eLink, eSave);
        if(iNumExtraAttacks>0) eLink = EffectLinkEffects(eLink, eAttacks);
    }
    if(spInfo.iSpellID==647) eLink = ExtraordinaryEffect(eLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:**********************************************
    //*:* Lively Step
    //*:**********************************************
    if(spInfo.iSpellID==SPELL_GR_LIVELY_STEP) {
        // Apply AOE to caster
        SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_LIVELY_STEP));
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLively, oCaster, fDuration);
        object oAOE = GRGetAOEOnObject(oCaster, AOE_TYPE_LIVELY_STEP, oCaster);
        GRSetAOESpellId(spInfo.iSpellID, oAOE);
        GRSetSpellInfo(spInfo, oAOE);
        GRCreateArrayList("GR_LIVELY_STEP", "AFFECTED", VALUE_TYPE_OBJECT, oCaster);
        SetLocalInt(oCaster, "GR_LIVELY_DUR", FloatToInt(fDuration/6.0));
        SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_REQCONCENTRATION", TRUE);
    }

    if(bMultiTarget) {
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                if(!GRPreventHasteStacking(spInfo.iSpellID, spInfo.oTarget)) {
                    GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
                    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                    if(spInfo.iSpellID!=SPELL_GR_LIVELY_STEP && spInfo.iSpellID!=SPELL_GR_ALLEGRO) {
                        iNumAffected--;
                    } else if(spInfo.iSpellID==SPELL_GR_LIVELY_STEP) {
                        GRObjectAdd("GR_LIVELY_STEP", "AFFECTED", spInfo.oTarget, oCaster);
                    }
                } else {
                    if(GetIsPC(oCaster)) {
                        if(oCaster!=spInfo.oTarget) {
                            SendMessageToPC(oCaster, GetName(spInfo.oTarget) + GetStringByStrRef(16939261));
                        } else {
                            SendMessageToPC(oCaster, GetStringByStrRef(16939246));
                        }
                    }
                }
            }

            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && (iNumAffected>0 || spInfo.iSpellID==SPELL_GR_MASS_LONGSTRIDER));
    }


    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
