//*:**************************************************************************
//*:*  GR_S0_RESURRECT.NSS
//*:**************************************************************************
//*:* Raise Dead [NW_S0_RaisDead.nss] Copyright (c) 2000 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 31, 2001
//*:* 3.5 Player's Handbook (p. 268)
//*:*
//*:* Resurrection [NW_S0_Ressurec.nss] Copyright (c) 2000 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 31, 2001
//*:* 3.5 Player's Handbook (p. 272)
//*:**************************************************************************
//*:* True Resurrection
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: November 8, 2007
//*:* 3.5 Player's Handbook (p. 296)
//*:**************************************************************************
//*:* Updated On: November 6, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"       - INCLUDED IN GR_IN_SPREMOVE
#include "GR_IN_SPELLHOOK"
#include "GR_IN_SPREMOVE"

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
    int     bDeathDrainLevels       = GetLocalInt(GetModule(), "GR_DEATHDRAINLEVELS");
    int     i;
    int     iHealAmount;
    int     iHD                     = GetHitDice(spInfo.oTarget);
    int     iDrainCon               = 2;
    int     iNewXP                  = MaxInt(0, ((iHD-1)*(iHD-2))/2*1000);
    /*** NWN1 SINGLE ***/ int     iVisualType             = VFX_IMP_RAISE_DEAD;
    //*** NWN2 SINGLE ***/ int     iVisualType             = VFX_HIT_SPELL_CONJURATION;

    int     bPassSpecialTarget;

    if(spInfo.iSpellID!=SPELL_GR_TRUE_RESURRECTION) {
        bPassSpecialTarget = GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_OUTSIDER && GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_ELEMENTAL &&
                GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_UNDEAD && GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_CONSTRUCT;
    } else {
        bPassSpecialTarget = GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_UNDEAD && GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_CONSTRUCT;
    }
    if(!bPassSpecialTarget) {
        bPassSpecialTarget = GRGetRacialType(spInfo.oTarget)!=GetRacialType(spInfo.oTarget);
    }


    int     bCannotRaise        = (iHD==1) && (GetAbilityScore(spInfo.oTarget, ABILITY_CONSTITUTION)<=2) && spInfo.iSpellID!=SPELL_GR_TRUE_RESURRECTION;
    int     bRaiseDeadDeathEffect   = (spInfo.iSpellID==SPELL_RAISE_DEAD && GetLocalInt(spInfo.oTarget, "GR_KILLED_DEATH_EFFECT"));
    int     iEffect3                = EFFECT_TYPE_INVALIDEFFECT;

    switch(spInfo.iSpellID) {
        case SPELL_RAISE_DEAD:
            iHealAmount = iHD;
            break;
        case SPELL_RESURRECTION:
        case SPELL_GR_TRUE_RESURRECTION:
            iHealAmount = GetMaxHitPoints(spInfo.oTarget)-GetCurrentHitPoints(spInfo.oTarget);
            break;
    }


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
    effect eRaise       = EffectResurrection();
    effect eVis         = EffectVisualEffect(iVisualType);
    effect eHeal        = EffectHeal(iHealAmount);
    effect eDrainCon    = SupernaturalEffect(EffectAbilityDecrease(ABILITY_CONSTITUTION, iDrainCon));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));

    //*:**********************************************
    //*:* Verify target can have spell cast on them
    //*:**********************************************
    if(GetIsDead(spInfo.oTarget) && bPassSpecialTarget && !bCannotRaise && !bRaiseDeadDeathEffect) {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(spInfo.oTarget));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eRaise, spInfo.oTarget);

        if(spInfo.iSpellID==SPELL_RAISE_DEAD) {
            //*:**********************************************
            //*:* Raise Dead - abilities reduced to 0 get bumped
            //*:* to 1
            //*:**********************************************
            for(i=ABILITY_STRENGTH; i<=ABILITY_CHARISMA; i++) {
                if(GetAbilityScore(spInfo.oTarget, i)==0) {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAbilityIncrease(i,1), spInfo.oTarget, GRGetDuration(spInfo.iCasterLevel, DUR_TYPE_DAYS));
                }
            }
        } else {
            //*:**********************************************
            //*:* Res/True Res - Ability Decreases are removed
            //*:**********************************************
            iEffect3 = EFFECT_TYPE_ABILITY_DECREASE;
            if(GetLocalInt(spInfo.oTarget, "GR_KILLED_DEATH_EFFECT")) {
                DeleteLocalInt(spInfo.oTarget, "GR_KILLED_DEATH_EFFECT");
            }
        }
        GRRemoveMultipleEffects(EFFECT_TYPE_POISON, EFFECT_TYPE_DISEASE, spInfo.oTarget, OBJECT_INVALID, iEffect3);

        if(iHealAmount>0) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spInfo.oTarget);
            //*:**********************************************
            //*:* Drain level or CON if not True Resurrection
            //*:* and Game Difficulty set to Normal or higher
            //*:**********************************************
            if(spInfo.iSpellID!=SPELL_GR_TRUE_RESURRECTION && GetGameDifficulty()>=GAME_DIFFICULTY_NORMAL) {
                //*:**********************************************
                //*:* Drain level
                //*:**********************************************
                if(iHealAmount>0) {
                    SetXP(spInfo.oTarget, iNewXP);
                    //*:**********************************************
                    //*:* Raise Dead - casters that do not prepare spells
                    //*:* ahead of time have 50% chance of losing 1 slot
                    //*:* casting upon revival
                    //*:**********************************************
                    if(d100()<51 && spInfo.iSpellID==SPELL_RAISE_DEAD) {
                        int bSorcerer = GRGetHasClass(CLASS_TYPE_SORCERER, spInfo.oTarget);
                        int bBard = GRGetHasClass(CLASS_TYPE_SORCERER, spInfo.oTarget);
                        int iSorcLvl = (bSorcerer ? GRGetLevelByClass(CLASS_TYPE_SORCERER, spInfo.oTarget) : 0);
                        int iBardLvl = (bBard ? GRGetLevelByClass(CLASS_TYPE_BARD, spInfo.oTarget) : 0);

                        if(iSorcLvl && iBardLvl) {
                            if(iSorcLvl>=iBardLvl) {
                                GRDoSpellRemoval(spInfo.oTarget, CLASS_TYPE_SORCERER);
                            } else {
                                GRDoSpellRemoval(spInfo.oTarget, CLASS_TYPE_BARD);
                            }
                        } else if(bSorcerer || bBard) {
                            GRDoSpellRemoval(spInfo.oTarget, (bSorcerer ? CLASS_TYPE_SORCERER : CLASS_TYPE_BARD));
                        }
                    }
                //*:**********************************************
                //*:* Drain CON
                //*:**********************************************
                } else {
                    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDrainCon, spInfo.oTarget);
                }
            }
        }
    } else if(bRaiseDeadDeathEffect) {
        //*:**********************************************
        //*:* Raise Dead doesn't raise those killed by death effects
        //*:**********************************************
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetName(spInfo.oTarget) + GetStringByStrRef(16939263));
        }
    } else if(!bPassSpecialTarget) {
        //*:**********************************************
        //*:* Target not of appropriate racial type
        //*:**********************************************
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetName(spInfo.oTarget) + GetStringByStrRef(16939264));
        }
    } else if(bCannotRaise) {
        //*:**********************************************
        //*:* Target is level 1 and CON reduction would
        //*:* reduce to 0 or lower
        //*:**********************************************
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetName(spInfo.oTarget) + GetStringByStrRef(16939265));
        }
    } else if(GetObjectType(spInfo.oTarget) == OBJECT_TYPE_PLACEABLE) {
        int iStrRef = GetLocalInt(spInfo.oTarget,"X2_L_RESURRECT_SPELL_MSG_RESREF");
        if(iStrRef == 0) {
            iStrRef = 83861;
        }
        if(iStrRef != -1) {
             FloatingTextStrRefOnCreature(iStrRef, oCaster);
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
