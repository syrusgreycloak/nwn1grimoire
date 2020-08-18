#include "GR_IN_SPELLS"

void GRDoSpellRemoval(object oTarget, int iSpellClass, int iNumSpellsToRemove = 1, int iLevelToRemove = -1) {

    int iSpellToRemove      = -1;
    int bAllSpellsChecked   = FALSE;
    int iNumSpellsChecked   = 0;
    int iTempSpell;
    int iNumSpellsToCheck;
    int iRandom;
    int iLevel              = GRGetLevelByClass(iSpellClass, oTarget);
    int iMaxSpellLevel;
    int bGetNextLevel;
    int bGetNextSpell;
    int iNumSpells;
    int i;


    switch(iSpellClass) {
        case CLASS_TYPE_BARD:
            if(iLevel==1) { iMaxSpellLevel=0; }
            else {
                iMaxSpellLevel = MinInt(6, 1+iLevel/3);
            }
            iNumSpellsToCheck = 147;
            SetLocalInt(oTarget, "NUM_SPELLS0", 4);
            SetLocalInt(oTarget, "NUM_SPELLS1", 23);
            SetLocalInt(oTarget, "NUM_SPELLS2", 39);
            SetLocalInt(oTarget, "NUM_SPELLS3", 25);
            SetLocalInt(oTarget, "NUM_SPELLS4", 18);
            SetLocalInt(oTarget, "NUM_SPELLS5", 23);
            SetLocalInt(oTarget, "NUM_SPELLS6", 15);
            break;
        case CLASS_TYPE_SORCERER:
            iMaxSpellLevel = MinInt(9, MaxInt(1, iLevel/2));
            iNumSpellsToCheck = 480;
            SetLocalInt(oTarget, "NUM_SPELLS0", 10);
            SetLocalInt(oTarget, "NUM_SPELLS1", 83);
            SetLocalInt(oTarget, "NUM_SPELLS2", 67);
            SetLocalInt(oTarget, "NUM_SPELLS3", 66);
            SetLocalInt(oTarget, "NUM_SPELLS4", 65);
            SetLocalInt(oTarget, "NUM_SPELLS5", 43);
            SetLocalInt(oTarget, "NUM_SPELLS6", 45);
            SetLocalInt(oTarget, "NUM_SPELLS7", 41);
            SetLocalInt(oTarget, "NUM_SPELLS8", 38);
            SetLocalInt(oTarget, "NUM_SPELLS9", 22);
            break;
    }

    while(iNumSpellsToRemove>0) {
        do {
            iLevel = (iLevelToRemove==-1 ? Random(iMaxSpellLevel+1) : iLevelToRemove);
            i = iLevel;
            do {
                bGetNextLevel = GetLocalInt(oTarget, "DONE_LVL"+IntToString(i));
                i = (iLevelToRemove==-1 ? (i+1) % 10 : (i-1) % 10);
                if(i<0) i=9;
            } while(bGetNextLevel && i!=iLevel);
            if(i==iLevel && bGetNextLevel) {
                bAllSpellsChecked = TRUE;
                return;
            } else if(!bGetNextLevel) {
                iLevel = i-1;
                iNumSpells = GetLocalInt(oTarget, "NUM_SPELLS"+IntToString(iLevel));
                iRandom = Random(iNumSpells)+1;
                i = iRandom;
                do {
                    bGetNextSpell = GetLocalInt(oTarget, "SPELL_L"+IntToString(iLevel)+"_S"+IntToString(i));
                    i = (i+1>iNumSpells ? 1 : i+1);
                } while(bGetNextSpell && i!=iRandom);
                if(i==iRandom && bGetNextSpell) {
                    SetLocalInt(oTarget, "DONE_LVL"+IntToString(iLevel), TRUE);
                } else if(iSpellClass==CLASS_TYPE_BARD) {
                    iRandom = i-1;
                    switch(iLevel) {
                        case 0:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_DAZE; break;
                                case 2: iTempSpell = SPELL_FLARE; break;
                                case 3: iTempSpell = SPELL_LIGHT; break;
                                case 4: iTempSpell = SPELL_RESISTANCE; break;
                            }
                            break;
                        case 1:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_GR_ALARM; break;
                                case 2: iTempSpell = SPELL_AMPLIFY; break;
                                case 3: iTempSpell = SPELL_GR_APPRAISING_TOUCH; break;
                                case 4: iTempSpell = SPELL_GR_BEASTLAND_FEROCITY; break;
                                case 5: iTempSpell = SPELL_CAUSE_FEAR; break;
                                case 6: iTempSpell = SPELL_CHARM_PERSON; break;
                                case 7: iTempSpell = SPELL_GR_COMPREHEND_LANGUAGES; break;
                                case 8: iTempSpell = SPELL_LESSER_CONFUSION; break;
                                case 9: iTempSpell = SPELL_CURE_LIGHT_WOUNDS; break;
                                case 10: iTempSpell = SPELL_LESSER_DISPEL; break;
                                case 11: iTempSpell = SPELL_EXPEDITIOUS_RETREAT; break;
                                case 12: iTempSpell = SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT; break;
                                case 13: iTempSpell = SPELL_GR_FLASH; break;
                                case 14: iTempSpell = SPELL_GREASE; break;
                                case 15: iTempSpell = SPELL_GR_HERALDS_CALL; break;
                                case 16: iTempSpell = SPELL_IDENTIFY; break;
                                case 17: iTempSpell = SPELL_GR_INVISIBILITY_SWIFT; break;
                                case 18: iTempSpell = SPELL_IRONGUTS; break;
                                case 19: iTempSpell = SPELL_BALAGARNSIRONHORN; break;
                                case 20: iTempSpell = SPELL_GR_RABBIT_FEET; break;
                                case 21: iTempSpell = SPELL_SLEEP; break;
                                case 22: iTempSpell = SPELL_SUMMON_CREATURE_I; break;
                                case 23: iTempSpell = SPELL_TASHAS_HIDEOUS_LAUGHTER; break;
                            }
                            break;
                        case 2:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_GR_GREATER_ALARM; break;
                                case 2: iTempSpell = SPELL_GR_BATTLECRY; break;
                                case 3: iTempSpell = SPELL_BLINDNESS_AND_DEAFNESS; break;
                                case 4: iTempSpell = SPELL_GR_BLUR; break;
                                case 5: iTempSpell = SPELL_GR_CALM_EMOTIONS; break;
                                case 6: iTempSpell = SPELL_CATS_GRACE; break;
                                case 7: iTempSpell = SPELL_CLOUD_OF_BEWILDERMENT; break;
                                case 8: iTempSpell = SPELL_CURE_MODERATE_WOUNDS; break;
                                case 9: iTempSpell = SPELL_CURSE_OF_BLADES; break;
                                case 10: iTempSpell = SPELL_DARKNESS; break;
                                case 11: iTempSpell = SPELL_GR_DAZE_MONSTER; break;
                                case 12: iTempSpell = SPELL_GR_DOLOMAR_WAVE; break;
                                case 13: iTempSpell = SPELL_EAGLES_SPLENDOR; break;
                                case 14: iTempSpell = SPELL_FOXS_CUNNING; break;
                                case 15: iTempSpell = SPELL_GHOSTLY_VISAGE; break;
                                case 16: iTempSpell = SPELL_GR_GLITTERDUST; break;
                                case 17: iTempSpell = SPELL_HEROISM; break;
                                case 18: iTempSpell = SPELL_HOLD_PERSON; break;
                                case 19: iTempSpell = SPELL_INVISIBILITY; break;
                                case 20: iTempSpell = SPELL_SCARE; break;
                                case 21: iTempSpell = SPELL_SEE_INVISIBILITY; break;
                                case 22: iTempSpell = SPELL_SILENCE; break;
                                case 23: iTempSpell = SPELL_SOUND_BURST; break;
                                case 24: iTempSpell = SPELL_GR_SUMMON_CREATURE_II_NORMAL; break;
                                case 25: iTempSpell = SPELL_GR_SUMMON_CREATURE_I_D3; break;
                                case 26: iTempSpell = SPELL_GR_CHROMATIC_ORB_WHITE; break;
                                case 27: iTempSpell = SPELL_GR_CHROMATIC_ORB_RED; break;
                                case 28: iTempSpell = SPELL_GR_CHROMATIC_ORB_YELLOW; break;
                                case 29: iTempSpell = SPELL_GR_CHROMATIC_ORB_ORANGE; break;
                                case 30: iTempSpell = SPELL_GR_CHROMATIC_ORB_GREEN; break;
                                case 31: iTempSpell = SPELL_GR_CHROMATIC_ORB_TURQUOISE; break;
                                case 32: iTempSpell = SPELL_GR_CHROMATIC_ORB_BLUE; break;
                                case 33: iTempSpell = SPELL_GR_CHROMATIC_ORB_VIOLET; break;
                                case 34: iTempSpell = SPELL_GR_CHROMATIC_ORB_BLACK; break;
                                case 35: iTempSpell = SPELL_SUMMON_CREATURE_II; break;
                                case 36: iTempSpell = SPELL_GR_CHROMATIC_ORB_LVLS15; break;
                                case 37: iTempSpell = SPELL_GR_CHROMATIC_ORB_LVLS69; break;
                                case 38: iTempSpell = SPELL_GR_BLINDNESS; break;
                                case 39: iTempSpell = SPELL_GR_DEAFNESS; break;
                            }
                            break;
                        case 3:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_CHARM_MONSTER; break;
                                case 2: iTempSpell = SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE; break;
                                case 3: iTempSpell = SPELL_CONFUSION; break;
                                case 4: iTempSpell = SPELL_CRUSHING_DESPAIR; break;
                                case 5: iTempSpell = SPELL_CURE_SERIOUS_WOUNDS; break;
                                case 6: iTempSpell = SPELL_GREATER_CURSE_OF_BLADES; break;
                                case 7: iTempSpell = SPELL_GR_DAYLIGHT; break;
                                case 8: iTempSpell = SPELL_DEEP_SLUMBER; break;
                                case 9: iTempSpell = SPELL_DISPEL_MAGIC; break;
                                case 10: iTempSpell = SPELL_DISPLACEMENT; break;
                                case 11: iTempSpell = SPELL_FEAR; break;
                                case 12: iTempSpell = SPELL_GR_GLIBNESS; break;
                                case 13: iTempSpell = SPELL_GR_GOOD_HOPE; break;
                                case 14: iTempSpell = SPELL_HASTE; break;
                                case 15: iTempSpell = SPELL_GR_HAUNTING_TUNE; break;
                                case 16: iTempSpell = SPELL_INVISIBILITY_SPHERE; break;
                                case 17: iTempSpell = SPELL_REMOVE_CURSE; break;
                                case 18: iTempSpell = SPELL_REMOVE_DISEASE; break;
                                case 19: iTempSpell = SPELL_SLOW; break;
                                case 20: iTempSpell = SPELL_GR_WALL_OF_SOUND; break;
                                case 21: iTempSpell = SPELL_WOUNDING_WHISPERS; break;
                                case 22: iTempSpell = SPELL_GR_SUMMON_CREATURE_III_NORMAL; break;
                                case 23: iTempSpell = SPELL_GR_SUMMON_CREATURE_II_D3; break;
                                case 24: iTempSpell = SPELL_GR_SUMMON_CREATURE_I_D4P1_III; break;
                                case 25: iTempSpell = SPELL_SUMMON_CREATURE_III; break;
                            }
                            break;
                        case 4:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_GR_MASS_CHARM_PERSON; break;
                                case 2: iTempSpell = SPELL_CLARITY; break;
                                case 3: iTempSpell = SPELL_GR_COMP_STRIFE; break;
                                case 4: iTempSpell = SPELL_CURE_CRITICAL_WOUNDS; break;
                                case 5: iTempSpell = SPELL_DOMINATE_PERSON; break;
                                case 6: iTempSpell = SPELL_HOLD_MONSTER; break;
                                case 7: iTempSpell = SPELL_GREATER_INVISIBILITY; break;
                                case 8: iTempSpell = SPELL_GR_IRON_MIND; break;
                                case 9: iTempSpell = SPELL_LEGEND_LORE; break;
                                case 10: iTempSpell = SPELL_NEUTRALIZE_POISON; break;
                                case 11: iTempSpell = SPELL_GR_REPEL_VERMIN; break;
                                case 12: iTempSpell = SPELL_SHOUT; break;
                                case 13: iTempSpell = SPELL_WAR_CRY; break;
                                case 14: iTempSpell = SPELL_GR_SUMMON_CREATURE_IV_NORMAL; break;
                                case 15: iTempSpell = SPELL_GR_SUMMON_CREATURE_III_D3; break;
                                case 16: iTempSpell = SPELL_GR_SUMMON_CREATURE_II_D4P1_IV; break;
                                case 17: iTempSpell = SPELL_GR_SUMMON_CREATURE_I_D4P1_IV; break;
                                case 18: iTempSpell = SPELL_SUMMON_CREATURE_IV; break;
                            }
                            break;
                        case 5:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_MASS_CURE_LIGHT_WOUNDS; break;
                                case 2: iTempSpell = SPELL_GREATER_DISPELLING; break;
                                case 3: iTempSpell = SPELL_ETHEREAL_VISAGE; break;
                                case 4: iTempSpell = SPELL_GREATER_HEROISM; break;
                                case 5: iTempSpell = SPELL_MIND_FOG; break;
                                case 6: iTempSpell = SPELL_GR_SHAD_EVOC1_ICE_STORM; break;
                                case 7: iTempSpell = SPELL_GR_SHAD_EVOC1_MORD_FORCE_MISSILES; break;
                                case 8: iTempSpell = SPELL_GR_SHAD_EVOC1_WALL_OF_FIRE; break;
                                case 9: iTempSpell = SPELL_GR_SHAD_EVOC1_FIREBALL; break;
                                case 10: iTempSpell = SPELL_GR_SHAD_EVOC1_FIREBURST; break;
                                case 11: iTempSpell = SPELL_GR_SHAD_EVOC2_ISAACS_LSR_MISSILES; break;
                                case 12: iTempSpell = SPELL_GR_SHAD_EVOC2_SHOUT; break;
                                case 13: iTempSpell = SPELL_GR_SHAD_EVOC2_WALL_OF_ICE; break;
                                case 14: iTempSpell = SPELL_GR_SHAD_EVOC2_ICE_BURST; break;
                                case 15: iTempSpell = SPELL_GR_SHAD_EVOC2_LIGHTNING_BOLT; break;
                                case 16: iTempSpell = SPELL_GR_SUMMON_CREATURE_V_NORMAL; break;
                                case 17: iTempSpell = SPELL_GR_SUMMON_CREATURE_IV_D3; break;
                                case 18: iTempSpell = SPELL_GR_SUMMON_CREATURE_III_D4P1_V; break;
                                case 19: iTempSpell = SPELL_GR_SUMMON_CREATURE_II_D4P1_V; break;
                                case 20: iTempSpell = SPELL_GR_SUMMON_CREATURE_I_D4P1_V; break;
                                case 21: iTempSpell = SPELL_GR_SHADOW_EVOCATION_I; break;
                                case 22: iTempSpell = SPELL_GR_SHADOW_EVOCATION_II; break;
                                case 23: iTempSpell = SPELL_SUMMON_CREATURE_V; break;
                            }
                            break;
                        case 6:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_MASS_CAT_GRACE; break;
                                case 2: iTempSpell = SPELL_GR_MASS_CHARM_MONSTER; break;
                                case 3: iTempSpell = SPELL_MASS_CURE_MODERATE_WOUNDS; break;
                                case 4: iTempSpell = SPELL_DIRGE; break;
                                case 5: iTempSpell = SPELL_MASS_EAGLE_SPLENDOR; break;
                                case 6: iTempSpell = SPELL_MASS_FOX_CUNNING; break;
                                case 7: iTempSpell = SPELL_GR_RAY_OF_LIGHT; break;
                                case 8: iTempSpell = SPELL_SUPERIOR_RESISTANCE; break;
                                case 9: iTempSpell = SPELL_GREATER_SHOUT; break;
                                case 10: iTempSpell = SPELL_GR_SUMMON_CREATURE_VI_NORMAL; break;
                                case 11: iTempSpell = SPELL_GR_SUMMON_CREATURE_V_D3; break;
                                case 12: iTempSpell = SPELL_GR_SUMMON_CREATURE_IV_D4P1_VI; break;
                                case 13: iTempSpell = SPELL_GR_SUMMON_CREATURE_III_D4P1_VI; break;
                                case 14: iTempSpell = SPELL_GR_SUMMON_CREATURE_II_D4P1_VI; break;
                                case 15: iTempSpell = SPELL_SUMMON_CREATURE_VI; break;
                            }
                            break;
                    }
                } else if(iSpellClass==CLASS_TYPE_SORCERER) {
                    switch(iLevel) {
                        case 0:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_ACID_SPLASH; break;
                                case 2: iTempSpell = SPELL_DAZE; break;
                                case 3: iTempSpell = SPELL_GR_DISRUPT_UNDEAD; break;
                                case 4: iTempSpell = SPELL_ELECTRIC_JOLT; break;
                                case 5: iTempSpell = SPELL_FLARE; break;
                                case 6: iTempSpell = SPELL_LIGHT; break;
                                case 7: iTempSpell = SPELL_RAY_OF_FROST; break;
                                case 8: iTempSpell = SPELL_GR_REP_MINOR_DAMAGE; break;
                                case 9: iTempSpell = SPELL_RESISTANCE; break;
                                case 10: iTempSpell = SPELL_GR_HORIZIKAULS_COUGH; break;
                            }
                            break;
                        case 1:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_GR_ACID_SPITTLE; break;
                                case 2: iTempSpell = SPELL_GR_ALARM; break;
                                case 3: iTempSpell = SPELL_GR_APPRAISING_TOUCH; break;
                                case 4: iTempSpell = SPELL_GR_ARCANE_BOLT; break;
                                case 5: iTempSpell = SPELL_GR_BABAU_SLIME; break;
                                case 6: iTempSpell = SPELL_GR_BENIGN_TRANSPOSITION; break;
                                case 7: iTempSpell = SPELL_GR_BLADES_OF_FIRE; break;
                                case 8: iTempSpell = SPELL_CAUSE_FEAR; break;
                                case 9: iTempSpell = SPELL_GR_CHAMELEON_SKIN; break;
                                case 10: iTempSpell = SPELL_CHARM_PERSON; break;
                                case 11: iTempSpell = SPELL_GR_CHILL_TOUCH; break;
                                case 12: iTempSpell = SPELL_COLOR_SPRAY; break;
                                case 13: iTempSpell = SPELL_GR_COMPREHEND_LANGUAGES; break;
                                case 14: iTempSpell = SPELL_GR_CORPSE_VISAGE; break;
                                case 15: iTempSpell = SPELL_ENLARGE_PERSON; break;
                                case 16: iTempSpell = SPELL_EXPEDITIOUS_RETREAT; break;
                                case 17: iTempSpell = SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT; break;
                                case 18: iTempSpell = SPELL_GR_EXTERMINATE; break;
                                case 19: iTempSpell = SPELL_GR_FLAME_BOLT; break;
                                case 20: iTempSpell = SPELL_GR_FLASH; break;
                                case 21: iTempSpell = SPELL_GREASE; break;
                                case 22: iTempSpell = SPELL_ICE_DAGGER; break;
                                case 23: iTempSpell = SPELL_IDENTIFY; break;
                                case 24: iTempSpell = SPELL_IRONGUTS; break;
                                case 25: iTempSpell = SPELL_GR_LARLOCHS_MINOR_DRAIN; break;
                                case 26: iTempSpell = SPELL_GR_CHROMATIC_ORB_WHITE; break;
                                case 27: iTempSpell = SPELL_GR_CHROMATIC_ORB_RED; break;
                                case 28: iTempSpell = SPELL_GR_CHROMATIC_ORB_YELLOW; break;
                                case 29: iTempSpell = SPELL_GR_CHROMATIC_ORB_ORANGE; break;
                                case 30: iTempSpell = SPELL_GR_CHROMATIC_ORB_GREEN; break;
                                case 31: iTempSpell = SPELL_GR_CHROMATIC_ORB_TURQUOISE; break;
                                case 32: iTempSpell = SPELL_GR_CHROMATIC_ORB_BLUE; break;
                                case 33: iTempSpell = SPELL_GR_CHROMATIC_ORB_VIOLET; break;
                                case 34: iTempSpell = SPELL_GR_CHROMATIC_ORB_BLACK; break;
                                case 35: iTempSpell = SPELL_MAGE_ARMOR; break;
                                case 36: iTempSpell = SPELL_MAGIC_MISSILE; break;
                                case 37: iTempSpell = SPELL_MAGIC_WEAPON; break;
                                case 38: iTempSpell = SPELL_NEGATIVE_ENERGY_RAY; break;
                                case 39: iTempSpell = SPELL_GR_LESSER_ACID_ORB; break;
                                case 40: iTempSpell = SPELL_GR_LESSER_COLD_ORB; break;
                                case 41: iTempSpell = SPELL_GR_LESSER_ELECTRIC_ORB; break;
                                case 42: iTempSpell = SPELL_GR_LESSER_FIRE_ORB; break;
                                case 43: iTempSpell = SPELL_GR_LESSER_SONIC_ORB; break;
                                case 44: iTempSpell = SPELL_PROTECTION_FROM_CHAOS; break;
                                case 45: iTempSpell = SPELL_PROTECTION_FROM_GOOD; break;
                                case 46: iTempSpell = SPELL_PROTECTION_FROM_EVIL; break;
                                case 47: iTempSpell = SPELL_PROTECTION_FROM_LAW; break;
                                case 48: iTempSpell = SPELL_GR_PROT_THIRST_HUNGER; break;
                                case 49: iTempSpell = SPELL_GR_RABBIT_FEET; break;
                                case 50: iTempSpell = SPELL_GR_RAY_OF_CLUMSINESS; break;
                                case 51: iTempSpell = SPELL_RAY_OF_ENFEEBLEMENT; break;
                                case 52: iTempSpell = SPELL_GR_RAY_OF_FLAME; break;
                                case 53: iTempSpell = SPELL_GR_NYBORS_GENTLE_REMINDER; break;
                                case 54: iTempSpell = SPELL_GR_REDUCE; break;
                                case 55: iTempSpell = SPELL_GR_REP_LIGHT_DAMAGE; break;
                                case 56: iTempSpell = SPELL_SHELGARNS_PERSISTENT_BLADE; break;
                                case 57: iTempSpell = SPELL_SHIELD; break;
                                case 58: iTempSpell = SPELL_SHOCKING_GRASP; break;
                                case 59: iTempSpell = SPELL_SLEEP; break;
                                case 60: iTempSpell = SPELL_HORIZIKAULS_BOOM; break;
                                case 61: iTempSpell = SPELL_GR_SPIRIT_WORM; break;
                                case 62: iTempSpell = SPELL_SUMMON_CREATURE_I; break;
                                case 63: iTempSpell = SPELL_TRUE_STRIKE; break;
                                case 64: iTempSpell = SPELL_GR_ENDURE_ELEMENTS_ACID; break;
                                case 65: iTempSpell = SPELL_GR_ENDURE_ELEMENTS_COLD; break;
                                case 66: iTempSpell = SPELL_GR_ENDURE_ELEMENTS_ELECTRICITY; break;
                                case 67: iTempSpell = SPELL_GR_ENDURE_ELEMENTS_FIRE; break;
                                case 68: iTempSpell = SPELL_GR_ENDURE_ELEMENTS_SONIC; break;
                                case 69: iTempSpell = SPELL_GR_LSE_DARKNESS; break;
                                case 70: iTempSpell = SPELL_GR_LSE_AGANAZZARS_SCORCHER; break;
                                case 71: iTempSpell = SPELL_GR_LSE_RAY_OF_ICE; break;
                                case 72: iTempSpell = SPELL_GR_LSE_RAY_OF_FLAME; break;
                                case 73: iTempSpell = SPELL_GR_LSE_RAY_OF_FROST; break;
                                case 74: iTempSpell = SPELL_GR_LSE_GANESTS_FARSTRIKE; break;
                                case 75: iTempSpell = SPELL_GR_LSE_GEDLEES_ELECTRIC_LOOP; break;
                                case 76: iTempSpell = SPELL_GR_LSE_SNILLOCS_SNOWBALL_SWARM; break;
                                case 77: iTempSpell = SPELL_GR_LSE_BURNING_HANDS; break;
                                case 78: iTempSpell = SPELL_GR_LSE_MAGIC_MISSILE; break;
                                case 79: iTempSpell = SPELL_GR_CHROMATIC_ORB_LVLS15; break;
                                case 80: iTempSpell = SPELL_GR_CHROMATIC_ORB_LVLS69; break;
                                case 81: iTempSpell = SPELL_ENDURE_ELEMENTS; break;
                                case 82: iTempSpell = SPELL_GR_LESSER_SHADOW_EVOCATION_I; break;
                                case 83: iTempSpell = SPELL_GR_LESSER_SHADOW_EVOCATION_II; break;
                            }
                            break;
                        case 2:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_GR_AGANAZZARS_SCORCHER; break;
                                case 2: iTempSpell = SPELL_GR_GREATER_ALARM; break;
                                case 3: iTempSpell = SPELL_GR_AUGMENT_FAMILIAR; break;
                                case 4: iTempSpell = SPELL_GR_BALEFUL_TRANSPOSITION; break;
                                case 5: iTempSpell = SPELL_GR_BATTLECRY; break;
                                case 6: iTempSpell = SPELL_BEARS_ENDURANCE; break;
                                case 7: iTempSpell = SPELL_BLINDNESS_AND_DEAFNESS; break;
                                case 8: iTempSpell = SPELL_GR_BLUR; break;
                                case 9: iTempSpell = SPELL_BULLS_STRENGTH; break;
                                case 10: iTempSpell = SPELL_CATS_GRACE; break;
                                case 11: iTempSpell = SPELL_CLOUD_OF_BEWILDERMENT; break;
                                case 12: iTempSpell = SPELL_COMBUST; break;
                                case 13: iTempSpell = SPELL_CONTINUAL_FLAME; break;
                                case 14: iTempSpell = SPELL_CURSE_OF_BLADES; break;
                                case 15: iTempSpell = SPELL_DARKNESS; break;
                                case 16: iTempSpell = SPELL_DARKVISION; break;
                                case 17: iTempSpell = SPELL_GR_DAZE_MONSTER; break;
                                case 18: iTempSpell = SPELL_DEATH_ARMOR; break;
                                case 19: iTempSpell = SPELL_LESSER_DISPEL; break;
                                case 20: iTempSpell = SPELL_GR_DOLOMAR_WAVE; break;
                                case 21: iTempSpell = SPELL_EAGLES_SPLENDOR; break;
                                case 22: iTempSpell = SPELL_FALSE_LIFE; break;
                                case 23: iTempSpell = SPELL_GR_FILTER; break;
                                case 24: iTempSpell = SPELL_FIREBURST; break;
                                case 25: iTempSpell = SPELL_GR_FOG_CLOUD; break;
                                case 26: iTempSpell = SPELL_FOXS_CUNNING; break;
                                case 27: iTempSpell = SPELL_GR_GANEST_FARSTRIKE; break;
                                case 28: iTempSpell = SPELL_GEDLEES_ELECTRIC_LOOP; break;
                                case 29: iTempSpell = SPELL_GHOSTLY_VISAGE; break;
                                case 30: iTempSpell = SPELL_GHOUL_TOUCH; break;
                                case 31: iTempSpell = SPELL_GR_GLITTERDUST; break;
                                case 32: iTempSpell = SPELL_GR_ICE_KNIFE; break;
                                case 33: iTempSpell = SPELL_GR_IGEDRAZAARS_MIASMA; break;
                                case 34: iTempSpell = SPELL_INVISIBILITY; break;
                                case 35: iTempSpell = SPELL_BALAGARNSIRONHORN; break;
                                case 36: iTempSpell = SPELL_KNOCK; break;
                                case 37: iTempSpell = SPELL_GR_LIFE_BOLT; break;
                                case 38: iTempSpell = SPELL_MELFS_ACID_ARROW; break;
                                case 39: iTempSpell = SPELL_OWLS_WISDOM; break;
                                case 40: iTempSpell = SPELL_GR_PROTECTION_CANTRIPS; break;
                                case 41: iTempSpell = SPELL_GR_PROTECTION_PARALYSIS; break;
                                case 42: iTempSpell = SPELL_GR_RAY_OF_ICE; break;
                                case 43: iTempSpell = SPELL_GR_RAY_OF_STUPIDITY; break;
                                case 44: iTempSpell = SPELL_GR_RAY_OF_WEAKNESS; break;
                                case 45: iTempSpell = SPELL_GR_REP_MODERATE_DAMAGE; break;
                                case 46: iTempSpell = SPELL_GR_RESIST_ENERGY_ACID; break;
                                case 47: iTempSpell = SPELL_GR_RESIST_ENERGY_COLD; break;
                                case 48: iTempSpell = SPELL_GR_RESIST_ENERGY_ELECTRICITY; break;
                                case 49: iTempSpell = SPELL_GR_RESIST_ENERGY_FIRE; break;
                                case 50: iTempSpell = SPELL_GR_RESIST_ENERGY_SONIC; break;
                                case 51: iTempSpell = SPELL_SCARE; break;
                                case 52: iTempSpell = SPELL_SEE_INVISIBILITY; break;
                                case 53: iTempSpell = SPELL_GR_LSC_GREASE; break;
                                case 54: iTempSpell = SPELL_GR_LSC_MAGE_ARMOR; break;
                                case 55: iTempSpell = SPELL_GR_LSC_ACID_SPLASH; break;
                                case 56: iTempSpell = SPELL_GR_LSC_LESSER_FIRE_ORB; break;
                                case 57: iTempSpell = SPELL_GR_LSC_BLADES_OF_FIRE; break;
                                case 58: iTempSpell = SPELL_GR_SNILLOC_SNOWBALL_SWARM; break;
                                case 59: iTempSpell = SPELL_STONE_BONES; break;
                                case 60: iTempSpell = SPELL_TASHAS_HIDEOUS_LAUGHTER; break;
                                case 61: iTempSpell = SPELL_WEB; break;
                                case 62: iTempSpell = SPELL_GR_SUMMON_CREATURE_II_NORMAL; break;
                                case 63: iTempSpell = SPELL_GR_SUMMON_CREATURE_I_D3; break;
                                case 64: iTempSpell = SPELL_GR_BLINDNESS; break;
                                case 65: iTempSpell = SPELL_GR_DEAFNESS; break;
                                case 66: iTempSpell = SPELL_RESIST_ENERGY; break;
                                case 67: iTempSpell = SPELL_SUMMON_CREATURE_II; break;
                            }
                            break;
                        case 3:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_GR_ARMOR_UNDEATH; break;
                                case 2: iTempSpell = SPELL_GR_BLACKLIGHT; break;
                                case 3: iTempSpell = SPELL_GR_BLOODSTORM; break;
                                case 4: iTempSpell = SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE; break;
                                case 5: iTempSpell = SPELL_GR_DARTAN_SBOLT; break;
                                case 6: iTempSpell = SPELL_GR_DAYLIGHT; break;
                                case 7: iTempSpell = SPELL_DEEP_SLUMBER; break;
                                case 8: iTempSpell = SPELL_DISPEL_MAGIC; break;
                                case 9: iTempSpell = SPELL_DISPLACEMENT; break;
                                case 10: iTempSpell = SPELL_GR_GREATER_DISRUPT_UNDEAD; break;
                                case 11: iTempSpell = SPELL_ENHANCE_FAMILIAR; break;
                                case 12: iTempSpell = SPELL_FIREBALL; break;
                                case 13: iTempSpell = SPELL_FLAME_ARROW; break;
                                case 14: iTempSpell = SPELL_GR_FORTIFY_FAMILIAR; break;
                                case 15: iTempSpell = SPELL_GREAT_THUNDERCLAP; break;
                                case 16: iTempSpell = SPELL_GREATER_MAGIC_WEAPON; break;
                                case 17: iTempSpell = SPELL_HASTE; break;
                                case 18: iTempSpell = SPELL_GR_HEALING_TOUCH; break;
                                case 19: iTempSpell = SPELL_HEROISM; break;
                                case 20: iTempSpell = SPELL_HOLD_PERSON; break;
                                case 21: iTempSpell = SPELL_GR_ICE_BURST; break;
                                case 22: iTempSpell = SPELL_INVISIBILITY_SPHERE; break;
                                case 23: iTempSpell = SPELL_GR_IRON_MIND; break;
                                case 24: iTempSpell = SPELL_KEEN_EDGE; break;
                                case 25: iTempSpell = SPELL_LIGHTNING_BOLT; break;
                                case 26: iTempSpell = SPELL_GR_GREATER_MAGE_ARMOR; break;
                                case 27: iTempSpell = SPELL_GR_MASS_MAGE_ARMOR; break;
                                case 28: iTempSpell = SPELL_MAGIC_CIRCLE_AGAINST_CHAOS; break;
                                case 29: iTempSpell = SPELL_MAGIC_CIRCLE_AGAINST_EVIL; break;
                                case 30: iTempSpell = SPELL_MAGIC_CIRCLE_AGAINST_GOOD; break;
                                case 31: iTempSpell = SPELL_MAGIC_CIRCLE_AGAINST_LAW; break;
                                case 32: iTempSpell = SPELL_GR_LESSER_MALISON; break;
                                case 33: iTempSpell = SPELL_MESTILS_ACID_BREATH; break;
                                case 34: iTempSpell = SPELL_NEGATIVE_ENERGY_BURST; break;
                                case 35: iTempSpell = SPELL_GR_PAIN_TOUCH; break;
                                case 36: iTempSpell = SPELL_GR_PROTECTION_FROM_ENERGY_ACID; break;
                                case 37: iTempSpell = SPELL_GR_PROTECTION_FROM_ENERGY_COLD; break;
                                case 38: iTempSpell = SPELL_GR_PROTECTION_FROM_ENERGY_ELECTRICITY; break;
                                case 39: iTempSpell = SPELL_GR_PROTECTION_FROM_ENERGY_FIRE; break;
                                case 40: iTempSpell = SPELL_GR_PROTECTION_FROM_ENERGY_SONIC; break;
                                case 41: iTempSpell = SPELL_GR_NYBORS_MILD_ADMONISHMENT; break;
                                case 42: iTempSpell = SPELL_GR_REP_SERIOUS_DAMAGE; break;
                                case 43: iTempSpell = SPELL_SCINTILLATING_SPHERE; break;
                                case 44: iTempSpell = SPELL_GR_LSE_DARKNESS; break;
                                case 45: iTempSpell = SPELL_GR_LSE_AGANAZZARS_SCORCHER; break;
                                case 46: iTempSpell = SPELL_GR_LSE_RAY_OF_ICE; break;
                                case 47: iTempSpell = SPELL_GR_LSE_RAY_OF_FLAME; break;
                                case 48: iTempSpell = SPELL_GR_LSE_RAY_OF_FROST; break;
                                case 49: iTempSpell = SPELL_GR_LSE_GANESTS_FARSTRIKE; break;
                                case 50: iTempSpell = SPELL_GR_LSE_GEDLEES_ELECTRIC_LOOP; break;
                                case 51: iTempSpell = SPELL_GR_LSE_SNILLOCS_SNOWBALL_SWARM; break;
                                case 52: iTempSpell = SPELL_GR_LSE_BURNING_HANDS; break;
                                case 53: iTempSpell = SPELL_GR_LSE_MAGIC_MISSILE; break;
                                case 54: iTempSpell = SPELL_SLOW; break;
                                case 55: iTempSpell = SPELL_GR_SONIC_BLAST; break;
                                case 56: iTempSpell = SPELL_GR_SPIDER_POISON; break;
                                case 57: iTempSpell = SPELL_STINKING_CLOUD; break;
                                case 58: iTempSpell = SPELL_GR_SUMMON_CREATURE_III_NORMAL; break;
                                case 59: iTempSpell = SPELL_GR_SUMMON_CREATURE_II_D3; break;
                                case 60: iTempSpell = SPELL_GR_SUMMON_CREATURE_I_D4P1_III; break;
                                case 61: iTempSpell = SPELL_VAMPIRIC_TOUCH; break;
                                case 62: iTempSpell = SPELL_GR_WATER_BREATHING; break;
                                case 63: iTempSpell = SPELL_PROTECTION_FROM_ENERGY; break;
                                case 64: iTempSpell = SPELL_GR_LESSER_SHADOW_EVOCATION_I; break;
                                case 65: iTempSpell = SPELL_GR_LESSER_SHADOW_EVOCATION_II; break;
                                case 66: iTempSpell = SPELL_SUMMON_CREATURE_III; break;
                            }
                            break;
                        case 4:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_ANIMATE_DEAD; break;
                                case 2: iTempSpell = SPELL_BESTOW_CURSE; break;
                                case 3: iTempSpell = SPELL_GR_BLAST_OF_FLAME; break;
                                case 4: iTempSpell = SPELL_CHARM_MONSTER; break;
                                case 5: iTempSpell = SPELL_GR_COMP_STRIFE; break;
                                case 6: iTempSpell = SPELL_CONFUSION; break;
                                case 7: iTempSpell = SPELL_CONTAGION; break;
                                case 8: iTempSpell = SPELL_CRUSHING_DESPAIR; break;
                                case 9: iTempSpell = SPELL_GR_MASS_DARKVISION; break;
                                case 10: iTempSpell = SPELL_GR_DIMENSION_DOOR; break;
                                case 11: iTempSpell = SPELL_GR_DIMENSIONAL_ANCHOR; break;
                                case 12: iTempSpell = SPELL_ENERVATION; break;
                                case 13: iTempSpell = SPELL_GR_MASS_ENLARGE; break;
                                case 14: iTempSpell = SPELL_EVARDS_BLACK_TENTACLES; break;
                                case 15: iTempSpell = SPELL_FEAR; break;
                                case 16: iTempSpell = SPELL_GR_FIRE_AURA; break;
                                case 17: iTempSpell = SPELL_GR_FIRE_SHIELD_HOT; break;
                                case 18: iTempSpell = SPELL_GR_FIRE_SHIELD_COLD; break;
                                case 19: iTempSpell = SPELL_ELEMENTAL_SHIELD; break;
                                case 20: iTempSpell = SPELL_GR_FORCEWARD; break;
                                case 21: iTempSpell = SPELL_LESSER_GLOBE_OF_INVULNERABILITY; break;
                                case 22: iTempSpell = SPELL_GR_GREATER_MALISON; break;
                                case 23: iTempSpell = SPELL_ICE_STORM; break;
                                case 24: iTempSpell = SPELL_GREATER_INVISIBILITY; break;
                                case 25: iTempSpell = SPELL_GR_IRON_BONES; break;
                                case 26: iTempSpell = SPELL_ISAACS_LESSER_MISSILE_STORM; break;
                                case 27: iTempSpell = SPELL_GR_MORDENKAINENS_FORCE_MISSILES; break;
                                case 28: iTempSpell = SPELL_GR_NEG_ENERGY_WAVE; break;
                                case 29: iTempSpell = SPELL_GR_ACID_ORB; break;
                                case 30: iTempSpell = SPELL_GR_COLD_ORB; break;
                                case 31: iTempSpell = SPELL_GR_ELECTRIC_ORB; break;
                                case 32: iTempSpell = SPELL_GR_FIRE_ORB; break;
                                case 33: iTempSpell = SPELL_GR_SONIC_ORB; break;
                                case 34: iTempSpell = SPELL_PHANTASMAL_KILLER; break;
                                case 35: iTempSpell = SPELL_POLYMORPH_SELF; break;
                                case 36: iTempSpell = SPELL_GR_PURIFY_FLAMES; break;
                                case 37: iTempSpell = SPELL_GR_RAY_OF_DEANIMATION; break;
                                case 38: iTempSpell = SPELL_GR_MASS_REDUCE; break;
                                case 39: iTempSpell = SPELL_REMOVE_CURSE; break;
                                case 40: iTempSpell = SPELL_GR_REP_CRITICAL_DAMAGE; break;
                                case 41: iTempSpell = SPELL_GR_MASS_RESIST_ELEMENTS; break;
                                case 42: iTempSpell = SPELL_GR_MASS_RESIST_ELEMENTS_ACID; break;
                                case 43: iTempSpell = SPELL_GR_MASS_RESIST_ELEMENTS_COLD; break;
                                case 44: iTempSpell = SPELL_GR_MASS_RESIST_ELEMENTS_ELECTRICITY; break;
                                case 45: iTempSpell = SPELL_GR_MASS_RESIST_ELEMENTS_FIRE; break;
                                case 46: iTempSpell = SPELL_GR_MASS_RESIST_ELEMENTS_SONIC; break;
                                case 47: iTempSpell = SPELL_GREATER_RESISTANCE; break;
                                case 48: iTempSpell = 159; break; // SHADOW_CONJURATION
                                case 49: iTempSpell = SPELL_GR_SHADOW_CON_MESTILS_ACID_BREATH; break;
                                case 50: iTempSpell = SPELL_GR_SHADOW_CON_STINKING_CLOUD; break;
                                case 51: iTempSpell = SPELL_GR_SHADOW_CON_MELFS_ACID_ARROW; break;
                                case 52: iTempSpell = SPELL_GR_SHADOW_CON_MAGE_ARMOR; break;
                                case 53: iTempSpell = SPELL_GR_SHADOW_CON_WEB; break;
                                case 54: iTempSpell = SPELL_SHOUT; break;
                                case 55: iTempSpell = SPELL_LESSER_SPELL_BREACH; break;
                                case 56: iTempSpell = SPELL_LESSER_SPELL_MANTLE; break;
                                case 57: iTempSpell = SPELL_STONESKIN; break;
                                case 58: iTempSpell = SPELL_SUMMON_CREATURE_IV; break;
                                case 59: iTempSpell = SPELL_GR_SUMMON_CREATURE_IV_NORMAL; break;
                                case 60: iTempSpell = SPELL_GR_SUMMON_CREATURE_III_D3; break;
                                case 61: iTempSpell = SPELL_GR_SUMMON_CREATURE_II_D4P1_IV; break;
                                case 62: iTempSpell = SPELL_GR_SUMMON_CREATURE_I_D4P1_IV; break;
                                case 63: iTempSpell = SPELL_GR_THUNDER_STAFF; break;
                                case 64: iTempSpell = SPELL_WALL_OF_FIRE; break;
                                case 65: iTempSpell = SPELL_GR_WALL_OF_ICE; break;
                            }
                            break;
                        case 5:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_GR_ANIMAL_GROWTH; break;
                                case 2: iTempSpell = SPELL_BALL_LIGHTNING; break;
                                case 3: iTempSpell = SPELL_BIGBYS_INTERPOSING_HAND; break;
                                case 4: iTempSpell = SPELL_GR_MASS_CHARM_PERSON; break;
                                case 5: iTempSpell = SPELL_CLARITY; break;
                                case 6: iTempSpell = SPELL_CLOUDKILL; break;
                                case 7: iTempSpell = SPELL_CONE_OF_COLD; break;
                                case 8: iTempSpell = SPELL_DISMISSAL; break;
                                case 9: iTempSpell = SPELL_DOMINATE_PERSON; break;
                                case 10: iTempSpell = SPELL_ENERGY_BUFFER; break;
                                case 11: iTempSpell = SPELL_GR_GREATER_ENLARGE; break;
                                case 12: iTempSpell = SPELL_FEEBLEMIND; break;
                                case 13: iTempSpell = SPELL_GR_MASS_FIRE_SHIELD; break;
                                case 14: iTempSpell = SPELL_GR_MASS_FIRE_SHIELD_HOT; break;
                                case 15: iTempSpell = SPELL_GR_MASS_FIRE_SHIELD_COLD; break;
                                case 16: iTempSpell = SPELL_FIREBRAND; break;
                                case 17: iTempSpell = SPELL_GREATER_FIREBURST; break;
                                case 18: iTempSpell = SPELL_HOLD_MONSTER; break;
                                case 19: iTempSpell = SPELL_MESTILS_ACID_SHEATH; break;
                                case 20: iTempSpell = SPELL_MIND_FOG; break;
                                case 21: iTempSpell = SPELL_LESSER_PLANAR_BINDING; break;
                                case 22: iTempSpell = SPELL_GR_GREATER_REDUCE; break;
                                case 23: iTempSpell = SPELL_GR_SHADOW_EVOCATION_I; break;
                                case 24: iTempSpell = SPELL_GR_SHADOW_EVOCATION_II; break;
                                case 25: iTempSpell = SPELL_GR_SHAD_EVOC1_ICE_STORM; break;
                                case 26: iTempSpell = SPELL_GR_SHAD_EVOC1_MORD_FORCE_MISSILES; break;
                                case 27: iTempSpell = SPELL_GR_SHAD_EVOC1_WALL_OF_FIRE; break;
                                case 28: iTempSpell = SPELL_GR_SHAD_EVOC1_FIREBALL; break;
                                case 29: iTempSpell = SPELL_GR_SHAD_EVOC1_FIREBURST; break;
                                case 30: iTempSpell = SPELL_GR_SHAD_EVOC2_ISAACS_LSR_MISSILES; break;
                                case 31: iTempSpell = SPELL_GR_SHAD_EVOC2_SHOUT; break;
                                case 32: iTempSpell = SPELL_GR_SHAD_EVOC2_WALL_OF_ICE; break;
                                case 33: iTempSpell = SPELL_GR_SHAD_EVOC2_ICE_BURST; break;
                                case 34: iTempSpell = SPELL_GR_SHAD_EVOC2_LIGHTNING_BOLT; break;
                                case 35: iTempSpell = SPELL_LESSER_SPELL_MANTLE; break;
                                case 36: iTempSpell = SPELL_SUMMON_CREATURE_V; break;
                                case 37: iTempSpell = SPELL_GR_SUMMON_CREATURE_V_NORMAL; break;
                                case 38: iTempSpell = SPELL_GR_SUMMON_CREATURE_IV_D3; break;
                                case 39: iTempSpell = SPELL_GR_SUMMON_CREATURE_III_D4P1_V; break;
                                case 40: iTempSpell = SPELL_GR_SUMMON_CREATURE_II_D4P1_V; break;
                                case 41: iTempSpell = SPELL_GR_SUMMON_CREATURE_I_D4P1_V; break;
                                case 42: iTempSpell = SPELL_GR_WALL_OF_IRON; break;
                                case 43: iTempSpell = SPELL_GR_WALL_OF_STONE; break;
                            }
                            break;
                        case 6:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_ACID_FOG; break;
                                case 2: iTempSpell = SPELL_GR_ACID_STORM; break;
                                case 3: iTempSpell = SPELL_MASS_BEAR_ENDURANCE; break;
                                case 4: iTempSpell = SPELL_BIGBYS_FORCEFUL_HAND; break;
                                case 5: iTempSpell = SPELL_MASS_BULL_STRENGTH; break;
                                case 6: iTempSpell = SPELL_MASS_CAT_GRACE; break;
                                case 7: iTempSpell = SPELL_CHAIN_LIGHTNING; break;
                                case 8: iTempSpell = SPELL_CIRCLE_OF_DEATH; break;
                                case 9: iTempSpell = SPELL_MASS_CONTAGION; break;
                                case 10: iTempSpell = SPELL_CREATE_UNDEAD; break;
                                case 11: iTempSpell = SPELL_DISINTEGRATE; break;
                                case 12: iTempSpell = SPELL_GREATER_DISPELLING; break;
                                case 13: iTempSpell = SPELL_MASS_EAGLE_SPLENDOR; break;
                                case 14: iTempSpell = SPELL_ETHEREAL_VISAGE; break;
                                case 15: iTempSpell = SPELL_FLESH_TO_STONE; break;
                                case 16: iTempSpell = SPELL_MASS_FOX_CUNNING; break;
                                case 17: iTempSpell = SPELL_GLOBE_OF_INVULNERABILITY; break;
                                case 18: iTempSpell = SPELL_GREATER_HEROISM; break;
                                case 19: iTempSpell = SPELL_ISAACS_GREATER_MISSILE_STORM; break;
                                case 20: iTempSpell = SPELL_LEGEND_LORE; break;
                                case 21: iTempSpell = SPELL_MASS_OWL_WISDOM; break;
                                case 22: iTempSpell = SPELL_PLANAR_BINDING; break;
                                case 23: iTempSpell = SPELL_GR_POWER_WORD_THUNDER; break;
                                case 24: iTempSpell = SPELL_GR_RAY_OF_ENTROPY; break;
                                case 25: iTempSpell = SPELL_GR_RAY_OF_LIGHT; break;
                                case 26: iTempSpell = SPELL_SUPERIOR_RESISTANCE; break;
                                case 27: iTempSpell = 158; break; // SHADES
                                case 28: iTempSpell = SPELL_GR_SHADES_INCENDIARY_CLOUD; break;
                                case 29: iTempSpell = SPELL_GR_SHADES_MORDS_MANSION; break;
                                case 30: iTempSpell = SPELL_GR_SHADES_ACID_FOG; break;
                                case 31: iTempSpell = SPELL_GR_SHADES_CLOUDKILL; break;
                                case 32: iTempSpell = SPELL_GR_SHADES_EVARDS_TENTACLES; break;
                                case 33: iTempSpell = SPELL_GREATER_SPELL_BREACH; break;
                                case 34: iTempSpell = SPELL_STONE_TO_FLESH; break;
                                case 35: iTempSpell = SPELL_GREATER_STONESKIN; break;
                                case 36: iTempSpell = SPELL_SUMMON_CREATURE_VI; break;
                                case 37: iTempSpell = SPELL_GR_SUMMON_CREATURE_VI_NORMAL; break;
                                case 38: iTempSpell = SPELL_GR_SUMMON_CREATURE_V_D3; break;
                                case 39: iTempSpell = SPELL_GR_SUMMON_CREATURE_IV_D4P1_VI; break;
                                case 40: iTempSpell = SPELL_GR_SUMMON_CREATURE_III_D4P1_VI; break;
                                case 41: iTempSpell = SPELL_GR_SUMMON_CREATURE_II_D4P1_VI; break;
                                case 42: iTempSpell = SPELL_GR_TALOS_WRATH; break;
                                case 43: iTempSpell = SPELL_TENSERS_TRANSFORMATION; break;
                                case 44: iTempSpell = SPELL_TRUE_SEEING; break;
                                case 45: iTempSpell = SPELL_UNDEATH_TO_DEATH; break;
                            }
                            break;
                        case 7:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_BANISHMENT; break;
                                case 2: iTempSpell = SPELL_BIGBYS_GRASPING_HAND; break;
                                case 3: iTempSpell = SPELL_CONTROL_UNDEAD; break;
                                case 4: iTempSpell = SPELL_DELAYED_BLAST_FIREBALL; break;
                                case 5: iTempSpell = SPELL_GR_DELAYED_BLAST_FIREBALL1; break;
                                case 6: iTempSpell = SPELL_GR_DELAYED_BLAST_FIREBALL2; break;
                                case 7: iTempSpell = SPELL_GR_DELAYED_BLAST_FIREBALL3; break;
                                case 8: iTempSpell = SPELL_GR_DELAYED_BLAST_FIREBALL4; break;
                                case 9: iTempSpell = SPELL_GR_DELAYED_BLAST_FIREBALL5; break;
                                case 10: iTempSpell = SPELL_ENERGY_IMMUNITY; break;
                                case 11: iTempSpell = SPELL_ENERGY_IMMUNITY_ACID; break;
                                case 12: iTempSpell = SPELL_ENERGY_IMMUNITY_COLD; break;
                                case 13: iTempSpell = SPELL_ENERGY_IMMUNITY_ELECTRICITY; break;
                                case 14: iTempSpell = SPELL_ENERGY_IMMUNITY_FIRE; break;
                                case 15: iTempSpell = SPELL_ENERGY_IMMUNITY_SONIC; break;
                                case 16: iTempSpell = SPELL_FINGER_OF_DEATH; break;
                                case 17: iTempSpell = SPELL_GR_FREEZING_CURSE; break;
                                case 18: iTempSpell = SPELL_MASS_HOLD_PERSON; break;
                                case 19: iTempSpell = SPELL_GR_INSANITY; break;
                                case 20: iTempSpell = SPELL_GR_MORDENKAINENS_MAGNIFICENT_MANSION; break;
                                case 21: iTempSpell = SPELL_MORDENKAINENS_SWORD; break;
                                case 22: iTempSpell = SPELL_POWORD_BLIND; break;
                                case 23: iTempSpell = SPELL_PRISMATIC_SPRAY; break;
                                case 24: iTempSpell = SPELL_GR_NYBORS_STERN_REPROOF; break;
                                case 25: iTempSpell = 71; break; // GREATER SHADOW CONJURATION
                                case 26: iTempSpell = SPELL_GR_GSC_ACID_FOG; break;
                                case 27: iTempSpell = SPELL_GR_GSC_CLOUDKILL; break; // SHADES
                                case 28: iTempSpell = SPELL_GR_GSC_MESTILS_ACID_SHEATH; break;
                                case 29: iTempSpell = SPELL_GR_GSC_EVARDS_TENTACLES; break;
                                case 30: iTempSpell = SPELL_GR_GSC_MESTILS_ACID_BREATH; break;
                                case 31: iTempSpell = SPELL_SHADOW_SHIELD; break;
                                case 32: iTempSpell = SPELL_GR_SIMBULS_SYNOSTODWEOMER; break;
                                case 33: iTempSpell = SPELL_SPELL_MANTLE; break;
                                case 34: iTempSpell = SPELL_SPELL_TURNING; break;
                                case 35: iTempSpell = SPELL_SUMMON_CREATURE_VII; break;
                                case 36: iTempSpell = SPELL_GR_SUMMON_CREATURE_VII_NORMAL; break;
                                case 37: iTempSpell = SPELL_GR_SUMMON_CREATURE_VI_D3; break;
                                case 38: iTempSpell = SPELL_GR_SUMMON_CREATURE_V_D4P1_VII; break;
                                case 39: iTempSpell = SPELL_GR_SUMMON_CREATURE_IV_D4P1_VII; break;
                                case 40: iTempSpell = SPELL_GR_SUMMON_CREATURE_III_D4P1_VII; break;
                                case 41: iTempSpell = SPELL_HISS_OF_SLEEP; break;
                            }
                            break;
                        case 8:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_GR_GREATER_BESTOW_CURSE; break;
                                case 2: iTempSpell = SPELL_BIGBYS_CLENCHED_FIST; break;
                                case 3: iTempSpell = SPELL_GR_BLACKFLAME; break;
                                case 4: iTempSpell = SPELL_BLACKSTAFF; break;
                                case 5: iTempSpell = SPELL_MASS_BLINDNESS_AND_DEAFNESS; break;
                                case 6: iTempSpell = SPELL_GR_MASS_BLINDNESS; break;
                                case 7: iTempSpell = SPELL_GR_MASS_DEAFNESS; break;
                                case 8: iTempSpell = SPELL_MASS_CHARM; break;
                                case 9: iTempSpell = SPELL_CREATE_GREATER_UNDEAD; break;
                                case 10: iTempSpell = SPELL_GR_FLENSING; break;
                                case 11: iTempSpell = SPELL_HORRID_WILTING; break;
                                case 12: iTempSpell = SPELL_INCENDIARY_CLOUD; break;
                                case 13: iTempSpell = SPELL_IRON_BODY; break;
                                case 14: iTempSpell = SPELL_GR_LEECH_FIELD; break;
                                case 15: iTempSpell = SPELL_MIND_BLANK; break;
                                case 16: iTempSpell = SPELL_GR_NYBORS_WRATHFUL_CASTIGATION; break;
                                case 17: iTempSpell = SPELL_GREATER_PLANAR_BINDING; break;
                                case 18: iTempSpell = SPELL_POLAR_RAY; break;
                                case 19: iTempSpell = SPELL_GR_GREATER_SHADOW_EVOCATION_I; break;
                                case 20: iTempSpell = SPELL_GR_GREATER_SHADOW_EVOCATION_II; break;
                                case 21: iTempSpell = SPELL_GR_GSE1_MORDENKAINENS_SWORD; break;
                                case 22: iTempSpell = SPELL_GR_GSE1_ACID_STORM; break;
                                case 23: iTempSpell = SPELL_GR_GSE1_CONE_OF_COLD; break;
                                case 24: iTempSpell = SPELL_GR_GSE1_FIREBRAND; break;
                                case 25: iTempSpell = SPELL_GR_GSE1_ICE_STORM; break; // GREATER SHADOW CONJURATION
                                case 26: iTempSpell = SPELL_GR_GSE2_PRISMATIC_SPRAY; break;
                                case 27: iTempSpell = SPELL_GR_GSE2_CHAIN_LIGHTNING; break; // SHADES
                                case 28: iTempSpell = SPELL_GR_GSE2_BALL_LIGHTNING; break;
                                case 29: iTempSpell = SPELL_GR_GSE2_GREATER_FIREBURST; break;
                                case 30: iTempSpell = SPELL_GR_GSE2_MORDENKAINENS_FORCE_MISSILES; break;
                                case 31: iTempSpell = SPELL_GR_SHADOW_STORM; break;
                                case 32: iTempSpell = SPELL_SUMMON_CREATURE_VIII; break;
                                case 33: iTempSpell = SPELL_GR_SUMMON_CREATURE_VII_D3; break;
                                case 34: iTempSpell = SPELL_GR_SUMMON_CREATURE_VI_D4P1_VIII; break;
                                case 35: iTempSpell = SPELL_GR_SUMMON_CREATURE_V_D4P1_VIII; break;
                                case 36: iTempSpell = SPELL_GR_SUMMON_CREATURE_IV_D4P1_VIII; break;
                                case 37: iTempSpell = SPELL_SUNBURST; break;
                                case 38: iTempSpell = SPELL_GREATER_WALL_DISPEL_MAGIC; break;
                            }
                            break;
                        case 9:
                            switch(iRandom) {
                                case 1: iTempSpell = SPELL_BIGBYS_CRUSHING_HAND; break;
                                case 2: iTempSpell = SPELL_BLACK_BLADE_OF_DISASTER; break;
                                case 3: iTempSpell = SPELL_DOMINATE_MONSTER; break;
                                case 4: iTempSpell = SPELL_ENERGY_DRAIN; break;
                                case 5: iTempSpell = SPELL_ETHEREALNESS; break;
                                case 6: iTempSpell = SPELL_PREMONITION; break;
                                case 7: iTempSpell = SPELL_GATE; break;
                                case 8: iTempSpell = SPELL_MASS_HOLD_MONSTER; break;
                                case 9: iTempSpell = SPELL_METEOR_SWARM; break;
                                case 10: iTempSpell = SPELL_MORDENKAINENS_DISJUNCTION; break;
                                case 11: iTempSpell = SPELL_POWER_WORD_KILL; break;
                                case 12: iTempSpell = SPELL_SHAPECHANGE; break;
                                case 13: iTempSpell = SPELL_GREATER_SPELL_MANTLE; break;
                                case 14: iTempSpell = SPELL_SUMMON_CREATURE_IX; break;
                                case 15: iTempSpell = SPELL_GR_SUMMON_CREATURE_IX_NORMAL; break;
                                case 16: iTempSpell = SPELL_GR_SUMMON_CREATURE_VIII_D3; break;
                                case 17: iTempSpell = SPELL_GR_SUMMON_CREATURE_VII_D4P1_IX; break;
                                case 18: iTempSpell = SPELL_GR_SUMMON_CREATURE_VI_D4P1_IX; break;
                                case 19: iTempSpell = SPELL_GR_SUMMON_CREATURE_V_D4P1_IX; break;
                                case 20: iTempSpell = SPELL_TIME_STOP; break;
                                case 21: iTempSpell = SPELL_WAIL_OF_THE_BANSHEE; break;
                                case 22: iTempSpell = SPELL_WEIRD; break;
                            }
                            break;
                    }
                }
            }
            if(GetHasSpell(iTempSpell, oTarget)) {
                iSpellToRemove = iTempSpell;
            } else {
                iNumSpellsChecked++;
                SetLocalInt(oTarget, "SPELL_L"+IntToString(iLevel)+"_S"+IntToString(iRandom), TRUE);
                DelayCommand((Random(3300)+300)*1.0, DeleteLocalInt(oTarget, "SPELL_L"+IntToString(iLevel)+"_S"+IntToString(iRandom)));
            }
        } while(iSpellToRemove==-1 && iNumSpellsChecked<=iNumSpellsToCheck);
        DecrementRemainingSpellUses(oTarget, iSpellToRemove);
        iNumSpellsToRemove--;
    }
}
