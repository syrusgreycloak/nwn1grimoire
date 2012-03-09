//*:**************************************************************************
//*:*  GR_S3_CLONEFIST.NSS
//*:**************************************************************************
//:: x0_s3_clonefist
//:: Copyright (c) 2001 Bioware Corp.
//*:**************************************************************************
/*
    Create a fiery version of the character
    to help them fight.
*/
//*:**************************************************************************
//*:* Updated On: December 26, 2007
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
void FakeHB() {

    effect  eFlame      = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect  eFirePro    = EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, 100);
    int     iExplode    = GetLocalInt(OBJECT_SELF, "X0_L_MYTIMERTOEXPLODE");
    object  oMaster     = GetLocalObject(OBJECT_SELF, "X0_L_MYMASTER");

    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eFlame, OBJECT_SELF);

    if(iExplode==6) {
        ClearAllActions();
        PlayVoiceChat(VOICE_CHAT_GOODBYE);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFirePro, oMaster, 3.5);
        ActionCastSpellAtLocation(SPELL_FIREBALL, GetLocation(OBJECT_SELF), METAMAGIC_ANY, TRUE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
        DestroyObject(OBJECT_SELF, 0.5);
        SetCommandable(FALSE);
        return;
    } else {
        object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oMaster, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        // * attack my master's enemy
        if(GetIsObjectValid(oEnemy)) {
            DetermineCombatRound(oEnemy);
        }

        ActionMoveToObject(GetLocalObject(OBJECT_SELF, "X0_L_MYMASTER"), TRUE);
        SetLocalInt(OBJECT_SELF, "X0_L_MYTIMERTOEXPLODE", iExplode + 1);
        DelayCommand(3.0, FakeHB());
    }
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
    object  oFireGuy        = CopyObject(oCaster, GetLocation(oCaster), OBJECT_INVALID, GetName(oCaster) + "CLONEFROMFISTS");

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
    effect eVis = EffectVisualEffect(VFX_DUR_ELEMENTAL_SHIELD);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SetLocalInt(oFireGuy, "X0_L_MYTIMERTOEXPLODE", 1);
    SetLocalObject(oFireGuy, "X0_L_MYMASTER", oCaster);
    ChangeToStandardFaction(oFireGuy, STANDARD_FACTION_COMMONER);
    SetPCLike(oCaster, oFireGuy);
    DelayCommand(0.5, SetPlotFlag(oFireGuy, TRUE)); // * so items don't drop, I can destroy myself.
    AssignCommand(oFireGuy, FakeHB());
    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eVis, oFireGuy);

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
