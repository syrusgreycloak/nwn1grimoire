//*:**************************************************************************
//*:*  GR_IN_SPELLHOOK.NSS
//*:**************************************************************************
//*:*
//*:* Spell Hook Include File (x2_inc_spellhook) Copyright (c) 2003 Bioware Corp.
//*:*
//*:* This file acts as a hub for all code that is hooked into the nwn spellscripts.
//*:*
//*:* If you want to implement material components into spells or add
//*:* restrictions to certain spells, this is the place to do it.
//*:*
//*:**************************************************************************
//*:* Created By: Georg Zoeller
//*:* Created On: 2003-06-04
//*:* Updated On: 2003-10-25
//*:**************************************************************************
//*:* Updated On: April 23, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
#include "X2_INC_SWITCHES"

//*:**********************************************
//*:* Constant Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_ITEMPROP"

//#include "GR_IN_DEBUG"

//*:**************************************************************************
int GRUseMagicDeviceCheck();
string GRGetModuleOverrideSpellscript();
int GRCastOnItemWasAllowed(object oItem);
int GRGetSpellCastOnSequencerItem(object oItem);
int GRRunUserDefinedSpellScript();
int GRSpellhookAbortSpell(object oTarget = OBJECT_INVALID, object oDebugPC = OBJECT_INVALID);
//*:**************************************************************************

//*:**********************************************
//*:* GRUseMagicDeviceCheck
//*:**********************************************
//*:* Use Magic Device Check.
//*:* Returns TRUE if the Spell is allowed to be
//*:* cast, either because the character is allowed
//*:* to cast it or he has won the required UMD check
//*:* Only active on spell scroll
//*:**********************************************
int GRUseMagicDeviceCheck() {
    int nRet = ExecuteScriptAndReturnInt(GetLocalString(GetModule(),"GR_UMDCHECK_STRING"), OBJECT_SELF);
    //AutoDebugString("Inside GRUseMagicDeviceCheck.  Executing script " + GetLocalString(GetModule(), "GR_UMDCHECK_STRING"));

    return nRet;
}

//*:**********************************************
//*:* GRCastOnItemWasAllowed
//*:**********************************************
//*:* GZ: This is a filter I added to prevent spells
//*:* from firing their original spell script when
//*:* they were cast on items and do not have special
//*:* coding for that case. If you add spells that
//*:* can be cast on items you need to put them into
//*:* des_crft_spells.2da
//*:**********************************************
int GRCastOnItemWasAllowed(object oItem) {

    int bAllow = (Get2DAString("des_crft_spells", "CastOnItems", GetSpellId())=="1");

    if(!bAllow) {
        FloatingTextStrRefOnCreature(83453, OBJECT_SELF); // not cast spell on item
    }

    return bAllow;

}

//*:**********************************************
//*:* GRGetModuleOverrideSpellscript
//*:**********************************************
//*:* Checks for a spellhook bypassing script. Can
//*:* be individually set on a per caster basis.
//*:*
//*:* If there is not one set on the caster, check
//*:* if one is set on the caster for the specific
//*:* spell being cast.
//*:*
//*:* Useful for triggers or specific spells.
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 23, 2007
//*:**********************************************
string GRGetModuleOverrideSpellscript() {

    //AutoDebugString("Inside GRGetModuleOverrideSpellscript()");
    string  sScript = GetLocalString(OBJECT_SELF, "GR_BYPASS_SPELLHOOK");
    //AutoDebugString("Checking if caster has a generic bypass spellhook script assigned.  Script value: " + sScript);

    if(sScript=="") {
        sScript = GetLocalString(OBJECT_SELF, "GR_"+IntToString(GetSpellId())+"_SCRIPT");
        //AutoDebugString("Checking if caster has a bypass spellhook script assigned for spell " + GRSpellToString(GetSpellId()) + ".  Script value: " + sScript);
    }
    if(sScript=="") {
        sScript = GetLocalString(GetModule(), "X2_S_UD_SPELLSCRIPT");
        //AutoDebugString("Assigning global spellhook script.  Script value: " + sScript);
    }

    return sScript;
}

//*:**********************************************
//*:* GRRunUserDefinedSpellScript
//*:**********************************************
//*:* Execute a user overridden spell script.
//*:**********************************************
int GRRunUserDefinedSpellScript() {

    // See x2_inc_switches for details on this code
    string sScript = GRGetModuleOverrideSpellscript();
    if(sScript!="") {
        ExecuteScript(sScript, OBJECT_SELF);
        if(GetModuleOverrideSpellScriptFinished() == TRUE) {
            return FALSE;
        }
    }
    return TRUE;
}

