//*:**************************************************************************
//*:*  GR_S0_WEBC.NSS
//*:**************************************************************************
//:: Web: On Heartbeat (NW_S0_WebC.nss) Copyright (c) 2001 Bioware Corp.
//:: Created By: Preston Watamaniuk  Created On: Aug 8, 2001
//*:* 3.5 Player's Handbook (p. 299)
//*:**************************************************************************
//*:* Choking Cobwebs
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: April 21, 2008
//*:* Complete Mage (p. 99)
//*:**************************************************************************
//*:* Updated On: April 21, 2008
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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
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
    effect eWeb     = EffectEntangle();
    effect eVis     = EffectVisualEffect(VFX_DUR_WEB);
    effect eInvis   = EffectInvisibility(INVISIBILITY_TYPE_DARKNESS);
    effect eSicken  = GREffectSickened();

    if(spInfo.iSpellID==SPELL_GR_CHOKING_COBWEBS) eLink = EffectLinkEffect(eLink, eInvis);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetFirstInPersistentObject();

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            if(!GRGetIsIncorporeal(spInfo.oTarget) &&
                !GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT, spInfo.oTarget) && !GetHasSpellEffect(SPELLABILITY_GR_FREEDOM_OF_MOVEMENT, spInfo.oTarget)) {

                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                spInfo.iDC = (spInfo.iSpellID==731 ? 20 : GRGetSpellSaveDC(oCaster, spInfo.oTarget));
                if(spInfo.iSpellID==SPELL_GR_CHOKING_COBWEBS || !GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC)) {
                    if(spInfo.iSpellSchool!=SPELL_SCHOOL_ILLUSION || !GetLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_WILLDISBELIEF")) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, GRGetDuration(1));
                    }
                    if(spInfo.iSpellID==SPELL_GR_CHOKING_COBWEBS && !GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC)) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSicken, spInfo.oTarget, GRGetDuration(1));
                    }
                }
            }
        }
        oTarget = GetNextInPersistentObject();
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
