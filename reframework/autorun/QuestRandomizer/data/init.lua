local this = {
    ace = require("QuestRandomizer.data.ace"),
    mod = require("QuestRandomizer.data.mod"),
}

local battlefield_quest = require("QuestRandomizer.data.battlefield_quest")
local e = require("QuestRandomizer.util.game.enum")
local game_lang = require("QuestRandomizer.util.game.lang")
local instant_quest = require("QuestRandomizer.data.instant_quest")
local keep_quest = require("QuestRandomizer.data.keep_quest")
local m = require("QuestRandomizer.util.ref.methods")
local quest_base = require("QuestRandomizer.data.quest_base")
local s = require("QuestRandomizer.util.ref.singletons")
local spoffer_quest = require("QuestRandomizer.data.spoffer_quest")
local util_game = require("QuestRandomizer.util.game.init")
local util_misc = require("QuestRandomizer.util.misc.init")
local util_ref = require("QuestRandomizer.util.ref.init")
local util_table = require("QuestRandomizer.util.misc.table")

local ace_map = this.ace.map
local mod_enum = this.mod.enum

---@return app.ItemDef.ID[], app.ItemDef.ID[]
local function make_items()
    ---@type app.ItemDef.ID[]
    local judge_items = {}
    ---@type app.ItemDef.ID[]
    local special_items = {}

    for _, item_id in e.iter("app.ItemDef.ID") do
        local item_data = m.getItemData(item_id)

        if not item_data or not m.isValidItem(item_id) or not item_data:get_Special() then
            goto continue
        end

        local guid = item_data:get_RawName()
        local name_english = game_lang.get_message_local(guid, 1)

        if name_english:len() == 0 then
            goto continue
        end

        table.insert(special_items, item_id)
        ::continue::
    end

    local setting = s.get("app.VariousDataManager"):get_Setting()
    local exrewards = setting:get_ExQuestRewardSetting()

    util_game.do_something(exrewards._ArtianRewardTbl, function(_, _, value)
        table.insert(judge_items, value:get_RewardItem())
    end)

    util_game.do_something(exrewards._AmuletRewardTbl, function(_, _, value)
        table.insert(judge_items, value:get_RewardItem())
    end)

    util_game.do_something(exrewards._SkillGemRewardTbl, function(_, _, value)
        table.insert(judge_items, value:get_RewardItem())
    end)

    util_game.do_something(exrewards._ExjudgeEmRewardArray, function(_, _, value)
        table.insert(judge_items, value:get_ItemID())
    end)

    return util_table.sort(judge_items), util_table.sort(special_items)
end

---@return app.FieldDef.STAGE[]
local function make_maps()
    ---@type app.FieldDef.STAGE[]
    local ret = {}
    -- 10 = Rimechain Peak, 11 = Dragontorch Shrine, 13 = Forgotten Machineworks
    local non_main_stages = { 10, 11, 13 }
    for _, stage in e.iter("app.FieldDef.STAGE") do
        if
            m.isMainStage(stage)
            or m.isArenaStage(stage)
            or util_table.contains(non_main_stages, stage)
        then
            table.insert(ret, stage)
        end
    end

    return util_table.sort(ret)
end

---@return app.EnemyDef.ID[], table<app.EnemyDef.ID, app.EnemyDef.SPECIES>
local function make_monsters()
    ---@type app.EnemyDef.ID[]
    local ret = {}
    ---@type table<app.EnemyDef.ID, app.EnemyDef.SPECIES>
    local ret2 = {}
    for _, em_id in e.iter("app.EnemyDef.ID") do
        -- 33 = High Purrformance Barrel Puncher
        if em_id ~= 33 and m.isEmValid(em_id) and m.isBossID(em_id) then
            local species_fixed = m.getEmSpecies(em_id)
            local species = e.to_enum("app.EnemyDef.SPECIES", species_fixed)

            table.insert(ret, em_id)
            ret2[em_id] = species
        end
    end

    return util_table.sort(ret), ret2
end

---@return app.EnemyDef.SPECIES[]
local function make_species()
    ---@type app.EnemyDef.SPECIES[]
    local ret = {}
    local all_species = util_table.values(ace_map.monster_to_species)
    for _, species in e.iter("app.EnemyDef.SPECIES") do
        -- 20 = ??? omega
        if species ~= 20 and util_table.contains(all_species, species) then
            table.insert(ret, species)
        end
    end

    return util_table.sort(ret)
end

---@return app.EnvironmentType.ENVIRONMENT[]
local function make_environ()
    ---@type app.EnemyDef.SPECIES[]
    local ret = {}
    for _, environ in e.iter("app.EnvironmentType.ENVIRONMENT") do
        table.insert(ret, environ)
    end

    return util_table.sort(ret)
end

