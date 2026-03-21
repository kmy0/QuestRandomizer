local config = require("QuestRandomizer.config.init")
local data = require("QuestRandomizer.data.init")
local quest_base = require("QuestRandomizer.data.quest_base")
local quest_reference = require("QuestRandomizer.quest_randomizer.quest_reference")
local randomizer = require("QuestRandomizer.quest_randomizer.randomizer")
local s = require("QuestRandomizer.util.ref.singletons")
local util_mod = require("QuestRandomizer.util.mod.init")
local util_table = require("QuestRandomizer.util.misc.table")

local ace_map = data.ace.map
local mod = data.mod
local R = mod.enum.quest_reload
local A = mod.enum.mod_action

local this = {}

---@param filter_type FilterType?
function this.filter_quests(filter_type)
    randomizer.filter_quests(filter_type)
    quest_reference.mark_dirty()
end

function this.clear_all()
    mod.mod_action = A.NONE
    mod.quest_reload = R.NONE
    mod.in_quest = false
    data.clear_quests()
    this.filter_quests()
end

---@param reload_type QuestReload
function this.request_quest_reload(reload_type)
    mod.quest_reload = mod.quest_reload | reload_type
end

---@param action_type ModAction
function this.request_mod_action(action_type)
    -- reload just in case
    this.request_quest_reload(R.INSTANT)
    if action_type == A.POST and config.current.mod.auto_randomize then
        mod.mod_action = mod.mod_action | A.ROLL
    end
    mod.mod_action = mod.mod_action | action_type
end

function this.do_reload_quest_data()
    if mod.quest_reload == R.NONE then
        return
    end

    if mod.quest_reload & R.FULL == R.FULL then
        mod.quest_reload = R.NONE
        data.reload_quest_data()
        this.clear_cache()
        this.filter_quests()
        return
    end

    -- unused
    if mod.quest_reload & R.NORMAL == R.NORMAL then
        mod.quest_reload = mod.quest_reload & ~R.NORMAL
    end

    if mod.quest_reload & R.INSTANT == R.INSTANT then
        mod.quest_reload = mod.quest_reload & ~R.INSTANT
        data.reload_instant_quest_data()
        this.filter_quests(randomizer.filter_type.INSTANT)
    end

    if mod.quest_reload & R.KEEP == R.KEEP then
        mod.quest_reload = mod.quest_reload & ~R.KEEP
        data.reload_keep_quest_data()
        this.clear_cache()
        this.filter_quests(randomizer.filter_type.KEEP)
    end
end

function this.do_mod_action()
    if mod.mod_action == A.NONE then
        return
    end

    if mod.mod_action & A.FILTER == A.FILTER then
        mod.mod_action = mod.mod_action & ~A.FILTER
        this.filter_quests()
    end

    if mod.mod_action & A.ROLL == A.ROLL then
        mod.mod_action = mod.mod_action & ~A.ROLL
        config.current.mod.quest_id = randomizer.roll() or ""
    end

    if mod.mod_action & A.POST == A.POST then
        mod.mod_action = mod.mod_action & ~A.POST
        if not s.get("app.MissionManager"):get_IsActiveQuest() then
            local config_mod = config.current.mod
            local quest = ace_map.quests[config_mod.quest_id]

            if quest then
                util_mod.post_quest(quest, config_mod.quest_start_type)
                if quest.type ~= quest_base.enum_type.INSTANT then
                    mod.map.posted_quests:set(quest.key, true)
                end
            elseif util_table.empty(ace_map.quests) then
                util_mod.send_message(config.lang:tr("mod.text_no_quest"))
            else
                util_mod.send_message(config.lang:tr("mod.text_invalid_quest"))
            end
        end
    end
end
function this.clear_cache()
    mod.map.custom_quest_list:with_dump(function()
        ---@diagnostic disable-next-line: invisible
        for k in pairs(mod.map.custom_quest_list._map) do
            if not ace_map.quests[k] then
                mod.map.custom_quest_list:set(k, nil)
            end
        end
    end)

    mod.map.posted_quests:with_dump(function()
        ---@diagnostic disable-next-line: invisible
        for k in pairs(mod.map.posted_quests._map) do
            if not ace_map.quests[k] then
                mod.map.posted_quests:set(k, nil)
            end
        end
    end)
end

return this
