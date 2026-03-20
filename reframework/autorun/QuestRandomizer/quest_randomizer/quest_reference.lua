local config = require("QuestRandomizer.config.init")
local data = require("QuestRandomizer.data.init")
local randomizer = require("QuestRandomizer.quest_randomizer.randomizer")

local ace_map = data.ace.map
local mod_map = data.mod.map

local this = {
    ---@type Quest[]?
    items = nil,
    changed = true,
}

function this.mark_dirty()
    this.changed = true
end

function this.filter()
    if not this.changed then
        return
    end

    local config_mod = config.current.mod
    this.changed = false
    this.items = {}

    local t = {}
    if config_mod.filter_quest_reference then
        t = randomizer.filtered
    elseif config_mod.use_custom_list then
        for k, v in pairs(ace_map.quests) do
            if mod_map.custom_quest_list:get(k) then
                table.insert(t, v)
            end
        end
    else
        t = ace_map.quests
    end

    local query = config_mod.quest_ref_query:lower()

    for _, quest in pairs(t) do
        local name = quest.title:lower()
        if query == "" or name:find(query) ~= nil then
            table.insert(this.items, quest)
        end
    end

    table.sort(this.items, function(a, b)
        local a_no = tonumber(a.key)
        local b_no = tonumber(b.key)
        if a_no and b_no then
            return a_no < b_no
        elseif not a_no and not b_no then
            return a.quest_id < b.quest_id
        end

        return a.key < b.key
    end)
end

return this
