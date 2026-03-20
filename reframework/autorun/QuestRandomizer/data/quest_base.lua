---@class Quest
---@field key string
---@field quest_id integer
---@field stage_name string
---@field level integer
---@field title string
---@field type QuestDataType
---@field targets MonsterQuestTarget[]?
---@field quest_data app.cActiveQuestData?

---@class (exact) MonsterQuestTarget
---@field em app.EnemyDef.ID
---@field role app.EnemyDef.ROLE_ID
---@field legendary app.EnemyDef.LEGENDARY_ID
---@field grade System.Int32

local game_lang = require("QuestRandomizer.util.game.lang")
local m = require("QuestRandomizer.util.ref.methods")
local s = require("QuestRandomizer.util.ref.singletons")
local util_game = require("QuestRandomizer.util.game.init")
local util_ref = require("QuestRandomizer.util.ref.init")

---@class Quest
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@enum QuestDataType
this.enum_type = {
    NORMAL = 1,
    KEEP = 2,
    INSTANT = 3,
}
local int32 = util_ref.value_type("System.Int32")

---@param quest_id app.MissionIDList.ID
---@return Quest?
function this:new(quest_id)
    local o = { quest_id = quest_id }
    setmetatable(o, self)
    ---@cast o Quest

    local active_quest_data = o:get_active_quest_data()
    if not active_quest_data then
        return
    end

    local stage = active_quest_data:getStage()
    local title_msg = active_quest_data:get_TitleText()
    local title_str = m.createQuestTitleMessage(title_msg)
    local guid_stage_name = util_ref.value_type("System.Guid")

    m.getStageNameGuid(stage, guid_stage_name:address())

    o.key = this.make_key(quest_id)
    o.title = game_lang.replace_tags(title_str)
    o.level = active_quest_data:getQuestLv()
    o.stage_name = game_lang.get_message_local2(guid_stage_name)
    o.type = this.enum_type.NORMAL

    return o
end

---@protected
---@return app.user_data.QuestData
function this:_get_quest_data()
    return s.get("app.MissionManager"):getQuestData(self.quest_id)
end

---@return app.QuestDef.RANK
function this:get_quest_rank()
    local quest_data = self:get_active_quest_data()
    quest_data:getQuestRank(int32:address())
    ---@diagnostic disable-next-line: undefined-field
    return int32.m_value
end

---@return MonsterQuestTarget[]
function this:get_targets()
    if not self.targets then
        self.targets = {}
        local quest_data = self:get_active_quest_data()
        local monsters = quest_data:getTargetEmId()
        local grades = quest_data:getTargetEmDifficulityGrade()
        local legs = quest_data:getTargetEmLegendaryId()
        local roles = quest_data:getTargetEmRoleId()

        util_game.do_something(monsters, function(_, index, value)
            table.insert(self.targets, {
                em = value,
                role = roles:get_Item(index),
                grade = grades:get_Item(index),
                legendary = legs:get_Item(index),
            })
        end)
    end

    return self.targets
end

---@return app.cActiveQuestData
function this:get_active_quest_data()
    if self.quest_data then
        return self.quest_data
    end

    local stream_data = s.get("app.MissionManager"):getStreamQuestDataFromID(self.quest_id)
    if stream_data and not stream_data:isEnable() then
        ---@diagnostic disable-next-line: missing-return-value
        return
    end

    local quest_data = self:_get_quest_data()
    if not quest_data then
        ---@diagnostic disable-next-line: missing-return-value
        return
    end

    local ret = util_ref.ctor("app.cActiveQuestData", true)
    local is_recommended = false
    ret:call(".ctor(app.user_data.QuestData, System.Boolean)", quest_data, is_recommended)
    ret:add_ref()

    self.quest_data = ret
    return ret
end

---@param quest app.cActiveQuestData
---@return string
function this.make_key_from_quest(quest)
    return this.make_key(quest:get_MissionId())
end

---@param quest_id app.MissionIDList.ID
function this.make_key(quest_id)
    return tostring(quest_id)
end

return this