---@return {[app.FieldDef.STAGE]: {[AreaId]: {CampId: integer}}}?
local function make_SmartCampPicker_data()
    if not util_misc.mod_exists("smart_camp_picker") then
        return
    end

    local SmartCampPicker_config = json.load_file("SmartCampPicker/config.json") or {}
    if not SmartCampPicker_config.enabled then
        return
    end

    ---@type {[app.FieldDef.STAGE]: {[AreaId]: {CampId: integer}}}?
    local ret = {}
    util_misc.try(function()
        ---@cast ret {[app.FieldDef.STAGE]: {[AreaId]: {CampId: integer}}}
        for _, stage in e.iter("app.FieldDef.STAGE") do
            local stage_data = json.load_file(
                string.format("SmartCampPicker/navmesh_distances/stage_%s.json", stage)
            )

            if stage_data then
                ---@cast stage_data {areas: {[string]: {distances: {[string]: integer}}}}
                for area, values in pairs(stage_data.areas) do
                    for camp_id, dist in pairs(values.distances) do
                        util_table.set_nested_value(
                            ret,
                            { stage, tonumber(area), tonumber(camp_id) },
                            dist
                        )
                    end
                end
            end
        end
    end, function(_)
        ret = nil
    end)

    return ret
end

local function make_base_quest_data()
    ---@type {[string]: Quest}
    local ret = {}
    for _, quest_id in e.iter("app.MissionIDList.ID") do
        local quest = quest_base:new(quest_id)

        if not quest then
            goto continue
        end

        ret[quest.key] = quest
        ::continue::
    end

    return ret
end

local function make_keep_quest_data()
    ---@type {[string]: Quest}
    local ret = {}
    local user_save = s.get("app.SaveDataManager"):getCurrentUserSaveData()

    util_game.do_something(user_save:get_Quest(), function(_, index, value)
        if value.RemainingNum < 0 then
            return
        end

        local quest = keep_quest:new(index, value.CreatedDate)
        if not quest then
            return
        end

        ret[quest.key] = quest
    end)

    return ret
end

local function make_instant_quest_data()
    ---@type {[string]: Quest}
    local ret = {}
    local env_man = s.get("app.EnvironmentManager")

    if not env_man:get_IsExploringMyExField() then
        return ret
    end

    for _, stage in pairs(ace_map.maps) do
        local sp_offers = env_man:getSpOfferInfoList(stage)
        local battlefields = env_man:getBattlefieldInfoList(stage)
        local ems = env_man:findExecutedPopEmsInMyExField(stage, true)

        util_game.do_something(ems, function(_, _, value)
            local quest = instant_quest:new(value:get_UniqueIndex(), stage)
            if not quest then
                return
            end

            ret[quest.key] = quest
        end)

        if battlefields then
            util_game.do_something(battlefields, function(_, _, value)
                local event = value:get_BattlefieldEvent()
                local quest = battlefield_quest:new(event:get_UniqueIndex(), stage)
                if not quest then
                    return
                end

                ret[quest.key] = quest
            end)
        end

        if sp_offers then
            util_game.do_something(sp_offers, function(_, _, value)
                local quest = spoffer_quest:new(value:get_SpOfferUniqueIdx(), stage)
                if not quest then
                    return
                end

                ret[quest.key] = quest
            end)
        end
    end

    return ret
end

---@return integer[]
local function make_ranks()
    ---@type integer[]
    local ret = {}
    for _, rank in e.iter("app.QuestDef.EM_REWARD_RANK") do
        table.insert(ret, rank)
    end

    return util_table.sort(ret)
end

---@return integer[]
local function make_grades()
    local max_grade = util_ref.types.get("app.EnemyDef"):get_field("MaxRewardGrade"):get_data() --[[@as integer]]
    ---@type integer[]
    local ret = {}
    for i = 1, max_grade do
        table.insert(ret, i)
    end

    return util_table.sort(ret)
end

---@return table<QuestType, app.MissionTypeList.TYPE[]>
local function make_mod_quest_type_to_quest_type()
    local e_quest = e.get("app.MissionTypeList.TYPE")

    ---@type table<QuestType, app.MissionTypeList.TYPE[]>
    local ret = {
        [mod_enum.quest_type.MISSION] = { e_quest.MAINSTORY, e_quest.SIDESTORY, e_quest.TUTORIAL },
        [mod_enum.quest_type.KEEP] = { e_quest.KEEPQUEST },
        [mod_enum.quest_type.FREE] = { e_quest.FREEQUEST },
        [mod_enum.quest_type.EVENT] = { e_quest.STREAM_EVENTQUEST, e_quest.STREAM_CHALLENGEQUEST },
        [mod_enum.quest_type.CHALLENGE] = { e_quest.TA_FREEQUEST },
        [mod_enum.quest_type.ARENA] = { e_quest.TOURNAMENTQUEST },
        [mod_enum.quest_type.INSTANT] = { e_quest.INSTANTQUEST },
    }

    return ret
end

