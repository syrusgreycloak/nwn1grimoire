//*:**************************************************************************
//*:*  GR_S0_FIREBRAND.NSS
//*:**************************************************************************
//*:* Firebrand (x0_x0_Firebrand) Copyright (c) 2002 Bioware Corp.
//*:* Created By: Brent   Created On: July 29 2002
//*:* Spell Compendium (p. 93)
//*:**************************************************************************
//*:* Updated On: November 26, 2007
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

    int     iDieType          = 6;
    int     iNumDice          = MinInt(15, spInfo.iCasterLevel);
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

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);
    int     iVisualType2    = GRGetEnergyVisualType(VFX_IMP_FLAME_S, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iMirvType       = GRGetEnergyMirvType(iEnergyType);

    float   fRange          = FeetToMeters(100.0 + 10.0*spInfo.iCasterLevel);
    float   fRadius         = FeetToMeters(5.0);
    float   fDmgPercent     = (spInfo.iSpellID==SPELL_GR_GSE1_FIREBRAND ? 0.6 : 1.0);
    int     iNumBrands      = spInfo.iCasterLevel;
    int     bAlreadyAffected= FALSE;
    string  sCasterString   = ObjectToString(oCaster);
    float   fDist           = GetDistanceBetween(OBJECT_SELF, spInfo.oTarget);
    float   fDelay          = fDist/(3.0 * log(fDist) + 2.0);
    float   fDelay2, fTime;
    object  oSubTarget;


    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eVis2    = EffectVisualEffect(iVisualType2);
    effect eBolt    = EffectVisualEffect(iMirvType);
    effect eDam;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* Get first target in range - range is 100 ft + 10 ft / level
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
    //*:* while target is valid object and we still have bursts left
    while(GetIsObjectValid(spInfo.oTarget) && iNumBrands>0) {
        //*:* check if target has already been affected
        bAlreadyAffected = GetLocalInt(spInfo.oTarget, "GR_FIREBRAND_" + sCasterString);
        //*:* if hostile target, and not already affected
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster) && !bAlreadyAffected) {
            //*:* fire bolt and get bolt delay ala magic missile, then fire visual impact
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, spInfo.oTarget);
            fDist = GetDistanceBetween(oCaster, spInfo.oTarget);
            fDelay = fDist/(3.0 * log(fDist) + 2.0);
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
            //*:* get targets for burst
            oSubTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRadius, GetLocation(spInfo.oTarget), TRUE);
            while(GetIsObjectValid(oSubTarget)) {
                //*:* check if already affected again - initial target may not have been affected
                //*:* but overlapping burst areas do not do more damage
                bAlreadyAffected = GetLocalInt(oSubTarget, "GR_FIREBRAND_"+sCasterString);
                if(GRGetIsSpellTarget(oSubTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster) && !bAlreadyAffected) {
                    //*:* check if resist burst, save, etc.  Apply damage
                    if(!GRGetSpellResisted(oCaster, oSubTarget)) {
                        spInfo.iDC = GRGetSpellSaveDC(oCaster, oSubTarget);
                        iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                        if(GRGetSpellHasSecondaryDamage(spInfo)) {
                            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                iDamage = iSecDamage;
                            }
                        }
                        if(iDamage>0 && spInfo.iSpellID==SPELL_GR_GSE1_FIREBRAND) {
                            if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                                iDamage = FloatToInt(iDamage * fDmgPercent);
                            }
                        }
                        eDam = EffectDamage(iDamage, iEnergyType);
                        if(iDamage>0) {
                            if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                            fDelay2 = GetDistanceBetweenLocations(GetLocation(spInfo.oTarget), GetLocation(oSubTarget))/20;
                            fTime = fDelay + fDelay2;
                            if(oSubTarget!=spInfo.oTarget) {
                                DelayCommand(fTime, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oSubTarget));
                            }
                            DelayCommand(fTime+0.1, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oSubTarget));
                            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                            }
                        }
                    }
                    //*:* update creature as affected
                    SetLocalInt(oSubTarget, "GR_FIREBRAND_" + sCasterString, TRUE);
                    //*:* need to remove int so that future spells will work
                    DelayCommand(GRGetDuration(1), DeleteLocalInt(oSubTarget, "GR_FIREBRAND_" + sCasterString));
                }
                //*:* get next burst target
                oSubTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRadius, GetLocation(spInfo.oTarget), TRUE);
            }
            //*:* done with this burst
            iNumBrands--;
        }
        //*:* get next initial burst target
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
