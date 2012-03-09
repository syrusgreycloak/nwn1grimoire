//*:**************************************************************************
//*:*  GR_S0_CLDSFOGS.NSS
//*:**************************************************************************
//*:* MASTER SCRIPT FOR CASTING CLOUD/FOG AOE SPELLS
//*:**************************************************************************
//*:* Acid Fog (NW_S0_AcidFog.nss) Copyright (c) 2001 Bioware Corp
//*:* Created By: Preston Watamaniuk  Created On: May 17, 2001
//*:* 3.5 Player's Handbook (p. 196)
//*:*
//*:* Cloudkill (NW_S0_CloudKill.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: May 17, 2001
//*:* 3.5 Player's Handbook (p. 210)
//*:*
//*:* Incendiary Cloud (NW_S0_IncCloud.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: May 17, 2001
//*:* 3.5 Player's Handbook (p. 244)
//*:*
//*:* Mind Fog (NW_S0_MindFog.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Aug 1, 2001
//*:* 3.5 Player's Handbook (p. 253)
//*:*
//*:* Stinking Cloud (NW_S0_StinkCld.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: May 17, 2001
//*:* 3.5 Player's Handbook (p. 284)
//*:*
//*:* Cloud of Bewilderment (X2_S0_CldBewld) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: November 04, 2002
//*:* Spell Compendium (p. 48)
//*:*
//*:* Tyrant Fog Zombie Mist (NW_S1_TyrantFog.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: May 25, 2001
//*:*
//*:**************************************************************************
//*:* Fog Cloud         3.5 Player's Handbook (p. 232)
//*:*
//*:* Igedrazaar's Miasma (sg_s0_igmiasma.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 3, 2004
//*:* Spell Compendium (p. 137 - Malevolent Miasma)
//*:*
//*:* Solid Fog
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 13, 2008
//*:* 3.5 Player's Handbook (p. 281)
//*:*
//*:* Obscuring Mist
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 18, 2008
//*:* 3.5 Player's Handbook (p. 258)
//*:*
//*:* Caustic Smoke
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 16, 2008
//*:* Complete Mage (p. 98)
//*:*
//*:* Breath of the Night
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 22, 2008
//*:* Complete Arcane (p. 132)
//*:*
//*:* Zone of Glacial Cold
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 29, 2008
//*:* Frostburn (p. 104)
//*:**************************************************************************
//*:* Update On: May 29, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = 6;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

    int     bDamageSpell        = TRUE;
    int     bEnergySpell        = TRUE;

    object  oAOE;
    int     iAOEType;
    string  sAOEType;
    int     iExplodeType        = -1;

    switch(spInfo.iSpellID) {
        case SPELL_ACID_FOG:
        case SPELL_GR_SHADES_ACID_FOG:
        case SPELL_GR_GSC_ACID_FOG:
            iNumDice = 2;
            iAOEType = AOE_PER_FOGACID;
            sAOEType = AOE_TYPE_FOGACID;
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_GAS_EXPLOSION_ACID;  //*:* need to include so illusions get right one
            //*** NWN2 SINGLE ***/ iExplodeType = VFX_HIT_AOE_ACID;
            break;
        case SPELL_CLOUD_OF_BEWILDERMENT:
            bDamageSpell = FALSE;
            bEnergySpell = FALSE;
            iAOEType = AOE_PER_FOG_OF_BEWILDERMENT;
            sAOEType = AOE_TYPE_FOGBEWILDERMENT;
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_IMP_DUST_EXPLOSION;
            break;
        case SPELL_CLOUDKILL:
        case SPELL_GR_SHADES_CLOUDKILL:
        case SPELL_GR_GSC_CLOUDKILL:
            bEnergySpell = FALSE;
            iDieType = 4;
            iNumDice = 1;
            iDurType = DUR_TYPE_TURNS;
            iAOEType = AOE_PER_FOGKILL;
            sAOEType = AOE_TYPE_FOGKILL;
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_GAS_EXPLOSION_EVIL;
            break;
        case SPELL_GR_FOG_CLOUD:
        case SPELL_I_BREATH_OF_NIGHT:
            bDamageSpell = FALSE;
            bEnergySpell = FALSE;
            iDurAmount = (spInfo.iSpellID==SPELL_GR_FOG_CLOUD ? iDurAmount * 10 : 1);
            iDurType = DUR_TYPE_TURNS;
            iAOEType = AOE_PER_FOGCLOUD;
            sAOEType = AOE_TYPE_FOGCLOUD;
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_GAS_EXPLOSION_EVIL;
            break;
        case SPELL_GR_IGEDRAZAARS_MIASMA:
            bEnergySpell = FALSE;
            iDieType = 4;
            iNumDice = (spInfo.iCasterLevel>5 ? 5 : spInfo.iCasterLevel);
            iDurAmount = 2;
            iAOEType = AOE_PER_IGEDRAZAARS_MIASMA;
            sAOEType = AOE_TYPE_IGEDRAZAARS_MIASMA;
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_IMP_DUST_EXPLOSION;
            break;
        case SPELL_INCENDIARY_CLOUD:
        case SPELL_GR_SHADES_INCENDIARY_CLOUD:
            iNumDice = 4;
            iAOEType = AOE_PER_FOGFIRE;
            sAOEType = AOE_TYPE_FOGFIRE;
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_GAS_EXPLOSION_FIRE; //*:* need to include so illusions get right one
            break;
        case SPELL_MIND_FOG:
            bDamageSpell = FALSE;
            bEnergySpell = FALSE;
            iDurAmount = 30;
            iDurType = DUR_TYPE_TURNS;
            iAOEType = AOE_PER_FOGMIND;
            sAOEType = AOE_TYPE_FOGMIND;
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_GAS_EXPLOSION_MIND;
            break;
        case SPELL_GR_SOLIDFOG:
            bDamageSpell = FALSE;
            bEnergySpell = FALSE;
            iDurType = DUR_TYPE_TURNS;
            iAOEType = AOE_PER_SOLIDFOG;
            sAOEType = AOE_TYPE_SOLIDFOG;
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_GAS_EXPLOSION_EVIL;
            break;
        case SPELL_STINKING_CLOUD:
        case SPELL_GR_SHADOW_CON_STINKING_CLOUD:
            bDamageSpell = FALSE;
            bEnergySpell = FALSE;
            iAOEType = AOE_PER_FOGSTINK;
            sAOEType = AOE_TYPE_FOGSTINK;
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_GAS_EXPLOSION_NATURE;
            break;
        case 306: // Tyrant Fog Zombie Mist
            bDamageSpell = FALSE;
            bEnergySpell = FALSE;
            iAOEType = AOE_MOB_TYRANT_FOG;
            iDurAmount = 100;
            iDurType = DUR_TYPE_HOURS;
            break;
        case SPELL_GR_OBSCURING_MIST:
            bDamageSpell = FALSE;
            bEnergySpell = FALSE;
            iAOEType = AOE_PER_OBSCURING_MIST;
            sAOEType = AOE_TYPE_OBSCURING_MIST;
            iDurType = DUR_TYPE_TURNS;
            break;
        case SPELL_GR_CAUSTIC_SMOKE:
            bDamageSpell = TRUE;
            bEnergySpell = FALSE;
            iNumDice = 1;
            iAOEType = AOE_PER_CAUSTIC_SMOKE;
            sAOEType = AOE_TYPE_CAUSTIC_SMOKE;
            iDurAmount = 5;
            break;
        case SPELL_GR_ZONE_GLACIAL_COLD:
            bDamageSpell = TRUE;
            bEnergySpell = TRUE;
            iNumDice = 1;
            iAOEType = AOE_PER_ZONE_GLACIAL_COLD;
            sAOEType = AOE_TYPE_ZONE_GLACIAL_COLD;
            break;
    }

    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID);

    if(bDamageSpell) spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int iEnergyType, iSpellType;

    if(bEnergySpell) {
        iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
        iSpellType      = GRGetEnergySpellType(iEnergyType);
        iExplodeType     = GRGetEnergyExplodeType(iEnergyType);

        spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);
    }

    spInfo = GRSetSpellDurationInfo(spInfo, spInfo.iDurAmount, spInfo.iDurType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo, iEnergyType, TRUE);
    //*:* float   fRange          = FeetToMeters(15.0);

    if(fDuration<1.0) fDuration = 1.0;

    //*:**********************************************
    //*:* Set percentage for illusion spells
    //*:**********************************************
    float fDamagePercentage = 1.0;

    switch(spInfo.iSpellID) {
        // SHADES
        case SPELL_GR_SHADES_ACID_FOG:
        case SPELL_GR_SHADES_CLOUDKILL:
        case SPELL_GR_SHADES_INCENDIARY_CLOUD:
            fDamagePercentage = 0.8;
            break;
        // GREATER SHADOW CONJURATION
        case SPELL_GR_GSC_ACID_FOG:
        case SPELL_GR_GSC_CLOUDKILL:
            fDamagePercentage = 0.6;
            break;
        // SHADOW CONJURATION
        // LESSER SHADOW CONJURATION
        case SPELL_GR_SHADOW_CON_STINKING_CLOUD:
            fDamagePercentage = 0.2;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SPECIFIC ***/
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        switch(spInfo.iSpellID) {
            case SPELL_ACID_FOG:
                iAOEType = AOE_PER_FOGACID_WIDE;
                sAOEType = AOE_TYPE_FOGACID_WIDE;
                break;
            case SPELL_CLOUD_OF_BEWILDERMENT:
                iAOEType = AOE_PER_FOGBEWILDERMENT_WIDE;
                sAOEType = AOE_TYPE_FOGBEWILDERMENT_WIDE;
                break;
            case SPELL_CLOUDKILL:
                iAOEType = AOE_PER_FOGKILL_WIDE;
                sAOEType = AOE_TYPE_FOGKILL_WIDE;
                break;
            case SPELL_GR_FOG_CLOUD:
                iAOEType = AOE_PER_FOGCLOUD_WIDE;
                sAOEType = AOE_TYPE_FOGCLOUD_WIDE;
                break;
            case SPELL_GR_IGEDRAZAARS_MIASMA:
                iAOEType = AOE_PER_IGEDRAZAARS_MIASMA_WIDE;
                sAOEType = AOE_TYPE_IGEDRAZAARS_MIASMA_WIDE;
                break;
            //*:* case SPELL_INCENDIARY_CLOUD: - can't widen (+3 lvls) Incendiary Cloud (lvl 8)
            case SPELL_MIND_FOG:
                iAOEType = AOE_PER_FOGMIND_WIDE;
                sAOEType = AOE_TYPE_FOGMIND_WIDE;
                break;
            case SPELL_GR_SOLIDFOG:
                iAOEType = AOE_PER_SOLIDFOG_WIDE;
                sAOEType = AOE_TYPE_SOLIDFOG_WIDE;
                break;
            case SPELL_STINKING_CLOUD:
                iAOEType = AOE_PER_FOGSTINK_WIDE;
                sAOEType = AOE_TYPE_FOGSTINK_WIDE;
                break;
            case SPELL_GR_OBSCURING_MIST:
                iAOEType = AOE_PER_OBSCURING_MIST_WIDE;
                sAOEType = AOE_TYPE_OBSCURING_MIST_WIDE;
                break;
            case SPELL_GR_CAUSTIC_SMOKE:
                iAOEType = AOE_PER_CAUSTIC_SMOKE_WIDE;
                sAOEType = AOE_TYPE_CAUSTIC_SMOKE_WIDE;
                break;
            case SPELL_GR_ZONE_GLACIAL_COLD:
                iAOEType = AOE_PER_ZONE_GLACIAL_COLD_WIDE;
                sAOEType = AOE_TYPE_ZONE_GLACIAL_COLD_WIDE;
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
    /*** NWN1 SINGLE ***/ effect eImpact  = EffectVisualEffect(iExplodeType);
    effect eAOE     = GREffectAreaOfEffect(iAOEType, "", "", "", sAOEType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ if(iExplodeType!=-1) GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);

    if(spInfo.iSpellID!=306) { // not tyrant fog zombie mist
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);

        /*** NWN1 SINGLE ***/ oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
        //*** NWN2 SINGLE ***/ oAOE = GetObjectByTag(sAOEType);
        GRSetAOESpellId(spInfo.iSpellID, oAOE);
        GRSetSpellInfo(spInfo, oAOE);
        GRSetAOEDamagePercentage(fDamagePercentage, oAOE);
        SetLocalInt(oAOE, "GR_DESTROYED_BY_GUSTWIND", TRUE);
    } else {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, OBJECT_SELF, fDuration);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
