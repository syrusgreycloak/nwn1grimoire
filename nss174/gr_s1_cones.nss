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

    if(GetHasSpellEffect(SPELL_GR_SUPPRESS_BREATH_WEAPON, oCaster)) {
        return;
    }

    int     iDieType          = 6;
    int     iNumDice          = 2;
    int     iBonus            = 0;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;
    spInfo.iDC = 10 + spInfo.iCasterLevel/2;

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = 10.0;
    float   fDelay          = 0.0f;
    float   fMaxDelay       = 0.0f;

    int     iCount          = MaxInt(1, spInfo.iCasterLevel/3);
    int     iVisual         = -1;
    int     iSpellID        = GetSpellId();
    int     iDamageType     = -1;
    int     iSaveType       = -1;
    int     iDurationType   = DURATION_TYPE_INSTANT;
    int     iDisease;
    int     iPoison;
    int     i;
    int     bNoSave         = FALSE;
    //*** NWN2 SINGLE ***/ int iConeVis     = -1;

    for(i=iCount; i>0; i--) {
        iDamage += GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, iBonus);
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
    effect  eCone;
    effect  eLightning;

    switch(iSpellID) {
        case 229:  // Cone Acid
            iVisual = VFX_IMP_ACID_S;
            iDamageType = DAMAGE_TYPE_ACID;
            iSaveType = SAVING_THROW_TYPE_ACID;
            //*** NWN2 SINGLE ***/ iConeVis = VFX_DUR_CONE_ACID;
            break;
        case 230:  // Cone Cold
            iVisual = VFX_IMP_FROST_S;
            iDamageType = DAMAGE_TYPE_COLD;
            iSaveType = SAVING_THROW_TYPE_COLD;
            iNumDice *= iCount;
            iDamage = d6(iNumDice);
            //*** NWN2 SINGLE ***/ iConeVis = VFX_DUR_WINTER_WOLF_BREATH;
            break;
        case 231:  // Cone Disease
            iDurationType = DURATION_TYPE_INSTANT;
            eCone = EffectDisease(GRGetDiseaseType(spInfo.iCasterLevel));
            //*** NWN2 SINGLE ***/ iConeVis = VFX_DUR_CONE_POISON;
            break;
        case 232:  // Cone Lightning
            iVisual = VFX_IMP_LIGHTNING_S;
            iDamageType = DAMAGE_TYPE_ELECTRICAL;
            iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
            /*** NWN1 SPECIFIC ***/
                eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oCaster, BODY_NODE_HAND);
                fDuration = 0.5;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/ iConeVis = VFX_DUR_CONE_LIGHTNING;
            break;
        case 264:  // Hell-hound fire breath
            iDieType = 4;
            iNumDice = 1;
            iBonus   = 1;
            iDamage  = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, iBonus);
            bNoSave  = TRUE;
            fRange   = 11.0;
        case 233:  // Cone Fire
            iVisual = VFX_IMP_FLAME_S;
            iDamageType = DAMAGE_TYPE_FIRE;
            iSaveType = SAVING_THROW_TYPE_FIRE;
            //*** NWN2 SINGLE ***/ iConeVis = VFX_DUR_CONE_FIRE;
            break;
        case 234:  // Cone Poison
        case 263:  // Cone Golem Gas (poison)
            iVisual = VFX_IMP_POISON_S;
            iDurationType = DURATION_TYPE_INSTANT;
            eCone = EffectPoison(GRGetPoisonType(spInfo.iCasterLevel));
            //*** NWN2 SINGLE ***/ iConeVis = (spInfo.iSpellID==234 ? VFX_DUR_CONE_POISON : VFX_DUR_CONE_ACID_BREATH);
            break;
        case 235:  // Cone Sonic
            iVisual = VFX_IMP_SONIC;
            iDamageType = DAMAGE_TYPE_SONIC;
            iSaveType = SAVING_THROW_TYPE_SONIC;
            //*** NWN2 SINGLE ***/ iConeVis = VFX_DUR_CONE_SONIC;
            break;
    }


    effect eVis     = EffectVisualEffect(iVisual);
    /*** NWN2 SPECIFIC ***
        effect eSpray;
        if(iConeVis!=-1) eSpray = EffectVisualEffect(iConeVis);
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, 10.0, spInfo.lTarget, TRUE);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
            //*** NWN2 SINGLE ***/ if(fDelay>fMaxDelay) fMaxDelay = fDelay;
            if(spInfo.iSpellID!=263 && !GetHasSpellEffect(SPELL_GR_FILTER, spInfo.oTarget)) {
                if(iVisual!=-1) {
                    /*** NWN1 SPECIFIC ***/
                        if(iSpellID==230) { // Cone Lightning
                            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, spInfo.oTarget, fDuration);
                        }
                    /*** END NWN1 SPECIFIC ***/
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                }
                if(iDamageType!=-1) {
                    if(!bNoSave) iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, iSaveType);
                    eCone = EffectDamage(iDamage, iDamageType);
                    if(iDamage > 0) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eCone, spInfo.oTarget));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iDamageType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                    }
                } else {
                    if(iDurationType!=DURATION_TYPE_TEMPORARY) {
                        DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eCone, spInfo.oTarget));
                    } else {
                        DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eCone, spInfo.oTarget, fDuration));
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, 10.0, spInfo.lTarget, TRUE);
    }
    /*** NWN2 SPECIFIC ***
    if(iConeVis!=-1) {
        fMaxDelay += 0.5;
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSpray, OBJECT_SELF, fMaxDelay);
    }
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
