//*:**************************************************************************
//*:*  GR_S0_DISINT.NSS
//*:**************************************************************************
//*:*
//*:* Disintegrate
//*:* 3.5 Player's Handbook (p. 222)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 27, 2004
//*:**************************************************************************
//*:* Updated On: February 28, 2008
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

    int     iDieType          = 6;
    int     iNumDice          = MinInt(40, spInfo.iCasterLevel*2);
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAttackResult   = GRTouchAttackRanged(spInfo.oTarget);

    if(GetHasSpellEffect(SPELL_GR_RAY_DEFLECTION, spInfo.oTarget)) {
        iAttackResult = 0;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    //*:* iDamage = GRGetSpellDamageAmount(spInfo)*iAttackResult;
    //*:* if(GRGetSpellHasSecondaryDamage(spInfo)) {
    //*:*     iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo)*iAttackResult;
    //*:*     if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
    //*:*         iDamage = iSecDamage;
    //*:*     }
    //*:* }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eBeam    = EffectBeam(VFX_BEAM_DISINTEGRATE, oCaster, BODY_NODE_HAND, (iAttackResult==0));
    effect eDamage;  //= EffectDamage(iDamage);
    effect eInvis   = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
    effect ePara    = EffectCutsceneParalyze();
    ePara = EffectLinkEffects(eInvis, ePara);

    effect eSmoke   = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1);
    effect eAcid    = EffectVisualEffect(VFX_IMP_ACID_S);
    eSmoke = EffectLinkEffects(eSmoke, eAcid);

    effect eDeath   = SupernaturalEffect(EffectDeath());
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_DISINTEGRATE));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, spInfo.oTarget, 1.5f);
    if(iAttackResult>0) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC)) {
                spInfo.iDmgNumDice = 5;
            }
            iDamage = GRGetSpellDamageAmount(spInfo)*iAttackResult;
            if(iDamage>=GetCurrentHitPoints(spInfo.oTarget)) {
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, ePara, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, spInfo.oTarget);
                if(GetIsPC(spInfo.oTarget)) {
                    DelayCommand(1.6f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, spInfo.oTarget));
                    DelayCommand(1.7f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                    GRSetKilledByDeathEffect(spInfo.oTarget);
                } else {
                    DelayCommand(1.7f, DestroyObject(spInfo.oTarget));
                }
            } else {
                eDamage = EffectDamage(iDamage);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo)*iAttackResult;
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget);
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
