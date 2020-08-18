//*:**************************************************************************
//*:*  SPELL_TEMPLATE.NSS
//*:**************************************************************************
//*:*
//*:* Blank template for spell scripts
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**************************************************************************
//*:* Updated On: December 10, 2007
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

    float   fDifficulty     = 0.0;
    int     bIsPC           = GetIsPC(spInfo.oTarget);
    int     bShowPopup      = FALSE;
    int     iGameDifficulty = GetGameDifficulty();
    float   fRadius         = 11.0;
    float   fDelay;
    int     iPower          = GetHitDice(oCaster);
    int     bMultiTarget    = TRUE;

    switch(spInfo.iSpellID) {
        case 495:  // Breath Petrify
            spInfo.iDC = 17;
            break;
        case 496:  // Gaze Petrify
            spInfo.iDC = 13;
            fRadius = 10.0;
            break;
        case 497:  // Touch Petrify
            spInfo.iDC = 15;
            iPower = GetHitDice(spInfo.oTarget);
            bMultiTarget = FALSE;
            break;
    }

    switch(iGameDifficulty) {
        case GAME_DIFFICULTY_VERY_EASY:
        case GAME_DIFFICULTY_EASY:
        case GAME_DIFFICULTY_NORMAL:
                fDifficulty = GRGetDuration(iPower); // One Round per hit-die or caster level
            break;
        case GAME_DIFFICULTY_CORE_RULES:
        case GAME_DIFFICULTY_DIFFICULT:
            bShowPopup = TRUE;
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
    effect ePetrify = EffectPetrify();
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink    = EffectLinkEffects(eDur, ePetrify);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {    // ie not the touch ability
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, fRadius, spInfo.lTarget, TRUE);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF, NO_CASTER)) {
                //*:* skip if creature is immune to petrification
                if(!spellsIsImmuneToPetrification(spInfo.oTarget)) {

                    SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, spInfo.iSpellID));
                    fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
                    if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC)) {
                        if(bIsPC == TRUE) {
                            if(bShowPopup == TRUE) {
                                    //*:* under hardcore rules or higher, this is an instant death
                                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget));
                                    DelayCommand(fDelay+2.75, PopUpDeathGUIPanel(spInfo.oTarget, FALSE , TRUE, 40579));
                                    //*:* if in hardcore, treat the player as an NPC
                                    bIsPC = FALSE;
                                    //fDifficulty = SGGetDuration(nPower, DUR_TYPE_TURNS); // One turn per hit-die
                            } else
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDifficulty));
                        } else {
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget));

                            //----------------------------------------------------------
                            // GZ: Fix for henchmen statues haunting you when changing
                            //     areas. Henchmen are now kicked from the party if
                            //     petrified.
                            //----------------------------------------------------------
                            if(GetAssociateType(spInfo.oTarget) == ASSOCIATE_TYPE_HENCHMAN) {
                                FireHenchman(GetMaster(spInfo.oTarget), spInfo.oTarget);
                            }

                        }
                        // April 2003: Clearing actions to kick them out of conversation when petrified
                        AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
                    }
                }
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, fRadius, spInfo.lTarget, TRUE);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