//*:**********************************************
//*:* GRGetSpellCastOnSequencerItem
//*:**********************************************
//*:* Returns TRUE (and charges the sequencer item) if the spell:
//*:* ... was cast on an item AND
//*:* ... the item has the sequencer property
//*:* ... the spell was non hostile
//*:* ... the spell was not cast from an item
//*:* in any other case, FALSE is returned an the normal spellscript will be run
//*:*
//*:* Created Brent Knowles, Georg Zoeller 2003-07-31
//*:**********************************************
int GRGetSpellCastOnSequencerItem(object oItem) {

    if(!GetIsObjectValid(oItem)) {
        return FALSE;
    }

    int nMaxSeqSpells = IPGetItemSequencerProperty(oItem); // get number of maximum spells that can be stored
    if(nMaxSeqSpells <1) {
        return FALSE;
    }

    if(GetIsObjectValid(GetSpellCastItem())) {// spell cast from item?
        // we allow scrolls
        int nBt = GetBaseItemType(GetSpellCastItem());
        if(nBt!=BASE_ITEM_SPELLSCROLL && nBt!=105) {
            FloatingTextStrRefOnCreature(83373, OBJECT_SELF);
            return TRUE; // wasted!
        }
    }

    // Check if the spell is marked as hostile in spells.2da
    int nHostile = StringToInt(Get2DAString("spells", "HostileSetting", GetSpellId()));
    if(nHostile==1) {
        FloatingTextStrRefOnCreature(83885,OBJECT_SELF);
        return TRUE; // no hostile spells on sequencers, sorry ya munchkins :)
    }

    int nNumberOfTriggers = GetLocalInt(oItem, "X2_L_NUMTRIGGERS");
    // is there still space left on the sequencer?
    if(nNumberOfTriggers < nMaxSeqSpells) {
        // success visual and store spell-id on item.
        effect eVisual = EffectVisualEffect(VFX_IMP_BREACH);
        nNumberOfTriggers++;
        //NOTE: I add +1 to the SpellId to spell 0 can be used to trap failure
        int nSID = GetSpellId()+1;
        SetLocalInt(oItem, "X2_L_SPELLTRIGGER" + IntToString(nNumberOfTriggers), nSID);
        SetLocalInt(oItem, "X2_L_NUMTRIGGERS", nNumberOfTriggers);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, OBJECT_SELF);
        FloatingTextStrRefOnCreature(83884, OBJECT_SELF);
    } else {
        FloatingTextStrRefOnCreature(83859,OBJECT_SELF);
    }

    return TRUE; // in any case, spell is used up from here, so do not fire regular spellscript
}


//*:**********************************************
//*:* GRSpellhookAbortSpell
//*:**********************************************
//*:* if FALSE is returned by this function, the
//*:* spell will not be cast the order in which the
//*:* functions are called here DOES MATTER, changing
//*:* it WILL break the crafting subsystems
//*:**********************************************
int GRSpellhookAbortSpell(object oTarget = OBJECT_INVALID, object oDebugPC = OBJECT_INVALID) {

   if(!GetIsObjectValid(oTarget)) oTarget = GetSpellTargetObject();
   if(!GetIsObjectValid(oDebugPC)) oDebugPC = GetFirstPC();

   int nContinue;

    //*:**********************************************
    //*:* This stuff is only interesting for player characters.
    //*:* We assume that Use Magic Device always works and NPCs
    //*:* don't use the crafting feats or sequencers anyway.
    //*:* Thus, any NON PC spellcaster always exits this script
    //*:* with TRUE (unless they are DM possessed or in the Wild Magic Area in
    //*:* Chapter 2 of Hordes of the Underdark.
    //*:**********************************************
    if(!GetIsPC(OBJECT_SELF)) {
        //AutoDebugString("Casting Object is not a PC");
        if(!GetIsDMPossessed(OBJECT_SELF)) {
            //AutoDebugString("Casting object is not possessed by a DM");
            if(!GetLocalInt(GetModule(), "GR_L_ALWAYS_ALLOW_NPCS")) {
                //AutoDebugString("No global npc allow set.");
                if(!GetLocalInt(GetArea(OBJECT_SELF), "X2_L_WILD_MAGIC") || !GetLocalInt(GetModule(), "GR_L_ALWAYS_ALLOW_NPCS")) {
                    //AutoDebugString("No area npc allow set.");
                    //AutoDebugString("Returning early from spellhook function.");
                    return TRUE;
                } else {
                    //AutoDebugString("Continuing spellhooking function for NPC.");
                }
            } else {
                //AutoDebugString("Continuing spellhooking function for NPC.");
            }
        }
    } else {
        //AutoDebugString("Casting object is a PC");
    }

    //*:**********************************************
    //*:* Run use magic device skill check
    //*:**********************************************
    nContinue = GRUseMagicDeviceCheck();
    //AutoDebugString("Result of GRUseMagicDeviceCheck is: " + GRBooleanToString(nContinue));

    if(nContinue) {
        //*:**********************************************
        // run any user defined spellscript here
        //*:**********************************************
        //AutoDebugString("Running user defined spell script.");
        nContinue = GRRunUserDefinedSpellScript();
    } else {
        //AutoDebugString("Skipping user defined spell script.");
    }

    //*:**********************************************
    //*:* The following code is only of interest if an item was targeted
    //*:**********************************************
    if(GetIsObjectValid(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_ITEM) {
        //*:**********************************************
        //*:* Check if spell was used to trigger item creation feat
        //*:**********************************************
        if(nContinue) {
            nContinue = !ExecuteScriptAndReturnInt("x2_pc_craft", OBJECT_SELF);
        }

        //*:**********************************************
        //*:* Check if spell was used for on a sequencer item
        //*:**********************************************
        if(nContinue) {
            nContinue = (!GRGetSpellCastOnSequencerItem(oTarget));
        }

        //*:**********************************************
        //*:* Execute item OnSpellCast At routing script if activated
        //*:**********************************************
        if(GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS) == TRUE) {
             SetUserDefinedItemEventNumber(X2_ITEM_EVENT_SPELLCAST_AT);
             int nRet = ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oTarget), OBJECT_SELF);
             if(nRet==X2_EXECUTE_SCRIPT_END) {
                return FALSE;
             }
        }

        //*:**********************************************
        //*:* Prevent any spell that has no special coding to
        //*:* handle targetting of items from being cast on
        //*:* items. We do this because we can not predict how
        //*:* all the hundreds spells in NWN will react when cast
        //*:* on items
        //*:**********************************************
        if(nContinue) {
            nContinue = GRCastOnItemWasAllowed(oTarget);
        }
    }

    return nContinue;
}
//*:**************************************************************************
//*:**************************************************************************
