//*:**************************************************************************
//*:*  GR_S0_THNDRSTF.NSS
//*:**************************************************************************
//*:* Thunder Staff (sg_s0_thndrstf.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: November 17, 2004
//*:* 2e Tome of Magic
//*:**************************************************************************
//*:* Updated On: March 11, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
//#include "X0_I0_POSITION"     - INCLUDED IN GR_IN_LIB

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

    spInfo.lTarget = GetAheadLocation(oCaster);

    int     iDieType          = 0;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount;        //= GRGetMetamagicAdjustedDamage(3, 1, spInfo.iMetamagic);
    int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    float   fStunDuration;
    float   fDeafDuration;
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(40.0);

    int     iObjectFilter   = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    int     iFeetHurled;    //= SGMaximizeOrEmpower(4,4,iMetamagic,4);
    float   fDistHurled;    //= FeetToMeters(iFeetHurled*1.0);
    float   fAngle;
    float   fFacing;
    location lHurledToLocation;
    int     bGiantSize;


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
    effect eDeaf        = EffectDeaf();
    effect eDeafVis     = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    effect eDmgVis      = EffectVisualEffect(VFX_COM_HIT_SONIC);
    effect eStun        = EffectStunned();
    effect eStunVis     = EffectVisualEffect(VFX_IMP_STUN);
    effect eDamage;
    effect eKnockdown   = EffectKnockdown();
    effect eDamageLink;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE, iObjectFilter);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_GR_THUNDER_STAFF));
            fDelay = GetDistanceBetween(OBJECT_SELF, spInfo.oTarget)/20.0;
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                fStunDuration = GRGetDuration(GRGetMetamagicAdjustedDamage(3, 1, spInfo.iMetamagic, 0));
                fDeafDuration = GRGetDuration(GRGetMetamagicAdjustedDamage(3, 1, spInfo.iMetamagic, 1));
                iFeetHurled = GRGetMetamagicAdjustedDamage(4, 4, spInfo.iMetamagic, 4);
                bGiantSize = (GetCreatureSize(spInfo.oTarget)>CREATURE_SIZE_MEDIUM);

                if(bGiantSize) {
                    iFeetHurled = GRGetMetamagicAdjustedDamage(2, 4, spInfo.iMetamagic, 2);
                }
                if(GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NONE, oCaster, fDelay)) {
                    GRSetSpellDmgSaveMade(spInfo.iSpellID, TRUE, oCaster);
                    if(bGiantSize) {
                        iFeetHurled = 0;
                    } else {
                        iFeetHurled /= 2;
                    }
                }
                iDamage = iFeetHurled/2;
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, FORTITUDE_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                eDamage = EffectDamage(iDamage);
                if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                eDamageLink = EffectLinkEffects(eDmgVis, eDamage);
                eLink = EffectLinkEffects(eDamageLink, eStunVis);
                eLink = EffectLinkEffects(eLink, eKnockdown);

                if(iFeetHurled>0) {
                    fDistHurled = FeetToMeters(iFeetHurled*1.0);
                    fAngle = GetAngleBetweenLocations(GetLocation(oCaster), GetLocation(spInfo.oTarget));
                    fFacing = GetFacing(spInfo.oTarget);
                    lHurledToLocation = GenerateNewLocation(spInfo.oTarget, fDistHurled, fAngle, fFacing);
                }
                if(!GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster)) {
                    DelayCommand(fDelay, AssignCommand(spInfo.oTarget, ClearAllActions()));
                    DelayCommand(fDelay+0.1, AssignCommand(spInfo.oTarget, ActionJumpToLocation(lHurledToLocation)));
                    DelayCommand(fDelay+0.2, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, spInfo.oTarget, fStunDuration));
                    DelayCommand(fDelay+0.3, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeaf, spInfo.oTarget, fDeafDuration));
                    DelayCommand(fDelay+0.4, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                } else {
                    if(!bGiantSize) {
                        eLink = EffectLinkEffects(eDamageLink, eKnockdown);
                        eLink = EffectLinkEffects(eLink, eDeafVis);
                        DelayCommand(fDelay, AssignCommand(spInfo.oTarget, ClearAllActions()));
                        DelayCommand(fDelay+0.1, AssignCommand(spInfo.oTarget, ActionJumpToLocation(lHurledToLocation)));
                        DelayCommand(fDelay+0.2, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeaf, spInfo.oTarget, fDeafDuration));
                        DelayCommand(fDelay+0.3, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                    } else {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeafVis, spInfo.oTarget));
                        DelayCommand(fDelay+0.1, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeaf, spInfo.oTarget, fDeafDuration));
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE, iObjectFilter);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
