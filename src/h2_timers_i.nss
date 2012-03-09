/*
Filename:           h2_timers_i
System:             core (timer functions include script)
Author:             Edward Beck (0100010)
Date Created:       Jan. 28, 2006
Summary:
HCR2 core constants and functions for the Timer (hearbeat hook-in) system.
Used throughout the core HCR2 system.

Revision Info should only be included for post-release revisions.
-----------------
Revision Date: Dec 31st, 2006
Revision Author: Edward Beck (0100010)
Revision Summary: v1.5
Altered timers to not be reliant on the heartbeat event.
Instead they use looping delayed commands.

*/
#include "h2_locals_i"

//Returns an integer that represents a unique ID of the created timer.
//oScriptObject becomes the OBJECT_SELF from within the script sScriptName when it gets
//run from ExecuteScript. This script gets run whenever the amount of fInterval seconds have
//elapsed. You should save the returned timerID somewhere so that
//it can be accessed and used to stop, start or kill the timer later.
//If oScriptObject has become invalid or if oScriptObject was a PC and that PC
//has logged off, then instead of executing the timer script, it will kill the timer instead.
//After a timer is created you will need to start it to get it to run.
//You cannot create a timer on an invalid oScriptObject or with a non-positive interval value.
//A returned timerID of 0 means the timer was not created.
int h2_CreateTimer(object oScriptObject, string sScriptName, float fInterval)
{
	if (!GetIsObjectValid(oScriptObject))
	{
		string sMessage  = "Warning cannot create " + sScriptName + " timer on invalid script object.";
		SendMessageToAllDMs(sMessage);
		WriteTimestampedLogEntry(sMessage);
		return 0;
	}
	if (fInterval <= 0.0)
	{
		string sMessage  = "Warning cannot create " + sScriptName + " timer with interval of " + FloatToString(fInterval);
		SendMessageToAllDMs(sMessage);
		WriteTimestampedLogEntry(sMessage);
		return 0;
	}

    int nTimerID = h2_GetModLocalInt(H2_NEXT_TIMER_ID);
    h2_SetModLocalInt(H2_NEXT_TIMER_ID, nTimerID + 1);
    if (GetIsPC(oScriptObject))
        SetLocalInt(oScriptObject, H2_TIMER_OBJECT_IS_PC, TRUE);
    h2_SetModLocalString(H2_TIMER_SCRIPT + IntToString(nTimerID), sScriptName);
    h2_SetModLocalObject(H2_TIMER_OBJECT + IntToString(nTimerID), oScriptObject);
	h2_SetModLocalFloat(H2_TIMER_INTERVAL + IntToString(nTimerID) , fInterval);
    return nTimerID;
}

//This will suspend execution of the timer script associated with the value of timerID.
//This does not kill the timer, it only stops it from being executed when its interval comes up.
void h2_StopTimer(int nTimerID)
{
    object oTimerObject = h2_GetModLocalObject(H2_TIMER_OBJECT + IntToString(nTimerID));
    DeleteLocalInt(oTimerObject, H2_TIMER_IS_RUNNING);
}

//This will kill the timer associated with the value of timerID.
//This results in all information abut the given timerID being deleted.
//Since the information is gone, and the script associated with that timerID
//will not  get executed again.
//There is a delay built into this, when the next interval for the given timerID
//elapses, that is when the timer is killed rather than the timer's script being executed.
void h2_KillTimer(int nTimerID)
{
    h2_DeleteModLocalString(H2_TIMER_SCRIPT + IntToString(nTimerID));
    h2_DeleteModLocalObject(H2_TIMER_OBJECT + IntToString(nTimerID));
    h2_DeleteModLocalFloat(H2_TIMER_INTERVAL + IntToString(nTimerID));
}

//This runs when a timer associated with the value of nTimerID elapses
void h2_TimerElapsed(int nTimerID)
{
	string sTimerScript = h2_GetModLocalString(H2_TIMER_SCRIPT + IntToString(nTimerID));
    object oTimerObject = h2_GetModLocalObject(H2_TIMER_OBJECT + IntToString(nTimerID));
	float fTimerInterval = h2_GetModLocalFloat(H2_TIMER_INTERVAL + IntToString(nTimerID));
	if (GetIsObjectValid(oTimerObject) && fTimerInterval > 0.0)
	{
		int bTimerRunning = GetLocalInt(oTimerObject, H2_TIMER_IS_RUNNING);
		if (!bTimerRunning)
			return;
		if (GetLocalInt(oTimerObject, H2_TIMER_OBJECT_IS_PC) && !GetIsPC(oTimerObject))
		{
			h2_KillTimer(nTimerID);
			return;
		}
		ExecuteScript(sTimerScript, oTimerObject);
		DelayCommand(fTimerInterval, h2_TimerElapsed(nTimerID));
	}
	else
		h2_KillTimer(nTimerID);
}

//A timer must be started after it is created for it's script to be run when its interval elapses.
//The timer's script is executed immediately, and again each interval period,
//unless it is stopped or killed.
void h2_StartTimer(int nTimerID)
{
	object oTimerObject = h2_GetModLocalObject(H2_TIMER_OBJECT + IntToString(nTimerID));
	SetLocalInt(oTimerObject, H2_TIMER_IS_RUNNING, 1);
	h2_TimerElapsed(nTimerID);
}

