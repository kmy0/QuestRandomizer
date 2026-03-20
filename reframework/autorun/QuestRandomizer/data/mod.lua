---@class ModData
---@field map ModMap
---@field enum ModEnum
---@field in_quest boolean
---@field quest_reload QuestReload
---@field mod_action ModAction
---@field initialized boolean

---@class (exact) ModMap
---@field colors {good: integer, bad: integer, info: integer, blue: integer, bg: integer}
---@field actions table<string, string>
---@field custom_quest_list SimpleJsonCache
---@field posted_quests SimpleJsonCache

---@class (exact) ModEnum
---@field quest_start QuestStartType.*
---@field monster_state MonsterState.*
---@field monster_target MonsterTarget.*
---@field quest_type QuestType.*
---@field quest_reload QuestReload.*
---@field mod_action ModAction.*

---@class (exact) QuestFilter
---@field time_limit integer?
---@field rank table<integer, boolean>?
---@field map table<app.FieldDef.STAGE, boolean>?
---@field monster_target table<MonsterTarget, boolean>?
---@field monster_state table<string, boolean>?
---@field monster_species table<app.EnemyDef.SPECIES, boolean>?
---@field monster table<app.EnemyDef.ID, boolean>?
---@field monster_grade table<integer, boolean>?
---@field type table<app.MissionTypeList.TYPE, boolean>?
---@field environ table<app.EnvironmentType.ENVIRONMENT, boolean>?
---@field attempts table<integer, boolean>?
---@field posted SimpleJsonCache?
---@field custom_quest_list SimpleJsonCache?
---@field quest_target table<app.QuestDef.QUEST_TARGET, boolean>?
---@field boost boolean
---@field item_wishlist boolean
---@field item_wishlist_any boolean
---@field item_rare boolean
---@field item_judge app.ItemDef.ID?
---@field spoffer boolean
---@field stage app.FieldDef.STAGE?
---@field completed boolean
---@field non_acceptable boolean

---@class (exact) QuestPrefer : QuestFilter
---@field spoffer boolean
---@field stage app.FieldDef.STAGE?
---@field item_wishlist boolean
---@field item_wishlist_any boolean
---@field item_rare boolean
---@field item_judge app.ItemDef.ID?
---@field boost boolean
---@field prefer_expiring_soon boolean
---@field completed nil
---@field non_acceptable nil

local config = require("QuestRandomizer.config.init")
local simple_json_cache = require("QuestRandomizer.util.misc.simple_json_cache")

---@class ModData
local this = {
    ---@diagnostic disable-next-line: missing-fields
    enum = {},
    map = {
        colors = {
            bad = 0xff1947ff,
            good = 0xff47ff59,
            info = 0xff27f3f5,
            blue = 0xff905c34,
            bg = 0xff1c1b1a,
        },
        actions = {
            post = "mod.button_post",
            randomize = "mod.button_randomize",
            retry_quest = "mod.button_retry",
        },
        custom_quest_list = simple_json_cache:new(config.custom_quest_list_path),
        posted_quests = simple_json_cache:new(config.posted_quests_path),
    },
    initialized = false,
    in_quest = false,
    ---@diagnostic disable-next-line: assign-type-mismatch
    mod_action = 0,
    ---@diagnostic disable-next-line: assign-type-mismatch
    quest_reload = 0,
}

---@enum QuestStartType
this.enum.quest_start = { ---@class QuestStartType.* : {[string]: integer}
    PICK = 1,
    START_AND_DEPART = 2,
    START_AND_PREP = 3,
}
---@enum MonsterState
this.enum.monster_state = { ---@class MonsterState.* : {[string]: integer}
    NONE = 1,
    NORMAL = 2,
    KING = 3,
    FRENZY = 4,
}
---@enum MonsterTarget
this.enum.monster_target = { ---@class MonsterTarget.* : {[string]: integer}
    SMALL = 1,
    SINGLE = 2,
    MULTI = 3,
}
---@enum QuestType
this.enum.quest_type = { ---@class QuestType.* : {[string]: integer}
    MISSION = 1,
    KEEP = 2,
    FREE = 3,
    EVENT = 4,
    ARENA = 5,
    CHALLENGE = 6,
    INSTANT = 7,
}
---@enum QuestReload
this.enum.quest_reload = { ---@class QuestReload.* : {[string]: integer}
    NONE = 0,
    INSTANT = 1 << 0,
    KEEP = 1 << 1,
    NORMAL = 1 << 2,
    FULL = (1 << 0) | (1 << 1) | (1 << 2),
}
---@enum ModAction
this.enum.mod_action = { ---@class ModAction.* : {[string]: integer}
    NONE = 0,
    ROLL = 1 << 0,
    POST = 1 << 1,
    FILTER = 1 << 2,
}

---@return boolean
function this.init()
    this.map.custom_quest_list:init()
    this.map.posted_quests:init()
    this.initialized = true
    return true
end

return this
