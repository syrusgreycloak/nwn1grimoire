//*:**************************************************************************
//*:*  GR_S0_BLESSLINE.NSS
//*:**************************************************************************
//*:*
//*:* Bless - +1 to attacks, save vs fear for allies (50 ft around caster)
//*:*           1 min/level
//*:* Prayer - +1 to attacks, dmg, saves, skills for allies,
//*:*           -1 for enemies (40 ft around caster)  1 round/level
//*:* Recitation - +2 to AC, attacks, saves for allies (+3 if same deity),
//*:*               -2 for enemies (60 ft around caster)   1 round/level
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: October 25, 2007
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
#include "GR_IN_ITEMPROP"

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
    int     iBonus            = 1;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = (spInfo.iSpellID==SPELL_BLESS ? DUR_TYPE_TURNS : DUR_TYPE_ROUNDS);

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
    float   fRange;          //= FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iSaveType       = SAVING_THROW_TYPE_ALL;
    int     iPosVisType;
    /*** NWN1 SINGLE ***/ iPosVisType     = VFX_IMP_HOLY_AID;
    //*** NWN2 SINGLE ***/ int      iNegVisType     = VFX_DUR_SPELL_PRAYER_VIC;

    switch(spInfo.iSpellID) {
        case SPELL_BLESS:
            iSaveType = SAVING_THROW_TYPE_FEAR;
            /*** NWN1 SINGLE ***/ iPosVisType = VFX_IMP_HEAD_HOLY;
            //*** NWN2 SINGLE ***/ iPosVistype = VFX_DUR_SPELL_BLESS;
            fRange = FeetToMeters(50.0);
            break;
        case SPELL_PRAYER:
            //*** NWN2 SINGLE ***/ iPosVistype = VFX_DUR_SPELL_PRAYER;
            fRange = FeetToMeters(40.0);
            break;
        case SPELL_GR_RECITATION:
            //*** NWN2 SINGLE ***/ iPosVistype = VFX_DUR_SPELL_RECITATION;
            iBonus = 2;
            fRange = FeetToMeters(60.0);
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration       = ApplyMetamagicDurationMods(fDuration);
        iDurationType   = ApplyMetamagicDurationTypeMods(iDurationType);
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
    /*** NWN1 SPECIFIC ***/
        effect ePosVis = EffectVisualEffect(iPosVisType);
        effect eNegVis = EffectVisualEffect(VFX_IMP_DOOM);
        effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eImpact = EffectVisualEffect(VFX_HIT_AOE_ENCHANTMENT);

    effect ePosAttack   = EffectAttackIncrease(iBonus);
    effect ePosSave     = EffectSavingThrowIncrease(SAVING_THROW_ALL, iBonus, iSaveType);
    effect ePosAC       = EffectACIncrease(iBonus, AC_DODGE_BONUS, AC_VS_DAMAGE_TYPE_ALL);
    effect ePosDam      = EffectDamageIncrease(GRGetDamageBonusValue(iBonus), DAMAGE_TYPE_DIVINE);
    effect ePosSkill    = EffectSkillIncrease(SKILL_ALL_SKILLS, iBonus);
    /*** NWN1 SINGLE ***/ effect ePosDur      = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    //*** NWN2 SINGLE ***/ effect ePosDur     = EffectVisualEffect(iPosVisType);

    effect ePosLink     = EffectLinkEffects(ePosAttack, ePosSave);
    ePosLink            = EffectLinkEffects(ePosLink, ePosDur);

    if(spInfo.iSpellID==SPELL_PRAYER) {
        ePosLink            = EffectLinkEffects(ePosLink, ePosDam);
        ePosLink            = EffectLinkEffects(ePosLink, ePosSkill);
    } else if(spInfo.iSpellID==SPELL_GR_RECITATION) {
        ePosLink            = EffectLinkEffects(ePosLink, ePosAC);
    }

    effect eNegAttack   = EffectAttackDecrease(iBonus);
    effect eNegSave     = EffectSavingThrowDecrease(SAVING_THROW_ALL, iBonus);
    effect eNegDam      = EffectDamageDecrease(iBonus, DAMAGE_TYPE_DIVINE);
    effect eNegSkill    = EffectSkillDecrease(SKILL_ALL_SKILLS, iBonus);
    /*** NWN1 SINGLE ***/ effect eNegDur      = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    //*** NWN2 SINGLE ***/ effect eNegDur     = EffectVisualEffect(iNegVisType);

    effect eNegLink     = EffectLinkEffects(eNegAttack, eNegSave);
    eNegLink            = EffectLinkEffects(eNegLink, eNegDam);
    eNegLink            = EffectLinkEffects(eNegLink, eNegSkill);
    eNegLink            = EffectLinkEffects(eNegLink, eNegDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.iSpellID==SPELL_BLESS) {
        // ---------------- TARGETED ON BOLT  -------------------
        if(GetIsObjectValid(spInfo.oTarget) && GetObjectType(spInfo.oTarget)==OBJECT_TYPE_ITEM) {
            // special handling for blessing crossbow bolts that can slay rakshasa's
            if(GetBaseItemType(spInfo.oTarget)==BASE_ITEM_BOLT) {
                SignalEvent(GetItemPossessor(spInfo.oTarget), EventSpellCastAt(OBJECT_SELF, spInfo.iSpellID, FALSE));
                GRIPSafeAddItemProperty(spInfo.oTarget, ItemPropertyOnHitCastSpell(123,1), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
                /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePosVis, GetItemPossessor(spInfo.oTarget));
                GRApplyEffectToObject(iDurationType, ePosVis, GetItemPossessor(spInfo.oTarget), fDuration);
                return;
            }
        }
    }


    /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, GetLocation(oCaster));

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(spInfo.iSpellID==SPELL_PRAYER && GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, TRUE));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eNegVis, spInfo.oTarget);
                GRApplyEffectToObject(iDurationType, eNegLink, spInfo.oTarget, fDuration);
            }
        } else if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, TRUE)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
            /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePosVis, spInfo.oTarget);
            if(spInfo.iSpellID==SPELL_GR_RECITATION && GetStringLowerCase(GetDeity(spInfo.oTarget))==GetStringLowerCase(GetDeity(oCaster))) {
                ePosAttack  = EffectAttackIncrease(iBonus+1);
                ePosSave    = EffectSavingThrowIncrease(SAVING_THROW_ALL, iBonus+1, iSaveType);
                ePosAC      = EffectACIncrease(iBonus+1, AC_DODGE_BONUS, AC_VS_DAMAGE_TYPE_ALL);
                ePosLink    = EffectLinkEffects(ePosAttack, ePosSave);
                ePosLink    = EffectLinkEffects(ePosLink, ePosDur);
                ePosLink    = EffectLinkEffects(ePosLink, ePosAC);
            }
            GRApplyEffectToObject(iDurationType, ePosLink, spInfo.oTarget, fDuration);
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, GetLocation(oCaster));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
