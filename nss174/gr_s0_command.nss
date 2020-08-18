//*:**************************************************************************
//*:*  GR_S0_COMMAND.NSS
//*:**************************************************************************
//*:* Command
//*:* Command, Greater
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 13, 2008
//*:* 3.5 Player's Handbook (p.  211)
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
void CheckCommandable(int iSpellID, object oTarget, object oCaster=OBJECT_SELF) {

    int iMasterSpellID = (iSpellID<SPELL_GR_COMMAND_GREATER ? SPELL_GR_COMMAND : SPELL_GR_COMMAND_GREATER);

    if(!GRGetHasSpellEffect(iMasterSpellID, oTarget, oCaster) || !GetIsObjectValid(oCaster)) {
        if(!GetCommandable(oTarget)) {
            SetCommandable(TRUE, oTarget);
        }
    }
}

void DoWillSaveCheck(int iSpellID, int iDC, object oTarget, float fDelay, int bRemoveCommand, object oCaster=OBJECT_SELF) {
    //*:* for Greater Command, target gets will save each round

    struct SpellStruct spInfo = GRGetSpellInfoFromObject(iSpellID, oTarget);
    int iMasterSpellID = (iSpellID<SPELL_GR_COMMAND_GREATER ? SPELL_GR_COMMAND : SPELL_GR_COMMAND_GREATER);
    //*:* Check if dispelled
    if(!GRGetHasSpellEffect(iMasterSpellID, oTarget, oCaster) && bRemoveCommand) {
        if(!GetCommandable(oTarget)) {
            SetCommandable(TRUE, oTarget);
        }
    } else {
        if(GRGetSaveResult(SAVING_THROW_WILL, oTarget, iDC, SAVING_THROW_TYPE_MIND_SPELLS)) {
            GRRemoveSpellEffects(iMasterSpellID, oTarget, oCaster);
            if(bRemoveCommand) {
                SetCommandable(TRUE, oTarget);
            }
        } else {
            if((bRemoveCommand && GetCommandable(oTarget)) || spInfo.iSpellID==SPELL_GR_COMMAND_DROP ||
                spInfo.iSpellID==SPELL_GR_COMMAND_GREATER_DROP) {

                //*:* lost our uncommandable state - probably due to stacking - reapply "effect"
                //*:* OR we have a drop command - double-check that the hands are empty
                AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
                switch(spInfo.iSpellID) {
                    case SPELL_GR_COMMAND_GREATER_APPROACH:
                        DelayCommand(0.1, AssignCommand(spInfo.oTarget, ActionMoveToObject(oCaster, TRUE, FeetToMeters(5.0))));
                        DelayCommand(0.1, SetCommandable(FALSE, spInfo.oTarget));
                        break;
                    case SPELL_GR_COMMAND_GREATER_DROP:
                        if(!GetCommandable(spInfo.oTarget)) {
                            SetCommandable(TRUE, spInfo.oTarget);
                        }
                        object oItemRight = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spInfo.oTarget);
                        object oItemLeft = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spInfo.oTarget);

                        if(oItemRight!=OBJECT_INVALID) {
                            DelayCommand(0.1, AssignCommand(spInfo.oTarget, ActionPutDownItem(oItemRight)));
                        }
                        if(oItemLeft!=OBJECT_INVALID) {
                            DelayCommand(0.1, AssignCommand(spInfo.oTarget, ActionPutDownItem(oItemLeft)));
                        }
                        if(spInfo.iSpellID==SPELL_GR_COMMAND_GREATER_DROP) {
                            DelayCommand(0.2, SetCommandable(FALSE, spInfo.oTarget));
                        }
                        break;
                    case SPELL_GR_COMMAND_GREATER_FLEE:
                    case SPELL_GR_COMMAND_GREATER:
                        DelayCommand(fDelay+0.1, AssignCommand(spInfo.oTarget, ActionMoveAwayFromObject(oCaster, TRUE, FeetToMeters(400.0))));
                        DelayCommand(fDelay+0.1, SetCommandable(FALSE, spInfo.oTarget));
                        break;
                }
            }
            DelayCommand(GRGetDuration(1), DoWillSaveCheck(iSpellID, iDC, oTarget, fDelay, bRemoveCommand));
        }
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
    int     iDurAmount        = (spInfo.iSpellID>=SPELL_GR_COMMAND && spInfo.iSpellID<SPELL_GR_COMMAND_GREATER ? 1 : spInfo.iCasterLevel);
    int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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
    float   fRange          = FeetToMeters(15.0);

    int     bMultiTarget    = (spInfo.iSpellID>=SPELL_GR_COMMAND_GREATER);
    int     iNumTargets     = spInfo.iCasterLevel;
    int     bRemoveCommand  = FALSE;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eVis     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eEffect;

    switch(spInfo.iSpellID) {
        case SPELL_GR_COMMAND_FALL:
        case SPELL_GR_COMMAND_GREATER_FALL:
            eEffect = EffectKnockdown();
            break;
        case SPELL_GR_COMMAND_HALT:
        case SPELL_GR_COMMAND_GREATER_HALT:
            eEffect = EffectDazed();
            break;
        default:
            bRemoveCommand = TRUE;
            break;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if((!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) && GRGetIsLiving(spInfo.oTarget)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, (spInfo.iSpellID<SPELL_GR_COMMAND_GREATER ? SPELL_GR_COMMAND : SPELL_GR_COMMAND_GREATER)));
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20.0;
                    if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, oCaster, fDelay)) {
                        if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_MIND_SPELLS, oCaster)) {
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, fDuration));
                            if(!bRemoveCommand) {
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, spInfo.oTarget, fDuration));
                            } else {
                                DelayCommand(fDelay, AssignCommand(spInfo.oTarget, ClearAllActions(TRUE)));
                                switch(spInfo.iSpellID) {
                                    case SPELL_GR_COMMAND_APPROACH:
                                    case SPELL_GR_COMMAND_GREATER_APPROACH:
                                        DelayCommand(fDelay+0.1, AssignCommand(spInfo.oTarget, ActionMoveToObject(oCaster, TRUE, FeetToMeters(5.0))));
                                        DelayCommand(fDelay+0.1, SetCommandable(FALSE, spInfo.oTarget));
                                        break;
                                    case SPELL_GR_COMMAND_DROP:
                                    case SPELL_GR_COMMAND_GREATER_DROP:
                                        object oItemRight = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spInfo.oTarget);
                                        object oItemLeft = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spInfo.oTarget);

                                        if(oItemRight!=OBJECT_INVALID) {
                                            DelayCommand(fDelay+0.1, AssignCommand(spInfo.oTarget, ActionPutDownItem(oItemRight)));
                                        }
                                        if(oItemLeft!=OBJECT_INVALID) {
                                            DelayCommand(fDelay+0.1, AssignCommand(spInfo.oTarget, ActionPutDownItem(oItemLeft)));
                                        }
                                        if(spInfo.iSpellID==SPELL_GR_COMMAND_GREATER_DROP) {
                                            DelayCommand(fDelay+0.2, SetCommandable(FALSE, spInfo.oTarget));
                                        }
                                        break;
                                    case SPELL_GR_COMMAND_FLEE:
                                    case SPELL_GR_COMMAND:
                                    case SPELL_GR_COMMAND_GREATER_FLEE:
                                    case SPELL_GR_COMMAND_GREATER:
                                        DelayCommand(fDelay+0.1, AssignCommand(spInfo.oTarget, ActionMoveAwayFromObject(oCaster, TRUE, FeetToMeters(400.0))));
                                        DelayCommand(fDelay+0.1, SetCommandable(FALSE, spInfo.oTarget));
                                        break;
                                }
                                DelayCommand(fDuration+0.1, CheckCommandable(spInfo.iSpellID, spInfo.oTarget, oCaster));
                            }
                            if(spInfo.iSpellID>=SPELL_GR_COMMAND_GREATER) {
                                GRSetAOESpellId(spInfo.iSpellID, spInfo.oTarget);
                                GRSetSpellInfo(spInfo, spInfo.oTarget);
                                DelayCommand(fDelay+GRGetDuration(1), DoWillSaveCheck(spInfo.iSpellID, spInfo.iDC, spInfo.oTarget, fDelay, bRemoveCommand));
                            }
                        }
                    }
                }
                iNumTargets--;
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumTargets>0);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
