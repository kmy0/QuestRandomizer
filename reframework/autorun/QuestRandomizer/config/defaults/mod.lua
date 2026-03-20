---@class (exact) MainSettings : SettingsBase
---@field version string
---@field mod ModSettings

---@class (exact) ModLanguage
---@field file string
---@field fallback boolean

---@class (exact) ModSettings
---@field enabled boolean
---@field quest_id string
---@field filter_quest_reference boolean
---@field use_custom_list boolean
---@field auto_post boolean
---@field auto_randomize boolean
---@field quest_start_type integer -- QuestStartType
---@field quest_ref_query string
---@field lang ModLanguage
---@field ignore_posted boolean
---@field ignore_completed boolean
---@field ignore_non_acceptable boolean
---@field ignore_attempts boolean
---@field ignore_time_limit boolean
---@field ignore_rank boolean
---@field ignore_monster boolean
---@field slider_time_limit integer
---@field ignore_monster_species boolean
---@field ignore_monster_state boolean
---@field ignore_monster_target boolean
---@field ignore_monster_grade boolean
---@field ignore_quest_target boolean
---@field ignore_map boolean
---@field ignore_type boolean
---@field ignore_environ boolean
---@field ignore_custom_list boolean
---@field require_item_wishlist CheckboxTri
---@field require_item_judge CheckboxTri
---@field require_item_rare CheckboxTri
---@field require_item_wishlist_any CheckboxTri
---@field require_boost CheckboxTri
---@field require_spoffer CheckboxTri
---@field require_current_stage CheckboxTri
---@field prefer_expiring_soon boolean
---@field combo_ignore_monster integer
---@field combo_ignore_map integer
---@field combo_item_judge integer
---@field combo_ignore_type integer
---@field combo_ignore_rank integer
---@field combo_ignore_monster_species integer
---@field combo_ignore_monster_target integer
---@field combo_ignore_monster_state integer
---@field combo_ignore_environ integer
---@field combo_ignore_attempts integer
---@field combo_ignore_quest_target integer
---@field combo_ignore_monster_grade integer
---@field monster table<string, integer>
---@field monster_species table<string, integer>
---@field monster_target table<string, integer>
---@field monster_state table<string, integer>
---@field map table<string, integer>
---@field type table<string, integer>
---@field environ table<string, integer>
---@field rank table<string, integer>
---@field monster_grade table<string, integer>
---@field quest_target table<string, integer>
---@field attempts table<string, integer>
---@field bind {
---     action: BindBase[],
---     buffer: integer,
---     combo_action: integer,
--- }

local version = require("QuestRandomizer.config.version")

---@type MainSettings
return {
    version = version.version,
    mod = {
        lang = {
            file = "en-us",
            fallback = true,
        },
        use_custom_list = false,
        quest_id = "",
        quest_ref_query = "",
        filter_quest_reference = true,
        quest_start_type = 1,
        auto_randomize = false,
        enabled = true,
        ignore_posted = false,
        ignore_completed = false,
        ignore_non_acceptable = false,
        ignore_attempts = false,
        ignore_time_limit = false,
        ignore_rank = false,
        ignore_map = false,
        ignore_monster = false,
        ignore_monster_state = false,
        ignore_monster_target = false,
        ignore_monster_species = false,
        ignore_monster_grade = false,
        ignore_type = false,
        ignore_quest_target = false,
        ignore_environ = false,
        ignore_custom_list = false,
        prefer_expiring_soon = false,
        require_item_wishlist = 1,
        require_item_wishlist_any = 1,
        require_item_judge = 1,
        require_item_rare = 1,
        require_boost = 1,
        require_current_stage = 1,
        require_spoffer = 1,
        auto_post = false,
        slider_time_limit = 1,
        combo_ignore_monster = 1,
        combo_ignore_map = 1,
        combo_item_judge = 1,
        combo_ignore_type = 1,
        combo_ignore_attempts = 1,
        combo_ignore_quest_target = 1,
        combo_ignore_monster_species = 1,
        combo_ignore_monster_state = 1,
        combo_ignore_monster_target = 1,
        combo_ignore_environ = 1,
        combo_ignore_monster_grade = 1,
        combo_ignore_rank = 1,
        monster = {},
        map = {},
        type = {},
        monster_species = {},
        monster_target = {},
        monster_state = {},
        environ = {},
        rank = {},
        monster_grade = {},
        quest_target = {},
        attempts = {},
        bind = {
            action = {},
            buffer = 2,
            combo_action = 1,
        },
    },
}
