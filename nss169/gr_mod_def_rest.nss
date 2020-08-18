//::///////////////////////////////////////////////
//:: Name: x2_mod_def_rest
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The generic wandering monster system
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: June 9/03
//:://////////////////////////////////////////////
//:: Edited By: Karl Nickels (Syrus Greycloak)
//:: Edited On: December 27, 2005
//:://////////////////////////////////////////////
/*
    SUMMARY OF CHANGES FOR THE GRIMOIRE
    added include "sg_i0_spells"

    In Start Rest section:
    - added code to check a cleric for domain bonus feats
    - added code to check if a cleric has memorized a domain
      spell at each level.  It will prevent resting if they do
      not.
*/
//:://////////////////////////////////////////////
#include "GR_IN_DEITIES"
#include "GR_IN_DOMAINS"
#include "GR_IN_LIB"

#include "x2_inc_restsys"
#include "x2_inc_switches"

void main()
{
    object oPC = GetLastPCRested();


    if(GetModuleSwitchValue(MODULE_SWITCH_USE_XP2_RESTSYSTEM) == TRUE) {
        /*  Georg, August 11, 2003
            Added this code to allow the designer to specify a variable on the module
            Instead of using a OnAreaEnter script. Nice new toolset feature!
            Basically, the first time a player rests, the area is scanned for the
            encounter table string and will set it up.
        */
        object oArea = GetArea (oPC);

        string sTable = GetLocalString(oArea,"X2_WM_ENCOUNTERTABLE") ;
        if (sTable != "" )
        {
            int nDoors = GetLocalInt(oArea,"X2_WM_AREA_USEDOORS");
            int nDC = GetLocalInt(oArea,"X2_WM_AREA_LISTENCHECK");
            WMSetAreaTable(oArea,sTable,nDoors,nDC);

            //remove string to indicate we are set up
            DeleteLocalString(oArea,"X2_WM_ENCOUNTERTABLE");
        }


        /* Brent, July 2 2003
           - If you rest and are a low level character at the beginning of the module.
             You will trigger the first dream cutscene
        */
        if (GetLocalInt(GetModule(), "X2_G_LOWLEVELSTART") == 10)
        {
            AssignCommand(oPC, ClearAllActions());
            if (GetHitDice(oPC) >= 12)
            {
                ExecuteScript("bk_sleep", oPC);
                return;
            }
            else
            {
                FloatingTextStrRefOnCreature(84141 , oPC);
                return;
            }
        }

        if (GetLastRestEventType()==REST_EVENTTYPE_REST_STARTED)
        {
            if (!WMStartPlayerRest(oPC))
            {
                // The resting system has objections against resting here and now
                // Probably because there is an ambush already in progress
                FloatingTextStrRefOnCreature(84142  ,oPC);
                AssignCommand(oPC,ClearAllActions());
            }
            if (WMCheckForWanderingMonster(oPC))
            {
                //This script MUST be run or the player won't be able to rest again ...
                ExecuteScript("x2_restsys_ambus",oPC);
            }
        }
        else if (GetLastRestEventType()==REST_EVENTTYPE_REST_CANCELLED)
        {
         // No longer used but left in for the community
         // WMFinishPlayerRest(oPC,TRUE); // removes sleep effect, etc
        }
        else if (GetLastRestEventType()==REST_EVENTTYPE_REST_FINISHED)
        {
         // No longer used but left in for the community
         //   WMFinishPlayerRest(oPC); // removes sleep effect, etc
        }
    }

    //:/********************************************************
    //:/ GRIMOIRE CHANGES
    //:/********************************************************
    if(!GetLocalInt(oPC,"MY_DEITY")) GRSetPCDeity(oPC);
    //AutoDebugString("Character is: "+GetName(oPC));
    if(GetLastRestEventType()==REST_EVENTTYPE_REST_CANCELLED) {
        // IF THE CASTER CANCELS REST OR IS INTERRUPTED
        // FORCE THE SPELLHOOK SCRIPT TO CALL THE CHECK FUNCTION
        // IF THEY ATTEMPT TO CAST A SPELL
        SetLocalInt(oPC, "GR_DOMAIN_CHECK_DONE", FALSE);
    } else if(GetLastRestEventType()==REST_EVENTTYPE_REST_FINISHED) {
        if(GRGetHasClass(CLASS_TYPE_CLERIC, oPC)) {
            //AutoDebugString("You are a cleric.");
            if(!GetLocalInt(oPC, "GR_L_DOMAIN_FEATS")) {
                //AutoDebugString("Checking if needs special domain feats.");
                GRCheckSpecialDomainFeats(oPC);
            }

            //AutoDebugString("Checking if Enforcing Domain Spells");
            if(GetModuleSwitchValue("GR_ENFORCE_DOMAINSPELLS")==TRUE) {
                //AutoDebugString("Checking domain spells for "+GetName(oPC));
                GRCheckDomainSpellsMemorized(oPC);
                if(GetLocalInt(oPC, "GR_DOMAIN_BLOCK")) {
                    FloatingTextStrRefOnCreature(16939275, oPC);
                }
            } /*else {  // debug message
                //AutoDebugString("Domain spell variable not set.");
            }*/
        } /*else {
            //AutoDebugString("You are not a cleric.");
        }*/
    }
    //:/********************************************************
    //:/ END OF GRIMOIRE CHANGES
    //:/********************************************************

}

