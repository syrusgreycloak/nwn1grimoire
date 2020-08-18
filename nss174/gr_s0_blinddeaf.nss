//*:**************************************************************************
//*:*  GR_S0_BLINDDEAF.NSS
//*:**************************************************************************
//*:*
//*:* Blindness/Deafness [NW_S0_BlindDeaf.nss] Copyright (c) 2000 Bioware Corp.
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 12, 2001
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
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = GRGetScaledBlindDeafDuration();
    int     iEffectDurType    = (iDurType!=5 ? DURATION_TYPE_TEMPORARY : DURATION_TYPE_PERMANENT);

    if(iDurType==5) iDurType=4;

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

    int     bMultiTarget    = ((spInfo.iSpellID==SPELL_GR_MASS_DEAFNESS || spInfo.iSpellID==SPELL_GR_MASS_BLINDNESS) ? TRUE : FALSE);

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
        effect eImp     = EffectVisualEffect(VFX_FNF_BLINDDEAF);
        effect eVis     = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eDur = EffectVisualEffect(VFX_DUR_SPELL_BLIND_DEAF);
    effect eBlind   = EffectBlindness();
    effect eDeaf    = EffectDeaf();

    effect eLink;

    if(spInfo.iSpellID==SPELL_GR_BLINDNESS || spInfo.iSpellID==SPELL_GR_MASS_BLINDNESS) {
        eLink = EffectLinkEffects(eDur, eBlind);
    } else {
        eLink = EffectLinkEffects(eDur, eDeaf);
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImp, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do{
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
                    FloatingTextStrRefOnCreature(40105, OBJECT_SELF, FALSE);
                } else {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                        spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                        if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC)) {
                            GRApplyEffectToObject(iEffectDurType, eLink, spInfo.oTarget, fDuration);
                            /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                        }
                    }
                }
            }

            if(bMultiTarget)
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);

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
