//*:**************************************************************************
//*:*  GR_S0_HOLD.NSS
//*:**************************************************************************
//*:* Master script for the following Hold spells
//*:**************************************************************************
//*:* Hold Animal (nw_s0_HoldAnim) Copyright (c) 2001 Bioware Corp.
//*:* Hold Monster (nw_s0_HoldMon) Copyright (c) 2001 Bioware Corp.
//*:* Hold Person (NW_S0_HoldPers) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Keith Soleski  Created On: Jan 18, 2001
//*:* 3.5 Player's Handbook (p. 241)
//*:**************************************************************************
//*:* Hold Monster, Mass
//*:* Hold Person, Mass
//*:* 3.5 Player's Handbook (p. 241)
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Master Script Created On: July 16, 2007
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
    //*:* float   fRange          = FeetToMeters(15.0);

    int     bIsTarget           = FALSE;
    int     bMultiTarget        = (spInfo.iSpellID==SPELL_MASS_HOLD_PERSON || spInfo.iSpellID==SPELL_MASS_HOLD_MONSTER);
    float   fRange              = FeetToMeters(15.0); // 15' rad (within 30 ft)
    int     iDurVisType         = VFX_DUR_CESSATE_NEGATIVE;

    int     iAOEType;
    string  sAOEType;

    switch(spInfo.iSpellID) {
        case SPELL_HOLD_ANIMAL:
            /*** NWN1 SPECIFIC ***/
                iAOEType = AOE_MOB_HOLD_ANIMAL;
                sAOEType = AOE_TYPE_HOLD_ANIMAL;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_HOLD_ANIMAL;
            break;
        case SPELL_HOLD_PERSON:
        case SPELL_MASS_HOLD_PERSON:
            /*** NWN1 SPECIFIC ***/
                iAOEType = AOE_MOB_HOLD_PERSON;
                sAOEType = AOE_TYPE_HOLD_PERSON;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_HOLD_PERSON;
            break;
        case SPELL_HOLD_MONSTER:
        case SPELL_MASS_HOLD_MONSTER:
            /*** NWN1 SPECIFIC ***/
                iAOEType = AOE_MOB_HOLD_MONSTER;
                sAOEType = AOE_TYPE_HOLD_MONSTER;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_HOLD_MONSTER;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SINGLE ***/ if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eDur     = EffectVisualEffect(iDurVisType);

    /*** NWN1 SPECIFIC ***/
        effect eAOE     = GREffectAreaOfEffect(iAOEType);
        effect eParal   = EffectParalyze();
        effect eVis     = EffectVisualEffect(82);
        effect eDur2    = EffectVisualEffect(VFX_DUR_PARALYZED);
        effect eDur3    = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eParal = EffectParalyze(spInfo.iDC, SAVING_THROW_WILL);

    effect eLink = EffectLinkEffects(eParal, eDur);
    /*** NWN1 SPECIFIC ***/
        eLink = EffectLinkEffects(eLink, eDur2);
        eLink = EffectLinkEffects(eLink, eDur3);
        eLink = EffectLinkEffects(eLink, eVis);
        eLink = EffectLinkEffects(eLink, eAOE);
    /*** END NWN1 SPECIFIC ***/

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            bIsTarget = FALSE;
            //*:**********************************************
            //*:* Targeting Rules
            //*:**********************************************
            switch(spInfo.iSpellID) {
                case SPELL_HOLD_ANIMAL:
                    if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ANIMAL && GRGetIsLiving(spInfo.oTarget)) bIsTarget = TRUE;
                    break;
                case SPELL_HOLD_PERSON:
                case SPELL_MASS_HOLD_PERSON:
                    if(GRGetIsHumanoid(spInfo.oTarget) && GRGetIsLiving(spInfo.oTarget) &&
                        (!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster))) {
                            bIsTarget = TRUE;
                    }
                    break;
                case SPELL_HOLD_MONSTER:
                case SPELL_MASS_HOLD_MONSTER:
                    if(GRGetIsLiving(spInfo.oTarget) &&
                        (!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster))) {
                            bIsTarget = TRUE;
                    }
                    break;
            }
            //*:**********************************************
            if(bIsTarget) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);

                        /*** NWN1 SPECIFIC ***/
                            object oAOE = GRGetAOEOnObject(spInfo.oTarget, sAOEType, oCaster);
                            GRSetAOESpellId(spInfo.iSpellID, oAOE);
                            GRSetSpellInfo(spInfo, oAOE);
                            SetLocalInt(spInfo.oTarget, "HOLD_SPELL_SAVE_TYPE", SAVING_THROW_WILL);
                        /*** END NWN1 SPECIFIC ***/
                    }
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
