//*:**************************************************************************
//*:*  GR_O0_GLYPHSPELL.NSS
//*:**************************************************************************
//*:* Glyph of Warding - OnSpellCastAt
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId(), oCaster);

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

    int     iLastSpell      = GetLastSpell();
    object  oLastCaster     = GetLastSpellCaster();
    struct SpellStruct spLastSpellInfo = GRGetSpellInfoFromObject(iLastSpell, oLastCaster);

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
    switch(iLastSpell) {
        case SPELL_DISPEL_MAGIC:
        case SPELL_GREATER_DISPELLING:
        case SPELL_LESSER_DISPEL:
        case SPELL_MORDENKAINENS_DISJUNCTION:
            DestroyObject(OBJECT_SELF);
            break;
        default:
            if(oLastCaster==spInfo.oCaster && !GetLocalInt(OBJECT_SELF, "GR_GLYPH_SET")) {
                if(spInfo.iSpellID>=SPELL_GR_GLYPH_OF_WARDING_ACID && spInfo.iSpellID<=SPELL_GR_GLYPH_OF_WARDING_SONIC &&
                    spLastSpellInfo.iSpellLevel<=3) {

                    SetLocalInt(OBJECT_SELF, "X2_PLC_GLYPH_SPELL", iLastSpell);
                    SetLocalInt(OBJECT_SELF, "GR_GLYPH_SET", TRUE);
                } else if(spInfo.iSpellID>=SPELL_GR_GREATER_GLYPH_OF_WARDING_ACID && spInfo.iSpellID<=SPELL_GR_GLYPH_OF_WARDING_SONIC &&
                    spLastSpellInfo.iSpellLevel<=6) {

                    SetLocalInt(OBJECT_SELF, "X2_PLC_GLYPH_SPELL", iLastSpell);
                    SetLocalInt(OBJECT_SELF, "GR_GLYPH_SET", TRUE);
                }
            }
            break;
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
