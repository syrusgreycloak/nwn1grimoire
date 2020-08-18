//*:**************************************************************************
//*:*  GR_S0_FINGER.NSS
//*:**************************************************************************
//*:* Finger of Death (NW_S0_FingDeath) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Noel Borstad  Created On: Oct 17, 2000
//*:* 3.5 Player's Handbook (p. 230)
//*:**************************************************************************
//*:* Finger of Agony
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: April 17, 2008
//*:* Complete Mage (p. 104)
//*:**************************************************************************
//*:* Updated On: April 17, 2008
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
//*:* Supporting functions
//*:**************************************************************************
void DoFingerOfAgony(object oTarget, struct SpellStruct spInfo, int iRemainingRounds) {

    if(iRemainingRounds>0) {
        int     iDamage             = 0;
        int     iSecDamage          = 0;

        iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, spInfo.oCaster);
        if(GRGetSpellHasSecondaryDamage(spInfo)) {
            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, FORTITUDE_HALF, spInfo.oCaster);
            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                iDamage = iSecDamage;
            }
        }

        effect eDam     = EffectDamage(iDamage);
        effect eVis     = EffectVisualEffect(VFX_IMP_ACID_S);

        effect eNausea  = EffectDazed();
        effect eSicken  = GREffectSickened();

        if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));

        effect eLink    = EffectLinkEffects(eDam, eVis);

        SignalEvent(oTarget, EventSpellCastAt(spInfo.oCaster, spInfo.iSpellID));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget);
        if(!GRGetSpellDmgSaveMade(spInfo.iSpellID, spInfo.oCaster)) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eNausea, oTarget, GRGetDuration(1)+1.0);
        } else {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSicken, oTarget, GRGetDuration(1)+1.0);
        }
        iRemainingRounds--;
        if(iRemainingRounds>0) DelayCommand(GRGetDuration(1), DoFingerOfAgony(oTarget, spInfo, iRemainingRounds));
    }
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

    int     iDieType            = 6;
    int     iNumDice            = 3;
    int     iBonus              = (spInfo.iSpellID==SPELL_FINGER_OF_DEATH ? MinInt(25, spInfo.iCasterLevel) : 0);
    int     iDamage             = 0;
    int     iSecDamage          = 0;
    int     iDurAmount          = 3;
    int     iDurType            = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iDamageType     = (spInfo.iSpellID==SPELL_FINGER_OF_DEATH ? DAMAGE_TYPE_NEGATIVE : DAMAGE_TYPE_MAGICAL);
    /*** NWN1 SINGLE ***/ int     iVisualType     = (spInfo.iSpellID==SPELL_FINGER_OF_DEATH ? VFX_IMP_DEATH_L : VFX_IMP_ACID_S);
    //*** NWN2 SINGLE ***/ int     iVisualType     = (spInfo.iSpellID==SPELL_FINGER_OF_DEATH ? VFX_HIT_SPELL_FINGER_OF_DEATH : VFX_HIT_SPELL_ACID);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) iDurAmount *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eDam     = EffectDamage(iDamage, iDamageType);
    effect eDeath   = EffectDeath();
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eVis2    = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eLink;

    effect eNausea  = EffectDazed();
    effect eSicken  = GREffectSickened();

    if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetIsLiving(spInfo.oTarget)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            switch(spInfo.iSpellID) {
                case SPELL_FINGER_OF_DEATH:
                    if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH)) {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                        DelayCommand(0.5, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                        GRSetKilledByDeathEffect(spInfo.oTarget, oCaster);
                    } else if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_DEATH)) {
                        eLink = EffectLinkEffects(eDam, eVis2);
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                    }
                    break;
                case SPELL_GR_FINGER_OF_AGONY:
                    iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, oCaster);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, FORTITUDE_HALF, oCaster);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    eDam = EffectDamage(iDamage, iDamageType);
                    if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    eLink = EffectLinkEffects(eDam, eVis);
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                    if(!GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster)) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eNausea, spInfo.oTarget, GRGetDuration(1)+1.0);
                    } else {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSicken, spInfo.oTarget, GRGetDuration(1)+1.0);
                    }
                    iDurAmount--;
                    DelayCommand(GRGetDuration(1), DoFingerOfAgony(spInfo.oTarget, spInfo, iDurAmount));
                    break;
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
