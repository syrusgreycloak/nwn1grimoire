//*:**************************************************************************
//*:*  GR_S0_DOMINATE.NSS
//*:**************************************************************************
//*:* Dominate Animal [NW_S0_DomAn.nss] Copyright (c) 2000 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 224)
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 30, 2001
//*:**************************************************************************
//*:* Dominate Monster [NW_S0_DomMon.nss] Copyright (c) 2000 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 224)
//*:* Dominate Person [NW_S0_DomPers.nss] Copyright (c) 2000 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 224)
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 29, 2001
//*:**************************************************************************
//*:*
//*:* Master Combo script
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 21, 2007
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
    int     iDurType          = (spInfo.iSpellID==SPELL_DOMINATE_ANIMAL ? DUR_TYPE_ROUNDS : DUR_TYPE_DAYS);

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

    float   fDuration           = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iDurVisType;
    /*** NWN1 SINGLE ***/ iDurVisType = VFX_DUR_MIND_AFFECTING_DOMINATED;
    /*** NWN2 SPECIFIC ***
        switch(spInfo.iSpellID) {
            case SPELL_DOMINATE_ANIMAL:
                iDurVisType = VFX_DUR_SPELL_DOMINATE_ANIMAL;
                break;
            case SPELL_DOMINATE_PERSON:
                iDurVisType = VFX_DUR_SPELL_DOMINATE_PERSON;
                break;
            case SPELL_DOMINATE_MONSTER:
                iDurVisType = VFX_DUR_SPELL_DOMINATE_MONSTER;
                break;
        }
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    /*** NWN1 SPECIFIC ***/
        effect eVis     = EffectVisualEffect(VFX_IMP_DOMINATE_S);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    /*** END NWN1 SPECIFIC ***/
    effect eDom     = EffectDominated();
    effect eMind    = EffectVisualEffect(iDurVisType);

    if(spInfo.iSpellID!=SPELL_DOMINATE_ANIMAL) {
        eDom = GetScaledEffect(eDom, spInfo.oTarget);
    }

    effect eLink    = EffectLinkEffects(eMind, eDom);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS)) {

                if( //*:* Dominate Monster
                    spInfo.iSpellID==SPELL_DOMINATE_MONSTER ||
                    //*:* Dominate Animal
                    (spInfo.iSpellID==SPELL_DOMINATE_ANIMAL &&
                        (GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ANIMAL || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_BEAST)) ||
                    //*:* Dominate Person
                    (spInfo.iSpellID==SPELL_DOMINATE_PERSON && GRGetIsHumanoid(spInfo.oTarget))
                ) {
                    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                }
            }
        }
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
