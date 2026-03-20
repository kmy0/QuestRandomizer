local data = require("QuestRandomizer.data.init")
local util_mod = require("QuestRandomizer.util.mod.init")
local util_randomizer = require("QuestRandomizer.quest_randomizer.util")

local mod = data.mod

local this = {}

function this.post(...)
    util_randomizer.request_mod_action(mod.enum.mod_action.POST)
end

function this.randomize(...)
    util_randomizer.request_mod_action(mod.enum.mod_action.ROLL)
end

function this.retry_quest(...)
    util_mod.retry_quest()
end

return this
