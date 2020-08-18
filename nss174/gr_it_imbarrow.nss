//*:**************************************************************************
//*:*  GR_IT_IMBARROW.NSS
//*:**************************************************************************
//*:* Arcane Archer Imbue Arrow
//*:**************************************************************************
//*:* Created by: Karl Nickels (Syrus Greycloak)
//*:* Created On: December 14, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"     // X2_INC_SWITCHES included by way of other includes here

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    int     iEvent = GetUserDefinedItemEventNumber();   //Which event triggered this
    object  oPC;                                        //The player character using the item
    object  oItem;                                      //The item being used
    object  oSpellOrigin;                               //The origin of the spell
    object  oSpellTarget;                               //The target of the spell
    struct  SpellStruct spInfo;

    //*:**************************************************************************
    //*:* Set the return value for the item event script
    //*:* X2_EXECUTE_SCRIPT_CONTINUE - continue calling script after executed script is done
    //*:* X2_EXECUTE_SCRIPT_END - end calling script after executed script is done
    //*:**************************************************************************
    int     iResult = X2_EXECUTE_SCRIPT_CONTINUE;

    switch(iEvent) {
        /*case X2_ITEM_EVENT_ONHITCAST:
            //*:* This code runs when the item has the 'OnHitCastSpell: Unique power' property
            //*:* and it hits a target(if it is a weapon) or is being hit (if it is a piece of armor)
            //*:* Note that this event fires for non PC creatures as well.

            oItem  =  GetSpellCastItem();            // The item triggering this spellscript
            oPC = OBJECT_SELF;                       // The player triggering it
            oSpellOrigin = OBJECT_SELF ;             // Where the spell came from
            oSpellTarget = GetSpellTargetObject();   // What the spell is aimed at

            //*:* Your code goes here
            break;*/

        case X2_ITEM_EVENT_ACTIVATE:
            //*:* This code runs when the Unique Power property of the item is used or the item
            //*:* is activated. Note that this event fires for PCs only

            oPC   = GetItemActivator();              // The player who activated the item
            oItem = GetItemActivated();              // The item that was activated

            //*:* Your code goes here
            break;

        /*case X2_ITEM_EVENT_EQUIP:
            //*:* This code runs when the item is equipped
            //*:* Note that this event fires for PCs only

            oPC = GetPCItemLastEquippedBy();         // The player who equipped the item
            oItem = GetPCItemLastEquipped();         // The item that was equipped

            //*:* Your code goes here
            break;

        case X2_ITEM_EVENT_UNEQUIP:
            //*:* This code runs when the item is unequipped
            //*:* Note that this event fires for PCs only

            oPC    = GetPCItemLastUnequippedBy();    // The player who unequipped the item
            oItem  = GetPCItemLastUnequipped();      // The item that was unequipped

            //*:* Your code goes here
            break;

        case X2_ITEM_EVENT_ACQUIRE:
            //*:* This code runs when the item is acquired
            //*:* Note that this event fires for PCs only

            oPC = GetModuleItemAcquiredBy();        // The player who acquired the item
            oItem  = GetModuleItemAcquired();       // The item that was acquired

            //*:* Your code goes here
            break;*/

        case X2_ITEM_EVENT_UNACQUIRE:
            //*:* This code runs when the item is unacquired
            //*:* Note that this event fires for PCs only

            oPC = GetModuleItemLostBy();            // The player who dropped the item
            oItem  = GetModuleItemLost();           // The item that was dropped

            //*:* Your code goes here

/**************************************************************************************************
PUT CODE HERE SO THAT AN AA CANNOT TRADE ARROWS AWAY (JUST IN CASE)
***************************************************************************************************/
            break;

        case X2_ITEM_EVENT_SPELLCAST_AT:
            //*:* This code runs when a PC or DM casts a spell from one of the
            //*:* standard spellbooks on the item

            oPC         = OBJECT_SELF;                  // The player who cast the spell
            oItem       = GetSpellTargetObject();       // The item targeted by the spell
            spInfo      = GRGetSpellInfoFromObject(GetSpellId(), oPC);

            //*:* Your code goes here
            int     iIPOnHitConst = -1;
            int     bDamaging = FALSE;


            if(GetTag(oItem)=="gr_it_imbarrow" && !GetLocalInt(oItem, "GR_IMBUE_EXPIRED")) {
                if(oPC==GetLocalObject(oItem, "GR_MY_CREATOR") && GRGetIsArcaneClass(spInfo.iSpellCastClass)) {
                    switch(spInfo.iSpellID) {
                        case SPELL_ACID_FOG:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_ACID_FOG;
                            bDamaging = TRUE;
                            break;
                        case SPELL_ACID_SPLASH:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_ACID_SPLASH;
                            bDamaging = TRUE;
                            break;
                        case SPELL_BALAGARNSIRONHORN:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_BALAGARNSIRONHORN;
                            bDamaging = TRUE;
                            break;
                        case SPELL_BALL_LIGHTNING:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_BALL_LIGHTNING;
                            bDamaging = TRUE;
                            break;
                        case SPELL_BANISHMENT:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_BANISHMENT;
                            bDamaging = TRUE;
                            break;
                        case SPELL_BOMBARDMENT:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_BOMBARDMENT;
                            bDamaging = TRUE;
                            break;
                        case SPELL_CHAIN_LIGHTNING:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_CHAIN_LIGHTNING;
                            bDamaging = TRUE;
                            break;
                        case SPELL_CLOUDKILL:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_CLOUDKILL;
                            bDamaging = TRUE;
                            break;
                        case SPELL_CONFUSION:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_CONFUSION;
                            bDamaging = TRUE;
                            break;
                        case SPELL_DARKNESS:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_DARKNESS;
                            bDamaging = TRUE;
                            break;
                        case SPELL_DISPEL_MAGIC:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_DISPEL_MAGIC;
                            bDamaging = TRUE;
                            break;
                        case SPELL_EVARDS_BLACK_TENTACLES:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_EVARDS_BLACK_TENTACLES;
                            bDamaging = TRUE;
                            break;
                        case SPELL_FEAR:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_FEAR;
                            bDamaging = TRUE;
                            break;
                        case SPELL_FIREBALL:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_FIREBALL;
                            bDamaging = TRUE;
                            break;
                        case SPELL_FIREBRAND:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_FIREBRAND;
                            bDamaging = TRUE;
                            break;
                        case SPELL_GEDLEES_ELECTRIC_LOOP:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_GEDLEES_ELECTRIC_LOOP;
                            bDamaging = TRUE;
                            break;
                        case SPELL_GREASE:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_GREASE;
                            bDamaging = TRUE;
                            break;
                        case SPELL_GREAT_THUNDERCLAP:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_GREAT_THUNDERCLAP;
                            bDamaging = TRUE;
                            break;
                        case SPELL_GUST_OF_WIND:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_GUST_OF_WIND;
                            bDamaging = TRUE;
                            break;
                        case SPELL_HORIZIKAULS_BOOM:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_HORIZIKAULS_BOOM;
                            bDamaging = TRUE;
                            break;
                        case SPELL_HORRID_WILTING:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_HORRID_WILTING;
                            bDamaging = TRUE;
                            break;
                        case SPELL_ICE_STORM:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_ICE_STORM;
                            bDamaging = TRUE;
                            break;
                        case SPELL_INCENDIARY_CLOUD:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_INCENDIARY_CLOUD;
                            bDamaging = TRUE;
                            break;
                        case SPELL_ISAACS_GREATER_MISSILE_STORM:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_ISAACS_GREATER_MISSILE_STORM;
                            bDamaging = TRUE;
                            break;
                        case SPELL_ISAACS_LESSER_MISSILE_STORM:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_ISAACS_LESSER_MISSILE_STORM;
                            bDamaging = TRUE;
                            break;
                        case SPELL_LIGHT:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_LIGHT;
                            break;
                        case SPELL_LIGHTNING_BOLT:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_LIGHTNING_BOLT;
                            bDamaging = TRUE;
                            break;
                        case SPELL_MASS_CHARM: //Mass charm monster
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_MASS_CHARM;
                            bDamaging = TRUE;
                            break;
                        case SPELL_MESTILS_ACID_BREATH:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_MESTILS_ACID_BREATH;
                            bDamaging = TRUE;
                            break;
                        case SPELL_METEOR_SWARM:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_METEOR_SWARM;
                            bDamaging = TRUE;
                            break;
                        case SPELL_MIND_FOG:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_MIND_FOG;
                            bDamaging = TRUE;
                            break;
                        case SPELL_NEGATIVE_ENERGY_BURST:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_NEGATIVE_ENERGY_BURST;
                            bDamaging = TRUE;
                            break;
                        case SPELL_POWER_WORD_KILL:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_POWER_WORD_KILL;
                            bDamaging = TRUE;
                            break;
                        case SPELL_POWER_WORD_STUN:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_POWER_WORD_STUN;
                            bDamaging = TRUE;
                            break;
                        case SPELL_SCARE:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_SCARE;
                            bDamaging = TRUE;
                            break;
                        case SPELL_SCINTILLATING_SPHERE:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_SCINTILLATING_SPHERE;
                            bDamaging = TRUE;
                            break;
                        case SPELL_SILENCE:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_SILENCE;
                            bDamaging = TRUE;
                            break;
                        case SPELL_SLEEP:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_SLEEP;
                            bDamaging = TRUE;
                            break;
                        case SPELL_SLOW:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_SLOW;
                            bDamaging = TRUE;
                            break;
                        case SPELL_SOUND_BURST:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_SOUND_BURST;
                            bDamaging = TRUE;
                            break;
                        case SPELL_STINKING_CLOUD:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_STINKING_CLOUD;
                            bDamaging = TRUE;
                            break;
                        case SPELL_SUNBURST:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_SUNBURST;
                            bDamaging = TRUE;
                            break;
                        case SPELL_UNDEATH_TO_DEATH:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_UNDEATH_TO_DEATH;
                            bDamaging = TRUE;
                            break;
                        case SPELL_WAIL_OF_THE_BANSHEE:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_WAIL_OF_THE_BANSHEE;
                            bDamaging = TRUE;
                            break;
                        case SPELL_WALL_OF_FIRE:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_WALL_OF_FIRE;
                            bDamaging = TRUE;
                            break;
                        case SPELL_WEB:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_WEB;
                            bDamaging = TRUE;
                            break;
                        case SPELL_WOUNDING_WHISPERS:
                            iIPOnHitConst = IP_CONST_ONHIT_CASTSPELL_WOUNDING_WHISPERS;
                            bDamaging = TRUE;
                            break;
                        default:
                            SendMessageToPC(oPC, GetStringByStrRef(16939240));
                            break;
                    }
                } else if(oPC!=GetLocalObject(oItem, "GR_MY_CREATOR")) {
                    SendMessageToPC(oPC, GetStringByStrRef(16939241));
                } else if(!GRGetIsArcaneClass(spInfo.iSpellCastClass)) {
                    SendMessageToPC(oPC, GetStringByStrRef(16939242));
                }

                //*:* Change the following line from X2_EXECUTE_SCRIPT_CONTINUE to
                //*:* X2_EXECUTE_SCRIPT_END if you want to prevent the spell that was
                //*:* cast on the item from taking effect
                iResult = X2_EXECUTE_SCRIPT_END;
            }
            break;
    }

    //*:* Pass the return value back to the calling script
    SetExecutedScriptReturnValue(iResult);
}
//*:**************************************************************************
//*:**************************************************************************