---@return app.QuestDef.QUEST_TARGET[]
local function make_quest_target()
    local e_tar = e.get("app.QuestDef.QUEST_TARGET")
    local ret = {
        e_tar.EM_BOSS_HUNTING,
        e_tar.EM_BOSS_KILL,
        e_tar.EM_BOSS_CAPTURE,
        e_tar.EM_BOSS_REMAIN_HP,
        e_tar.ITEM,
    }
    return util_table.sort(ret)
end

---@return integer[]
local function make_attempts()
    local mission_setting = s.get("app.MissionManager"):get_MissionSetting()
    local quest_setting = mission_setting:get_QuestSetting()
    local max = quest_setting:get_KeepQuestAcceptableMax()
    ---@type integer[]
    local ret = {}

    for i = 1, max do
        table.insert(ret, i)
    end

    return ret
end

function this.reload_quest_data()
    s.get("app.MissionManager"):reflectStreamQuestListCache()
    ace_map.quests = util_table.shallow_merge(
        make_base_quest_data(),
        make_keep_quest_data(),
        make_instant_quest_data()
    )
end

function this.reload_instant_quest_data()
    for k, v in pairs(ace_map.quests) do
        if v.type == quest_base.enum_type.INSTANT then
            ace_map.quests[k] = nil
        end
    end

    ace_map.quests = util_table.shallow_merge(ace_map.quests, make_instant_quest_data())
end

function this.reload_keep_quest_data()
    for k, v in pairs(ace_map.quests) do
        if v.type == quest_base.enum_type.KEEP then
            ace_map.quests[k] = nil
        end
    end

    ace_map.quests = util_table.shallow_merge(ace_map.quests, make_keep_quest_data())
end

---@param stage app.FieldDef.STAGE
---@param areas AreaId[]
---@param camp_ids CampId[]
---@return {[CampId]: integer}?
function this.get_camp_distances(stage, areas, camp_ids)
    if not ace_map.SmartCampPicker_data then
        return
    end

    ---@type {[CampId]: integer[]}
    local distances = {}
    for _, area in pairs(areas) do
        for _, camp_id in pairs(camp_ids) do
            local dist =
                util_table.get_nested_value(ace_map.SmartCampPicker_data, { stage, area, camp_id })
            if dist then
                util_table.insert_nested_value(distances, { camp_id }, dist)
            end
        end
    end

    if util_table.empty(distances) then
        return
    end

    ---@type {[CampId]: integer}
    local ret = {}
    for camp_id, dist in pairs(distances) do
        ret[camp_id] = math.min(table.unpack(dist))
    end

    return ret
end

---@param quest app.cActiveQuestData
---@return string
function this.make_quest_key(quest)
    local keep = quest:get_KeepQuestData()
    if keep then
        if quest:get_MissionType() ~= e.get("app.MissionTypeList.TYPE").INSTANTQUEST then
            return keep_quest.make_key_from_quest(quest)
        end

        if keep:get_IsSpOffer() then
            return spoffer_quest.make_key_from_quest(quest)
        elseif keep:get_BfExUniqueIndex() ~= -1 then
            return battlefield_quest.make_key_from_quest(quest)
        else
            return instant_quest.make_key_from_quest(quest)
        end
    end

    return quest_base.make_key_from_quest(quest)
end

function this.clear_quests()
    ace_map.quests = {}
end

---@return boolean
function this.init()
    if not s.get("app.VariousDataManager") then
        return false
    end

    if
        not e.wrap_init(function()
            e.new("ace.ACE_PAD_KEY.BITS")
            e.new("ace.ACE_MKB_KEY.INDEX")
            e.new("app.net_context_manager.cContextManager.CONTEXT_STATE")
            e.new("app.MissionTypeList.TYPE")
            e.new("app.QuestDef.QUEST_TARGET")
            e.new("app.EnemyDef.LEGENDARY_ID")
            e.new("app.cStartPointInfo.START_POINT_TYPE")
            e.new("app.GUI050000.QUEST_TYPE")
            e.new("app.GUIFlowQuestCounter.MODE")
            e.new("app.GUI060102.OPEN_FROM")
            e.new("app.GUI060102.OPEN_ANIMATION")
            e.new("app.net_session_manager.SESSION_TYPE")
        end)
    then
        return false
    end

    ace_map.SmartCampPicker_data = make_SmartCampPicker_data()
    ace_map.judge_items, ace_map.special_items = make_items()
    ace_map.monsters, ace_map.monster_to_species = make_monsters()
    ace_map.monster_species = make_species()
    ace_map.environ = make_environ()
    ace_map.maps = make_maps()
    ace_map.ranks = make_ranks()
    ace_map.grades = make_grades()
    ace_map.mod_quest_type_to_quest_type = make_mod_quest_type_to_quest_type()
    ace_map.quest_target = make_quest_target()
    ace_map.attempts = make_attempts()

    return true
end

return this
