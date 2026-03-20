---@class Randomizer
---@field filtered Quest[]

local config = require("QuestRandomizer.config.init")
local data = require("QuestRandomizer.data.init")
local quest_base = require("QuestRandomizer.data.quest_base")
local util_mod = require("QuestRandomizer.util.mod.init")
local util_table = require("QuestRandomizer.util.misc.table")

local ace_map = data.ace.map
local mod_map = data.mod.map

---@class Randomizer
local this = {
    filtered = {},
}
---@enum FilterType
this.filter_type = {
    NORMAL = 1,
    KEEP = 2,
    INSTANT = 3,
}

local type_map = {
    [this.filter_type.NORMAL] = quest_base.enum_type.NORMAL,
    [this.filter_type.KEEP] = quest_base.enum_type.KEEP,
    [this.filter_type.INSTANT] = quest_base.enum_type.INSTANT,
}

---@param filter_type FilterType?
function this.filter_quests(filter_type)
    ---@param quest Quest
    ---@return boolean
    local function predicate(quest)
        if not filter_type then
            return true
        end

        return quest.type == type_map[filter_type]
    end

    if not filter_type then
        this.filtered = {}
    else
        ---@type Quest[]
        local temp = {}
        for _, quest in pairs(this.filtered) do
            if not predicate(quest) then
                table.insert(temp, quest)
            end
        end

        this.filtered = temp
    end

    local config_mod = config.current.mod

    mod_map.custom_quest_list:with_dump(function()
        ---@diagnostic disable-next-line: invisible
        for k in pairs(mod_map.custom_quest_list._map) do
            if not ace_map.quests[k] then
                mod_map.custom_quest_list:set(k, nil)
            end
        end
    end)

    local quest_filter =
        util_mod.make_quest_filter(mod_map.posted_quests, mod_map.custom_quest_list)
    for _, quest in pairs(ace_map.quests) do
        if config_mod.use_custom_list and not mod_map.custom_quest_list:get(quest.key) then
            goto continue
        end

        if predicate(quest) and util_mod.predicate_quest(quest, quest_filter) then
            table.insert(this.filtered, quest)
        end

        ::continue::
    end
end

---@return Quest?
function this.get_quest()
    local quest_prefer = util_mod.make_quest_prefer()

    if
        ---@diagnostic disable-next-line: no-unknown
        util_table.any(quest_prefer, function(_, value)
            return value ~= nil and value ~= false
        end)
    then
        ---@type table<number, Quest[]>
        local scores = {}
        for _, quest in pairs(this.filtered) do
            local score = util_mod.get_prefer_score(quest, quest_prefer)
            util_table.insert_nested_value(scores, { score }, quest)
        end

        local key = math.max(table.unpack(util_table.keys(scores)))
        return util_table.pick_random_value(scores[key])
    end

    return util_table.pick_random_value(this.filtered)
end

---@return string?
function this.roll()
    local quest = this.get_quest()
    if not quest then
        return
    end

    return quest.key
end

return this
