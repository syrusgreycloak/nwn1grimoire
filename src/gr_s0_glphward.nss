//*:**************************************************************************
//*:*  GR_S0_GLPHWARD.NSS
//*:**************************************************************************
//*:* Glyph of Warding (X2_S0_GlphWard) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Dec 04, 2002
//*:* 3.5 Player's Handbook (p. 236)
//*:**************************************************************************
//*:* Glyph of Warding, Greater
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: June 21, 2007
//*:* 3.5 Player's Handbook (p. 237)
//*:**************************************************************************
//*:* Updated On: December 20, 2007
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
    struct  SpellStruct spInfo;

    if(GetObjectType(oCaster)==OBJECT_TYPE_CREATURE) {
        spInfo = GRGetSpellStruct(GetSpellId(), oCaster);
    } else {
        spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId(), oCaster);
    }

    if(spInfo.iSpellID==SPELL_GLYPH_OF_WARDING)
        spInfo = GRGetSpellStruct(SPELL_GR_GLYPH_OF_WARDING_SONIC, oCaster);

    int     iDieType          = 8;
    int     iNumDice          = MinInt(5, spInfo.iCasterLevel/2);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    if(spInfo.iSpellID>=SPELL_GR_GREATER_GLYPH_OF_WARDING_ACID && spInfo.iSpellID<=SPELL_GR_GREATER_GLYPH_OF_WARDING_SONIC) {
        iNumDice = MinInt(10, spInfo.iCasterLevel/2);
    }

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(5.0);

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);
    int     iExplodeType    = GRGetEnergyExplodeType(iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eImpact      = EffectVisualEffect(iExplodeType);
    effect eVis         = EffectVisualEffect(iVisualType);
    effect eDam         = eVis;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetObjectType(oCaster)==OBJECT_TYPE_CREATURE) {
        //*:* Caster is creating glyph
        object oGlyph = CreateObject(OBJECT_TYPE_PLACEABLE, "x2_plc_glyph", spInfo.lTarget);
        object  oTest = GetNearestObjectByTag("X2_PLC_GLYPH", oGlyph);

        if (GetIsObjectValid(oTest) && GetDistanceBetween(oGlyph, oTest) <5.0f) {
            FloatingTextStrRefOnCreature(84612, oCaster);
            DestroyObject(oGlyph);
            return;
        }

        GRSetAOESpellId(spInfo.iSpellID, oGlyph);
        //GRSetAOEEnergyType(iEnergyType, oAOE);
        GRSetSpellInfo(spInfo, oGlyph);

        // Store the caster

        // Store the caster level
        SetLocalInt(oGlyph, "X2_PLC_GLYPH_CASTER_LEVEL", spInfo.iCasterLevel);

        // Store Meta Magic
        SetLocalInt(oGlyph, "X2_PLC_GLYPH_CASTER_METAMAGIC", spInfo.iMetamagic);

        // This spell (default = line 768 in spells.2da) will run when someone enters the glyph
        if(GetIsPC(oCaster)) {
            SetLocalInt(oGlyph, "X2_PLC_GLYPH_SPELL", spInfo.iSpellID);
        } else {
            SetLocalInt(oGlyph, "X2_PLC_GLYPH_SPELL", 764);
        }

        // Tell the system that this glyph was player and not toolset created
        SetLocalInt(oGlyph, "X2_PLC_GLYPH_PLAYERCREATED", TRUE);

        // Tell the game the glyph is not a permanent one
        DeleteLocalInt(oGlyph, "X2_PLC_GLYPH_PERMANENT");

        // Force first hb
        ExecuteScript("x2_o0_glyphhb",oGlyph);

        if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    } else if(GetObjectType(oCaster)==OBJECT_TYPE_PLACEABLE) {
        //*:* Glyph is casting spell - Blast Glyph [energy type]
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        while(GetIsObjectValid(spInfo.oTarget)) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(spInfo.oCaster, spInfo.iSpellID));
                if(!GRGetSpellResisted(spInfo.oCaster, spInfo.oTarget)) {
                    spInfo.iDC = GRGetSpellSaveDC(spInfo.oCaster, spInfo.oTarget);
                    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    if(iDamage>0) {
                        eDam = EffectLinkEffects(eDam, EffectDamage(iDamage, iEnergyType));
                        if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget);
                    }
                }
            }
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
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
