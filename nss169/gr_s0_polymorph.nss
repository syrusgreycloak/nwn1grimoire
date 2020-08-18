//*:**************************************************************************
//*:*  GR_S0_POLYMORPH.NSS
//*:**************************************************************************
//*:*
//*:* Master script for polymorph type spells
//*:*
//*:* Polymorph Self (NW_S0_PolySelf.nss) Copyright (c) 2001 Bioware Corp.
//*:* Shapechange (NW_S0_ShapeChg.nss) Copyright (c) 2001 Bioware Corp.
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 21, 2002
//*:**************************************************************************
//*:* Animal Shapes - 3.5 Player's Handbook (p. 198)
//*:* Aspect of the Wolf - Spell Compendium (p. 16)
//*:* Aspect of the Earth Hunter - Spell Compendium (p. 16)
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:*
//*:* Aspect of the Icy Hunter          Complete Mage (p. 96)
//*:* Shape of the Hellspawned Stalker  Complete Mage (p. 117)
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On:  April 17, 2008
//*:*
//*:* Dreaded Form of the Eye Tyrant    Complete Mage (p. 102)
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On:  April 21, 2008
//*:**************************************************************************
//*:* Updated On: April 21, 2008
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
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_TURNS;

    int     iPolyType;
    int     iSpellType      = spInfo.iSpellID;
    int     bMultiTarget    = FALSE;
    int     iNumCreatures   = spInfo.iCasterLevel;
    int     bNotPolySpell   = FALSE;

    switch(spInfo.iSpellID) {
        //*:**********************************************
        //*:* Polymorph Self
        //*:**********************************************
        case 387:
            /*** NWN1 SINGLE ***/ iPolyType  = POLYMORPH_TYPE_GIANT_SPIDER;
            //*** NWN2 SINGLE ***/ iPolyType = POLYMORPH_TYPE_SWORD_SPIDER;
            iSpellType = SPELL_POLYMORPH_SELF;
            break;
        case 388:
            iPolyType  = POLYMORPH_TYPE_TROLL;
            iSpellType = SPELL_POLYMORPH_SELF;
            break;
        case 389:
            iPolyType  = POLYMORPH_TYPE_UMBER_HULK;
            iSpellType = SPELL_POLYMORPH_SELF;
            break;
        case 390:
            /*** NWN1 SINGLE ***/ iPolyType  = POLYMORPH_TYPE_PIXIE;
            //*** NWN2 SINGLE ***/ iPolyType = POLYMORPH_TYPE_GARGOYLE;
            iSpellType = SPELL_POLYMORPH_SELF;
            break;
        case 391:
            /*** NWN1 SINGLE ***/ iPolyType  = POLYMORPH_TYPE_ZOMBIE;
            //*** NWN2 SINGLE ***/ iPolyType = POLYMORPH_TYPE_MINDFLAYER;
            iSpellType = SPELL_POLYMORPH_SELF;
            break;
        //*:**********************************************
        //*:* Aspect of the Wolf/Earth Hunter/Icy Hunter
        //*:**********************************************
        case SPELL_GR_ASPECT_OF_THE_WOLF:
            iPolyType   = POLYMORPH_TYPE_WOLF;
            iDurAmount *= 10;
            break;
        case SPELL_GR_ASPECT_OF_THE_EARTH_HUNTER:
            iPolyType   = POLYMORPH_TYPE_BULETTE;
            iDurAmount *= 10;
            break;
        case SPELL_GR_ASPECT_OF_THE_ICY_HUNTER:
            iPolyType   = POLYMORPH_TYPE_WINTER_WOLF;
            iDurType = DUR_TYPE_ROUNDS;
            break;
        //*:**********************************************
        //*:* Shape of the Hellspawned Stalker
        //*:**********************************************
        case SPELL_GR_SHAPE_OF_THE_HELLSPAWNED_STALKER:
            iPolyType = POLYMORPH_TYPE_HELLHOUND;
            iDurType = DUR_TYPE_ROUNDS;
            break;
        //*:**********************************************
        //*:* Dreaded Form of the Eye Tyrant
        //*:**********************************************
        case SPELL_GR_DREADED_FORM_OF_THE_EYE_TYRANT:
            iPolyType = POLYMORPH_TYPE_DF_EYETYRANT;
            iDurType = DUR_TYPE_ROUNDS;
            break;
        //*:**********************************************
        //*:* Animal Shapes
        //*:**********************************************
        case SPELL_GR_ANISHAPE_BEAR:
        case SPELL_GR_ANISHAPE_NORMAL:
            iPolyType = (spInfo.iCasterLevel<18 ? POLYMORPH_TYPE_BROWN_BEAR : POLYMORPH_TYPE_DIRE_BROWN_BEAR);
            iDurType  = DUR_TYPE_HOURS;
            iSpellType = SPELL_GR_ANISHAPE_NORMAL;
            bMultiTarget = TRUE;
            break;
        case SPELL_GR_ANISHAPE_PANTHER:
            iPolyType = (spInfo.iCasterLevel<18 ? POLYMORPH_TYPE_PANTHER : POLYMORPH_TYPE_DIRE_PANTHER);
            iDurType  = DUR_TYPE_HOURS;
            iSpellType = SPELL_GR_ANISHAPE_NORMAL;
            bMultiTarget = TRUE;
            break;
        case SPELL_GR_ANISHAPE_WOLF:
            iPolyType = (spInfo.iCasterLevel<18 ? POLYMORPH_TYPE_WOLF : POLYMORPH_TYPE_DIRE_WOLF);
            iDurType  = DUR_TYPE_HOURS;
            iSpellType = SPELL_GR_ANISHAPE_NORMAL;
            bMultiTarget = TRUE;
            break;
        case SPELL_GR_ANISHAPE_BOAR:
            iPolyType = (spInfo.iCasterLevel<18 ? POLYMORPH_TYPE_BOAR : POLYMORPH_TYPE_DIRE_BOAR);
            iDurType  = DUR_TYPE_HOURS;
            iSpellType = SPELL_GR_ANISHAPE_NORMAL;
            bMultiTarget = TRUE;
            break;
        case SPELL_GR_ANISHAPE_BADGER:
            iPolyType = (spInfo.iCasterLevel<18 ? POLYMORPH_TYPE_BADGER : POLYMORPH_TYPE_DIRE_BADGER);
            iDurType  = DUR_TYPE_HOURS;
            iSpellType = SPELL_GR_ANISHAPE_NORMAL;
            bMultiTarget = TRUE;
            break;
        //*:**********************************************
        //*:* Shapechange
        //*:**********************************************
        case 392:
            /*** NWN1 SINGLE ***/ iPolyType   = POLYMORPH_TYPE_RED_DRAGON;
            //*** NWN2 SINGLE ***/ iPolyType = POLYMORPH_TYPE_FROST_GIANT_MALE;
            iDurAmount *= 10;
            iSpellType  = SPELL_SHAPECHANGE;
            break;
        case 393:
            iPolyType   = POLYMORPH_TYPE_FIRE_GIANT;
            iDurAmount *= 10;
            iSpellType  = SPELL_SHAPECHANGE;
            break;
        case 394:
            /*** NWN1 SINGLE ***/ iPolyType   = POLYMORPH_TYPE_BALOR;
            //*** NWN2 SINGLE ***/ iPolyType = POLYMORPH_TYPE_HORNED_DEVIL;
            iDurAmount *= 10;
            iSpellType  = SPELL_SHAPECHANGE;
            break;
        case 395:
            /*** NWN1 SINGLE ***/ iPolyType   = POLYMORPH_TYPE_DEATH_SLAAD;
            //*** NWN2 SINGLE ***/ iPolyType = POLYMORPH_TYPE_NIGHTWALKER;
            iDurAmount *= 10;
            iSpellType  = SPELL_SHAPECHANGE;
            break;
        case 396:
            iPolyType   = POLYMORPH_TYPE_IRON_GOLEM;
            iDurAmount *= 10;
            iSpellType  = SPELL_SHAPECHANGE;
            break;
        default:
            bNotPolySpell = TRUE;
            break;
    }
    //*:**********************************************
    //*:* End spell types
    //*:**********************************************

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
    float   fRange          = FeetToMeters(15.0);

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
    /*** NWN1 SPECIFIC ***/
        effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
        effect eVis     = EffectVisualEffect(VFX_IMP_POLYMORPH);
    /*** END NWN1 SPECIFIC ***/

    effect ePoly    = EffectPolymorph(iPolyType);

    /*** NWN2 SPECIFIC ***
        effect eVis = EffectVisualEffect(VFX_DUR_POLYMORPH);
        ePoly = EffectLinkEffects(ePoly, eVis);
        if(!GetIsPC(oCaster)) SetEffectSpellID(ePoly, SPELL_I_WORD_OF_CHANGING);
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!bNotPolySpell) {
        if(bMultiTarget) {
            /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
            spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
        }

        if(GetIsObjectValid(spInfo.oTarget)) {
            do {
                if(!bMultiTarget || (GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, FALSE) && GRGetIsHumanoid(spInfo.oTarget) &&
                    GRGetIsLiving(spInfo.oTarget))) {

                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, iSpellType, FALSE));

                    if(GetHasEffect(EFFECT_TYPE_POLYMORPH, spInfo.oTarget)) {
                        GRRemoveEffects(EFFECT_TYPE_POLYMORPH, spInfo.oTarget);
                    }

                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                    DelayCommand(0.4f, AssignCommand(spInfo.oTarget, ClearAllActions())); // prevents an exploit
                    DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoly, spInfo.oTarget, fDuration));
                }

                if(bMultiTarget) {
                    spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
                }
            } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumCreatures>0);
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
