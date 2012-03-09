//*:**************************************************************************
//*:*  GR_S0_BLKFLAME.NSS
//*:**************************************************************************
//*:*
//*:* Blackflame
//*:* Shadowy flames burst to life on one subject, causing dmg.  target must
//*:* save each round throughout the duration of the spell.  Those failing a
//*:* will save take no actions that round and are considered to be cowering.
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 25, 2003
//*:**************************************************************************
//*:* Updated On: February 21, 2008
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

    int     iDieType          = 10;
    int     iNumDice          = 1;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    string  sAfraid         = "Help me please! Help me! I'm burning!";

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eAOE     = GREffectAreaOfEffect(AOE_MOB_BLACKFLAME);
    effect eDmg     = EffectDamage(iDamage, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY);
    effect eVis     = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MAJOR);
    effect eImp     = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_GREASE);
    effect eCowerVis= EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eFright  = EffectFrightened();
    effect ePara    = EffectParalyze();

    effect eCower   = EffectLinkEffects(eFright, ePara);
    eCower = EffectLinkEffects(eCowerVis,eCower);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* Cannot stack from same caster
    if(!GRGetHasSpellEffect(SPELL_GR_BLACKFLAME, spInfo.oTarget, oCaster)) {
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget);
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_BLACKFLAME));
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);

            object oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_BLACKFLAME, oCaster);
            GRSetAOESpellId(spInfo.iSpellID, oAOE);
            GRSetSpellInfo(spInfo, oAOE);

            DelayCommand(0.2f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, fDuration));
            if(FortitudeSave(spInfo.oTarget, spInfo.iDC)==0) {
                if(iSecDamage>0) eDmg = EffectLinkEffects(eDmg, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, spInfo.oTarget);
                if(WillSave(spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS)==0) {
                    AssignCommand(spInfo.oTarget,ClearAllActions());
                    DelayCommand(0.2f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCower, spInfo.oTarget, GRGetDuration(1)));
                    DelayCommand(0.5f, AssignCommand(spInfo.oTarget, ActionSpeakString(sAfraid)));
                }
            }
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
