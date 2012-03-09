//*:**************************************************************************
//*:*  GR_S2_LAYONHAND.NSS
//*:**************************************************************************
//*:* Lay_On_Hands (NW_S2_LayOnHand.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Aug 15, 2001
//*:* Updated On: Oct 20, 2003
//*:**************************************************************************
//*:* Updated On: November 13, 2007
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

    spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_PALADIN) + GRGetLevelByClass(CLASS_TYPE_DIVINECHAMPION);
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
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iTouchAttack;
    int     iCHAMod         = MaxInt(0, GetAbilityModifier(ABILITY_CHARISMA));
    int     iHealAmt        = spInfo.iCasterLevel * iCHAMod;

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
    effect eHeal    = SupernaturalEffect(EffectHeal(iHealAmt));
    effect eVis     = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eVis2    = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eDam;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(iHealAmt>0) {
        if(GRGetRacialType(spInfo.oTarget) == RACIAL_TYPE_UNDEAD || GRGetLevelByClass(CLASS_TYPE_UNDEAD, spInfo.oTarget)>0) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELLABILITY_LAY_ON_HANDS));

            iTouchAttack = TouchAttackMelee(spInfo.oTarget);
            if(iTouchAttack>0) {
                if(iTouchAttack == 2) {
                    iHealAmt *= 2;
                }
                //*:**********************************************
                //*:* GZ: The PhB classifies Lay on Hands as spell-like
                //*:* ability, so it is subject to SR. No more
                //*:* cheesy demi lich kills on touch, sorry.
                //*:*
                //*:* SG: 3.5 rules classifies Lay on Hands as a
                //*:* supernatural ability, so I guess cheesy kills
                //*:* might be back in, but the damage is positive
                //*:* now, not divine, so Prot from Pos energy will
                //*:* help the demi-lich :)
                //*:**********************************************
                eDam = SupernaturalEffect(EffectDamage(iHealAmt, DAMAGE_TYPE_POSITIVE));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spInfo.oTarget);
            }
        } else {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_LAY_ON_HANDS, FALSE));
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spInfo.oTarget);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
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
