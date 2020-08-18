//*:**************************************************************************
//*:*  GR_S0_WALLSPCST.NSS
//*:**************************************************************************
//*:*
//*:* Check for certain spells being cast at a wall
//*:* Current spells:
//*:*   Dispel Magic, Mordenkainen's Disjunction, Stone to Flesh, Disintegrate
//*:*
//*:**************************************************************************
//*:* Created By: Dennis Dollins (Danmar)
//*:* Created On: ?
//*:**************************************************************************
//*:* Updated On: March 3, 2008
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
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());
    object  oCaster         = spInfo.oCaster;

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

    int     iSpell          = GetLastSpell();
    string  sWallType       = GetTag(OBJECT_SELF);

    spInfo.oTarget          = GetLastSpellCaster();

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
    //*:* write effects here

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(sWallType!="wallofstone" && sWallType!="wallofiron") {
        if((iSpell==SPELL_DISPEL_MAGIC || iSpell==SPELL_GREATER_DISPELLING) && sWallType!="wallofforce") {
            int iDispelCheck = d20();
            int iDispelCasterLevel = GRGetCasterLevel(spInfo.oTarget);
            int iLimit = (iSpell==SPELL_DISPEL_MAGIC ? 10 : 20);
            iDispelCheck += (iDispelCasterLevel>iLimit ? iLimit : iDispelCasterLevel);
            if(GetIsObjectValid(oCaster)) {
                spInfo.iDC = 11 + spInfo.iCasterLevel;
            } else {
                spInfo.iDC = 11;
            }
            if(iDispelCheck>=spInfo.iDC) {
                DestroyObject(OBJECT_SELF);
                return;
            }
        } else if(iSpell==SPELL_MORDENKAINENS_DISJUNCTION) {
            int iClericLevel    = GRGetLevelByClass(CLASS_TYPE_CLERIC, spInfo.oTarget);
            int iSorcererLevel  = GRGetLevelByClass(CLASS_TYPE_SORCERER, spInfo.oTarget);
            int iWizardLevel    = GRGetLevelByClass(CLASS_TYPE_WIZARD, spInfo.oTarget);
            int iModifier=0;

            if(iClericLevel >= 17) {
                iModifier = GetAbilityModifier(ABILITY_WISDOM, spInfo.oTarget);
            } else if(iSorcererLevel >= 18) {
                iModifier = GetAbilityModifier(ABILITY_CHARISMA, spInfo.oTarget);
            } else if(iWizardLevel >= 17) {
                iModifier = GetAbilityModifier(ABILITY_INTELLIGENCE, spInfo.oTarget);
            }

            spInfo.iDC = 10 + 9 + iModifier;  // DC is 10 + spell level + relevant ability modifier

            if(!WillSave(OBJECT_SELF, spInfo.iDC)) {
                DestroyObject(OBJECT_SELF);
                return;
            }
        }
    }

    if(sWallType=="wallofstone") {
        if(iSpell==SPELL_STONE_TO_FLESH) {
            DestroyObject(OBJECT_SELF);
            effect eVis = EffectVisualEffect(VFX_COM_CHUNK_RED_LARGE);
            effect eVis2 = EffectVisualEffect(VFX_COM_BLOOD_LRG_RED);
            effect eLink = EffectLinkEffects(eVis, eVis2);
            GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eLink, GetLocation(OBJECT_SELF));
        }
    }

    if(sWallType=="wallofforce" && (iSpell==SPELL_DISINTEGRATE || iSpell==SPELL_MORDENKAINENS_DISJUNCTION)) {
        DestroyObject(OBJECT_SELF);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
