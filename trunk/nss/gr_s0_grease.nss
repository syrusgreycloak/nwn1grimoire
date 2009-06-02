//*:**************************************************************************
//*:*  GR_S0_GREASE.NSS
//*:**************************************************************************
//*:* Grease (NW_S0_Grease.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Aug 1, 2001
//*:* 3.5 Player's Handbook (p. 237)
//*:**************************************************************************
//*:* Incendiary Slime
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 18, 2008
//*:* Complete Mage (p. 108)
//*:**************************************************************************
//*:* Updated On: April 18, 2008
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
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

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

    float   fDuration       = GRGetSpellDuration(spInfo, DAMAGE_TYPE_MAGICAL, TRUE);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAOEType        = (spInfo.iSpellID==SPELL_GR_INCENDIARY_SLIME ? AOE_PER_INCENDIARY_SLIME : AOE_PER_GREASE);
    string  sAOEType        = (spInfo.iSpellID==SPELL_GR_INCENDIARY_SLIME ? AOE_TYPE_INCENDIARY_SLIME : AOE_TYPE_GREASE);

    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
            switch(spInfo.iSpellID) {
                case SPELL_GR_INCENDIARY_SLIME:
                    iAOEType = AOE_PER_INCENDIARY_SLIME_WIDE;
                    sAOEType = AOE_TYPE_INCENDIARY_SLIME_WIDE;
                    break;
                default:
                    iAOEType = AOE_PER_GREASE_WIDE;
                    sAOEType = AOE_TYPE_GREASE_WIDE;
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
    effect eAOE     = GREffectAreaOfEffect(iAOEType, "", "", "", sAOEType);
    /*** NWN1 SINGLE ***/ effect eImpact  = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_GREASE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);

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
