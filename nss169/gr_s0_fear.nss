//*:**************************************************************************
//*:*  GR_S0_FEAR.NSS
//*:**************************************************************************
//*:*  MASTER SCRIPT FOR FEAR-TYPE SPELLS
//*:**************************************************************************
//*:* Cause Fear [Scare] [NW_S0_Scare.nss] Copyright (c) 2000 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 30, 2001
//*:* Bioware implementation was for Cause Fear - not Scare, as it was named
//*:*
//*:* Fear [NW_S0_Fear.nss] Copyright (c) 2000 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: April 23, 2001
//*:* 3.5 Player's Handbook (p. 229)
//*:*
//*:* Purple Dragon Knight - Fear ability  (x3_s2_pdk_fear.nss)
//*:* Created By: Stratovarius  Created On: Sept 22, 2005
//*:* **same as fear spell with caster level = character level**
//*:* Player's Guide to Faerun (p. 69)
//*:**************************************************************************
//*:* Scare - 3.5 Player's Handbook (p. 274)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 23, 2003
//*:**************************************************************************
//*:* Updated On: January 28, 2008
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

    if(spInfo.iSpellID==808) {  //*:* Purple Dragon Knight Fear ability
        spInfo.iCasterLevel = GetHitDice(oCaster);
    }

    int     iDieType        = 4;
    int     iNumDice        = 1;
    int     iBonus          = 0;
    int     iDamage         = 0;
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

    float   fDuration       = (spInfo.iSpellID==SPELL_CAUSE_FEAR ? GRGetDuration(GRGetSpellDamageAmount(spInfo)) : GRGetSpellDuration(spInfo));
    float   fRange          = (spInfo.iSpellID==SPELL_SCARE ? FeetToMeters(15.0) : FeetToMeters(30.0));
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     bMultiTarget    = (spInfo.iSpellID!=SPELL_CAUSE_FEAR);
    int     iSpellShape     = (spInfo.iSpellID==SPELL_SCARE ? SHAPE_SPHERE : SHAPE_SPELLCONE);
    float   fDelay          = 0.0;

    /*** NWN1 SINGLE ***/ int       iDurVisType     = VFX_DUR_MIND_AFFECTING_FEAR;
    //*** NWN2 SINGLE ***/ int      iDurVisType     = (spInfo.iSpellID==SPELL_FEAR ? VFX_DUR_SPELL_FEAR : VFX_DUR_SPELL_CAUSE_FEAR);

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
    effect eFear    = EffectFrightened();
    effect eShaken  = GREffectShaken();
    effect eMind    = EffectVisualEffect(iDurVisType);
    /*** NWN1 SINGLE ***/ effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink    = eMind;
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        if(spInfo.iSpellID!=SPELL_FEAR) GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(iSpellShape, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE)) {
                if(spInfo.iSpellID==SPELL_FEAR || (spInfo.iSpellID!=SPELL_FEAR && GetHitDice(spInfo.oTarget)<6)) {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                    if(bMultiTarget) fDelay = GetRandomDelay();
                    eLink = eMind;
                    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);

                    if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                        spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                        if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_FEAR, oCaster, fDelay)) {
                            eLink = EffectLinkEffects(eLink, eFear);
                            DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration));
                        } else {
                            eLink = EffectLinkEffects(eLink, eShaken);
                            DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, GRGetDuration(2)));
                        }
                    }
                }
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(iSpellShape, fRange, spInfo.lTarget);
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
