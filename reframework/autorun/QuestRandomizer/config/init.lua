---@class MainConfig : ConfigBase
---@field current MainSettings
---@field default MainSettings
---
---@field lang Language
---@field gui GuiConfig
---
---@field version string
---@field commit string
---@field name string
---
---@field posted_quests_path string
---@field custom_quest_list_path string
---
---@field min_ignore_all integer
---@field weight_current_stage number
---@field weight_spoffer number
---@field weight_item_wishlist number
---@field weight_item_rare number
---@field weight_item_judge number
---@field weight_boost number
---@field weight_expire number
---@field expire_step number

local config_base = require("QuestRandomizer.util.misc.config_base")
local lang = require("QuestRandomizer.config.lang")
local util_misc = require("QuestRandomizer.util.misc.init")
local util_table = require("QuestRandomizer.util.misc.table")
local version = require("QuestRandomizer.config.version")

local mod_name = "QuestRandomizer"
local config_path = util_misc.join_paths(mod_name, "config.json")

---@class MainConfig
local this = config_base:new(require("QuestRandomizer.config.defaults.mod"), config_path)

this.version = version.version
this.commit = version.commit
this.name = mod_name

this.posted_quests_path = util_misc.join_paths(this.name, "data", "posted_quests.json")
this.custom_quest_list_path = util_misc.join_paths(this.name, "data", "custom_quest_list.json")

this.min_ignore_all = 5
this.weight_expire = 1
this.weight_current_stage = 2
this.weight_boost = 4
this.weight_spoffer = 8
this.weight_item_judge = 16
this.weight_item_rare = 32
this.weight_item_wishlist = 64
this.expire_step = 300

this.gui = config_base:new(
    require("QuestRandomizer.config.defaults.gui"),
    util_misc.join_paths(this.name, "other_configs", "gui.json")
) --[[@as GuiConfig]]
this.lang = lang:new(
    require("QuestRandomizer.config.defaults.lang"),
    util_misc.join_paths(this.name, "lang"),
    "en-us.json",
    this
)

function this:load()
    local loaded_config = json.load_file(self.path) --[[@as MainSettings?]]
    if loaded_config then
        self.current = util_table.merge_t(self.default, loaded_config)
    else
        self.current = util_table.deep_copy(self.default)
        self:save_no_timer()
    end
end

---@return boolean
function this.init()
    this:load()
    this.gui:load()
    this.lang:load()

    return true
end

return this
