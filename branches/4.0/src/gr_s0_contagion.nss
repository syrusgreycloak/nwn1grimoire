//*:**************************************************************************
//*:*  GR_S0_CONTAGION.NSS
//*:**************************************************************************
//*:* Contagion (NW_S0_Contagion.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 213)
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: June 6, 2001
//*:**************************************************************************
//*:*
//*:* Contagion, Mass
//*:* Spell Compendium (p. 51)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: August 6, 2007
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

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    if(spInfo.iSpellID==613) { //*:* Blackguard contagion
        spInfo.iSpellID = SPELL_CONTAGION;
        spInfo.iSpellCastClass = CLASS_TYPE_BLACKGUARD;
        spInfo.iCasterLevel = GRGetCasterLevel(oCaster, spInfo.iSpellCastClass);
    }


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
    float   fRange          = FeetToMeters(20.0);

    int     bMultiTarget    = (spInfo.iSpellID==SPELL_MASS_CONTAGION ? TRUE : FALSE);
    int     iDisease;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SINGLE ***/ if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    /*** NWN1 SINGLE ***/ effect eMassVis = EffectVisualEffect(VFX_FNF_LOS_EVIL_20);
    //*** NWN2 SINGLE ***/ effect eHit = EffectVisualEffect( VFX_HIT_SPELL_NECROMANCY );

    effect eDisease;    // = EffectDisease(iDisease);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eMassVis, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if((!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) && GRGetIsLiving(spInfo.oTarget)) {
                if(bMultiTarget || TouchAttackMelee(spInfo.oTarget)) {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                        if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DISEASE)) {
                            switch(Random(7)+1) {
                                case 1:
                                    iDisease = DISEASE_BLINDING_SICKNESS;
                                    break;
                                case 2:
                                    iDisease = DISEASE_CACKLE_FEVER;
                                    break;
                                case 3:
                                    iDisease = DISEASE_FILTH_FEVER;
                                    break;
                                case 4:
                                    iDisease = DISEASE_MINDFIRE;
                                    break;
                                case 5:
                                    iDisease = DISEASE_RED_ACHE;
                                    break;
                                case 6:
                                    iDisease = DISEASE_SHAKES;
                                    break;
                                case 7:
                                    iDisease = DISEASE_SLIMY_DOOM;
                                    break;
                            }
                            eDisease = EffectDisease(iDisease);
                            //*** NWN2 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHit, spInfo.oTarget);
                            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDisease, spInfo.oTarget);
                        }
                    }
                }
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
