//*:**************************************************************************
//*:*  GR_S0_CALMANI.NSS
//*:**************************************************************************
//*:* Calm Animals
//*:* 3.5 Player's Handbook (p. 207)
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 7, 2003
//*:**************************************************************************
//*:* Updated On: February 21, 2008
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
    int     iDurType          = DUR_TYPE_TURNS;

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
    //*:* float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(15.0);

    int     iHDAffected     = 0;
    int     iHDTotal        = spInfo.iCasterLevel + GRGetMetamagicAdjustedDamage(4, 2, spInfo.iMetamagic);

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
    effect eDaze    = EffectDazed();
    effect eDur     = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eImp     = EffectVisualEffect(VFX_FNF_LOS_NORMAL_30);
    effect eLink    = EffectLinkEffects(eDaze, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImp, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    while(GetIsObjectValid(spInfo.oTarget) && (iHDAffected<iHDTotal)) {
        if(!GetIsFriend(spInfo.oTarget, oCaster)) {
            if((GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ANIMAL || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_BEAST ||
                GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_MAGICAL_BEAST || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_VERMIN)
                && GetAbilityScore(spInfo.oTarget,ABILITY_INTELLIGENCE)<=3) {

                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_CALM_ANIMALS));
                    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                        if((GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ANIMAL || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_VERMIN) &&
                            !((FindSubString(GetName(spInfo.oTarget),"Dire")!=-1) || (FindSubString(GetName(spInfo.oTarget),"Winter")!=-1)
                            || (FindSubString(GetName(spInfo.oTarget),"Malar")!=-1) && GetMaster(spInfo.oTarget)==OBJECT_INVALID)) {

                                iHDAffected += GetHitDice(spInfo.oTarget);
                                if(iHDAffected<=iHDTotal) {
                                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                                    ClearPersonalReputationWithFaction(oCaster, spInfo.oTarget);
                                    SetIsTemporaryNeutral(spInfo.oTarget, oCaster, FALSE, fDuration);
                                } else {
                                    iHDAffected-=GetHitDice(spInfo.oTarget);
                                }

                        } else if(WillSave(spInfo.oTarget,spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS)==0) {
                            iHDAffected += GetHitDice(spInfo.oTarget);
                            if(iHDAffected<=iHDTotal) {
                                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDaze, spInfo.oTarget, fDuration);
                                ClearPersonalReputationWithFaction(oCaster, spInfo.oTarget);
                                SetIsTemporaryNeutral(spInfo.oTarget, oCaster, FALSE, fDuration);
                            } else {
                                iHDAffected-=iHDTotal;
                            }
                        }
                    }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
