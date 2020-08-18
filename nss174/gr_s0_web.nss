//*:**************************************************************************
//*:*  GR_S0_WEB.NSS
//*:**************************************************************************
//*:* Web (NW_S0_Web.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Aug 8, 2001
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
    int     iDurAmount        = (spInfo.iSpellID==SPELL_GR_CHOKING_COBWEBS ? spInfo.iCasterLevel : spInfo.iCasterLevel*10);
    int     iDurType          = DUR_TYPE_TURNS;

    if(spInfo.iSpellID==731) {  // Bebelith Web
        iDurAmount = GetHitDice(OBJECT_SELF) / 2;
        iDurType = DUR_TYPE_ROUNDS;
    }

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAOEType;
    string  sAOEType;

    switch(spInfo.iSpellID) {
        case SPELL_WEB:
            iAOEType = AOE_PER_WEB;
            sAOEType = AOE_TYPE_WEB;
            break;
        case SPELL_GR_CHOKING_COBWEBS:
            iAOEType = AOE_PER_CHOKING_COBWEBS;
            sAOEType = AOE_TYPE_CHOKING_COBWEBS;
            break;
    }
    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
            switch(spInfo.iSpellID) {
                case SPELL_WEB:
                    iAOEType = AOE_PER_WEB_WIDE;
                    sAOEType = AOE_TYPE_WEB_WIDE;
                    break;
                case SPELL_GR_CHOKING_COBWEBS:
                    iAOEType = AOE_PER_CHOKING_COBWEBS_WIDE;
                    sAOEType = AOE_TYPE_CHOKING_COBWEBS_WIDE;
                    break;
            }
        }
    /*** END NWN1 SPECIFIC ***/
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
    effect eAOE = GREffectAreaOfEffect(iAOEType, "", "", "", sAOEType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);

    /*** NWN1 SINGLE ***/ object oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
    //*** NWN2 SINGLE ***/ object oAOE = GetObjectByTag(sAOEType);
    GRSetAOESpellId(spInfo.iSpellID, oAOE);
    GRSetSpellInfo(spInfo, oAOE);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
