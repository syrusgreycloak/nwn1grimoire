//*:**************************************************************************
//*:*  GR_S0_ACIDARROW.NSS
//*:**************************************************************************
//*:*
//*:* Melf's Acid Arrow (nw_s0_acidarrow.nss) by Bioware Corp.
//*:*
//*:* 3.5 Player's Handbook (p. 253)
//*:*
//*:**************************************************************************
//:: Created By: Aidan Scanlan
//:: Created On: 01/09/01
//*:**************************************************************************
//*:* Updated On: November 2, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = 4;
    int     iNumDice          = 2;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = MinInt(7, 1+spInfo.iCasterLevel/3);
    int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    /*** NWN1 SPECIFIC ***/ 
        int     iVisualType     = VFX_IMP_ACID_L;
        int     iDurVisType     = VFX_DUR_CESSATE_NEGATIVE;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC *** 
        int     iVisualType     = VFX_HIT_SPELL_ACID;
        int     iDurVisType     = VFX_DUR_SPELL_MELFS_ACID_ARROW;
    /*** END NWN2 SPECIFIC ***/
    int     iMirvType       = GRGetEnergyMirvType(iEnergyType);
    iVisualType     = GRGetEnergyVisualType(iVisualType, iEnergyType);

    float   fDist           = GetDistanceToObject(spInfo.oTarget);
    float   fDelay          = (fDist/25.0);//(3.0 * log(fDist) + 2.0);
    float   fPercent        = 1.0;
    object  oAOE;
    int     iAttackResult   = GRTouchAttackRanged(spInfo.oTarget);
    string  sAOEType        = AOE_TYPE_MELFS_ACID_ARROW;
    
    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo) * iAttackResult;
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDur     = EffectVisualEffect(iDurVisType);
    effect eArrow   = EffectVisualEffect(iMirvType);
    effect eDam     = EffectDamage(iDamage, iEnergyType);
    effect eSmoke   = EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE);
    effect eAOE     = GREffectAreaOfEffect(AOE_MOB_MELFS_ACID_ARROW, "", "", "", sAOEType);
    effect eSave    = EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE);
    effect eLink    = EffectLinkEffects(eDur, eAOE);

    if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Set the VFX to be non-dispellable, because
    //*:* the acid is not magic
    //*:**********************************************
    eLink = ExtraordinaryEffect(eLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:**********************************************
    //*:* This spell no longer stacks. If there is one
    //*:* of that type, thats ok
    //*:**********************************************
    if(spInfo.iSpellID==SPELL_MELFS_ACID_ARROW && GRGetHasSpellEffect(SPELL_MELFS_ACID_ARROW, spInfo.oTarget)) {
        FloatingTextStrRefOnCreature(100775, oCaster, FALSE);
        return;
    }

    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        if(iAttackResult>0 && !GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(spInfo.iSpellID==SPELL_GR_SHADOW_CON_MELFS_ACID_ARROW && GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSave, spInfo.oTarget));
                iDamage = FloatToInt(iDamage*0.40); // will disbelief - damage at 40%
                fPercent = 0.40;
                eDam = EffectDamage(iDamage, iEnergyType);
            }
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }

            //*:**********************************************
            //*:* Apply the VFX that is used to track the spells duration
            //*:**********************************************
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration));

            /*** NWN1 SINGLE ***/ oAOE = GRGetAOEOnObject(spInfo.oTarget, sAOEType, oCaster);
            //*** NWN2 SINGLE ***/ oAOE = GetObjectByTag(sAOEType);
            GRSetAOESpellId(spInfo.iSpellID, oAOE);
            GRSetAOEVisualType(iVisualType, oAOE);
            GRSetAOEDamagePercentage(fPercent, oAOE);
            GRSetSpellInfo(spInfo, oAOE);
        } /*** NWN1 SPECIFIC ***/ else {
            //*:**********************************************
            //*:* Indicate Failure
            //*:**********************************************
            DelayCommand(fDelay+0.1f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, spInfo.oTarget));
        } /*** END NWN1 SPECIFIC ***/
    }
    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eArrow, spInfo.oTarget);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
