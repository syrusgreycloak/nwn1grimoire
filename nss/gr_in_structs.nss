//*:**************************************************************************
//*:*  GR_IN_STRUCTS.NSS
//*:**************************************************************************
//*:*
//*:* Structs to be used by various functions
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: August 19, 2019
//*:**************************************************************************

//*:**************************************************************************
//*:* class_info
//*:**************************************************************************
//*:* Contains class type information of an object
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:**************************************************************************
struct class_info {
    //*:* Base classes
    int bBarbarian;
    int bBard;
    int bCleric;
    int bDruid;
    int bFighter;
    int bMonk;
    int bPaladin;
    int bRanger;
    int bRogue;
    int bSorcerer;
    int bWizard;
    //*:* Monster/NPC Classes
    int bAberration;
    int bAnimal;
    int bConstruct;
    int bHumanoid;
    int bMonstrous;
    int bElemental;
    int bFey;
    int bDragon;
    int bUndead;
    int bCommoner;
    int bBeast;
    int bGiant;
    int bMagicBeast;
    int bOutsider;
    int bShapechanger;
    int bVermin;
    int bOoze;
    //*:* Prestige Classes
    int bShadowdancer;
    int bHarper;
    int bArcaneArcher;
    int bAssassin;
    int bBlackguard;
    int bDivChamp;
    int bWeaponmaster;
    int bPaleMaster;
    int bShifter;
    int bDwarvenDefender;
    int bDragonDisciple;
    int bPurpleDragKnt;
    //*:* Other info
    int iCastingLevels;
    int iFightingLevels;
    int iBestSaveType;
};

//*:**************************************************************************
//*:* SpellStruct
//*:**************************************************************************
//*:* Contains spell information about a spell being cast
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:**************************************************************************
struct SpellStruct {
    object  oCaster;            // caster of the spell
    int     iSpellID;           // spell id from spells.2da
    int     iSpellSchool;       // spell school - read from spells.2da
    int     iSpellSubschool;    // spell subschool - read from spells.2da
    int     iSpellType1;        // 1st spell descriptor - read from spells.2da
    int     iSpellType2;        // 2nd spell descriptor - read from spells.2da
    int     iSpellType3;        // 3rd spell descriptor - read from spells.2da
    int     iUnderwater;        // allowed to be cast underwater - read from spells.2da
    int     iTurnable;          // spell can be turned - read from spells.2da
    int     iPlayerSpell;       // spell is player spell (type 1) - read from spells.2da
    int     iReqConcentration;  // spell requires concentration - read from spells.2da
    int     iSpellLevel;        // level of the spell - read from spells.2da
    int     iSpellCastClass;    // class used to cast spell
    int     iCasterLevel;       // caster level used to cast spell
    int     iMetamagic;         // metamagic used to cast spell
    int     iDC;                // spell DC for saves
    object  oTarget;            // current target
    location lTarget;           // current target location
    int     iDurAmount;         // amount of iDurType for duration
    int     iDurType;           // type (rounds/turns/etc) for duration
    float   fDurOverride;       // set duration amount - overrides iDurAmount of iDurType (for spellhook)
    float   fDmgChangePct;      // change spell damage by percentage (for spellhook)
    int     iDmgDieType;        // damage die type
    int     iDmgNumDice;        // number of damage dice
    int     iDmgBonus;          // additional bonus damage after dietype*numdice
    int     iDmgOverride;       // fixed amount of damage if no dice to roll
    int     iSecDmgType;        // DAMAGE_TYPE_* for secondary damage
    int     iSecDmgAmountType;  // SECDMG_TYPE_*
    int     iSecDmgOverride;    // set amount of damage if others do not apply
    int     iXPCost;            // xp cost for casting spell - read from spells.2da
    int     bEpicSpell;         // boolean denoting epic spell
    int     iEpicSpellcraftDC;  // DC for Spellcraft check
    int     bDmgSaveMade;       // DamageSave made
    int     bNWN2;              // Game version
};

