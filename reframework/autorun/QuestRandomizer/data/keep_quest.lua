---@class KeepQuest : Quest

local m = require("QuestRandomizer.util.ref.methods")
local quest_base = require("QuestRandomizer.data.quest_base")
local s = require("QuestRandomizer.util.ref.singletons")
local util_misc = require("QuestRandomizer.util.misc.init")
local util_ref = require("QuestRandomizer.util.ref.init")

---@class KeepQuest
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = quest_base })

---@param index integer
---@param ts integer
---@return KeepQuest?
function this:new(index, ts)
    local o = quest_base.new(self, index)

    if not o then
        return
    end

    setmetatable(o, self)
    ---@cast o KeepQuest

    o.key = this.make_key(index, ts)
    o.type = quest_base.enum_type.KEEP
    return o
end

---@protected
---@return app.cKeepQuestData
function this:_get_quest_data()
    local user_save = s.get("app.SaveDataManager"):getCurrentUserSaveData()
    local quests = user_save:get_Quest()
    local quest_param = quests:get_Item(self.quest_id)
    return m.convertSaveData2KeepQuest(quest_param)
end

---@param keep_quest app.cKeepQuestData
---@return System.Array<app.savedata.cItemWork>
function this:get_ex_rewards(keep_quest)
    if keep_quest:get_IsSpOffer() then
        return keep_quest:getSpOfferRewardList()
    end

    return keep_quest:getExEmRewardList()
end

---@return app.cActiveQuestData
function this:get_active_quest_data()
    if self.quest_data then
        return self.quest_data
    end

    local quest_data = self:_get_quest_data()
    local ret = util_ref.ctor("app.cActiveQuestData", true)
    ret:call(".ctor(app.cKeepQuestData)", quest_data)
    ret:add_ref()

    self.quest_data = ret
    return ret
end

---@param quest app.cActiveQuestData
---@return string
function this.make_key_from_quest(quest)
    local keep_data = quest:get_KeepQuestData()
    local index = keep_data:get_Index()
    local ts = keep_data:get_CreatedDate()
    return this.make_key(index, ts)
end

---@param index integer
---@param ts integer
---@return string
function this.make_key(index, ts)
    return string.format("KEEP_%s_%s", index, util_misc.to_base36(ts))
end

return this
