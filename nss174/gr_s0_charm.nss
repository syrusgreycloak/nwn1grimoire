//*:**************************************************************************
//*:*  GR_S0_CHARM.NSS
//*:**************************************************************************
//*:*
//*:* Combination script for charm spells
//*:*
//*:* Charm Animal - [Charm Person or Animal] [NW_S0_DomAni.nss] Copyright (c) 2000 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 208)
//*:* Charm Monster - [Charm Monster] [NW_S0_CharmMon.nss] Copyright (c) 2000 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 209)
//*:* Charm Monster, Mass - [Mass Charm] [NW_S0_MsCharm.nss] Copyright (c) 2000 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 209)
//*:* Charm Person - [Charm Person] [NW_S0_CharmPer.nss] Copyright (c) 2000 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 209)
//*:*
//*:* Charm Person, Mass    (Races of Destiny p. 164)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 25, 2007
//*:*
//*:* Charm                 (Complete Arcane p. 132)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 23, 2008
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2005
//*:**************************************************************************
//*:* Updated On: April 23, 2008
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
//*:* Supporting functions
//*:**************************************************************************
int GRGetIsCharmTarget(int iCharmSpellId, object oTarget) {
    int bIsTarget = FALSE;

    switch(iCharmSpellId) {
        case SPELL_GR_CHARM_ANIMAL:
            bIsTarget = (GRGetRacialType(oTarget)==RACIAL_TYPE_ANIMAL ? TRUE : FALSE);
            break;
        case SPELL_CHARM_PERSON:
        case SPELL_GR_MASS_CHARM_PERSON:
            bIsTarget = GRGetIsHumanoid(oTarget) && GRGetIsLiving(oTarget) && !GRGetIsMindless(oTarget);
            break;
        case SPELL_CHARM_MONSTER:
        case SPELL_I_CHARM:
        case SPELL_MASS_CHARM:
            bIsTarget = GRGetIsLiving(oTarget) && !GRGetIsMindless(oTarget);
            break;
    }

    return bIsTarget;
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_HOURS;

    switch(spInfo.iSpellID) {
        case SPELL_CHARM_MONSTER:
        case SPELL_I_CHARM:
        case SPELL_MASS_CHARM:
            iDurType = DUR_TYPE_DAYS;
            break;
    }

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

    fDuration = IntToFloat(GetScaledDuration(FloatToInt(fDuration), spInfo.oTarget));
    int     iHD             = 0;
    int     iMaxHD          = 2*spInfo.iCasterLevel;
    int     bMultiTarget    = ((spInfo.iSpellID==SPELL_GR_MASS_CHARM_MONSTER || spInfo.iSpellID==SPELL_GR_MASS_CHARM_PERSON) ? TRUE : FALSE);
    int     iDurVisType;
    /*** NWN1 SINGLE ***/ iDurVisType = VFX_DUR_CESSATE_NEGATIVE;
    //*** NWN2 SINGLE ***/ iDurVisType = (spInfo.iSpellID==SPELL_CHARM_PERSON || spInfo.iSpellID==SPELL_GR_MASS_CHARM_PERSON) ? VFX_DUR_SPELL_CHARM_PERSON : VFX_DUR_SPELL_CHARM_MONSTER);

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
        effect eVis     = EffectVisualEffect(VFX_IMP_CHARM);
        effect eMind    = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    /*** END NWN1 SPECIFIC ***/
    effect eDur     = EffectVisualEffect(iDurVisType);
    effect eCharm   = EffectCharmed();
    eCharm = GetScaledEffect(eCharm, spInfo.oTarget);

    //Link persistant effects
    effect eLink = EffectLinkEffects(eCharm, eDur);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eMind);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE)) {
                if(!bMultiTarget || (bMultiTarget && (iHD+GetHitDice(spInfo.oTarget))<=iMaxHD)) {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                        if(GRGetIsCharmTarget(spInfo.iSpellID, spInfo.oTarget)) {
                            if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS)) {
                                iHD += GetHitDice(spInfo.oTarget);
                                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                                /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                                if(spInfo.iSpellID==SPELL_I_CHARM) {
                                    if(GetIsObjectValid(GetLocalObject(oCaster, "GR_WARLOCK_CHARM_TARGET"))) {
                                        if(GRGetHasSpellEffect(SPELL_I_CHARM, GetLocalObject(oCaster, "GR_WARLOCK_CHARM_TARGET"), oCaster)) {
                                            GRRemoveSpellEffects(SPELL_I_CHARM, GetLocalObject(oCaster, "GR_WARLOCK_CHARM_TARGET"), oCaster);
                                        }
                                        DeleteLocalObject(oCaster, "GR_WARLOCK_CHARM_TARGET");
                                    }
                                    SetLocalObject(oCaster, "GR_WARLOCK_CHARM_TARGET", spInfo.oTarget);
                                }
                            }
                        }
                    }
                }
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iHD<=iMaxHD);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
