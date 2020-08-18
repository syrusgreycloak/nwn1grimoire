//*:**************************************************************************
//*:*  GR_S0_CHLTCH.NSS
//*:**************************************************************************
//*:* Chill Touch
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 31, 2003
//*:* 3.5 Player's Handbook (p. 209)
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

    int     iNumTargets     = GetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_TARGETS");
    object  oItem           = GetSpellCastItem();

    //*:**********************************************
    //*:* Special wand item checking
    //*:**********************************************
    int     bHasWand        = (GetItemPossessedBy(oCaster, "GR_IT_HNDCHLTCH")!=OBJECT_INVALID);
    int     bUsingWand      = (GetTag(oItem)=="GR_IT_HNDCHLTCH");
    int     bFirstCast      = (iNumTargets==0 && !bUsingWand);
    int     bRecastInitial  = (bHasWand && !bUsingWand);
    int     bHasSpellEffect = (GRGetHasEffectTypeFromSpell(EFFECT_TYPE_VISUALEFFECT, oCaster, SPELL_GR_CHILL_TOUCH, oCaster));
    int     bDestroyFirst   = FALSE;
    int     bDestroyAfter   = FALSE;

    //*:**********************************************
    //*:* Using wand correctly - get previous spell cast info
    //*:**********************************************
    if(bUsingWand && bHasSpellEffect && iNumTargets>0) {
        spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oItem);
    } else {
        //*:**********************************************
        //*:* Recasting initial spell while spell still active
        //*:* Destroy current wand, reset target number to 0,
        //*:* remove previous spell effects, set first cast true
        //*:**********************************************
        if(bRecastInitial) {
            GRRemoveSpellEffects(SPELL_GR_CHILL_TOUCH, oCaster, oCaster); /* include oCaster as caster in case we've been hit with
                                                                             the spell by someone else so we only remove our spell */
            object oWand = GetItemPossessedBy(oCaster, "GR_IT_HNDCHLTCH");
            SetPlotFlag(oWand, FALSE);
            DestroyObject(oWand);
            iNumTargets = 0;
            bFirstCast = TRUE;
            DeleteLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_TARGETS");
        }

        //*:**********************************************
        //*:* Caster no longer has visual effect from spell
        //*:* or no longer has targets remaining but has wand -
        //*:* dispelled effect, logged off, or item possessed by
        //*:* someone other than original caster - destroy wand
        //*:**********************************************
        if((bHasWand && !bHasSpellEffect) || (bHasWand && iNumTargets<=0)) {
            object oWand = GetItemPossessedBy(oCaster, "GR_IT_HNDCHLTCH");
            SetPlotFlag(oWand, FALSE);
            DestroyObject(oWand);
            DeleteLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_TARGETS");
            return;
        }
    }

    int     iDieType        = 6;
    int     iNumDice        = 1;
    int     iBonus          = 0;
    int     iDamage         = 0;
    int     iSecDamage      = 0;
    int     iDurAmount      = GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic) + spInfo.iCasterLevel;
    int     iDurType        = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
        //*:* First cast and caster is targetting self to
        //*:* just create the wand
        //*:**********************************************
        if(bFirstCast && spInfo.oTarget==oCaster) {
            CreateItemOnObject("GR_IT_HNDCHLTCH", oCaster, 1);
            object oWand = GetItemPossessedBy(oCaster, "GR_IT_HNDCHLTCH");
            SetItemCharges(oWand, spInfo.iCasterLevel);
            SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_TARGETS", spInfo.iCasterLevel);
            SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_CHILL_TOUCH, FALSE));
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_GLOW_LIGHT_BLUE), oCaster, GRGetDuration(7, DUR_TYPE_DAYS));
            if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
            return;
        }

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = GetRandomDelay(0.4, 1.1);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAttackResult   = TouchAttackMelee(spInfo.oTarget);
    int     iSaveResult;
    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NEGATIVE, fDelay);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eSaveVis     = EffectVisualEffect(VFX_IMP_FORTITUDE_SAVING_THROW_USE);

    effect eVis         = EffectVisualEffect(VFX_IMP_FROST_S);
    effect eDam         = EffectDamage(iDamage, DAMAGE_TYPE_NEGATIVE);
    effect eStr         = EffectAbilityDecrease(ABILITY_STRENGTH,1);
    effect eLink        = EffectLinkEffects(eVis,eDam);

    effect eUndFear     = EffectTurned();

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_CHILL_TOUCH));
    if(iAttackResult>0) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
           if(GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_UNDEAD) {
               iSaveResult = FortitudeSave(spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NEGATIVE);
               if(iSaveResult!=2) {
                   if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                   DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                   if(iSaveResult==0) {
                       DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eStr, spInfo.oTarget));
                   } else {
                       DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSaveVis, spInfo.oTarget));
                   }
               }
            } else {
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SPELL)) {
                   DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eUndFear, spInfo.oTarget, fDuration));
                }
            }
        }
    }
    if(bFirstCast) {
        CreateItemOnObject("GR_IT_HNDCHLTCH", oCaster, 1);
        object oWand = GetItemPossessedBy(oCaster, "GR_IT_HNDCHLTCH");
        SetItemCharges(oWand, spInfo.iCasterLevel-1);
        SetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_TARGETS", spInfo.iCasterLevel-1);
        SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_CHILL_TOUCH, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_GLOW_LIGHT_BLUE), oCaster, GRGetDuration(7, DUR_TYPE_DAYS));
        if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    }
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
