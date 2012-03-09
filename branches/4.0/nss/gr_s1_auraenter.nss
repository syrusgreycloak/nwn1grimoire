//*:**************************************************************************
//*:*  GR_S1_AURAENTER.NSS
//*:**************************************************************************
//*:* Master Script for all the common auras with OnEnter scripts
//*:**************************************************************************
//*:* Updated On: February 20, 2008
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

#include "GR_IN_DEBUG"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();

    AutoDebugString("Aura caster is " + GetName(oCaster));

    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    spInfo.oTarget = GetEnteringObject();
    AutoDebugString("Entering object is " + GetName(spInfo.oTarget));

    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

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
    /*if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);*/

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iDurVisType         = VFX_DUR_CESSATE_NEGATIVE;
    int     iVisualType         = VFX_IMP_DEATH;
    effect  eEffect;
    int     iSavingThrow        = SAVING_THROW_WILL;
    int     iSaveType           = SAVING_THROW_TYPE_NONE;
    int     iSpellTargetType    = SPELL_TARGET_SELECTIVEHOSTILE;
    int     bIncludeCaster      = NO_CASTER;
    int     iEffectDurationType = DURATION_TYPE_TEMPORARY;
    int     bNoSave             = FALSE;
    int     bMeetsRaceReqs      = TRUE;

    AutoDebugString("Setting Variables for Aura type");
    switch(spInfo.iSpellID) {
        case 195: // Aura of Blinding
            eEffect = EffectBlindness();
            iDurAmount = (spInfo.iCasterLevel+12)/9;
            iVisualType = VFX_IMP_BLIND_DEAF_M;
            break;
        case 198: // Aura of Fear
            eEffect = EffectFrightened();
            iDurAmount = GetScaledDuration(spInfo.iCasterLevel, spInfo.oTarget);
            /*** NWN1 SPECIFIC ***/
                iVisualType = VFX_IMP_FEAR_S;
                iDurVisType = VFX_DUR_MIND_AFFECTING_FEAR;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iVisualType = -1;
                iDurVisType = VFX_DUR_SPELL_FEAR;
            /*** END NWN2 SPECIFIC ***/
            iSaveType = SAVING_THROW_TYPE_FEAR;
            break;
        case 200: // Aura of Menacing
            eEffect = CreateDoomEffectsLink();
            iDurAmount = spInfo.iCasterLevel/3 + 1;
            iVisualType = VFX_IMP_DOOM;
            break;
        case 201: // Aura of Protection
            eEffect = GREffectProtectionFromAlignment(ALIGNMENT_EVIL);
            eEffect = EffectLinkEffects(eEffect, EffectSpellLevelAbsorption(3, 0));
            iEffectDurationType = DURATION_TYPE_PERMANENT;
            iDurVisType = VFX_DUR_GLOBE_MINOR;
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_HEAD_HOLY;
            //*** NWN2 SINGLE ***/ iVisualType = -1;
            iSpellTargetType = SPELL_TARGET_ALLALLIES;
            bIncludeCaster = TRUE;
            bNoSave = TRUE;
            break;
        case 202: // Aura of Stunning
            eEffect = EffectStunned();
            iDurAmount = GetScaledDuration(spInfo.iCasterLevel/3+1, spInfo.oTarget);
            /*** NWN1 SPECIFIC ***/
                iDurVisType = VFX_DUR_MIND_AFFECTING_DISABLED;
                iVisualType = VFX_IMP_STUN;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iDurVisType = VFX_DUR_SPELL_DAZE;
                iVisualType = VFX_HIT_SPELL_ENCHANTMENT;
            /*** END NWN2 SPECIFIC ***/
            iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
            break;
        case 203: // Aura of Unearthly Visage
            eEffect = EffectDeath();
            iEffectDurationType = DURATION_TYPE_INSTANT;
            iVisualType = VFX_IMP_DEATH;
            iSaveType = SAVING_THROW_TYPE_DEATH;
            fDelay = 0.7f;
            break;
        case 204: // Unnatural Aura
            eEffect = EffectFrightened();
            iDurAmount = spInfo.iCasterLevel/3+1;
            /*** NWN1 SPECIFIC ***/
                iVisualType = VFX_IMP_FEAR_S;
                iDurVisType = VFX_DUR_MIND_AFFECTING_FEAR;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iVisualType = -1;
                iDurVisType = VFX_DUR_SPELL_FEAR;
            /*** END NWN2 SPECIFIC ***/
            iSaveType = SAVING_THROW_TYPE_FEAR;
            bMeetsRaceReqs = (GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ANIMAL);
            break;
        case 412: // Aura Dragon Fear
            int iHD = GetHitDice(oCaster);
            eEffect = EffectFrightened();
            iDurAmount = (GetTag(oCaster)=="q3_vixthra" ? 3+d6() : MinInt(20, GetScaledDuration(iHD, spInfo.oTarget)));
            spInfo.iDC = GetDragonFearDC(iHD);
            /*** NWN1 SPECIFIC ***/
                iVisualType = VFX_IMP_FEAR_S;
                iDurVisType = VFX_DUR_MIND_AFFECTING_FEAR;
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iVisualType = -1;
                iDurVisType = VFX_DUR_SPELL_FEAR;
            /*** END NWN2 SPECIFIC ***/
            iSaveType = SAVING_THROW_TYPE_FEAR;
            break;
    }

    fDuration = GRGetDuration(iDurAmount, iDurType);
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
    AutoDebugString("Defining effects");
    effect eDurVis  = EffectVisualEffect(iDurVisType);
    effect eVis;
    if(iVisualType!=-1) eVis = EffectVisualEffect(iVisualType);

    effect eLink;

    if(iEffectDurationType!=DURATION_TYPE_INSTANT) {
        eLink = EffectLinkEffects(eEffect, eDurVis);
    } else {
        eLink = eEffect;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    AutoDebugString("Applying effects");
    if(GRGetIsSpellTarget(spInfo.oTarget, iSpellTargetType, oCaster, bIncludeCaster) && bMeetsRaceReqs) {
        AutoDebugString(GetName(spInfo.oTarget) + " is a spell target");
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        if(bNoSave || (bNoSave && !GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster))) {
            if(iVisualType!=-1) GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
            if(fDelay==0.0f) {
                GRApplyEffectToObject(iEffectDurationType, eLink, spInfo.oTarget, fDuration);
            } else {
                DelayCommand(fDelay, GRApplyEffectToObject(iEffectDurationType, eLink, spInfo.oTarget, fDuration));
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
