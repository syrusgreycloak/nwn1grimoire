//*:**************************************************************************
//*:*  GR_S3_GEMSPRAY.NSS
//*:**************************************************************************
//*:* Rod of Wonder spray of gems
//*:* (x0_s3_gemspray) Copyright (c) 2001 Bioware Corp.
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
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = 4;
    int     iNumDice          = 1;
    int     iBonus            = 0;
    int     iDamage           = 0;
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    vector  vOrigin = GetPosition(oCaster);
    int     i, iRandom;
    string  sResRef;
    object  oGem;

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
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_CONE, 30.0, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE, vOrigin);

    while(GetIsObjectValid(spInfo.oTarget)) {
        iNumDice = Random(5) + 1;  // number of gems target will be hit by
        for(i=0;i<iNumDice; i++) {
            // create the gems on the target
            sResRef = "nw_it_gem0";
            iRandom = Random(20);
            if(iRandom==0) {
                sResRef += "11"; // topaz, a nice windfall
            } else if(iRandom<7) {
                sResRef += "02";
            } else if(iRandom<14) {
                sResRef += "05";
            } else {
                sResRef += "08";
            }

            oGem = CreateItemOnObject(sResRef, spInfo.oTarget);
            if(GetIsObjectValid(oGem)==FALSE) {
                sResRef = GetStringUpperCase(sResRef);
                oGem = CreateItemOnObject(sResRef, spInfo.oTarget);
                if(GetIsObjectValid(oGem)==FALSE) {
                    // SpeakString("Gem " + sResRef + " is invalid.");
                }
            }
        }
        iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice);
        iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, 14);

        if(iDamage>0) {
            DelayCommand(0.01, GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(iDamage, DAMAGE_TYPE_BLUDGEONING), spInfo.oTarget));
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_CONE, 30.0, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE, vOrigin);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
