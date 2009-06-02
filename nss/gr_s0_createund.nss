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
//*:* Updated On: October 25, 2007
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    if(spInfo.iSpellID==609) { // blackguard spell
        spInfo.iSpellCastClass = CLASS_TYPE_BLACKGUARD;
        spInfo.iCasterLevel = GRGetCasterLevel(oCaster, spInfo.iSpellCastClass);
    }

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
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iStep1Top, iStep2Low, iStep2Top, iStep3Low, iStep3Top, iStep4Low, iStep4Top;
    string  sStep1Ref, sStep2Ref, sStep3Ref, sStep4Ref, sStep5Ref;
    int     iVisualType     = VFX_FNF_SUMMON_UNDEAD;

    switch(spInfo.iSpellID) {
        case SPELL_CREATE_UNDEAD:
            //*** NWN2 SINGLE ***/ iVisualType = VFX_HIT_SPELL_SUMMON_CREATURE;
            iStep1Top = 11;
            /*** NWN1 SINGLE ***/ sStep1Ref = "NW_S_GHOUL";
            //*** NWN2 SINGLE ***/ sStep1Ref = "c_ghoul";
            iStep2Low = 12;
            iStep2Top = 14;
            /*** NWN1 SINGLE ***/ sStep2Ref = "NW_S_GHAST";
            //*** NWN2 SINGLE ***/ sStep2Ref = "c_ghast";
            iStep3Low = 15;
            iStep3Top = 17;
            /*** NWN1 SINGLE ***/ sStep3Ref = "X2_S_MUMMY";
            //*** NWN2 SINGLE ***/ sStep3Ref = "c_mummy";
            iStep4Low = 18;
            iStep4Top = 999;
            /*** NWN1 SINGLE ***/ sStep4Ref = "NW_S_WIGHT";
            //*** NWN2 SINGLE ***/ sStep4Ref = "c_wight";
            /*** NWN1 SINGLE ***/ sStep5Ref = "NW_S_WRAITH";
            //*** NWN1 SINGLE ***/ sStep5Ref = "c_wraith";
            break;
        case SPELL_CREATE_GREATER_UNDEAD:
            //*** NWN2 SINGLE ***/ iVisualType = VFX_HIT_SPELL_SUMMON_CREATURE;
            iStep1Top = -1;
            sStep1Ref = "";
            iStep2Low = 0;
            iStep2Top = 15;
            /*** NWN1 SINGLE ***/ sStep2Ref = "X1_S_SHADOW";
            //*** NWN2 SINGLE ***/ sStep2Ref = "c_shadow";
            iStep3Low = 16;
            iStep3Top = 17;
            /*** NWN1 SINGLE ***/ sStep3Ref = "NW_S_WRAITH";
            //*** NWN2 SINGLE ***/ sStep3Ref = "c_wraith";
            iStep4Low = 18;
            iStep4Top = 19;
            /*** NWN1 SPECIFIC ***/
                sStep4Ref = "x2_s_spectre_10";
                sStep5Ref = "X2_S_VAMP_18";
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                sStep4Ref = "c_vampirem";
                sStep5Ref = "c_vampireelite";
            /*** END NWN2 SPECIFIC ***/
            break;
        case 609: // Blackguard version - Undead companion
            iStep1Top = -1;
            sStep1Ref = "";
            iStep2Low = -1;
            iStep2Top = -1;
            sStep2Ref = "";
            iStep3Low = -1;
            iStep3Top = -1;
            sStep3Ref = "";
            iStep4Low = 0;
            iStep4Top = 6;
            /*** NWN1 SPECIFIC ***/
                sStep4Ref = "NW_S_GHAST";
                sStep5Ref = "NW_S_DOOMKGHT";
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                sStep4Ref = "c_skeleton7";
                sStep5Ref = "c_skeleton9";
            /*** END NWN2 SPECIFIC ***/
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
    effect eSummon;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetStringLowerCase(GetName(spInfo.oTarget))=="corpse" && GetIsNight()) {
        // Step 1
        if(spInfo.iCasterLevel <= iStep1Top) {
            eSummon = EffectSummonCreature(sStep1Ref, iVisualType);
        // Step 2
        } else if ((spInfo.iCasterLevel >= iStep2Low) && (spInfo.iCasterLevel <= iStep2Top)) {
            eSummon = EffectSummonCreature(sStep2Ref, iVisualType);
        // Step 3
        } else if ((spInfo.iCasterLevel >= iStep3Low) && (spInfo.iCasterLevel <= iStep3Top)) {
            eSummon = EffectSummonCreature(sStep3Ref, iVisualType);
        // Step 4
        } else if ((spInfo.iCasterLevel >= iStep4Low) && (spInfo.iCasterLevel <=iStep4Top)) {
            eSummon = EffectSummonCreature(sStep4Ref, iVisualType);
        // Step 5
        } else {
            eSummon = EffectSummonCreature(sStep5Ref, iVisualType);
        }
        GRApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eSummon, GetLocation(spInfo.oTarget));
        if(GetHasInventory(spInfo.oTarget)) {
            object oItem = GetFirstItemInInventory(spInfo.oTarget);
            while(GetIsObjectValid(oItem)) {
                AssignCommand(spInfo.oTarget, ActionPutDownItem(oItem));
                oItem = GetNextItemInInventory(spInfo.oTarget);
            }
        }
        DestroyObject(spInfo.oTarget);

        if(GetHasSpellEffect(SPELL_GR_DESECRATE, OBJECT_SELF)) {
            int i=1;
            object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF, i);
            while(GetRacialType(oSummon)!=RACIAL_TYPE_UNDEAD || (GetRacialType(oSummon)==RACIAL_TYPE_UNDEAD &&
                GetCurrentHitPoints(oSummon)>GetMaxHitPoints(oSummon))) {
                i++;
                oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF, i);
            }
            if(GetRacialType(oSummon)==RACIAL_TYPE_UNDEAD) {
                int iSummonHD = GetHitDice(oSummon);
                effect eTempHP = EffectTemporaryHitpoints(iSummonHD);
                SignalEvent(oSummon, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTempHP, oSummon, GRGetDuration(24, DUR_TYPE_HOURS));
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
