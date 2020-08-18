//*:**************************************************************************
//*:*  GR_S0_PRISAURA.NSS
//*:**************************************************************************
//*:* Prismatic Aura
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 21, 2008
//*:* Complete Mage (p. 113)
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
int ApplyPrismaticEffect(int iEffect, struct SpellStruct spInfo) {
    int iDamage;
    int iSecDamage;
    int iVis;
    float fParaDur = GRGetDuration(10);

    effect ePrism;
    effect eVis;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink;
    effect ePoison;
    effect eDur2;
    effect eMind;

    //Based on the random number passed in, apply the appropriate effect and set the visual to
    //the correct constant
    switch(iEffect) {
        case 1://fire
            iDamage = 20;
            iVis = VFX_IMP_FLAME_S;
            iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, spInfo.oCaster, SAVING_THROW_TYPE_FIRE);
            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, spInfo.oCaster, SAVING_THROW_TYPE_FIRE);
                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                    iDamage = iSecDamage;
                }
            }
            ePrism = EffectDamage(iDamage, DAMAGE_TYPE_FIRE);
            if(iSecDamage>0) ePrism = EffectLinkEffects(ePrism, EffectDamage(iSecDamage, spInfo.iSecDmgType));
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, spInfo.oTarget);
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }
            break;
        case 2: //Acid
            iDamage = 40;
            iVis = VFX_IMP_ACID_L;
            iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, spInfo.oCaster, SAVING_THROW_TYPE_ACID);
            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, spInfo.oCaster, SAVING_THROW_TYPE_ACID);
                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                    iDamage = iSecDamage;
                }
            }
            ePrism = EffectDamage(iDamage, DAMAGE_TYPE_ACID);
            if(iSecDamage>0) ePrism = EffectLinkEffects(ePrism, EffectDamage(iSecDamage, spInfo.iSecDmgType));
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, spInfo.oTarget);
            break;
        case 3: //Electricity
            iDamage = 80;
            iVis = VFX_IMP_LIGHTNING_S;
            iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, spInfo.oCaster, SAVING_THROW_TYPE_ELECTRICITY);
            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, spInfo.oCaster, SAVING_THROW_TYPE_ELECTRICITY);
                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                    iDamage = iSecDamage;
                }
            }
            ePrism = EffectDamage(iDamage, DAMAGE_TYPE_ELECTRICAL);
            if(iSecDamage>0) ePrism = EffectLinkEffects(ePrism, EffectDamage(iSecDamage, spInfo.iSecDmgType));
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, spInfo.oTarget);
            break;
        case 4: //Poison
            ePoison = EffectPoison(POISON_BEBILITH_VENOM);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePoison, spInfo.oTarget);
            break;
        case 5: //Petrified
            eDur2 = EffectVisualEffect(VFX_DUR_PETRIFY);
            if(GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC) == 0) {
                ePrism = EffectPetrify();
                eLink = EffectLinkEffects(eDur, ePrism);
                eLink = EffectLinkEffects(eLink, eDur2);
                if(!GetHasSpellEffect(SPELL_IRON_BODY, spInfo.oTarget)) {
                    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
                }
            }
            break;
        case 6: //Confusion
            eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
            ePrism = EffectConfused();
            eLink = EffectLinkEffects(eMind, ePrism);
            eLink = EffectLinkEffects(eLink, eDur);

            if (!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, spInfo.oCaster)) {
                iVis = VFX_IMP_CONFUSION_S;
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
            }
            break;
        case 7: //Death
            if (!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH, spInfo.oCaster)) {
                ePrism = EffectDeath();
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, spInfo.oTarget);
                GRSetKilledByDeathEffect(spInfo.oTarget, spInfo.oCaster);
            }
            break;
    }

    return iVis;
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oItem           = GetSpellCastItem();
    string  sMyTag          = GetTag(oItem);
    object  oCaster         = GetItemPossessor(oItem);
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId(), oItem);

    spInfo.oTarget         = GetLastAttacker(oCaster);
    spInfo.iDC             = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

    float   fTargetDist     = GetDistanceBetween(oCaster, spInfo.oTarget);

    //*:* hack - only works for melee attackers - not ranged
    if(fTargetDist>FeetToMeters(5.0)) {
        return;
    }
    //*:* caster no longer has visual effect, spell must have
    //*:* been dispelled
    if(!GetHasSpellEffect(SPELL_GR_PRISMATIC_AURA, oCaster)) {
        return;
    }
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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     bRed    = GetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_RED");
    int     bOrange = GetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_ORANGE");
    int     bYellow = GetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_YELLOW");
    int     bGreen  = GetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_GREEN");
    int     bBlue   = GetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_BLUE");
    int     bIndigo = GetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_INDIGO");
    int     bViolet = GetLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_VIOLET");

    int     bValidRoll = FALSE;

    int     iRandom, iVisual;

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
    effect eVisual;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_PRISMATIC_AURA, TRUE));
    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
    while(!bValidRoll) {
        iRandom = d8();
        switch(iRandom) {
            case 1:
                bValidRoll = bRed;
                break;
            case 2:
                bValidRoll = bOrange;
                break;
            case 3:
                bValidRoll = bYellow;
                break;
            case 4:
                bValidRoll = bGreen;
                break;
            case 5:
                bValidRoll = bBlue;
                break;
            case 6:
                bValidRoll = bIndigo;
                break;
            case 7:
                bValidRoll = bViolet;
                break;
        }
    }

    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        iVisual = ApplyPrismaticEffect(iRandom, spInfo);

        if(iVisual != 0) {
            eVisual = EffectVisualEffect(iVisual);
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spInfo.oTarget));
        }
    }

    switch(iRandom) {
        case 1:
            DeleteLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_RED");
            break;
        case 2:
            DeleteLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_ORANGE");
            break;
        case 3:
            DeleteLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_YELLOW");
            break;
        case 4:
            DeleteLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_GREEN");
            break;
        case 5:
            DeleteLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_BLUE");
            break;
        case 6:
            DeleteLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_INDIGO");
            break;
        case 7:
            DeleteLocalInt(oCaster, "GR_"+IntToString(spInfo.iSpellID)+"_VIOLET");
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
