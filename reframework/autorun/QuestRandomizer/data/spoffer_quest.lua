---@class SpOfferQuest : InstantQuest

local instant_quest = require("QuestRandomizer.data.instant_quest")
local m = require("QuestRandomizer.util.ref.methods")
local s = require("QuestRandomizer.util.ref.singletons")
local util_game = require("QuestRandomizer.util.game.init")

---@class SpOfferQuest
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = instant_quest })

---@param index integer
---@param stage app.FieldDef.STAGE
---@return SpOfferQuest?
function this:new(index, stage)
    local o = instant_quest.new(self, index, stage)

    if not o then
        return
    end

    setmetatable(o, self)
    ---@cast o SpOfferQuest

    return o
end

---@protected
---@return app.cExSpOfferInfo_forView
function this:_get_quest_data()
    ---@type app.cExSpOfferInfo_forView
    local ret
    local sp_offers = s.get("app.EnvironmentManager"):getSpOfferInfoList(self.stage)

    util_game.do_something(sp_offers, function(_, _, value)
        if value:get_SpOfferUniqueIdx() == self.quest_id then
            ret = value
            return false
        end
    end)

    return ret
end

---@return app.cActiveQuestData
function this:get_active_quest_data()
    if self.quest_data then
        return self.quest_data
    end

    local quest_data = self:_get_quest_data()
    if not quest_data then
        ---@diagnostic disable-next-line: missing-return-value
        return
    end

    self.quest_data = m.createActiveQuestData_InstantSpOffer(quest_data)
    return self.quest_data
end

---@param quest app.cActiveQuestData
---@return string
function this.make_key_from_quest(quest)
    local keep_data = quest:get_KeepQuestData()
    local spoffer = keep_data:getSpOfferInfo()
    local index = spoffer:get_UniqueIndex()
    local stage = quest:getStage()
    return this.make_key(index, stage)
end

return this
