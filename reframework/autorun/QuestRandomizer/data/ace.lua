---@class (exact) AceData
---@field map AceMap

---@class (exact) AceMap
---@field SmartCampPicker_data {[app.FieldDef.STAGE]: {[AreaId]: {CampId: integer}}}?
---@field quests table<string, Quest>
---@field maps app.FieldDef.STAGE[]
---@field judge_items app.ItemDef.ID[]
---@field special_items app.ItemDef.ID[]
---@field monsters app.EnemyDef.ID[]
---@field ranks integer[]
---@field grades integer[]
---@field monster_to_species table<app.EnemyDef.ID, app.EnemyDef.SPECIES>
---@field monster_species app.EnemyDef.SPECIES[]
---@field environ app.EnvironmentType.ENVIRONMENT[]
---@field mod_quest_type_to_quest_type table<QuestType, app.MissionTypeList.TYPE[]>
---@field quest_target app.QuestDef.QUEST_TARGET[]
---@field max_time integer
---@field attempts integer[]

---@alias AreaId integer
---@alias CampId integer

---@class AceData
local this = {
    map = {
        quests = {},
        monster_species = {},
        environ = {},
        multiplay_setting = {},
        ranks = {},
        grades = {},
        monster_to_species = {},
        maps = {},
        judge_items = {},
        special_items = {},
        monsters = {},
        mod_quest_type_to_quest_type = {},
        quest_target = {},
        max_time = 50,
        attempts = {},
    },
}
return this
