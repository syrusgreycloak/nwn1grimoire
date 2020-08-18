//*:**************************************************************************
//*:*  GR_S0_PRISSPRAY.NSS
//*:**************************************************************************
//*:* Prismatic Spray [NW_S0_PrisSpray.nss] Copyright (c) 2000 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Dec 19, 2000
//*:* 3.5 Player's Handbook (p. 264)
//*:**************************************************************************
//*:* Updated On: November 6, 2007
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
//*:*  Supporting Functions
//*:**************************************************************************
//*:*  ApplyPrismaticEffect
//*:**************************************************************************
//*:*  Given a reference integer and a target, this function will apply the effect
//*:*  of corresponding prismatic cone to the target.  To have any effect the
//*:*  reference integer (iEffect) must be from 1 to 7.*/
//*:**************************************************************************
//*:*  Created By: Aidan Scanlan On: April 11, 2001
//*:**************************************************************************
int ApplyPrismaticEffect(int iEffect, struct SpellStruct spInfo) {
    int iDamage;
    int iVis        = 0;
    float fDelay    = (spInfo.bNWN2 ? 1.5 : 0.5) + GetDistanceBetween(OBJECT_SELF, spInfo.oTarget)/20;
    float fParaDur  = GRGetDuration(10);

    effect ePrism;
    effect eVis;
    /*** NWN1 SINGLE ***/ effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    //*** NWN2 SINGLE ***/ effect eDur = EffectVisualEffect(VFX_DUR_PRISMATIC_SPRAY);
    effect eLink;
    effect ePoison;
    effect eDur2;
    effect eMind;

    //Based on the random number passed in, apply the appropriate effect and set the visual to
    //the correct constant
    switch(iEffect) {
        case 1://fire
            iDamage = 20;
            /*** NWN1 SINGLE ***/ iVis = VFX_IMP_FLAME_S;
            //*** NWN2 SINGLE ***/ iVis = VFX_HIT_SPELL_FIRE;
            iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_FIRE);
            if(spInfo.iSpellID==SPELL_GR_GSE2_PRISMATIC_SPRAY && GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                iDamage = FloatToInt(iDamage*0.60);
            }
            ePrism = EffectDamage(iDamage, DAMAGE_TYPE_FIRE);
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, spInfo.oTarget));
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }
            break;
        case 2: //Acid
            iDamage = 40;
            /*** NWN1 SINGLE ***/ iVis = VFX_IMP_ACID_L;
            //*** NWN2 SINGLE ***/ iVis = VFX_HIT_SPELL_ACID;
            iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_ACID);
            if(spInfo.iSpellID==SPELL_GR_GSE2_PRISMATIC_SPRAY && GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                iDamage = FloatToInt(iDamage*0.60);
            }
            ePrism = EffectDamage(iDamage, DAMAGE_TYPE_ACID);
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, spInfo.oTarget));
            break;
        case 3: //Electricity
            iDamage = 80;
            /*** NWN1 SINGLE ***/ iVis = VFX_IMP_LIGHTNING_S;
            //*** NWN2 SINGLE ***/ iVis = VFX_HIT_SPELL_LIGHTNING;
            iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_ELECTRICITY);
            if(spInfo.iSpellID==SPELL_GR_GSE2_PRISMATIC_SPRAY && GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                iDamage = FloatToInt(iDamage*0.60);
            }
            ePrism = EffectDamage(iDamage, DAMAGE_TYPE_ELECTRICAL);
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, spInfo.oTarget));
            break;
        case 4: //Poison
            if(spInfo.iSpellID==SPELL_PRISMATIC_SPRAY || (spInfo.iSpellID==SPELL_GR_GSE2_PRISMATIC_SPRAY && d100()<=60)) {
                //*** NWN2 SINGLE ***/ iVis = VFX_HIT_SPELL_POISON;
                ePoison = EffectPoison(POISON_BEBILITH_VENOM);
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePoison, spInfo.oTarget));
            }
            break;
        case 5: //Petrified
            eDur2 = EffectVisualEffect(VFX_DUR_PETRIFY);
            if(GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC) == 0) {
                if(spInfo.iSpellID==SPELL_PRISMATIC_SPRAY || (spInfo.iSpellID==SPELL_GR_GSE2_PRISMATIC_SPRAY && d100()<=60)) {
                    //*** NWN2 SINGLE ***/ iVis = VFX_HIT_SPELL_TRANSMUTATION;
                    ePrism = EffectPetrify();
                    eLink = EffectLinkEffects(eDur, ePrism);
                    eLink = EffectLinkEffects(eLink, eDur2);
                    if(!GetHasSpellEffect(SPELL_IRON_BODY, spInfo.oTarget)) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget));
                    }
                }
            }
            break;
        case 6: //Insanity - i.e. permanent confusion effect
            /*** NWN1 SINGLE ***/ eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
            //*** NWN2 SINGLE ***/ eMind = EffectVisualEffect(VFX_DUR_SPELL_CONFUSION);
            ePrism = EffectConfused();
            eLink = EffectLinkEffects(eMind, ePrism);
            eLink = EffectLinkEffects(eLink, eDur);

            if (!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, OBJECT_SELF, fDelay)) {
                iVis = VFX_IMP_CONFUSION_S;
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget));
            }
            break;
        case 7: //Death - since we can't do "sent to another plane"
            if (!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH, OBJECT_SELF, fDelay)) {
                //*** NWN2 SINGLE ***/ iVis = VFX_HIT_SPELL_NECROMANCY;
                ePrism = EffectDeath();
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, spInfo.oTarget));
                GRSetKilledByDeathEffect(spInfo.oTarget, spInfo.oCaster);
            }
            break;
    }

    return iVis;
}

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
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

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
    float   fRange          = (spInfo.iSpellID==SPELL_PRISMATIC_SPRAY ? 11.0f : FeetToMeters(40.0));

    int     iRandom;
    int     iHD;
    int     iVisual, iVisual2;
    int     bTwoEffects;
    float   fDelay;
    float   fMaxDelay       = 0.0f;

    int     iSpellShape     = (spInfo.iSpellID==SPELL_PRISMATIC_SPRAY ? SHAPE_SPELLCONE : SHAPE_SPHERE);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eBlind   = EffectBlindness();
    effect eVisual;

    //*** NWN2 SINGLE ***/ effect eCone = EffectVisualEffect(VFX_DUR_CONE_COLORSPRAY);

    /*** NWN1 SPECIFIC ***/
    effect eImp1    = EffectVisualEffect(VFX_FNF_DISPEL_DISJUNCTION);
    effect eImp2    = EffectVisualEffect(VFX_FNF_FIRESTORM);
    effect eImp3    = EffectVisualEffect(VFX_FNF_NATURES_BALANCE);
    effect eLink    = EffectLinkEffects(eImp1, eImp2);
    eLink = EffectLinkEffects(eLink, eImp3);
    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.iSpellID==SPELL_GR_PRISMATIC_DELUGE)
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eLink, spInfo.lTarget);
    /*** END NWN1 SPECIFIC ***/

    spInfo.oTarget = GRGetFirstObjectInShape(iSpellShape, fRange, spInfo.lTarget);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = (spInfo.bNWN2 ? 1.5 : 0.5) + GetDistanceBetween(oCaster, spInfo.oTarget)/20;
            //*** NWN2 SINGLE ***/ if(fMaxDelay<fDelay) fMaxDelay = fDelay;
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                iHD = GetHitDice(spInfo.oTarget);
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(iHD <= 8) {
                    if(spInfo.iSpellID==SPELL_GR_PRISMATIC_DELUGE) fDuration = GRGetDuration(GRGetMetamagicAdjustedDamage(4,2,0,0));
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBlind, spInfo.oTarget, fDuration);
                }
                iRandom = d8();
                if(iRandom == 8) {
                    iVisual = ApplyPrismaticEffect(Random(7) + 1, spInfo);
                    iVisual2 = ApplyPrismaticEffect(Random(7) + 1, spInfo);
                } else {
                    iVisual = ApplyPrismaticEffect(iRandom, spInfo);
                }
                if(iVisual != 0) {
                    eVisual = EffectVisualEffect(iVisual);
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spInfo.oTarget));
                }
                if(iVisual2 != 0) {
                    eVisual = EffectVisualEffect(iVisual2);
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spInfo.oTarget));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(iSpellShape, fRange, spInfo.lTarget);
    }
    /*** NWN2 SPECIFIC ***
    if(spInfo.iSpellID==SPELL_PRISMATIC_SPRAY) {
        fMaxDelay += 0.5f;
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCone, oCaster, fMaxDelay);
    }
    /*** END NWN2 SPECIFIC ***/

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
