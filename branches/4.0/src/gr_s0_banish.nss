//*:**************************************************************************
//*:*  GR_S0_BANISH.NSS
//*:**************************************************************************
//*:* Banish Shadow
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 24, 2003
//*:*
//*:* Banishment
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 7, 2003
//*:* 3.5 Player's Handbook (p. 203)
//*:*
//*:* Dismissal
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 7, 2003
//*:* 3.5 Player's Handbook (p. 222)
//*:*
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

    int     iDieType        = 4;
    int     iNumDice        = 3;
    int     iBonus          = (spInfo.iCasterLevel>10 ? 10 : spInfo.iCasterLevel);
    int     iDamage         = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    if(spInfo.iSpellID==SPELL_DISMISSAL) {
        spInfo.iDC = spInfo.iDC - GetHitDice(spInfo.oTarget) + spInfo.iCasterLevel;
    }

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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(15.0);

    float   fDelay          = 0.5f;
    int     iHDPool         = (spInfo.iSpellID==SPELL_BANISHMENT ? spInfo.iCasterLevel*2 : 9999);
    int     bMultiTarget    = (spInfo.iSpellID==SPELL_BANISHMENT);
    /*** NWN2 SPECIFIC ***
    string  sTargetName     = GetStringLeft(GetName(spInfo.oTarget),7);
    int     iAppearanceType = GetAppearanceType(spInfo.oTarget);
    int     bShadowTarget   = ((sTargetName=="Shadow" || iAppearanceType==180 || iAppearanceType==146 || iAppearanceType==147 || iAppearanceType==418)
                                && GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD);
    /*** END NWN2 SPECIFIC ***/
    /*** NWN1 SPECIFIC ***/
        int     bShadowTarget   = (GetTag(GetItemInSlot(INVENTORY_SLOT_CARMOUR, spInfo.oTarget))=="NW_IT_CREITEMUN4" ||
                                    GetTag(GetItemInSlot(INVENTORY_SLOT_CARMOUR, spInfo.oTarget))=="NW_IT_CREITEMUN5") &&
                                    GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD;

        int     iIndVisType     = VFX_IMP_EVIL_HELP;
        if(spInfo.iSpellID==SPELL_GR_BANISH_SHADOW) iIndVisType = VFX_IMP_DISPEL;
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ int  iIndVistype     = VFX_HIT_SPELL_ABJURATION;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ effect eImpact      = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    //*** NWN1 SINGLE ***/ effect eImpact       = EffectVisualEffect(VFX_HIT_AOE_ABJURATION);
    effect eIndVis      = EffectVisualEffect(iIndVisType);
    effect eUnsummon    = EffectVisualEffect(VFX_IMP_UNSUMMON);
    effect eDmg         = EffectDamage(iDamage, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if((spInfo.iSpellID!=SPELL_GR_BANISH_SHADOW && (GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_OUTSIDER || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ELEMENTAL)) ||
                (spInfo.iSpellID==SPELL_GR_BANISH_SHADOW && bShadowTarget)) {

                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay) && GetHitDice(spInfo.oTarget)<=iHDPool) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                        if(CanCreatureBeDestroyed(spInfo.oTarget) == TRUE && !GetHasSpellEffect(SPELL_GR_DIMENSIONAL_ANCHOR, spInfo.oTarget)) {
                            GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eIndVis, GetLocation(spInfo.oTarget));
                            iHDPool -= GetHitDice(spInfo.oTarget);
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eUnsummon, spInfo.oTarget));
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetCurrentHitPoints(spInfo.oTarget)+20), spInfo.oTarget));
                            DelayCommand(fDelay+0.3, GRApplyEffectToObject(DURATION_TYPE_INSTANT, SupernaturalEffect(EffectDeath(FALSE, FALSE)), spInfo.oTarget));
                        }
                    } else if(spInfo.iSpellID==SPELL_GR_BANISH_SHADOW) {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, spInfo.oTarget);
                    }
                }
            }
            if(bMultiTarget)
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);

        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && (iHDPool>0));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
