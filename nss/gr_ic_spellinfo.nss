//********************************************************
// Fixes to misspelled constant names
//********************************************************
const int   VFX_IMP_REFLEX_SAVING_THROW_USE = VFX_IMP_REFLEX_SAVE_THROW_USE;

//********************************************************
// VFX Constants for EffectVisualEffect - Maps in Visualeffects.2da
//********************************************************
const int   VFX_DUR_GHOSTLY_IMAGE     =   9; //-- added in 1.69 (apparently not)
const int   VFX_BEAM_FLAME              =   444;
//const int   VFX_BEAM_DISINTEGRATE         =   447;  -- added in 1.69
const int   VFX_DUR_CONECOLD_HEAD       =   490;
//********************************************************
const int   VFX_DUR_FIRE_SHIELD_COLD    =   700;
const int   VFX_DUR_FIRE_SHIELD_HOT     =   701;
const int   VFX_FNF_PWBLIND             =   702;
const int   VFX_DUR_ACID_STORM          =   703;
const int   VFX_DUR_BLACK_SMOKE         =   704;
const int   VFX_FNF_IGREDRAZZARS_MIASMA =   705;
const int   VFX_DUR_GLITTERDUST         =   706;
const int   VFX_IMP_GLITTERDUST         =   707;
const int   VFX_DUR_FORCEWARD           =   708;
const int   VFX_FNF_LEECH_FIELD         =   709;
const int   VFX_FNF_ANTILIFE            =   710;
//********************************************************


//********************************************************
// POLYMORPH_TYPE CONSTANTS - MAPS INTO POLYMORPH.2DA
//********************************************************
const int   POLYMORPH_TYPE_MIMIC                    = 79;
const int   POLYMORPH_TYPE_BOY                      = 80;
const int   POLYMORPH_TYPE_GIRL                     = 81;
const int   POLYMORPH_TYPE_LIZARDFOLK               = 82;
const int   POLYMORPH_TYPE_KOBOLD_ASSASSIN          = 83;
const int   POLYMORPH_TYPE_WISP                     = 84;
const int   POLYMORPH_TYPE_AZER_BOSS_MALE           = 85;
const int   POLYMORPH_TYPE_AZER_BOSS_FEMALE         = 86;
const int   POLYMORPH_TYPE_DEATHSLAAD               = 87;
const int   POLYMORPH_TYPE_RAKSHASA_MALE            = 88;
const int   POLYMORPH_TYPE_RAKSHASA_FEMALE          = 89;
//const int   POLYMORPH_TYPE_IRON_GOLEM             = 90; -- IN NWSCRIPT.NSS
const int   POLYMORPH_TYPE_STONE_GOLEM              = 91;
const int   POLYMORPH_TYPE_DEMONFLESH_GOLEM         = 92;
const int   POLYMORPH_TYPE_MITHRAL_GOLEM            = 93;
const int   POLYMORPH_TYPE_MORPH_EARTH_ELEMENTAL    = 94;
const int   POLYMORPH_TYPE_BOAT                     = 95;
const int   POLYMORPH_TYPE_MINOTAUR_EPIC            = 96;
const int   POLYMORPH_TYPE_HARPY_EPIC               = 97;
const int   POLYMORPH_TYPE_GARGOYLE_EPIC            = 98;
const int   POLYMORPH_TYPE_BASILISK_EPIC            = 99;
const int   POLYMORPH_TYPE_DRIDER_EPIC              = 100;
const int   POLYMORPH_TYPE_MANTICORE_EPIC           = 101;
const int   POLYMORPH_TYPE_WINTER_WOLF              = 102;
const int   POLYMORPH_TYPE_KOBOLD_ASSASSIN_EPIC     = 103;
const int   POLYMORPH_TYPE_LIZARDFOLK_EPIC          = 104;
const int   POLYMORPH_TYPE_MALE_DROW_EPIC           = 105;
const int   POLYMORPH_TYPE_FEMALE_DROW_EPIC         = 106;
//********************************************************
const int   POLYMORPH_TYPE_BULETTE                  = 300;
const int   POLYMORPH_TYPE_HELLHOUND                = 301;
//********************************************************


