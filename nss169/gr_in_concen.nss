//*:**************************************************************************
//*:*  GR_IN_CONCEN.NSS
//*:**************************************************************************
//*:*
//*:* Attempt at a concentration system
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 7, 2005
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
//#include "X2_INC_SPELLHOOK"

//*:**************************************************************************
//*:* Constants
//*:**************************************************************************
const int GR_EVENT_CONCENTRATION_BROKEN = 12400;

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void    GRBreakConcentrationSpells();
int     GRCheckCasterConcentration(object oCaster = OBJECT_SELF);
void    GRDoBreakConcentrationCheck();
int     GRGetBreakConcentrationCondition(object oPlayer);
int     GRGetCasterConcentrating(int iSpellID, object oCaster = OBJECT_SELF);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//------------------------------------------------------------------------------
// being hit by any kind of negative effect affecting the caster's ability to concentrate
// will cause a break condition for concentration spells
//------------------------------------------------------------------------------
int GRGetBreakConcentrationCondition(object oPlayer) {

     effect e1 = GetFirstEffect(oPlayer);
     int nType;
     int bRet = FALSE;

     while(GetIsEffectValid(e1) && !bRet) {
        nType = GetEffectType(e1);

        if(nType == EFFECT_TYPE_STUNNED || nType == EFFECT_TYPE_PARALYZE ||
            nType == EFFECT_TYPE_SLEEP || nType == EFFECT_TYPE_FRIGHTENED ||
            nType == EFFECT_TYPE_PETRIFY || nType == EFFECT_TYPE_CONFUSED ||
            nType == EFFECT_TYPE_DOMINATED || nType == EFFECT_TYPE_POLYMORPH) {

            bRet = TRUE;
        }
        e1 = GetNextEffect(oPlayer);
     }

    return bRet;
}

void GRDoBreakConcentrationCheck() {
    object oMaster = GetMaster();

    if(GetLocalInt(OBJECT_SELF, CREATURE_NEEDS_CONCENTRATION)) {
        if(GetIsObjectValid(oMaster)) {

            int nAction = GetCurrentAction(oMaster);

            // master doing anything that requires attention and breaks concentration
            if(nAction == ACTION_DISABLETRAP || nAction == ACTION_TAUNT ||
                nAction == ACTION_PICKPOCKET || nAction ==ACTION_ATTACKOBJECT ||
                nAction == ACTION_COUNTERSPELL || nAction == ACTION_FLAGTRAP ||
                nAction == ACTION_CASTSPELL || nAction == ACTION_ITEMCASTSPELL) {

                SignalEvent(OBJECT_SELF, EventUserDefined(GR_EVENT_CONCENTRATION_BROKEN));
            } else if(GRGetBreakConcentrationCondition(oMaster)) {
                SignalEvent(OBJECT_SELF, EventUserDefined(GR_EVENT_CONCENTRATION_BROKEN));
            }
        }
    }
}

//*:**********************************************
//*:* SGCheckCasterConcentration
//*:* 2005 Karl Nickels (Syrus Greycloak)
//*:**********************************************
/*
    Checks if caster is still concentrating for spell
*/
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 7, 2005
//*:**********************************************
int GRCheckCasterConcentration(object oCaster = OBJECT_SELF) {

    int bIsConcentrating = FALSE;

    if(GetLocalInt(oCaster, CASTER_NEEDS_CONCENTRATION)) {
        if(GetIsObjectValid(oCaster)) {
            bIsConcentrating = TRUE;
            int iAction = GetCurrentAction(oCaster);

            //*:**********************************************
            //*:* Caster doing anything that requires
            //*:* attention and breaks concentration?
            //*:**********************************************
            if (iAction == ACTION_DISABLETRAP || iAction == ACTION_TAUNT ||
                iAction == ACTION_PICKPOCKET || iAction ==ACTION_ATTACKOBJECT ||
                iAction == ACTION_COUNTERSPELL || iAction == ACTION_FLAGTRAP ||
                iAction == ACTION_CASTSPELL || iAction == ACTION_ITEMCASTSPELL)
            {
                SetLocalInt(oCaster, CASTER_NEEDS_CONCENTRATION, FALSE);
                bIsConcentrating = FALSE;
            } else if(GRGetBreakConcentrationCondition(oCaster)) {
                SetLocalInt(oCaster, CASTER_NEEDS_CONCENTRATION, FALSE);
                bIsConcentrating = FALSE;
            }
        }
    }

    return bIsConcentrating;
}

//*:**********************************************
//*:* GRGetCasterConcentrating
//*:* 2005 Karl Nickels (Syrus Greycloak)
//*:**********************************************
/*
    Checks if caster is still concentrating for spell.
    Updated version of above function to allow for
    different spells.
*/
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 7, 2005
//*:**********************************************
int GRGetCasterConcentrating(int iSpellID, object oCaster = OBJECT_SELF) {

    int bIsConcentrating = FALSE;

    if(GetLocalInt(oCaster, CONCENTRATION_REQUIRED + IntToString(iSpellID))) {
        if(GetIsObjectValid(oCaster)) {
            bIsConcentrating = TRUE;
            int iAction = GetCurrentAction(oCaster);

            //*:**********************************************
            //*:* Caster doing anything that requires
            //*:* attention and breaks concentration?
            //*:**********************************************
            if (iAction == ACTION_DISABLETRAP || iAction == ACTION_TAUNT ||
                iAction == ACTION_PICKPOCKET || iAction ==ACTION_ATTACKOBJECT ||
                iAction == ACTION_COUNTERSPELL || iAction == ACTION_FLAGTRAP ||
                iAction == ACTION_CASTSPELL || iAction == ACTION_ITEMCASTSPELL ||
                GRGetBreakConcentrationCondition(oCaster))
            {
                bIsConcentrating = FALSE;
            }
        }
    }

    return bIsConcentrating;
}

//*:**********************************************
//*:* GRBreakConcentrationSpells
//*:**********************************************
//*:* This is our little concentration system for
//*:* black blade of disaster.  If the mage tries
//*:* to cast any kind of spell, the blade is
//*:* signaled an event to die
//*:**********************************************
void GRBreakConcentrationSpells() {
    // * At the moment we got only one concentration spell, black blade of disaster

    object oAssoc = GetAssociate(ASSOCIATE_TYPE_SUMMONED);
    if(GetIsObjectValid(oAssoc) && GetIsPC(OBJECT_SELF)) { // only applies to PCS
        if(GetTag(oAssoc) == BLACK_BLADE_OF_DISASTER_TAG) { // black blade of disaster
            if(GetLocalInt(OBJECT_SELF, CREATURE_NEEDS_CONCENTRATION)) {
                SignalEvent(oAssoc, EventUserDefined(GR_EVENT_CONCENTRATION_BROKEN));
            }
        }
    }
}

//*:**************************************************************************
//*:**************************************************************************
