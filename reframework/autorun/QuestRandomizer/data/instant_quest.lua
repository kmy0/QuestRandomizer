---@class InstantQuest : KeepQuest
---@field stage app.FieldDef.STAGE

local keep_quest = require("QuestRandomizer.data.keep_quest")
local m = require("QuestRandomizer.util.ref.methods")
local quest_base = require("QuestRandomizer.data.quest_base")
local s = require("QuestRandomizer.util.ref.singletons")
local util_game = require("QuestRandomizer.util.game.init")

---@class InstantQuest
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = keep_quest })

---@param index integer
---@param stage app.FieldDef.STAGE
---@return InstantQuest?
function this:new(index, stage)
    self.stage = stage
    local o = keep_quest.new(self, index, 0)

    if not o then
        return
    end

    setmetatable(o, self)
    ---@cast o InstantQuest

    o.stage = stage
    o.key = this.make_key(index, stage)
    o.type = quest_base.enum_type.INSTANT

    return o
end

---@protected
---@return app.cExFieldEvent_PopEnemy
function this:_get_quest_data()
    return s.get("app.EnvironmentManager"):call(
        "getExEventFromUniqueIdx(System.Int32, app.FieldDef.STAGE)",
        self.quest_id,
        self.stage
    )
end

---@param keep_quest app.cKeepQuestData
---@return integer
function this:get_time_remain(keep_quest)
    local ret = math.huge

    local ids = keep_quest:get_TatgetExUniqueIdxArray()
    util_game.do_something(ids, function(_, _, value)
        local event = s.get("app.EnvironmentManager"):call(
            "getExEventFromUniqueIdx(System.Int32, app.FieldDef.STAGE)",
            value,
            self.stage
        )
        ret = math.min(ret, m.getExEmRemainSec(event, false))
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

    self.quest_data = m.createActiveQuestData_InstantPopEnemy(quest_data, self.stage)
    return self.quest_data
end

---@param quest app.cActiveQuestData
---@return string
function this.make_key_from_quest(quest)
    local keep_data = quest:get_KeepQuestData()
    local index = keep_data:get_ExSpawnUniqueIndex()
    local stage = quest:getStage()
    return this.make_key(index, stage)
end

---@param index integer
---@param stage app.FieldDef.STAGE
---@return string
function this.make_key(index, stage)
    return string.format("FIELD_%s_%s", stage, index)
end

return this
