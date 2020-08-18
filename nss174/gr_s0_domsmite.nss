//*:**************************************************************************
//*:*  GR_S0_DOMSMITE.NSS
//*:**************************************************************************
//*:* Chaos Hammer
//*:* Holy Smite
//*:* Order's Wrath
//*:* Unholy Blight
//*:* Alignment Domain Smite spells (SG_S0_ChaosHam.nss)  2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: May 7, 2003
//*:* 3.5 Player's Handbook (pgs. 208, 241, 258, 297)
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
#include "GR_IN_ALIGNMENT"

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

    int     iDieType          = 8;
    int     iNumDice          = MinInt(5, spInfo.iCasterLevel/2);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount;        //= spInfo.iCasterLevel;
    switch(spInfo.iSpellID) {
        case SPELL_GR_CHAOS_HAMMER:
            iDurAmount = GRGetMetamagicAdjustedDamage(6, 1, spInfo.iMetamagic, 0);
            break;
        case SPELL_GR_HOLY_SMITE:
        case SPELL_GR_ORDERS_WRATH:
            iDurAmount = 1;
            break;
        case SPELL_GR_UNHOLY_BLIGHT:
            iDurAmount = GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic, 0);
            break;
    }

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
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(20.0);

    int     iAlignNotAffected;
    int     iAlignAgainst;
    int     iAlignAxis;
    int     iSavingThrow    = SAVING_THROW_WILL;
    effect  eSpellEffect;
    int     iVisualType;
    int     iDurVisType     = VFX_DUR_CESSATE_NEGATIVE;
    int     iBurstType;
    int     bSave;

    switch(spInfo.iSpellID) {
        case SPELL_GR_CHAOS_HAMMER:
            iAlignNotAffected = ALIGNMENT_CHAOTIC;
            iAlignAgainst = ALIGNMENT_LAWFUL;
            iAlignAxis = ALIGNMENT_AXIS_LAWCHAOS;
            eSpellEffect = EffectSlow();
            iVisualType = VFX_IMP_SLOW;
            iBurstType = VFX_FNF_DISPEL_DISJUNCTION;
            break;
        case SPELL_GR_HOLY_SMITE:
            iAlignNotAffected = ALIGNMENT_GOOD;
            iAlignAgainst = ALIGNMENT_EVIL;
            iAlignAxis = ALIGNMENT_AXIS_GOODEVIL;
            eSpellEffect = EffectBlindness();
            iVisualType = VFX_IMP_BLIND_DEAF_M;
            iDurVisType = VFX_DUR_BLIND;
            iBurstType = VFX_FNF_LOS_HOLY_30;
            break;
        case SPELL_GR_ORDERS_WRATH:
            iAlignNotAffected = ALIGNMENT_LAWFUL;
            iAlignAgainst = ALIGNMENT_EVIL;
            iAlignAxis = ALIGNMENT_AXIS_LAWCHAOS;
            eSpellEffect = EffectDazed();
            iVisualType = VFX_IMP_DAZED_S;
            iDurVisType = VFX_DUR_MIND_AFFECTING_DISABLED;
            /*** NWN1 SPECIFIC ***/
            iBurstType = VFX_FNF_PWKILL;
            /*** END NWN1 SPECIFIC ***/
            break;
        case SPELL_GR_UNHOLY_BLIGHT:
            iAlignNotAffected = ALIGNMENT_EVIL;
            iAlignAgainst = ALIGNMENT_GOOD;
            iAlignAxis = ALIGNMENT_AXIS_GOODEVIL;
            eSpellEffect = GREffectSickened();
            iVisualType = VFX_IMP_DISEASE_S;
            iDurVisType = VFX_DUR_MIND_AFFECTING_DISABLED;
            iBurstType = VFX_FNF_GAS_EXPLOSION_GREASE;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eImpact  = EffectVisualEffect(iBurstType);
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDur     = EffectVisualEffect(iDurVisType);
    effect eLink    = EffectLinkEffects(eSpellEffect, eDur);
    effect eDam;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(!GRGetCreatureAlignmentEqual(spInfo.oTarget, iAlignNotAffected, iAlignAxis)) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20.0;

                if(GRGetCreatureAlignmentEqual(spInfo.oTarget, iAlignAgainst, iAlignAxis)) {
                    if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_OUTSIDER) {
                        spInfo.iDmgDieType = 6;
                        spInfo.iDmgNumDice = MinInt(10, spInfo.iCasterLevel);
                        iDamage = GRGetSpellDamageAmount(spInfo, WILL_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                        if(GRGetSpellHasSecondaryDamage(spInfo)) {
                            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, WILL_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                iDamage = iSecDamage;
                            }
                        }

                        bSave = GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster);
                    } else {
                        spInfo.iDmgDieType = iDieType;
                        spInfo.iDmgNumDice = iNumDice;
                        iDamage = GRGetSpellDamageAmount(spInfo, WILL_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                        if(GRGetSpellHasSecondaryDamage(spInfo)) {
                            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, WILL_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                iDamage = iSecDamage;
                            }
                        }

                        bSave = GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster);
                    }
                    if(!bSave) DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget));
                } else {
                    spInfo.iDmgDieType = iDieType;
                    spInfo.iDmgNumDice = iNumDice;
                    iDamage = GRGetSpellDamageAmount(spInfo, WILL_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, WILL_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    iDamage /= 2;
                    iSecDamage /= 2;
                }
                if(iDamage>0) {
                    eDam = EffectDamage(iDamage);
                    if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
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
