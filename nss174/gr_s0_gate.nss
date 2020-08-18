//*:**************************************************************************
//*:*  GR_S0_GATE.NSS
//*:**************************************************************************
//*:*
//*:* Gate (NW_S0_Gate.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 234)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: April 12, 2001
//*:**************************************************************************
//*:* Updated On: October 25, 2007
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
//*:* Supporting functions
//*:**************************************************************************
void CreateOutsider(int iIsPvPArea, object oCaster) {

    /*** NWN1 SINGLE ***/ string sResref = "SG_S_BALOR_EVIL";
    //*** NWN2 SINGLE ***/ string sResref = "c_summ_devilhorn";
    object oOutsider = CreateObject(OBJECT_TYPE_CREATURE, sResref, GetSpellTargetLocation());
    SetLocalInt(oOutsider, "PVP_AREA", iIsPvPArea);
    SetLocalObject(oOutsider, "MY_SUMMONER", oCaster);
    if(iIsPvPArea) AssignCommand(oOutsider, DetermineCombatRound(oCaster) );
}

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
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo.oTarget         = GetFirstPC();

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iIsPvPArea      = FALSE;
    /*** NWN1 SPECIFIC***/
        string  sResref         = "NW_S_BALOR";
        int     iVisual         = VFX_FNF_SUMMON_GATE;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        string  sResref         = "c_summ_devilhorn";
        int     iVisual         = VFX_INVOCATION_BRIMSTONE_DOOM;
    /*** END NWN2 SPECIFIC ***/

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
    effect eSummon;
    effect eVis     = EffectVisualEffect(iVisual);
    //*** NWN2 SINGLE ***/ effect eGate     = EffectVisualEffect(VFX_DUR_GATE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GetHasSpellEffect(SPELL_PROTECTION_FROM_EVIL) ||
            GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_EVIL) ||
            GetHasSpellEffect(SPELL_HOLY_AURA)) {
    /*** END NWN1 SPECIFIC ***/
                eSummon = EffectSummonCreature(sResref, VFX_FNF_SUMMON_GATE, 3.0);
                DelayCommand(3.0, GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spInfo.lTarget, fDuration));
                //*** NWN 2 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eGate, spInfo.lTarget, 5.0);
    /*** NWN1 SPECIFIC ***/
        } else {
            GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spInfo.lTarget);
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                iIsPvPArea = TRUE;
            }
            DelayCommand(3.0, CreateOutsider(iIsPvPArea, oCaster));
        }
    /*** END NWN1 SPECIFIC ***/
    //*:**********************************************
    //*:* XP Cost for spell
    //*:**********************************************
    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);

    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
