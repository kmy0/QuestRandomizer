local data = require("QuestRandomizer.data.init")
local util_mod = require("QuestRandomizer.util.mod.init")
local util_randomizer = require("QuestRandomizer.quest_randomizer.util")

local mod = data.mod

local this = {}

function this.post(...)
    if util_randomizer.post_ok() then
        util_randomizer.request_mod_action(mod.enum.mod_action.POST)
    end
end

function this.randomize(...)
    if util_randomizer.rand_ok() then
        util_randomizer.request_mod_action(mod.enum.mod_action.ROLL)
    end
end

function this.retry_quest(...)
    util_mod.retry_quest()
end

return this
