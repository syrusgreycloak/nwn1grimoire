//*:**************************************************************************
//*:*  GR_S0_LESSRORB.NSS
//*:**************************************************************************
//*:* Lesser Orb of (Acid/Cold/Electricity/Fire/Sound)(sg_s0_lessrorb.nss)
//*:* 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 15, 2003
//*:* Spell Compendium (p. 150-151)
//*:**************************************************************************
//*:* Updated On: February 27, 2008
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

    int     iDieType          = 0;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDist           = GetDistanceBetween(oCaster, spInfo.oTarget);
    float   fDelay          = fDist/(3.0 * log(fDist) + 2.0);
    //*:* float   fRange          = FeetToMeters(15.0);

    float   fDelay2, fTime;

    int     iMissiles       = MinInt(5, (spInfo.iCasterLevel+1)/2);
    int     iCount;
    int     iVisualType;
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iAttackResult;

    switch(spInfo.iSpellID) {
        case SPELL_GR_LESSER_ACID_ORB:
            iVisualType = VFX_COM_HIT_ACID;
            break;
        case SPELL_GR_LESSER_COLD_ORB:
            iVisualType = VFX_COM_HIT_FROST;
            break;
        case SPELL_GR_LESSER_ELECTRIC_ORB:
            iVisualType = VFX_COM_HIT_ELECTRICAL;
            break;
        case SPELL_GR_LSC_LESSER_FIRE_ORB:
        case SPELL_GR_LESSER_FIRE_ORB:
            iVisualType = VFX_COM_HIT_FIRE;
            break;
        case SPELL_GR_LESSER_SONIC_ORB:
            iVisualType = VFX_COM_HIT_SONIC;
            break;
    }

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
    effect  eImp    = EffectVisualEffect(GRGetEnergyVisualType(iVisualType, iEnergyType));
    effect  eDamage;
    effect  eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    iAttackResult = GRTouchAttackRanged(spInfo.oTarget);
    if(iAttackResult>0) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
            for(iCount = 1; iCount <= iMissiles; iCount++) {
                iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, oCaster, iSaveType, fDelay)*iAttackResult;
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, FORTITUDE_HALF, oCaster)*iAttackResult;
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                fTime = fDelay;
                fDelay2 += 0.1;
                fTime += fDelay2;
                if(spInfo.iSpellSchool==SPELL_SCHOOL_ILLUSION) {
                    if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                        iDamage = FloatToInt(iDamage*0.20);
                    }
                }
                if(iDamage>0) {
                    eDamage = EffectDamage(iDamage, iEnergyType);
                    eLink= EffectLinkEffects(eDamage, eImp);
                    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    DelayCommand(fTime, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget));
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                }
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
