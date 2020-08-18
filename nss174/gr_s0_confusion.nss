//*:**************************************************************************
//*:*  GR_S0_CONFUSION.NSS
//*:**************************************************************************
//*:*
//*:* Confusion (NW_S0_Confusion.nss) Copyright (c) 2000 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 212)
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 30 , 2001
//*:**************************************************************************
//*:*
//*:* Lesser Confusion (Random Action)
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: August 10, 2004
//*:* 3.5 Player's Handbook (p. 212)
//*:*
//*:* Insanity
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: September 27, 2007
//*:* 3.5 Player's Handbook (p. 244)
//*:*
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

    float   fDuration       = (spInfo.iSpellID==SPELL_LESSER_CONFUSION ? GRGetDuration(2) : GRGetSpellDuration(spInfo));
    float   fRange          = FeetToMeters(15.0);

    float   fDelay;
    int     bMultiTarget    = (spInfo.iSpellID==SPELL_CONFUSION);

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
    /*** NWN1 SPECIFIC ***/
        effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
        effect eVis     = EffectVisualEffect(VFX_IMP_CONFUSION_S);
        effect eMind    = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    /*** END NWN1 SPECIFIC ***/
    effect eConfuse = EffectConfused();

    //*** NWN2 SINGLE ***/ effect eMind = EffectVisualEffect(VFX_DUR_SPELL_CONFUSION);

    effect eLink    = EffectLinkEffects(eMind, eConfuse);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
               SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
               fDelay = GetRandomDelay();
               if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                   spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                   if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, oCaster, fDelay)) {
                       if(spInfo.iSpellID!=SPELL_GR_INSANITY) {
                           fDuration = IntToFloat(GetScaledDuration(FloatToInt(fDuration), spInfo.oTarget));
                           DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration));
                       } else {
                           DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget));
                       }
                       /*** NWN1 SINGLE ***/ DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
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
