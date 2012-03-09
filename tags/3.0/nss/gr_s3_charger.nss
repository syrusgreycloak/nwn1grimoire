//*:**************************************************************************
//*:*  GR_S3_CHARGER.NSS
//*:**************************************************************************
//*:* Copyright (c) 2001 Bioware Corp.
//*:* Created By: Brent Knowles Created On: March 20, 2003
//*:**************************************************************************
//*:* Updated On: December 10, 2007
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
int ConvertCostToCharge() {
    int nValue = GetLocalInt(OBJECT_SELF, "X0_L_CHARGES_ELECTRIFIER");
    nValue = nValue / 1000;

    return nValue;
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
    //GRSetSpellInfo(spInfo, oCaster);

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
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
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
    //*:* list effect declarations here

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(spInfo.oTarget)) {
        if(GetObjectType(spInfo.oTarget)==OBJECT_TYPE_ITEM) {
            if(spInfo.iSpellID==509) {
                int iCharges = GetItemCharges(spInfo.oTarget);
                //*:* if item has some charges, then allow renewal
                if(iCharges>0) {
                    int iNewCharges = ConvertCostToCharge();
                    if(iNewCharges>=1) {
                        //*:* null the cost on the stored item
                        SetLocalInt(OBJECT_SELF, "X0_L_CHARGES_ELECTRIFIER", 0);
                        SetItemCharges(spInfo.oTarget, iCharges + iNewCharges);
                        SpeakStringByStrRef(40055);
                    } else {
                        SpeakStringByStrRef(40056);
                    }
                }
            } else if(GetPlotFlag(spInfo.oTarget)==FALSE) {
                int iValue = GetGoldPieceValue(spInfo.oTarget);
                SpeakStringByStrRef(40057);
                int iPreviousValue = GetLocalInt(OBJECT_SELF, "X0_L_CHARGES_ELECTRIFIER");
                SetLocalInt(OBJECT_SELF, "X0_L_CHARGES_ELECTRIFIER", iPreviousValue + iValue);
                effect eVis = EffectVisualEffect(VFX_IMP_DISPEL);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
                DestroyObject(spInfo.oTarget);
            }
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    //GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
