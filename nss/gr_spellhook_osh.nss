//*:**************************************************************************
//*:*  GR_SPELLHOOK_OSH.NSS
//*:**************************************************************************
//*:* Grimoire Spellhook Script
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: a long time ago
//*:*
//*:**************************************************************************
//*:* Updated On: April 10, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_HEALHARM" // - includes "GR_IN_SPELLS"

//*:* #include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
int PassConcentrationCheck(int iDC, int iStrRef, object oCaster, int iSpellID) {
    if(d20()+GetSkillRank(SKILL_CONCENTRATION, oCaster)<iDC) {
        SetModuleOverrideSpellScriptFinished();
        GRClearSpellInfo(iSpellID, oCaster);
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetStringByStrRef(iStrRef));
        }
        return FALSE;
    }
    return TRUE;
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    object  oItem           = GetSpellCastItem();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GetSpellId(), oCaster);


    int     bSpellReflection = GetLocalInt(oCaster, "GR_SPELL_REFLECTION");

    if(bSpellReflection) {
        DeleteLocalInt(oCaster, "GR_SPELL_REFLECTION");
    }
    //*:**********************************************
    //*:* Magic Dead/Anti-magic areas
    //*:**********************************************
    if(GRGetMagicBlocked(oCaster) || GRGetMagicBlocked(GetArea(oCaster))) {
        SetModuleOverrideSpellScriptFinished();
        GRClearSpellInfo(spInfo.iSpellID, oCaster);
        return;
    }
    //*:**********************************************
    //*:* Warlock Arcane spell failure
    //*:**********************************************
    if(spInfo.iSpellCastClass==CLASS_TYPE_WARLOCK) {
        int iArcaneSpellFailure = GetArcaneSpellFailure(oCaster);
        //*:**********************************************
        //*:* Armor check - Chain Shirt is Light
        //*:* Hide is Medium
        //*:**********************************************
        object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, spSpellInfo.oTarget);
        int iArmorType = GRGetArmorType(oArmor);
        string sArmorName = GetName(oArmor);
        int iFailureAmount = 0;
        switch(iArmorType) {
            case 1: // Padded
                iFailureAmount = 5;
                break;
            case 2: // Leather
                iFailureAmount = 10;
                break;
            case 3: // Studded Leather & Hide Armor (Hide is medium armor)
                if(FindSubString(GetStringLowerCase(sArmorName), "hide")==-1) {
                    iFailureAmount = 15;
                }
                break;
            case 4: // Chain Shirt & Scale Mail (Chain Shirt is light armor)
                if(FindSubString(GetStringLowerCase(sArmorName), "chain shirt")>-1) {
                    iFailureAmount = 20;
                }
                break;
        }
        if(iArcaneSpellFailure>=iFailureAmount) {
            iArcaneSpellFailure -= iFailureAmount;
        }

        if(d100()<=iArcaneSpellFailure) {
            if(GetIsPC(oCaster)) {
                SendMessageToPC(oCaster, GetStringByStrRef(16939216)+" ("+IntToString(iArcaneSpellFailure)+"%)");
            }
            SetModuleOverrideSpellScriptFinished();
            GRClearSpellInfo(spInfo.iSpellID, oCaster);
        }
    }

    //*:**********************************************
    //*:* Underwater
    //*:**********************************************
    if(GRGetIsUnderwater(oCaster) && spInfo.iUnderwater) {
        if(!GRGetUnderwaterFireSuccess(spInfo.iSpellID, oCaster)) {
            SetModuleOverrideSpellScriptFinished();
            GRClearSpellInfo(spInfo.iSpellID, oCaster);
            return;
        }
    }

    //*:**********************************************
    //*:* Cleric memorized domain-spells && domain feats
    //*:**********************************************
    if(spInfo.iSpellCastClass==CLASS_TYPE_CLERIC && GetIsPC(oCaster)) {
        if(GetModuleSwitchValue("GR_ENFORCE_DOMAINSPELLS")) {
            //AutoDebugString("Domain check done = "+IntToString(GetLocalInt(oCaster,"SG_DOMAIN_CHECK_DONE")));
            if(!GetLocalInt(oCaster,"GR_DOMAIN_CHECK_DONE"))  {
                GRCheckDomainSpellsMemorized(oCaster);
            }
            if(GetLocalInt(oCaster, "GR_DOMAIN_BLOCK")) {
                FloatingTextStrRefOnCreature(16939217, oCaster, FALSE);
                SendMessageToPC(oCaster, GetStringByStrRef(16939218));
                SendMessageToPC(oCaster, GetStringByStrRef(16939219));
                SetModuleOverrideSpellScriptFinished();
                GRClearSpellInfo(spInfo.iSpellID, oCaster);
            }
        }

        if(!GetLocalInt(oCaster,"GR_L_DOMAIN_FEATS") && GRGetHasClass(CLASS_TYPE_CLERIC, oCaster)) {
            if(GRGetHasDomain(DOMAIN_DARKNESS) || GRGetHasDomain(DOMAIN_DROW) || GRGetHasDomain(DOMAIN_DWARF) ||
               GRGetHasDomain(DOMAIN_UNDEATH)) {
                   GRCheckSpecialDomainFeats(oCaster);
            }
        }
    }

    //*:**********************************************
    //*:* Cleric alignment spell restrictions
    //*:**********************************************
    if(spInfo.iSpellCastClass==CLASS_TYPE_CLERIC) {
        int iGoodEvilAlign = GetAlignmentGoodEvil(oCaster);
        int iLawChaosAlign = GetAlignmentLawChaos(oCaster);

        if(iGoodEvilAlign==ALIGNMENT_NEUTRAL) {
            iGoodEvilAlign = GRGetDeityAlignGoodEvil(GRGetDeity(oCaster));
            if(iGoodEvilAlign==ALIGNMENT_NEUTRAL) iGoodEvilAlign = ALIGNMENT_GOOD;
        }
        if(iLawChaosAlign==ALIGNMENT_NEUTRAL) {
            iLawChaosAlign = GRGetDeityAlignGoodEvil(GRGetDeity(oCaster));
            if(iLawChaosAlign==ALIGNMENT_NEUTRAL) iLawChaosAlign = ALIGNMENT_LAWFUL;
        }

        int bAlignSpell = FALSE;
        int bCanCast    = TRUE;
        int iPos;
        int iDescriptor;

        for(iPos=1; iPos<=3; i++) {
            iDescriptor = GRGetSpellDescriptor(spInfo.iSpellID, oCaster, iPos);
            switch(iDescriptor) {
                case SPELL_TYPE_EVIL:
                    if(!bAlignSpell) {
                        bCanCast = (iGoodEvilAlign==ALIGNMENT_EVIL);
                    } else {
                        bCanCast = bCanCast || (iGoodEvilAlign==ALIGNMENT_EVIL);
                    }
                    bAlignSpell = TRUE;
                    break;
                case SPELL_TYPE_GOOD:
                    if(!bAlignSpell) {
                        bCanCast = (iGoodEvilAlign==ALIGNMENT_GOOD);
                    } else {
                        bCanCast = bCanCast || (iGoodEvilAlign==ALIGNMENT_GOOD);
                    }
                    bAlignSpell = TRUE;
                    break;
                case SPELL_TYPE_CHAOTIC:
                    if(!bAlignSpell) {
                        bCanCast = (iLawChaosAlign==ALIGNMENT_CHAOTIC);
                    } else {
                        bCanCast = bCanCast || (iLawChaosAlign==ALIGNMENT_CHAOTIC);
                    }
                    bAlignSpell = TRUE;
                    break;
                case SPELL_TYPE_LAWFUL:
                    if(!bAlignSpell) {
                        bCanCast = (iLawChaosAlign==ALIGNMENT_LAWFUL);
                    } else {
                        bCanCast = bCanCast || (iLawChaosAlign==ALIGNMENT_LAWFUL);
                    }
                    bAlignSpell = TRUE;
                    break;
            }
        }

        if(bAlignSpell && !bCanCast) {
            SetModuleOverrideSpellScriptFinished();
            if(GetIsPC(oCaster)) {
                SendMessageToPC(oCaster, GetStringByStrRef(16939297));
            }
            GRClearSpellInfo(spInfo.iSpellID, oCaster);
            return;
        }
    }


    //*:**********************************************
    //*:* Check for effects that influence spells/item
    //*:* use.  Effects that cancel spellcasting should
    //*:* come before effects that modify spellcasting
    //*:**********************************************
    //*:* - Tenser's Transformation
    //*:* - Barbarian Rage/other rage abilities
    //*:* - Iron Body
    //*:* - Sting Ray
    //*:* - Heartfire
    //*:* - Insidious Rhythm
    //*:* - Creaking Cacophony
    //*:* - Dirge of Discord
    //*:* - Fever Dream
    //*:* - Discordant Malediction
    //*:* - Distort Speech
    //*:* - Simbul's Synostodweomer
    //*:* - Spell Turning
    //*:* - Iron Mind
    //*:* - Incapacitate and Condemned
    //*:* - Time Stop blocked
    //*:* - Divine Interdiction
    //*:* - Consecrate blocks summoning/creating undead
    //*:* - Dimensional Anchor block teleport
    //*:* - Aura against Flame counters fire spells
    //*:**********************************************
    //*:* - Tenser's Transformation
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_TENSERS_TRANSFORMATION, oCaster)) {
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetStringByStrRef(16939220));
        }
        SetModuleOverrideSpellScriptFinished();
        GRClearSpellInfo(spInfo.iSpellID, oCaster);
        return;
    }
    //*:**********************************************
    //*:* - Barbarian Rage/other rage effects
    //*:**********************************************
    if(GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCaster) ||
        GetHasSpellEffect(SPELL_BLOOD_FRENZY, oCaster) || GetHasSpellEffect(SPELL_RAGE, oCaster)) {

        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetStringByStrRef(16939221));
        }
        SetModuleOverrideSpellScriptFinished();
        GRClearSpellInfo(spInfo.iSpellID, oCaster);
        return;
    }
    //*:**********************************************
    //*:* - Iron Body
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_IRON_BODY, spInfo.oTarget)) {
        if(GetIsObjectValid(oItem) && GetBaseItemType(oItem)==BASE_ITEM_POTIONS) {
            if(GetIsPC(spInfo.oTarget)) {
                SendMessageToPC(spInfo.oTarget, GetStringByStrRef(16939236));
            }
            SetModuleOverrideSpellScriptFinished();
            GRClearSpellInfo(spInfo.iSpellID, oCaster);
            return;
        }
    }
    //*:**********************************************
    //*:* Concentration check spells
    //*:**********************************************
    //*:* - Sting Ray
    //*:**********************************************
    if(GRGetHasEffectTypeFromSpell(EFFECT_TYPE_MOVEMENT_SPEED_DECREASE, oCaster, SPELL_GR_STING_RAY)) {
        int iDC = GetLocalInt(oCaster, "GR_STINGRAY_DC") + spInfo.iSpellLevel;
        if(!PassConcentrationCheck(iDC, 16939222, oCaster, spInfo.iSpellID)) return;
    }
    //*:**********************************************
    //*:* - Heartfire
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_HEARTFIRE, oCaster)) {
        int iDC = 10 + MaxInt(1, GetLocalInt(oCaster, "GR_HF_DMG")/2);
        if(!PassConcentrationCheck(iDC, 16939223, oCaster, spInfo.iSpellID)) return;
    }
    //*:**********************************************
    //*:* - Insidious Rhythm
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_INSIDIOUS_RHYTHM, oCaster)) {
        int iDC = 11 + spInfo.iSpellLevel;
        if(!PassConcentrationCheck(iDC, 16939225, oCaster, spInfo.iSpellID)) return;
    }
    //*:**********************************************
    //*:* - Creaking Cacophony
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_CREAKING_CACOPHONY, oCaster)) {
        int iDC = GetLocalInt(oCaster, "GR_CREAK_DC") + spInfo.iSpellLevel;
        if(!PassConcentrationCheck(iDC, 16939294, oCaster, spInfo.iSpellID)) return;
    }
    //*:**********************************************
    //*:* - Dirge of Discord
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_DIRGE_OF_DISCORD, oCaster)) {
        int iDC = GetLocalInt(oCaster, "GR_DIRGEDISCORD_DC") + spInfo.iSpellLevel;
        if(!PassConcentrationCheck(iDC, 16939295, oCaster, spInfo.iSpellID)) return;
    }
    //*:**********************************************
    //*:* - Fever Dream
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_FEVER_DREAM, oCaster)) {
        int iDC = GetLocalInt(oCaster, "GR_FEVERDREAM_DC") + spInfo.iSpellLevel;
        if(!PassConcentrationCheck(iDC, 16939298, oCaster, spInfo.iSpellID)) return;
    }
    //*:**********************************************
    //*:* - Discordant Malediction
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_DISCORDANT_MALEDICTION, oCaster)) {
        int iDamage = GRDoDiscordantMalediction(oCaster);
        int iCheckDC = 15 + iDamage + spInfo.iSpellLevel;
        if(!PassConcentrationCheck(iCheckDC, 16939230, oCaster, spInfo.iSpellID)) return;
    }
    //*:**********************************************
    //*:* - Distort Speech
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_DISTORT_SPEECH, oCaster)) {
        int dPct = d100();
        if(dPct>50) {
            FloatingTextStrRefOnCreature(16939227, oCaster, TRUE);
            if(GetIsPC(oCaster)) {
                SendMessageToPC(oCaster, GetStringByStrRef(16939226));
            }
            SetModuleOverrideSpellScriptFinished();
            GRClearSpellInfo(spInfo.iSpellID, oCaster);
            return;
        }
    }
    //*:**********************************************
    //*:* - Simbul's Synostodweomer
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_SIMBULS_SYNOSTODWEOMER, oCaster) && !GetIsObjectValid(oItem)) {
        GRDoSynostodweomer(spInfo, oCaster);
        SetModuleOverrideSpellScriptFinished();
        GRClearSpellInfo(spInfo.iSpellID, oCaster);
        return;
    }
    //*:**********************************************
    //*:* - Spell Turning (, Lesser)
    //*:**********************************************
    if((GetHasSpellEffect(SPELL_SPELL_TURNING, spInfo.oTarget) || GetHasSpellEffect(SPELL_GR_LESSER_SPELL_TURNING, spInfo.oTarget)) &&
        !bSpellReflection) {

        if(spInfo.iTurnable) {
            GRDoSpellTurning(spInfo, spInfo.oTarget, oCaster);
            if(!GetLocalInt(spInfo.oTarget, "GR_SPELLTURN_TARGET_AFFECTED")) {
                SetModuleOverrideSpellScriptFinished();
                GRClearSpellInfo(spInfo.iSpellID, oCaster);
            } else {
                DeleteLocalInt(spInfo.oTarget, "GR_SPELLTURN_TARGET_AFFECTED");
            }
        }
    }
    //*:**********************************************
    //*:* - Iron Mind: Charm subschool immunity
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_IRON_MIND, spInfo.oTarget) && GRGetSpellSubschool(spInfo.iSpellID)==SPELL_SUBSCHOOL_CHARM) {
        SetModuleOverrideSpellScriptFinished();
    }
    //*:**********************************************
    //*:* - Incapacitate and Condemned effects
    //*:**********************************************
    if(GRGetIsHealingSpell(oCaster) && GRGetIsImmuneToMagicalHealing(spInfo.oTarget)) {
            SetModuleOverrideSpellScriptFinished();
    }
    if(GetHasSpellEffect(SPELL_GR_INCAPACITATE, spInfo.oTarget)) {
        if(GRGetIsHealingSpell(oCaster)) {
            if(spInfo.iSpellID!=SPELL_HEAL && spInfo.iSpellID!=SPELL_MASS_HEAL && spInfo.iSpellID!=SPELL_MASS_CURE_CRITICAL_WOUNDS) {
                SetModuleOverrideSpellScriptFinished();
            }
        }
        if(spInfo.iSpellID==SPELL_LESSER_RESTORATION)
            SetModuleOverrideSpellScriptFinished();
    }
    //*:**********************************************
    //*:* - Time Stop - check if activated
    //*:**********************************************
    if(spInfo.iSpellID==SPELL_TIME_STOP) {
        if(GetLocalInt(GetModule(),"GR_NO_TIMESTOP")) {
            SetModuleOverrideSpellScriptFinished();
            GRClearSpellInfo(spInfo.iSpellID, oCaster);
            return;
        }
    }
    //*:**********************************************
    //*:* - Divine Interdiction
    //*:**********************************************
    if(spInfo.iSpellID==SPELLABILITY_TURN_UNDEAD && GetHasSpellEffect(SPELL_GR_DIVINE_INTERDICTION, oCaster)) {
        if(GetIsPC(oCaster)) {
            FloatingTextStrRefOnCreature(16939228, oCaster, FALSE);
            SendMessageToPC(oCaster, GetStringByStrRef(16939229));
        }
        SetModuleOverrideSpellScriptFinished();
        GRClearSpellInfo(spInfo.iSpellID, oCaster);
        return;
    }
    //*:**********************************************
    //*:* - Consecrate
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_CONSECRATE, oCaster) && (spInfo.iSpellID==SPELL_CREATE_UNDEAD ||
        spInfo.iSpellID==SPELL_CREATE_GREATER_UNDEAD || spInfo.iSpellID==609 || spInfo.iSpellID==624 ||
        spInfo.iSpellID==627)) {
            SetModuleOverrideSpellScriptFinished();
            if(GetIsPC(oCaster)) {
                SendMessageToPC(oCaster, GetStringByStrRef(16939231));
            }
            GRClearSpellInfo(spInfo.iSpellID, oCaster);
            return;
    }
    //*:**********************************************
    //*:* - Dimensional Anchor
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_DIMENSIONAL_ANCHOR) || GetLocalInt(oCaster, "GR_TELEPORT_BLOCKED") ||
        GetLocalInt(GetArea(oCaster),"GR_TELEPORT_BLOCKED")) {
        if(spInfo.iSpellID==SPELL_GR_DIMENSION_DOOR ||
            spInfo.iSpellID==668 ||    // item teleport spell
            spInfo.iSpellID==SPELL_ETHEREALNESS ||
            GRGetSpellSubschool(spInfo.iSpellID)==SPELL_SUBSCHOOL_TELEPORTATION ||
            GRGetSpellHasDescriptor(spInfo.iSpellID, SPELL_TYPE_TELEPORTATION) {
                if(GetIsPC(oCaster))
                    SendMessageToPC(oCaster, GetStringByStrRef(16939232));
                SetModuleOverrideSpellScriptFinished();
                GRClearSpellInfo(spInfo.iSpellID, oCaster);
                return;
        }
    } else if(GetHasSpellEffect(SPELL_GR_DIMENSIONAL_ANCHOR, oTarget) || GetLocalInt(oTarget,"SG_TELEPORT_BLOCKED")) {
        if(spInfo.iSpellID==SPELL_BANISHMENT ||
            spInfo.iSpellID==SPELL_DISMISSAL ||
            GRGetSpellSubschool(spInfo.iSpellID)==SPELL_SUBSCHOOL_TELEPORTATION ||
            GRGetSpellHasDescriptor(spInfo.iSpellID, SPELL_TYPE_TELEPORTATION) {
                SetModuleOverrideSpellScriptFinished();
                GRClearSpellInfo(spInfo.iSpellID, oCaster);
                return;
        }
    }
    //*:**********************************************
    //*:* - Aura against Flame
    //*:**********************************************
    if(GRGetSpellHasDescriptor(spInfo.iSpellID, SPELL_TYPE_FIRE, oCaster)) {
        if(GetIsObjectValid(spInfo.oTarget) && GetHasSpellEffect(SPELL_GR_AURA_AGAINST_FLAME, spInfo.oTarget)) {
            int iCounterCheck = d20() + GetLevelByClass(CLASS_TYPE_CLERIC, spInfo.oTarget);
            iDC = 11 + iCasterLevel;
            if(iCounterCheck>=iDC) {
                GRRemoveSpellEffects(SPELL_GR_AURA_AGAINST_FLAME, spInfo.oTarget);
                SetModuleOverrideSpellScriptFinished();
                if(GetIsPC(spInfo.oTarget)) {
                    string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", spInfo.iSpellID)));
                    SendMessageToPC(spInfo.oTarget, GetStringByStrRef(16939233)+sSpellName+GetStringByStrRef(16939234));
                    SendMessageToPC(spInfo.oTarget, GetStringByStrRef(16939235);
                }
                GRClearSpellInfo(spInfo.iSpellID, oCaster);
                return;
            }
        }
    }
}
//*:**************************************************************************
//*:**************************************************************************
