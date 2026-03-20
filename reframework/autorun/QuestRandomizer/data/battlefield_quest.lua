---@class BattlefieldQuest : InstantQuest

local instant_quest = require("QuestRandomizer.data.instant_quest")
local s = require("QuestRandomizer.util.ref.singletons")
local util_game = require("QuestRandomizer.util.game.init")
local util_ref = require("QuestRandomizer.util.ref.init")

---@class BattlefieldQuest
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = instant_quest })

---@param index integer
---@param stage app.FieldDef.STAGE
---@return BattlefieldQuest?
function this:new(index, stage)
    local o = instant_quest.new(self, index, stage)

    if not o then
        return
    end

    setmetatable(o, self)
    ---@cast o BattlefieldQuest

    return o
end

---@protected
---@return app.cKeepQuestData
function this:_get_quest_data()
    ---@type app.cKeepQuestData
    local ret
    local bfs = s.get("app.EnvironmentManager"):getBattlefieldInfoList(self.stage)

    util_game.do_something(bfs, function(_, _, value)
        local event = value:get_BattlefieldEvent()
        if event:get_UniqueIndex() == self.quest_id then
            ret = value:get_KeepQuestData()
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

    local ret = util_ref.ctor("app.cActiveQuestData", true)
    ret:add_ref()
    ret:call(".ctor(app.cKeepQuestData)", quest_data)

    self.quest_data = ret
    return ret
end

---@param quest app.cActiveQuestData
---@return string
function this.make_key_from_quest(quest)
    local keep_data = quest:get_KeepQuestData()
    local index = keep_data:get_BfExUniqueIndex()
    local stage = keep_data:get_BfBelongingStage()
    return this.make_key(index, stage)
end

return this