//********************************************************
// SPELL SUBSCHOOL CONSTANTS
//********************************************************
const int   SPELL_SUBSCHOOL_GENERAL         = 0;
const int   SPELL_SUBSCHOOL_CREATION        = 1;
const int   SPELL_SUBSCHOOL_SUMMONING       = 2;
const int   SPELL_SUBSCHOOL_SCRYING         = 3;
const int   SPELL_SUBSCHOOL_GLAMER          = 4;
const int   SPELL_SUBSCHOOL_COMPULSION      = 5;
const int   SPELL_SUBSCHOOL_HEALING         = 6;
const int   SPELL_SUBSCHOOL_CHARM           = 7;
const int   SPELL_SUBSCHOOL_PATTERN         = 8;
const int   SPELL_SUBSCHOOL_SHADOW          = 9;
const int   SPELL_SUBSCHOOL_CALLING         = 10;
const int   SPELL_SUBSCHOOL_PHANTASM        = 11;
const int   SPELL_SUBSCHOOL_TELEPORTATION   = 12;
const int   SPELL_SUBSCHOOL_POLYMOPRH       = 13;
const int   SPELL_SUBSCHOOL_FIGMENT         = 14;

//********************************************************
// SPELL TYPE CONSTANTS
//********************************************************
const int   SPELL_TYPE_GENERAL              = 0;
const int   SPELL_TYPE_ALIGNMENT_SPECIFIC   = 1;
const int   SPELL_TYPE_CHAOTIC              = 2;
const int   SPELL_TYPE_EVIL                 = 3;
const int   SPELL_TYPE_GOOD                 = 4;
const int   SPELL_TYPE_LAWFUL               = 5;
const int   SPELL_TYPE_ACID                 = 6;
const int   SPELL_TYPE_COLD                 = 7;
const int   SPELL_TYPE_ELECTRICITY          = 8;
const int   SPELL_TYPE_FIRE                 = 9;
const int   SPELL_TYPE_SONIC                = 10;
const int   SPELL_TYPE_FORCE                = 11;
const int   SPELL_TYPE_FEAR                 = 12;
const int   SPELL_TYPE_MIND_AFFECTING       = 13;
const int   SPELL_TYPE_LANGUAGE             = 14;
const int   SPELL_TYPE_DARKNESS             = 15;
const int   SPELL_TYPE_LIGHT                = 16;
const int   SPELL_TYPE_DEATH                = 17;
const int   SPELL_TYPE_AIR                  = 18;
const int   SPELL_TYPE_EARTH                = 19;
const int   SPELL_TYPE_WATER                = 20;
const int   SPELL_TYPE_TELEPORTATION        = 21;

//********************************************************
// SPELL SAVE TYPE CONSTANTS
//********************************************************
const int   SPELL_SAVE_NONE     = 0;
const int   FORTITUDE_HALF      = 1;
const int   FORTITUDE_NEGATES   = 2;
const int   WILL_HALF           = 3;
const int   WILL_NEGATES        = 4;
const int   REFLEX_HALF         = 5;
const int   REFLEX_NEGATES      = 6;

//********************************************************
const int   SAVING_THROW_TYPE_SLEEP = 25;

//********************************************************
// SPELL SECONDARY DAMAGE CONSTANTS
//********************************************************
const int   SECDMG_TYPE_NONE        = 0;    // no secondary damage
const int   SECDMG_TYPE_HALF        = 1;    // half damage amount is sec dmg type
const int   SECDMG_TYPE_EQUAL       = 2;    // equal amount of sec dmg type on top of dmg amount
const int   SECDMG_TYPE_DICE        = 3;    // sec dmg type gets same die roll as initial dmg amount
const int   SECDMG_TYPE_OVERRIDE    = 4;    // use override amount instead

//********************************************************
// SPECIAL REQUIREMENT TYPES
//********************************************************
const int   SPECIAL_REQ_TYPE_NONE   = 0;
const int   SPECIAL_REQ_TYPE_LIVING = 1;
const int   SPECIAL_REQ_TYPE_UNDEAD = 2;
const int   SPECIAL_REQ_TYPE_SIZE   = 3;