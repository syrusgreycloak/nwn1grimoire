//*:**************************************************************************
//*:*  GR_S0_ANITRANCE.NSS
//*:**************************************************************************
//*:* Animal Trance                         2008 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 18, 2008
//*:* 3.5 Player's Handbook (p. 198)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
//#include "GR_IN_CONCEN"

//*:* #include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
/*void DoAniTranceCheckCasterConcentration(object oTarget, object oCaster) {

    if(!GRGetCasterConcentrating(SPELL_GR_ANIMAL_TRANCE, oCaster)) {
        GRRemoveSpellEffects(SPELL_GR_ANIMAL_TRANCE, oTarget, oCaster);
    } else {
        DelayCommand(GRGetDuration(1), CheckCasterConcentration(oTarget, oCaster));
    }
}*/

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = 6;
    int     iNumDice          = 2;
    int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
    //*:* float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(25.0 + 5.0*(spInfo.iCasterLevel/2));

    int     iCount          = 1;
    int     iHDLimit        = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
    int     iHDAffected     = 0;
    int     iCurrentHD      = 0;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    //*:* iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eDazed   = EffectDazed();
    effect eDurVis  = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eLink    = EffectLinkEffects(eDazed, eDurVis);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, oCaster, iCount);

    while(GetDistanceBetween(spInfo.oTarget, oCaster)<=fRange) {
        if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ANIMAL || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_MAGICAL_BEAST) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                if(GetAbilityScore(spInfo.oTarget, ABILITY_INTELLIGENCE)<=3) {
                    if(GetMaster(spInfo.oTarget)==OBJECT_INVALID ||
                        (spInfo.oTarget!=GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, GetMaster(spInfo.oTarget)) &&
                         spInfo.oTarget!=GetAssociate(ASSOCIATE_TYPE_FAMILIAR, GetMaster(spInfo.oTarget)))  ) {

                        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_ANIMAL_TRANCE));

                        iCurrentHD = GetHitDice(spInfo.oTarget);
                        if(iHDAffected + iCurrentHD <= iHDLimit) {
                            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                                if((GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_MAGICAL_BEAST &&
                                    FindSubString(GetStringLowerCase(GetName(spInfo.oTarget)), "dire")==-1) ||
                                    !GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS) ) {

                                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                                    PrintString("Animal Trance concentration system is still broken.");
                                    //DelayCommand(GRGetDuration(1)*1.5, DoAniTranceCheckCasterConcentration(spInfo.oTarget, oCaster));
                                    iHDAffected += iCurrentHD;
                                }
                            }
                        }
                    }
                }
            }
        }
        iCount++;
        spInfo.oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, oCaster, iCount);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
