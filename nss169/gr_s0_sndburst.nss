//*:**************************************************************************
//*:*  GR_S0_SNDBURST.NSS
//*:**************************************************************************
//*:* Sound Burst [NW_S0_SndBurst.nss] Copyright (c) 2000 Bioware Corp.
//*:* Created By: Preston Watamaniuk Created On: Jan 31, 2001
//*:* 3.5 Player's Handbook (p. 281)
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

    int     iDieType          = 8;
    int     iNumDice          = 1;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 2;
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
    float   fRange          = FeetToMeters(10.0);
    float   fDelay;

    int     iExplodeType    = GRGetEnergyExplodeType(iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    /*** NWN1 SINGLE ***/ int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_SONIC, iEnergyType);
    //*** NWN2 SINGLE ***/ int     iVisualType     = GRGetEnergyVisualType(VFX_HIT_SPELL_SONIC, iEnergyType);

    if(GRGetIsUnderwater(oCaster) && iEnergyType==DAMAGE_TYPE_SONIC) fRange *=2.0;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 1.5;
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
    effect eStun    = EffectStunned();
    effect eVis     = EffectVisualEffect(iVisualType);
    /*** NWN1 SPECIFIC ***/
        effect eFNF     = EffectVisualEffect(iExplodeType);
        effect eMind    = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eMind = EffectVisualEffect(VFX_DUR_STUN);
    effect eDam;

    effect eDurLink = EffectLinkEffects(eStun, eMind);
    /*** NWN1 SINGLE ***/ eDurLink = EffectLinkEffects(eDurLink, eDur);

    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFNF, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_SOUND_BURST));
            fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20.0;
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                iDamage = GRGetSpellDamageAmount(spInfo);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, iSaveType)) {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDurLink, spInfo.oTarget, fDuration);
                }
                eDam = EffectDamage(iDamage, iEnergyType);
                eLink = EffectLinkEffects(eVis, eDam);
                if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
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
