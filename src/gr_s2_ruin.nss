//*:**************************************************************************
//*:*  GR_S2_RUIN.NSS
//*:**************************************************************************
//*:* Greater Ruin (X2_S2_Ruin) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Nov 18, 2002
//*:* Epic Level Handbook (p. 80)
//*:**************************************************************************
//*:* Ruin
//*:* Created By: Karl Nickels  (Syrus Greycloak) Created On: January 10, 2008
//*:* Epic Level Handbook (p. 85)
//*:**************************************************************************
//*:* Updated On: January 10, 2007
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

    spInfo.iDC = GetEpicSpellSaveDC(oCaster);

    //*:* int     iDieType          = 0;
    int     iNumDice          = (spInfo.iSpellID==SPELL_EPIC_RUIN ? 35 : 20); /* reason for 35 for SPELL_EPIC_RUIN is that
                                                                                Bioware coded for GREATER RUIN, not RUIN - I'm
                                                                                maintaining consistency - SG.  */
    //*:* int     iBonus            = 0;
    int     iDamage           = d6(iNumDice);
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDist           = GetDistanceBetween(oCaster, spInfo.oTarget);
    float   fDelay          = fDist/(3.0 * log(fDist) + 2.0);
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eDmg;
    effect eVisShake    = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
    effect eImpact      = EffectVisualEffect(487);
    effect eVisBlood    = EffectVisualEffect(VFX_COM_BLOOD_CRT_RED);
    effect eVisBone     = EffectVisualEffect(VFX_COM_CHUNK_BONE_MEDIUM);


    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    GRApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisShake, GetLocation(spInfo.oTarget));

    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SPELL, OBJECT_SELF)>0) {
            iDamage /= 2;
        }
        eDmg = EffectDamage(iDamage, DAMAGE_TYPE_POSITIVE, DAMAGE_POWER_PLUS_TWENTY);

        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisBlood, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisBone, spInfo.oTarget);
        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, spInfo.oTarget));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
