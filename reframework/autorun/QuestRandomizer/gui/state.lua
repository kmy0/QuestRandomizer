---@class GuiState
---@field combo GuiCombo
---@field listener NewBindListener?

---@class (exact) GuiCombo
---@field monster Combo
---@field map Combo
---@field item Combo
---@field monster_species Combo
---@field monster_target Combo
---@field monster_state Combo
---@field environ Combo
---@field action Combo
---@field rank Combo
---@field monster_grade Combo
---@field type Combo
---@field quest_target Combo
---@field attempts Combo

---@class (exact) NewBindListener
---@field opt string
---@field opt_name string
---@field listener BindListener
---@field collision string?

local combo = require("QuestRandomizer.util.imgui.combo")
local config = require("QuestRandomizer.config.init")
local data = require("QuestRandomizer.data.init")
local e = require("QuestRandomizer.util.game.enum")
local game_lang = require("QuestRandomizer.util.game.lang")
local m = require("QuestRandomizer.util.ref.methods")
local util_ref = require("QuestRandomizer.util.ref.init")
local util_table = require("QuestRandomizer.util.misc.table")

local ace_map = data.ace.map
local mod = data.mod

---@class GuiState
local this = {
    combo = {
        monster = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local guid = m.getEnemyNameGuid(tonumber(key) --[[@as app.EnemyDef.ID]])
                return game_lang.get_message_local2(guid)
            end
        ),
        map = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local guid = util_ref.value_type("System.Guid")
                m.getStageNameGuid(tonumber(key) --[[@as app.FieldDef.STAGE]], guid:address())
                return game_lang.get_message_local2(guid)
            end
        ),
        item = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local guid = m.getItemNameGuid(tonumber(key) --[[@as app.ItemDef.ID]])
                return game_lang.get_message_local2(guid)
            end
        ),
        monster_species = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local species_data = m.getSpeciesData(tonumber(key) --[[@as app.EnemyDef.SPECIES]])
                local guid = species_data:get_EmSpeciesName()
                return game_lang.get_message_local2(guid)
            end
        ),
        monster_target = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local name = util_table.reverse_lookup(mod.enum.monster_target, tonumber(key))
                return config.lang:tr("mod.combo_ignore_monster_target." .. name)
            end
        ),
        monster_state = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local name = util_table.reverse_lookup(mod.enum.monster_state, tonumber(key))
                return config.lang:tr("mod.combo_ignore_monster_state." .. name)
            end
        ),
        environ = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local environ = tonumber(key) --[[@as app.EnvironmentType.ENVIRONMENT]]
                local name = e.get("app.EnvironmentType.ENVIRONMENT")[environ]
                return config.lang:tr("mod.combo_ignore_environ." .. name)
            end
        ),
        action = combo:new(
            mod.map.actions,
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr(mod.map.actions[key])
            end
        ),
        rank = combo:new(
            nil,
            function(a, b)
                return tonumber(a.key) < tonumber(b.key)
            end,
            nil,
            function(key)
                return key .. config.lang:tr("misc.text_star")
            end
        ),
        monster_grade = combo:new(
            nil,
            function(a, b)
                return tonumber(a.key) < tonumber(b.key)
            end,
            nil,
            function(key)
                return key .. config.lang:tr("misc.text_diamond")
            end
        ),
        type = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local name = util_table.reverse_lookup(mod.enum.quest_type, tonumber(key))
                return config.lang:tr("mod.combo_ignore_quest_type." .. name)
            end
        ),
        quest_target = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local val = tonumber(key) --[[@as app.QuestDef.QUEST_TARGET]]
                local name = e.get("app.QuestDef.QUEST_TARGET")[val]
                return config.lang:tr("mod.combo_ignore_quest_target." .. name)
            end
        ),
        attempts = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local val = tonumber(key)
                return string.format(
                    config.lang:tr("mod.text_attempts_left"),
                    key,
                    val == 1 and config.lang:tr("misc.text_attempt")
                        or config.lang:tr("misc.text_attempt_plural")
                )
            end
        ),
    },
}

function this.translate_combo()
    for _, c in
        pairs(this.combo --[[@as table<string, Combo>]])
    do
        c:translate()
    end
end

function this.clear_disabled_items()
    for _, c in
        pairs(this.combo --[[@as table<string, Combo>]])
    do
        c:enable_all_items()
    end
end

function this.init()
    local config_mod = config.current.mod

    this.combo.monster:swap(
        util_table.map_array(ace_map.monsters),
        nil,
        util_table.keys(config_mod.monster)
    )
    this.combo.map:swap(util_table.map_array(ace_map.maps), nil, util_table.keys(config_mod.map))
    this.combo.item:swap(util_table.map_array(ace_map.judge_items))
    this.combo.monster_species:swap(
        util_table.map_array(ace_map.monster_species),
        nil,
        util_table.keys(config_mod.monster_species)
    )
    this.combo.monster_target:swap(
        util_table.map_array(mod.enum.monster_target),
        nil,
        util_table.keys(config_mod.monster_target)
    )
    this.combo.monster_state:swap(
        util_table.map_array(mod.enum.monster_state),
        nil,
        util_table.keys(config_mod.monster_state)
    )
    this.combo.environ:swap(
        util_table.map_array(ace_map.environ),
        nil,
        util_table.keys(config_mod.environ)
    )
    this.combo.rank:swap(util_table.map_array(ace_map.ranks), nil, util_table.keys(config_mod.rank))
    this.combo.monster_grade:swap(
        util_table.map_array(ace_map.grades),
        nil,
        util_table.keys(config_mod.monster_grade)
    )
    this.combo.type:swap(
        util_table.map_array(util_table.values(mod.enum.quest_type)),
        nil,
        util_table.keys(config_mod.type)
    )
    this.combo.quest_target:swap(
        util_table.map_array(ace_map.quest_target),
        nil,
        util_table.keys(config_mod.quest_target)
    )
    this.combo.attempts:swap(
        util_table.map_array(ace_map.attempts),
        nil,
        util_table.keys(config_mod.attempts)
    )

    this.translate_combo()
end

return this
