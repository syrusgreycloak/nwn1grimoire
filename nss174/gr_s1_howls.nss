//*:**************************************************************************
//*:*  SPELL_TEMPLATE.NSS
//*:**************************************************************************
//*:*
//*:* Blank template for spell scripts
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**************************************************************************
//*:* Updated On: November 8, 2007
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

    int     iDieType          = 0;
    int     iNumDice          = (spInfo.iCasterLevel/4)+1;
    int     iBonus            = 0;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;
    spInfo.iDC = 10 + spInfo.iCasterLevel/4;

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

    float   fDelay;
    int     iSpellID        = GetSpellId();
    int     iVisual         = -1;
    int     iScaledEffect   = TRUE;
    int     iImpact         = VFX_FNF_HOWL_MIND;
    int     iSavingThrow    = SAVING_THROW_WILL;
    int     iSaveType       = SAVING_THROW_TYPE_MIND_SPELLS;
    int     iDurationType   = DURATION_TYPE_TEMPORARY;
    int     bAlignSpell     = FALSE;
    float   fDuration       = GRGetDuration(iNumDice);
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eVis;
    effect eHowl;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);;
    effect eDurVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eImpact;

    switch(iSpellID) {
        case 265:  // Howl - Confuse
            iVisual = VFX_IMP_CONFUSION_S;
            eHowl = EffectConfused();
            break;
        case 266:  // Howl - Daze
            iVisual = VFX_IMP_DAZED_S;
            eHowl = EffectDazed();
            break;
        case 267:  // Howl - Death
            iVisual = VFX_IMP_DEATH;
            iImpact = VFX_FNF_HOWL_ODD;
            eHowl = EffectDeath();
            iSaveType = SAVING_THROW_TYPE_DEATH;
            iDurationType = DURATION_TYPE_INSTANT;
            iScaledEffect = FALSE;
            break;
        case 268:  // Howl - Doom
            iVisual = VFX_IMP_DOOM;
            iImpact = VFX_FNF_HOWL_ODD;
            eHowl = CreateDoomEffectsLink();
            iSaveType = SAVING_THROW_TYPE_NONE;
            iScaledEffect = FALSE;
            break;
        case 269:  // Howl - Fear
            iVisual = VFX_IMP_FEAR_S;
            eHowl = EffectFrightened();
            eDurVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
            iSaveType = SAVING_THROW_TYPE_FEAR;
            break;
        case 270:  // Howl - Paralyze
        case 305:  // Trumpet Blast
            iImpact = VFX_FNF_HOWL_ODD;
            eHowl = EffectParalyze();
            eDurVis = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
            iSaveType = SAVING_THROW_TYPE_NONE;
            break;
        case 271:  // Howl - Sonic
            iVisual = VFX_IMP_SONIC;
            iImpact = VFX_FNF_HOWL_WAR_CRY;
            iDieType = 6;
            iDurationType = DURATION_TYPE_INSTANT;
            iSavingThrow = SAVING_THROW_FORT;
            iScaledEffect = FALSE;
            break;
        case 272:  // Howl - Stun
            iVisual = VFX_IMP_STUN;
            eHowl = EffectStunned();
            break;
    }

    if(iVisual!=-1)
        eVis = EffectVisualEffect(iVisual);
    if(iImpact!=-1) {
        eImpact = EffectVisualEffect(iImpact);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCaster);
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spInfo.lTarget);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster, NO_CASTER)) {
            if(iScaledEffect) {
                fDuration = GRGetDuration(GetScaledDuration(iNumDice, spInfo.oTarget));
                eHowl = GetScaledEffect(eHowl, spInfo.oTarget);
                eHowl = EffectLinkEffects(eHowl, eDur);
                eHowl = EffectLinkEffects(eHowl, eDurVis);
            }


            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
            if(!GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster, fDelay)) {
                if(iSpellID==271) {
                    iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, 0);
                    eHowl = EffectDamage(iDamage, DAMAGE_TYPE_SONIC);
                }
                if(iVisual!=-1)
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                if(iDurationType!=DURATION_TYPE_TEMPORARY) {
                    DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eHowl, spInfo.oTarget));
                } else {
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHowl, spInfo.oTarget, fDuration));
                }
            } else if(iSpellID==271) {
                iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, 0)/2;
                if(iDamage==0) iDamage=1;
                eHowl = EffectDamage(iDamage, DAMAGE_TYPE_SONIC);
                DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eHowl, spInfo.oTarget));
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spInfo.lTarget);
    }

    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
