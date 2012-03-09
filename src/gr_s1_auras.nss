//*:**************************************************************************
//*:*  GR_S1_AURAS.NSS
//*:**************************************************************************
//*:* Master Script for the various aura abilities
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: July 24, 2007
//*:**************************************************************************
//*:* Body of the Sun
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 5, 2009
//*:* Spell Compendium (p. 35)
//*:**************************************************************************
//*:* Updated On: January 5, 2009
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
    int     iDurAmount        = (spInfo.iSpellID==SPELL_BODY_OF_THE_SUN ? spInfo.iCasterLevel : 100);
    int     iDurType          = (spInfo.iSpellID==SPELL_BODY_OF_THE_SUN ? DUR_TYPE_ROUNDS : DUR_TYPE_HOURS);

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

    int     iDurationType = DURATION_TYPE_TEMPORARY;
    int     iAOEType;
    string  sAOEType;

    switch(GetSpellId()) {
        case SPELL_BODY_OF_THE_SUN:
            iAOEType = AOE_MOB_BODY_SUN;
            sAOEType = AOE_TYPE_BODY_SUN;
            break;
        case 195: // Aura of Blinding
            iAOEType = AOE_MOB_BLINDING;
            sAOEType = AOE_TYPE_BLINDING;
            iDurationType = DURATION_TYPE_PERMANENT;
            break;
        case 196: // Aura of Cold
            iAOEType = AOE_MOB_FROST;
            sAOEType = AOE_TYPE_FROST;
            break;
        case 197: // Aura of Electricity
            iAOEType = AOE_MOB_ELECTRICAL;
            sAOEType = AOE_TYPE_ELECTRICAL;
            break;
        case 198: // Aura of Fear
            iAOEType = AOE_MOB_FEAR;
            sAOEType = AOE_TYPE_FEAR;
            break;
        case 199: // Aura of Fire
            iAOEType = AOE_MOB_FIRE;
            sAOEType = AOE_TYPE_FIRE;
            break;
        case 200: // Aura of Menacing
            iAOEType = AOE_MOB_MENACE;
            sAOEType = AOE_TYPE_MENACE;
            break;
        case 201: // Aura of Protection
            iAOEType = AOE_MOB_PROTECTION;
            sAOEType = AOE_TYPE_PROTECTION;
            /*** NWN1 SPECIFIC ***/
                fDuration = GRGetDuration(spInfo.iCasterLevel/2, DUR_TYPE_TURNS);
                if(fDuration==0.0) fDuration = GRGetDuration(1, DUR_TYPE_TURNS);
                if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/ iDurationType = DURATION_TYPE_PERMANENT;
            break;
        case 202: // Aura of Stunning
            iAOEType = AOE_MOB_STUN;
            sAOEType = AOE_TYPE_STUN;
            break;
        case 203: // Aura of Unearthly Visage
            iAOEType = AOE_MOB_UNEARTHLY;
            sAOEType = AOE_TYPE_UNEARTHLY;
            break;
        case 204: // Unnatural Aura
            iAOEType = AOE_MOB_UNNATURAL;
            sAOEType = AOE_TYPE_UNNATURAL;
            break;
        case 412: // Aura Dragon Fear
            iAOEType = 36;
            sAOEType = AOE_TYPE_DRAGON_FEAR;
            break;
        /*** NWN1 SPECIFIC ***/
        case 804: // Aura Horrific Appearance (Sea Hag)
            iAOEType = AOE_MOB_GR_HORRAPPEARANCE;
            sAOEType = AOE_TYPE_HORRIFICAPPEARANCE;
            break;
        case 805: // Troglodyte Stench
            iAOEType = AOE_MOB_GR_TROGLODYTE_STENCH;
            sAOEType = AOE_TYPE_TROGLODYTE_STENCH;
            break;
        /*** END NWN1 SPECIFIC ***/
        case 1591: // BG Aura of Despair
            iAOEType = AOE_PER_AURA_OF_DESPAIR;
            sAOEType = AOE_TYPE_AURA_OF_DESPAIR;
            iDurationType = DURATION_TYPE_PERMANENT;
            break;
        case 314: // Pal Aura of Courage
            iAOEType = AOE_PER_AURA_OF_COURAGE;
            sAOEType = AOE_TYPE_AURA_OF_COURAGE;
            iDurationType = DURATION_TYPE_PERMANENT;
            break;
    }

    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);

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
    effect eVis = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MAJOR);
    effect eAOE = GREffectAreaOfEffect(iAOEType, "", "", "", sAOEType);

    if(spInfo.iSpellID==1591 || spInfo.iSpellID==314) eAOE = SupernaturalEffect(eAOE);

    effect ePalFearImm  = SupernaturalEffect(EffectImmunity(IMMUNITY_TYPE_FEAR));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget) || spInfo.iSpellID==SPELL_BODY_OF_THE_SUN) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
        GRApplyEffectToObject(iDurationType, eAOE, spInfo.oTarget, fDuration);
        if(spInfo.iSpellID==SPELL_BODY_OF_THE_SUN) GRApplyEffectToObject(iDurationType, eVis, spInfo.oTarget, fDuration);
        if(spInfo.iSpellID==314) GRApplyEffectToObject(iDurationType, ePalFearImm, spInfo.oTarget);

        /*** NWN1 SINGLE ***/ object oAOE = GRGetAOEOnObject(spInfo.oTarget, sAOEType, oCaster);
        //*** NWN2 SINGLE ***/ object oAOE = GetObjectByTag(sAOEType);
        GRSetAOESpellId(spInfo.iSpellID, oAOE);
        GRSetSpellInfo(spInfo, oAOE);
    }

    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
