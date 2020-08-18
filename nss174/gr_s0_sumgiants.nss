//*:**************************************************************************
//*:*  GR_S0_SUMGIANTS.NSS
//*:**************************************************************************
//*:* Summon Giants
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 13, 2008
//*:* Frostburn (p. 105)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"  - INCLUDED IN GR_IN_SUMMON
#include "GR_IN_SPELLHOOK"
#include "GR_IN_SUMMON"

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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iNumToSummon    = 1;
    string  sSummonResRef;
    object  oPriorSummon;

    int     iSummonEffect   = GRGetSummonVisual(spInfo.iSpellLevel);

    switch(spInfo.iSpellID) {
        case SPELL_GR_SUMMON_GIANTS:
        case SPELL_GR_SUMMON_GIANTS_HILL:
            iNumToSummon = 3;
            sSummonResRef = "gr_s_hillgntfi";
            break;
        case SPELL_GR_SUMMON_GIANTS_STONE_C:
            iNumToSummon = 2;
            sSummonResRef = "gr_s_stngntce";
            break;
        case SPELL_GR_SUMMON_GIANTS_STONE_F:
            iNumToSummon = 2;
            sSummonResRef = "gr_s_stngntfi";
            break;
        case SPELL_GR_SUMMON_GIANTS_FROST:
            sSummonResRef = "gr_s_frstgntfi";
            break;
        case SPELL_GR_SUMMON_GIANTS_FIRE:
            sSummonResRef = "gr_s_firegntfi";
            break;
    }

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
    effect eSummon      = EffectSummonCreature(sSummonResRef, iSummonEffect, 0.0f);
    effect eStr = EffectAbilityIncrease(ABILITY_STRENGTH, 4);
    effect eCon = EffectAbilityIncrease(ABILITY_CONSTITUTION, 4);
    effect eAugmentSummons = EffectLinkEffects(eStr, eCon);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(oCaster, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    if(GetLocalInt(GetModule(), "GR_L_DESTROY_SUMMONS")) {
        GRDestroyPreviousSummons();
    } else {
        //AutoDebugString("Getting associate");
        oPriorSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF);
        if(GetIsObjectValid(oPriorSummon)) {
            //AutoDebugString("Associate is Valid.  Name is: "+GetName(oPriorSummon));
            SetPlotFlag(oPriorSummon, TRUE);
            SetImmortal(oPriorSummon, TRUE);
            AssignCommand(oPriorSummon, SetIsDestroyable(FALSE));
        }
    }

    int i;
    for(i=1; i<=iNumToSummon; i++) {
        object oSummon;

        if(i>1) {
            eSummon = EffectSummonCreature(sSummonResRef, VFX_NONE, i*0.1);
        }
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spInfo.lTarget, fDuration);
        int j = 1;
        int iNumFound = 0;
        while(iNumFound<i && j<50) { // sanity check j<50 to drop out of loop, just in case something strange happens
            oSummon = GetNearestObjectByTag(sSummonResRef, oCaster, j);
            if(GetMaster(oSummon)==oCaster) {
                if(GetPlotFlag(oSummon)==FALSE) {
                    SetPlotFlag(oSummon, TRUE);
                    SetImmortal(oSummon, TRUE);
                    AssignCommand(oSummon, SetIsDestroyable(FALSE));
                    SetLocalInt(oSummon, "GR_L_AM_SUMMON", TRUE);
                    if(GetHasFeat(FEAT_GR_AUGMENT_SUMMONING, oCaster)) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAugmentSummons, oSummon, fDuration);
                    }
                    DelayCommand(2.5+i*0.1, SetPlotFlag(oSummon, FALSE));
                    DelayCommand(2.6+i*0.1, SetImmortal(oSummon, FALSE));
                    DelayCommand(2.7+i*0.1, AssignCommand(oSummon, SetIsDestroyable(FALSE)));
                }
                iNumFound++;
            }
            j++;
        }
    }

    if(GetIsObjectValid(oPriorSummon)) {
        //AutoDebugString("Associate is Valid.  Name is: "+GetName(oPriorSummon));
        DelayCommand(2.0, SetPlotFlag(oPriorSummon, FALSE));
        DelayCommand(2.1, SetImmortal(oPriorSummon, FALSE));
        DelayCommand(2.2, AssignCommand(oPriorSummon, SetIsDestroyable(TRUE)));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
