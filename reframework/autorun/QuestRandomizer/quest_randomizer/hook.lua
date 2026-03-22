local config = require("QuestRandomizer.config.init")
local data = require("QuestRandomizer.data.init")
local m = require("QuestRandomizer.util.ref.methods")
local s = require("QuestRandomizer.util.ref.singletons")
local util_mod = require("QuestRandomizer.util.mod.init")
local util_randomizer = require("QuestRandomizer.quest_randomizer.util")

local mod = data.mod
local mod_enum = mod.enum

local this = {}

---@param f fun(...): any
---@return fun(...): any
local function wrapper(f)
    return function(...)
        if not config.current.mod.enabled then
            return
        end

        return f(...)
    end
end

local function reload_hook(flag)
    return wrapper(function()
        util_randomizer.request_quest_reload(flag)
    end)
end

---@return boolean
local function is_returned_quest()
    local misman = s.get("app.MissionManager")
    if not mod.in_quest then
        local quest_director = misman:get_QuestDirector()
        if quest_director:isPlayingQuest() then
            mod.in_quest = true
        end
    elseif not misman:get_IsActiveQuest() and m.canOpenStartMenu(false) then
        mod.in_quest = false
        return true
    end

    return false
end

function this.update(_)
    if not util_randomizer.update_ok() then
        return
    end

    if is_returned_quest() then
        util_randomizer.request_quest_reload(mod_enum.quest_reload.FULL)

        if config.current.mod.auto_post then
            util_randomizer.request_mod_action(mod_enum.mod_action.POST)
        end
    end

    util_randomizer.do_reload_quest_data()
    util_randomizer.do_mod_action()
end

function this.accept_quest_pre(args)
    local quest = sdk.to_managed_object(args[3]) --[[@as app.cActiveQuestData]]
    if quest:get_KeepQuestData() and not util_mod.is_quest_host() then
        return
    end

    config.current.mod.quest_id = data.make_quest_key(quest)
end

function this.update_50001_pre(args)
    if mod.flag_decide then
        local o = sdk.to_managed_object(args[2]) --[[@as app.GUI050001_AcceptList]]
        local select_item = mod.flag_decide == mod_enum.quest_start.START_AND_PREP
                and o._MenuItem_AcceptAndPreparing
            or o._MenuItem_AcceptAndStart
        local input_ctrl = o._InputCtrl
        local fluent_link = input_ctrl._FicLink
        local index = o:getItemIndex(select_item)

        fluent_link:set_SelectedItemIndex(index)
        o:callbackDecide(fluent_link, select_item, index)

        mod.flag_decide = nil
    end
end

this.reload_keep_quest_data = reload_hook(mod_enum.quest_reload.KEEP)
this.reload_quest_data = reload_hook(mod_enum.quest_reload.FULL)
this.clear_quest_data = wrapper(util_randomizer.clear_all)
this.update = wrapper(this.update)
this.accept_quest_pre = wrapper(this.accept_quest_pre)
this.update_50001_pre = wrapper(this.update_50001_pre)

return this
