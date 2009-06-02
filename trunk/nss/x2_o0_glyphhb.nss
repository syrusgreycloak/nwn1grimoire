//*:**************************************************************************
//*:*  X2_O0_GLYPHHB.NSS
//*:**************************************************************************
//*:*
//*:* Glyph of Warding Heartbeat
//*:* x2_o0_glyphhb
//*:* Copyright (c) 2003 Bioware Corp.
//*:*
//*:*     Heartbeat for glyph of warding object
//*:*
//*:*     Short rundown:
//*:*
//*:*     Casting "glyph of warding" will create a GlyphOfWarding object from
//*:* the palette and store all required variables on that object. You can also
//*:* manually add those variables through the toolset.
//*:*
//*:*     On the first heartbeat, the glyph creates the glyph visual effect on
//*:* itself for the duration of the spell.
//*:*
//*:*     Each subsequent heartbeat the glyph checks if the effect is still there.
//*:* If it is no longer there, it has either been dispelled or removed, and the
//*:* glyph will terminate itself.
//*:*
//*:*     Also on the first heartbeat, this object creates an AOE object around
//*:* itself, which, when getting the OnEnter Event from a Creature Hostile to
//*:* the player, will  signal User Defined Event 2000 to the glyph placeable
//*:* which will fire the spell stored on a variable on it self on the intruder
//*:*
//*:*     Note that not all spells might work because this is a placeable object
//*:* casting them, but the more populare ones are working.
//*:*
//*:*     The default spell cast is id 764, which is the script for the standard
//*:* glyph of warding.
//*:*
//*:*     Check the comments on the Glyph of Warding object on the palette for
//*:* more information
//*:*
//*:**************************************************************************
//*:* Created By: Georg Zoeller
//*:* Created On: 2003-09-02
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

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster             = GetLocalObject(OBJECT_SELF, "X2_PLC_GLYPH_CASTER");

    if(!GetIsObjectValid(oCaster) || GetIsDead(oCaster)) {
        if(GetLocalInt(OBJECT_SELF, "X2_PLC_GLYPH_PLAYERCREATED")==TRUE) {
            DestroyObject(OBJECT_SELF);
        }
        return;
    }

    struct  SpellStruct spInfo  = GRGetSpellInfoFromObject(GRGetAOESpellId(), OBJECT_SELF);

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
    /*if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);*/

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************
    float   fDuration       = GRGetDuration(spInfo.iCasterLevel/2, DUR_TYPE_TURNS);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     bSetup          = GetLocalInt(OBJECT_SELF, "X2_PLC_GLYPH_INIT");

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
    effect eVis     = EffectVisualEffect(VFX_IMP_DEATH);
    effect eAOE     = EffectAreaOfEffect(38, "gr_s0_glphwarda");

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bSetup == 0) {
        SetLocalInt(OBJECT_SELF, "X2_PLC_GLYPH_INIT", 1);

        if(GetModuleSwitchValue(MODULE_SWITCH_ENABLE_INVISIBLE_GLYPH_OF_WARDING)) {
            //*:* show glyph symbol only for 6 seconds
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(445), OBJECT_SELF, 6.0f);
            //*:*  use blur VFX therafter (which should be invisible);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(0), OBJECT_SELF, fDuration);
        } else {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(445), OBJECT_SELF, fDuration);
        }

        if(GetLocalInt(OBJECT_SELF, "X2_PLC_GLYPH_PERMANENT")==TRUE) {
            GRApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eAOE, spInfo.lTarget);
        } else {
            GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);
        }
    } else {
        //*:**********************************************
        //*:* replaced effect search loop with below function
        //*:* not sure if spell id check will work
        //*:**********************************************
        if(!GRGetHasEffectTypeFromSpell(OBJECT_SELF, EFFECT_TYPE_VISUALEFFECT, spInfo.iSpellID, OBJECT_SELF)) {
            DestroyObject(OBJECT_SELF);
            return;
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
