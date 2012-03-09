//*:**************************************************************************
//*:*  GR_IN_HASTE.NSS
//*:**************************************************************************
//*:*
//*:* Stacking prevention function for haste type spells
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 10, 2004
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IN_SPELLS"


//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
int GRPreventHasteStacking(int iSpellID, object oTarget) {

    int bPrevent = FALSE;
    int bHasEffect = FALSE;

    int bHasEpicBlindingSpeed   = (GetHasSpellEffect(647, oTarget) || GetHasFeatEffect(FEAT_EPIC_BLINDING_SPEED, oTarget));
    int bHasHaste               = GetHasSpellEffect(SPELL_HASTE, oTarget);
    int bHasSwiftHaste          = GetHasSpellEffect(SPELL_GR_HASTE_SWIFT, oTarget);
    int bHasExpeditious         = GetHasSpellEffect(SPELL_EXPEDITIOUS_RETREAT, oTarget);
    int bHasExpeditiousSwift    = GetHasSpellEffect(SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT, oTarget);
    int bHasLongstrider         = GetHasSpellEffect(SPELL_GR_LONGSTRIDER, oTarget);
    int bHasMassLongstrider     = GetHasSpellEffect(SPELL_GR_MASS_LONGSTRIDER, oTarget);
    int bHasLivelyStep          = GRGetHasEffectTypeFromSpell(EFFECT_TYPE_MOVEMENT_SPEED_INCREASE, oTarget, SPELL_GR_LIVELY_STEP);
    int bHasAllegro             = GetHasSpellEffect(SPELL_GR_ALLEGRO, oTarget);
    int bHasStormAvatar         = GetHasSpellEffect(SPELL_STORM_AVATAR, oTarget);
    int bHasNatureAvatar        = GetHasSpellEffect(SPELL_NATURE_AVATAR, oTarget);

    bHasEffect = bHasEpicBlindingSpeed || bHasHaste || bHasSwiftHaste || bHasExpeditious ||
                 bHasExpeditiousSwift || bHasLongstrider || bHasMassLongstrider || bHasLivelyStep ||
                 bHasAllegro || bHasStormAvatar || bHasNatureAvatar;

    if(bHasEffect) {
        switch(iSpellID) {
            case SPELL_NATURE_AVATAR:
                if(bHasNatureAvatar) GRRemoveSpellEffects(SPELL_NATURE_AVATAR, oTarget);
                else if(bHasStormAvatar) GRRemoveSpellEffects(SPELL_STORM_AVATAR, oTarget);
                else if(bHasEpicBlindingSpeed) GRRemoveSpellEffects(647, oTarget);
                else if(bHasHaste) GRRemoveSpellEffects(SPELL_HASTE, oTarget);
                else if(bHasSwiftHaste) GRRemoveSpellEffects(SPELL_GR_HASTE_SWIFT, oTarget);
                else if(bHasExpeditious) GRRemoveSpellEffects(SPELL_EXPEDITIOUS_RETREAT, oTarget);
                else if(bHasExpeditiousSwift) GRRemoveSpellEffects(SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT, oTarget);
                else if(bHasLongstrider) GRRemoveSpellEffects(SPELL_GR_LONGSTRIDER, oTarget);
                else if(bHasMassLongstrider) GRRemoveSpellEffects(SPELL_GR_MASS_LONGSTRIDER, oTarget);
                else if(bHasLivelyStep) GRRemoveSpellEffects(SPELL_GR_LIVELY_STEP, oTarget);
                else if(bHasAllegro) GRRemoveSpellEffects(SPELL_GR_ALLEGRO, oTarget);
                break;
            case SPELL_STORM_AVATAR:
                if(bHasNatureAvatar) bPrevent = TRUE;
                else {
                    if(bHasStormAvatar) GRRemoveSpellEffects(SPELL_STORM_AVATAR, oTarget);
                    else if(bHasEpicBlindingSpeed) GRRemoveSpellEffects(647, oTarget);
                    else if(bHasHaste) GRRemoveSpellEffects(SPELL_HASTE, oTarget);
                    else if(bHasSwiftHaste) GRRemoveSpellEffects(SPELL_GR_HASTE_SWIFT, oTarget);
                    else if(bHasExpeditious) GRRemoveSpellEffects(SPELL_EXPEDITIOUS_RETREAT, oTarget);
                    else if(bHasExpeditiousSwift) GRRemoveSpellEffects(SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT, oTarget);
                    else if(bHasLongstrider) GRRemoveSpellEffects(SPELL_GR_LONGSTRIDER, oTarget);
                    else if(bHasMassLongstrider) GRRemoveSpellEffects(SPELL_GR_MASS_LONGSTRIDER, oTarget);
                    else if(bHasLivelyStep) GRRemoveSpellEffects(SPELL_GR_LIVELY_STEP, oTarget);
                    else if(bHasAllegro) GRRemoveSpellEffects(SPELL_GR_ALLEGRO, oTarget);
                }
                break;
            case 647: // Blinding Speed
            case SPELL_HASTE:
            case SPELL_GR_HASTE_SWIFT:
                if(bHasStormAvatar) bPrevent = TRUE;
                else {
                    if(bHasEpicBlindingSpeed) GRRemoveSpellEffects(647, oTarget);
                    else if(bHasHaste) GRRemoveSpellEffects(SPELL_HASTE, oTarget);
                    else if(bHasSwiftHaste) GRRemoveSpellEffects(SPELL_GR_HASTE_SWIFT, oTarget);
                    else if(bHasExpeditious) GRRemoveSpellEffects(SPELL_EXPEDITIOUS_RETREAT, oTarget);
                    else if(bHasExpeditiousSwift) GRRemoveSpellEffects(SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT, oTarget);
                    else if(bHasLongstrider) GRRemoveSpellEffects(SPELL_GR_LONGSTRIDER, oTarget);
                    else if(bHasMassLongstrider) GRRemoveSpellEffects(SPELL_GR_MASS_LONGSTRIDER, oTarget);
                    else if(bHasLivelyStep) GRRemoveSpellEffects(SPELL_GR_LIVELY_STEP, oTarget);
                    else if(bHasAllegro) GRRemoveSpellEffects(SPELL_GR_ALLEGRO, oTarget);
                }
                break;
            case SPELL_GR_MASS_LONGSTRIDER:
                if(bHasEpicBlindingSpeed || bHasHaste || bHasSwiftHaste) bPrevent = TRUE;
                else {
                    if(bHasExpeditious) GRRemoveSpellEffects(SPELL_EXPEDITIOUS_RETREAT, oTarget);
                    else if(bHasExpeditiousSwift) GRRemoveSpellEffects(SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT, oTarget);
                    else if(bHasLongstrider) GRRemoveSpellEffects(SPELL_GR_LONGSTRIDER, oTarget);
                    else if(bHasMassLongstrider) GRRemoveSpellEffects(SPELL_GR_MASS_LONGSTRIDER, oTarget);
                    else if(bHasLivelyStep) GRRemoveSpellEffects(SPELL_GR_LIVELY_STEP, oTarget);
                    else if(bHasAllegro) GRRemoveSpellEffects(SPELL_GR_ALLEGRO, oTarget);
                }
                break;
            case SPELL_GR_ALLEGRO:
                if(bHasEpicBlindingSpeed || bHasHaste || bHasSwiftHaste || bHasMassLongstrider) bPrevent = TRUE;
                else {
                    if(bHasExpeditious) GRRemoveSpellEffects(SPELL_EXPEDITIOUS_RETREAT, oTarget);
                    else if(bHasExpeditiousSwift) GRRemoveSpellEffects(SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT, oTarget);
                    else if(bHasLongstrider) GRRemoveSpellEffects(SPELL_GR_LONGSTRIDER, oTarget);
                    else if(bHasMassLongstrider) GRRemoveSpellEffects(SPELL_GR_MASS_LONGSTRIDER, oTarget);
                    else if(bHasLivelyStep) GRRemoveSpellEffects(SPELL_GR_LIVELY_STEP, oTarget);
                    else if(bHasAllegro) GRRemoveSpellEffects(SPELL_GR_ALLEGRO, oTarget);
                }
                break;
            case SPELL_GR_LONGSTRIDER:
            case SPELL_EXPEDITIOUS_RETREAT:
                if(bHasEpicBlindingSpeed || bHasHaste || bHasSwiftHaste || bHasAllegro || bHasMassLongstrider) bPrevent = TRUE;
                else {
                    if(bHasExpeditious) GRRemoveSpellEffects(SPELL_EXPEDITIOUS_RETREAT, oTarget);
                    else if(bHasExpeditiousSwift) GRRemoveSpellEffects(SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT, oTarget);
                    else if(bHasLongstrider) GRRemoveSpellEffects(SPELL_GR_LONGSTRIDER, oTarget);
                    else if(bHasLivelyStep) GRRemoveSpellEffects(SPELL_GR_LIVELY_STEP, oTarget);
                }
                break;
            case SPELL_GR_LIVELY_STEP:
                if(bHasEpicBlindingSpeed || bHasHaste || bHasSwiftHaste || bHasAllegro || bHasMassLongstrider || bHasExpeditious || bHasLongstrider)
                    bPrevent = TRUE;
                else {
                    if(bHasLivelyStep) GRRemoveSpellEffects(SPELL_GR_LIVELY_STEP, oTarget);
                    else if(bHasExpeditiousSwift) GRRemoveSpellEffects(SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT, oTarget);
                }
                break;
            case SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT:
                if(bHasExpeditiousSwift) GRRemoveSpellEffects(SPELL_GR_EXPEDITIOUS_RETREAT_SWIFT, oTarget);
                else bPrevent = TRUE; // we tested bHasEffect to get into the switch statement
                break;
        }
    }

    return bPrevent;
}
