//*:**************************************************************************
//*:*  GR_S0_SUNBURST.NSS
//*:**************************************************************************
//*:* Sunburst
//*:* 3.5 Player's Handbook (p. 289)
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**************************************************************************
//*:* Updated On: November 26, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"         - INCLUDED IN GR_IN_LIGHTDARK
#include "GR_IN_SPELLHOOK"
#include "GR_IN_LIGHTDARK"

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

    int     iDieType          = 6;
    int     iNumDice          = 6;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = GRGetScaledBlindDeafDuration();
    int     iEffectDurType    = (iDurType!=5 ? DURATION_TYPE_TEMPORARY : DURATION_TYPE_PERMANENT);

    if(iDurType==5) iDurType = 4;

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
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(80.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eImpact      = EffectVisualEffect(VFX_FNF_SUNBEAM);
    effect eBlindVis    = EffectVisualEffect(VFX_DUR_BLIND);
    effect eBlind       = EffectBlindness();
    effect eBlindLink   = EffectLinkEffects(eBlind, eBlindVis);
    effect eDam;
    effect eVis         = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eDeath       = SupernaturalEffect(EffectDeath());

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveLowerLvlDarknessEffectsInArea(spInfo.iSpellID, spInfo.lTarget);
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            fDelay = GetRandomDelay(1.0, 2.0);
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                iNumDice = ((GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_OOZE) ? spInfo.iCasterLevel : 6);
                iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
                if(GRGetIsLightSensitive(spInfo.oTarget)) iDamage *= 2;
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }

                if(GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC)) {
                    iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, 0);
                    iSecDamage = GRGetReflexAdjustedDamage(iSecDamage, spInfo.oTarget, 0);
                } else {
                    DelayCommand(fDelay, GRApplyEffectToObject(iEffectDurType, eBlindLink, spInfo.oTarget, fDuration));
                    if(GRGetIsLightSensitive(spInfo.oTarget) && GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                        if(!GetIsPC(spInfo.oTarget)) {
                            DestroyObject(spInfo.oTarget, fDelay);
                        } else {
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                        }
                    }
                }
                if(iDamage>0) {
                    eDam = EffectDamage(iDamage, DAMAGE_TYPE_DIVINE);
                    if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
