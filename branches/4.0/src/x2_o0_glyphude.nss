//*:**************************************************************************
//*:*  GR_O0_GLYPHUDE.NSS
//*:**************************************************************************
//*:* Glyph of Warding - OnUserDefined
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
    if(GetUserDefinedEventNumber()==2000 && GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_TRIGGERED")==0) {
        //*:**********************************************
        //*:* Declare major variables
        //*:**********************************************
        object  oCaster         = OBJECT_SELF;
        struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId(), oCaster);

        spInfo.oTarget = GetLocalObject(OBJECT_SELF, "X2_GLYPH_LAST_ENTER");

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
        if(!GRSpellhookAbortSpell()) return;
        spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

        //*:**********************************************
        //*:* Declare Spell Specific Variables & impose limiting
        //*:**********************************************

        //*:* float   fDuration       = GRGetSpellDuration(spInfo);
        //*:* float   fDelay          = 0.0f;
        //*:* float   fRange          = FeetToMeters(15.0);

        int     iSpell          = GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_SPELL");
        string  sScript         = GetLocalString(OBJECT_SELF, "X2_GLYPH_SPELLSCRIPT");
        int     iCharges        = GetLocalInt(OBJECT_SELF, "X2_PLC_GLYPH_CHARGES");
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
        effect eVis = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);

        //*:**********************************************
        //*:* Apply effects
        //*:**********************************************
        //*:**********************************************
        if(sScript!="") {
            ActionCastFakeSpellAtObject(iSpell, spInfo.oTarget, PROJECTILE_PATH_TYPE_DEFAULT);
            ExecuteScript(sScript, spInfo.oTarget);
        } else {
            ActionCastSpellAtObject(iSpell, spInfo.oTarget, spInfo.iMetamagic, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
        }

        if(iCharges==0) {
            SetLocalInt(OBJECT_SELF, "X2_PLC_GLYPH_TRIGGERED", TRUE);
            GRRemoveEffects(EFFECT_TYPE_VISUALEFFECT, OBJECT_SELF, OBJECT_SELF);
            DestroyObject(OBJECT_SELF, 1.0f);
        } else if(iCharges>0) {
            iCharges--;
            SetLocalInt(OBJECT_SELF, "X2_PLC_GLYPH_CHARGES", iCharges);
        }

        //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
        //*:**********************************************
        //*:* Remove spell info from caster
        //*:**********************************************
        //GRClearSpellInfo(spInfo.iSpellID, oCaster);
    }
}
//*:**************************************************************************
//*:**************************************************************************
