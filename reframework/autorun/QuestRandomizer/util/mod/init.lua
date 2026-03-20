local checkbox_tri = require("QuestRandomizer.util.imgui.checkbox_tri")
local config = require("QuestRandomizer.config.init")
local data = require("QuestRandomizer.data.init")
local e = require("QuestRandomizer.util.game.enum")
local m = require("QuestRandomizer.util.ref.methods")
local s = require("QuestRandomizer.util.ref.singletons")
local state = require("QuestRandomizer.gui.state")
local util_game = require("QuestRandomizer.util.game.init")
local util_ref = require("QuestRandomizer.util.ref.init")
local util_table = require("QuestRandomizer.util.misc.table")

local ace_map = data.ace.map
local mod_enum = data.mod.enum

local this = {}
local int32 = util_ref.value_type("System.Int32")

---@param quest Quest
---@param ex_rewards System.Array<app.savedata.cItemWork>?
function this.any_wishlisted_items(quest, ex_rewards)
    local any_wishlist = false
    local quest_data = quest:get_active_quest_data()
    local quest_rank = quest:get_quest_rank()
    local quest_level = quest_data:getQuestLv()
    local quest_id = quest_data:get_MissionId()

    for _, target in pairs(quest:get_targets()) do
        if ex_rewards then
            any_wishlist = m.isExQuestRequiredForWishlist(
                ex_rewards,
                target.em,
                target.role,
                target.legendary,
                quest_rank,
                quest_level,
                true
            )
        else
            any_wishlist = any_wishlist
                or m.isQuestRequiredForWishlist(quest_id, quest_rank)
                or m.isEnemyRequiredForWishlist(target.em, quest_rank)
        end

        if any_wishlist then
            return true
        end
    end
end

---@param quest Quest
---@param quest_filter QuestFilter
---@return boolean
function this.any_excluded_monster(quest, quest_filter)
    for _, target in pairs(quest:get_targets()) do
        local grade_match = quest_filter.monster_grade and quest_filter.monster_grade[target.grade]
        local id_match = quest_filter.monster and quest_filter.monster[target.em]
        local species_match = quest_filter.monster_species
            and quest_filter.monster_species[ace_map.monster_to_species[target.em]]
        local state_match = false

        if quest_filter.monster_state then
            local leg = e.get("app.EnemyDef.LEGENDARY_ID")[target.legendary]
            local role = e.get("app.EnemyDef.ROLE_ID")[target.role]
            state_match = quest_filter.monster_state[leg]
                or (role ~= "NORMAL" and quest_filter.monster_state[role])
        end

        if grade_match or id_match or species_match or state_match then
            return true
        end
    end
    return false
end

---@param posted_quests SimpleJsonCache
---@param custom_quest_list SimpleJsonCache
---@return QuestFilter
function this.make_quest_filter(posted_quests, custom_quest_list)
    local config_mod = config.current.mod
    ---@type table<app.MissionTypeList.TYPE, boolean>?
    local quest_type

    if config_mod.ignore_type then
        quest_type = {}
        for e_string, _ in pairs(config_mod.type) do
            local e_enum = tonumber(e_string) --[[@as QuestType]]
            for _, mission_type in pairs(ace_map.mod_quest_type_to_quest_type[e_enum]) do
                quest_type[mission_type] = true
            end
        end
    end

    ---@type QuestFilter
    return {
        time_limit = config_mod.ignore_time_limit and config_mod.slider_time_limit or nil,
        rank = config_mod.ignore_rank and util_table.map_table(config_mod.rank, function(o)
            return tonumber(o)
        end) or nil,
        map = config_mod.ignore_map and util_table.map_table(config_mod.map, function(o)
            return tonumber(o)
        end) or nil,
        environ = config_mod.ignore_environ
                and util_table.map_table(config_mod.environ, function(o)
                    return tonumber(o)
                end)
            or nil,
        monster_target = config_mod.ignore_monster_target
                and util_table.map_table(config_mod.monster_target, function(o)
                    return tonumber(o)
                end)
            or nil,
        monster_state = config_mod.ignore_monster_state
                and util_table.map_table(config_mod.monster_state, function(o)
                    return util_table.reverse_lookup(mod_enum.monster_state, tonumber(o))
                end)
            or nil,
        monster = config_mod.ignore_monster
                and util_table.map_table(config_mod.monster, function(o)
                    return tonumber(o)
                end)
            or nil,
        monster_species = config_mod.ignore_monster_species
                and util_table.map_table(config_mod.monster_species, function(o)
                    return tonumber(o)
                end)
            or nil,
        monster_grade = config_mod.ignore_monster_grade
                and util_table.map_table(config_mod.monster_grade, function(o)
                    return tonumber(o)
                end)
            or nil,
        boost = config_mod.require_boost == checkbox_tri.state.ON,
        item_wishlist = config_mod.require_item_wishlist == checkbox_tri.state.ON,
        item_wishlist_any = config_mod.require_item_wishlist_any == checkbox_tri.state.ON,
        item_rare = config_mod.require_item_rare == checkbox_tri.state.ON,
        item_judge = config_mod.require_item_judge == checkbox_tri.state.ON and tonumber(
            state.combo.item:get_key(config_mod.combo_item_judge)
        ) or nil,
        spoffer = config_mod.require_spoffer == checkbox_tri.state.ON,
        stage = config_mod.require_current_stage == checkbox_tri.state.ON and s.get(
            "app.EnvironmentManager"
        ):get_ExCurrentStage() or nil,
        type = quest_type,
        quest_target = config_mod.ignore_quest_target
                and util_table.map_table(config_mod.quest_target, function(o)
                    return tonumber(o)
                end)
            or nil,
        attempts = config_mod.ignore_attempts
                and util_table.map_table(config_mod.attempts, function(o)
                    return tonumber(o)
                end)
            or nil,
        posted = config_mod.ignore_posted and posted_quests or nil,
        custom_quest_list = config_mod.ignore_custom_list and custom_quest_list or nil,
        completed = config_mod.ignore_completed,
        non_acceptable = config_mod.ignore_non_acceptable,
    }
end

---@return QuestPrefer
function this.make_quest_prefer()
    local config_mod = config.current.mod
    return {
        boost = config_mod.require_boost == checkbox_tri.state.MIXED,
        item_wishlist = config_mod.require_item_wishlist == checkbox_tri.state.MIXED,
        item_wishlist_any = config_mod.require_item_wishlist_any == checkbox_tri.state.MIXED,
        item_rare = config_mod.require_item_rare == checkbox_tri.state.MIXED,
        item_judge = config_mod.require_item_judge == checkbox_tri.state.MIXED and tonumber(
            state.combo.item:get_key(config_mod.combo_item_judge)
        ) or nil,
        spoffer = config_mod.require_spoffer == checkbox_tri.state.MIXED,
        stage = config_mod.require_current_stage == checkbox_tri.state.MIXED and s.get(
            "app.EnvironmentManager"
        ):get_ExCurrentStage() or nil,
        prefer_expiring_soon = config_mod.prefer_expiring_soon,
    }
end

---@param quest Quest
---@param quest_prefer QuestPrefer
---@return number
function this.get_prefer_score(quest, quest_prefer)
    local ret = 0
    local quest_data = quest:get_active_quest_data()

    if quest_prefer.stage and quest_data:getStage() == quest_prefer.stage then
        ret = ret + config.weight_current_stage
    end

    local investigation = quest_data:get_KeepQuestData()
    local ex_rewards = investigation ---@cast quest KeepQuest
        and quest:get_ex_rewards(investigation)
    local has_wishlisted_items = this.any_wishlisted()

    if
        quest_prefer.item_wishlist_any
        and has_wishlisted_items
        and this.any_wishlisted_items(quest, ex_rewards)
    then
        ret = ret + config.weight_item_wishlist
    end

    if investigation then
        if quest_prefer.boost and investigation:get_IsVillageBoost() then
            ret = ret + config.weight_boost
        end

        if quest_prefer.spoffer and investigation:get_IsSpOffer() then
            ret = ret + config.weight_spoffer
        end

        if
            quest_prefer.prefer_expiring_soon
            and e.get("app.MissionTypeList.TYPE").INSTANTQUEST == quest_data:get_MissionType()
        then
            ---@cast quest InstantQuest
            local time_left = quest:get_time_remain(investigation)
            local interval = math.floor(time_left / 300) + 1
            ret = ret + config.weight_expire / interval
        end

        local filter_wishlist = quest_prefer.item_wishlist and has_wishlisted_items
        if filter_wishlist or quest_prefer.item_rare or quest_prefer.item_judge then
            local any_wishlisted, any_judge, any_rare = false, false, false

            util_game.do_something(ex_rewards, function(_, _, value)
                local item = value:get_ItemId()

                if
                    not any_judge and (quest_prefer.item_judge and quest_prefer.item_judge == item)
                then
                    any_judge = true
                    ret = ret + config.weight_item_judge
                end

                if not any_wishlisted and (filter_wishlist and m.isItemWishlisted(item)) then
                    any_wishlisted = true
                    ret = ret + config.weight_item_wishlist
                end

                if
                    not any_rare
                    and (
                        quest_prefer.item_rare and util_table.contains(ace_map.special_items, item)
                    )
                then
                    any_rare = true
                    ret = ret + config.weight_item_rare
                end
            end)
        end
    end

    return ret
end

---@param quest Quest
---@param quest_filter QuestFilter
---@return boolean
function this.predicate_quest(quest, quest_filter)
    local quest_data = quest:get_active_quest_data()

    if quest_filter.posted and quest_filter.posted:get(quest.key) then
        return false
    end

    if quest_filter.custom_quest_list and quest_filter.custom_quest_list:get(quest.key) then
        return false
    end

    if quest_filter.non_acceptable and not m.checkAcceptable(int32:get_address(), quest_data) then
        return false
    end

    if quest_filter.completed and m.checkQuestClear(quest_data:get_MissionId()) then
        return false
    end

    if quest_filter.time_limit and quest_filter.time_limit > quest_data:getTimeLimit() then
        return false
    end

    if quest_filter.rank and quest_filter.rank[quest_data:getQuestLv()] then
        return false
    end

    if quest_filter.type and quest_filter.type[quest_data:get_MissionType()] then
        return false
    end

    if quest_filter.quest_target then
        local qt = quest_data:getQuestTarget()
        local ZAKO = e.get("app.QuestDef.QUEST_TARGET").EM_ZAKO_KILL
        local BOSS = e.get("app.QuestDef.QUEST_TARGET").EM_BOSS_KILL
        if quest_filter.quest_target[qt == ZAKO and BOSS or qt] then
            return false
        end
    end

    if
        (quest_filter.map and quest_filter.map[quest_data:getStage()])
        or (quest_filter.environ and quest_filter.environ[quest_data:getEnvironmentType()])
        ---@cast quest InstantQuest

        or (quest_filter.stage and (quest.stage or quest_data:getStage()) ~= quest_filter.stage)
    then
        return false
    end

    if quest_filter.monster_target then
        if
            quest_filter.monster_target[mod_enum.monster_target.SMALL]
            and quest_data:isTargetZako()
        then
            return false
        end
        local len = quest_data:getTargetEmId():get_Count()

        if
            (quest_filter.monster_target[mod_enum.monster_target.SINGLE] and len == 1)
            or (quest_filter.monster_target[mod_enum.monster_target.MULTI] and len > 1)
        then
            return false
        end
    end

    if
        (
            quest_filter.monster
            or quest_filter.monster_state
            or quest_filter.monster_species
            or quest_filter.monster_grade
        ) and this.any_excluded_monster(quest, quest_filter)
    then
        return false
    end

    local has_wishlisted_items = this.any_wishlisted()
    local investigation = quest_data:get_KeepQuestData()
    local ex_rewards = investigation ---@cast quest KeepQuest
        and quest:get_ex_rewards(investigation)

    if
        quest_filter.item_wishlist_any
        and has_wishlisted_items
        and not this.any_wishlisted_items(quest, ex_rewards)
    then
        return false
    end

    if investigation then
        if quest_filter.boost and not investigation:get_IsVillageBoost() then
            return false
        end

        if quest_filter.spoffer and not investigation:get_IsSpOffer() then
            return false
        end

        if
            quest_filter.attempts
            and e.get("app.MissionTypeList.TYPE").INSTANTQUEST ~= quest_data:get_MissionType()
        then
            if quest_filter.attempts[m.getKeepQuestRemain(investigation:get_Index())] then
                return false
            end
        end

        local filter_wishlist = quest_filter.item_wishlist and has_wishlisted_items
        if filter_wishlist or quest_filter.item_rare or quest_filter.item_judge then
            local any_wishlisted, any_judge, any_rare = false, false, false

            util_game.do_something(ex_rewards, function(_, _, value)
                local item = value:get_ItemId()

                any_judge = any_judge
                    or (quest_filter.item_judge and quest_filter.item_judge == item)
                    or false
                any_wishlisted = any_wishlisted or (filter_wishlist and m.isItemWishlisted(item))
                any_rare = any_rare
                    or (quest_filter.item_rare and util_table.contains(ace_map.special_items, item))
            end)

            if
                (filter_wishlist and not any_wishlisted)
                or (quest_filter.item_rare and not any_rare)
                or (quest_filter.item_judge and not any_judge)
            then
                return false
            end
        end
    end

    return true
end

---@return boolean
function this.any_wishlisted()
    local savedata = s.get("app.SaveDataManager"):getCurrentUserSaveData()
    local equip = savedata:get_Equip()
    local wishlist = equip:get_Wishlist()
    return wishlist:getEntryCount() > 0
end

---@param stage app.FieldDef.STAGE
---@param camps System.Int16?
---@return app.cStartPointInfo[]
function this.get_starting_points(stage, camps)
    -- app_GUI050001__initStartPoint
    ---@type app.cStartPointInfo[]
    local ret = {}

    ---@param start_point_type app.cStartPointInfo.START_POINT_TYPE
    ---@param gm_id app.GimmickDef.ID
    ---@param camp_id System.Int32
    ---@return app.cStartPointInfo
    local function start_point_ctor(start_point_type, gm_id, camp_id)
        local start_point = util_ref.ctor("app.cStartPointInfo", true)

        start_point:add_ref()
        start_point:call(
            ".ctor(app.cStartPointInfo.START_POINT_TYPE, app.GimmickDef.ID, System.Int32, app.PlayerDef.LAYOUT_ID)",
            start_point_type,
            gm_id,
            camp_id,
            -1
        )

        return start_point
    end

    local camp_man = s.get("app.GimmickManager"):get_CampManager()
    camps = camps or camp_man:getQuestStartPointBitInfo(stage)
    local camp_arr =
        camp_man:call("getQuestStartPointInfoList(app.FieldDef.STAGE, System.Int16)", stage, camps) --[[@as System.Array<app.cCampManager.TentQuestStartPointInfo>]]

    util_game.do_something(camp_arr, function(_, _, value)
        local camp_id = value:get_CampID()
        local start_point = start_point_ctor(
            e.get("app.cStartPointInfo.START_POINT_TYPE").TENT,
            m.getGmIDFromSimpleCampID(camp_id, stage),
            camp_id
        )

        table.insert(ret, start_point)
    end)

    local base_start_point = start_point_ctor(
        e.get("app.cStartPointInfo.START_POINT_TYPE").BASE_CAMP,
        m.getStageBaseCampGmID(stage),
        0
    )
    table.insert(ret, base_start_point)
    return ret
end

---@param stage app.FieldDef.STAGE
---@return app.cStartPointInfo
function this.get_base_starting_point(stage)
    local ret = util_ref.ctor("app.cStartPointInfo", true)

    ret:add_ref()
    ret:call(
        ".ctor(app.cStartPointInfo.START_POINT_TYPE, app.GimmickDef.ID, System.Int32, app.PlayerDef.LAYOUT_ID)",
        e.get("app.cStartPointInfo.START_POINT_TYPE").BASE_CAMP,
        m.getStageBaseCampGmID(stage),
        0,
        -1
    )

    return ret
end

---@param stage app.FieldDef.STAGE
---@param target_em_area System.Array<System.Int32>
---@param camps System.Int16?
---@return app.cStartPointInfo
function this.get_closest_starting_point(stage, target_em_area, camps)
    local starting_points = this.get_starting_points(stage, camps)
    local camp_ids = util_table.map_table(starting_points, function(o)
        return starting_points[o].CampID
    end) --[[@as {[CampId]: app.cStartPointInfo}]]

    local distances = data.get_camp_distances(
        stage,
        util_game.system_array_to_lua(target_em_area),
        util_table.keys(camp_ids)
    )

    if not distances then
        return this.get_base_starting_point(stage)
    end

    local sorted_distances = util_table.sort(util_table.keys(distances), function(a, b)
        return distances[a] < distances[b]
    end)
    local closest_camp = sorted_distances[1]
    return camp_ids[closest_camp]
end

function this.retry_quest()
    local misman = s.get("app.MissionManager")
    local quest_director = misman:get_QuestDirector()

    if not quest_director:isPlayingQuest() then
        return
    end

    local quest_data = quest_director:get_QuestData()
    if quest_data:get_MissionType() == e.get("app.MissionTypeList.TYPE").INSTANTQUEST then
        return
    end

    if not this.is_quest_host() then
        return
    end

    quest_director:notifyQuestRetry()
end

---@return boolean
function this.is_quest_host()
    local user_manager = s.get("app.NetworkManager"):get_UserInfoManager()
    local host_info =
        user_manager:getHostUserInfo(e.get("app.net_session_manager.SESSION_TYPE").QUEST)
    local self_info =
        user_manager:getSelfUserInfo(e.get("app.net_session_manager.SESSION_TYPE").QUEST, false)

    if host_info and host_info ~= self_info then
        return false
    end

    return true
end

---@param message string
function this.send_message(message)
    s.get("app.ChatManager"):addSystemLog(message)
end

---@param quest_data app.cActiveQuestData
---@return app.GUI050000.QUEST_TYPE
function this.get_gui50000_quest_type(quest_data)
    local quest_type = quest_data:get_MissionType()
    local e_50000Type = e.get("app.GUI050000.QUEST_TYPE")
    local e_QuestType = e.get("app.MissionTypeList.TYPE")
    local ret = e_50000Type.FREE

    if util_table.contains({ e_QuestType.MAINSTORY, e_QuestType.SIDESTORY }, quest_type) then
        ret = e_50000Type.MISSION
    elseif quest_type == e_QuestType.KEEPQUEST then
        ret = e_50000Type.KEEP_QUEST
    elseif quest_type == e_QuestType.INSTANTQUEST then
        ret = e_50000Type.DECLARATION_QUEST
    end

    return ret
end

---@param quest_data app.cActiveQuestData
---@param starting_point app.cStartPointInfo?
---@return app.cGUIQuestOrderParam
function this.get_quest_order_param(quest_data, starting_point)
    local category = this.get_gui50000_quest_type(quest_data)

    local gui_quest_view = util_ref.ctor("app.cGUIQuestViewData", true)
    gui_quest_view:add_ref()
    gui_quest_view:call(".ctor(app.cActiveQuestData)", quest_data)
    gui_quest_view:set_QuestCategory(category)

    local quest_order_param = util_ref.ctor("app.cGUIQuestOrderParam", true)
    quest_order_param:add_ref()
    quest_order_param.QuestType = category
    quest_order_param.ActiveQuestData = quest_data
    quest_order_param.QuestViewData = gui_quest_view
    quest_order_param.IsHost = true
    quest_order_param.IsOnline = m.isEnableNetwork()

    if starting_point then
        quest_order_param.SelectStartPointInfo = starting_point
    end

    return quest_order_param
end

---@param quest Quest
---@param start_type QuestStartType
function this.post_quest(quest, start_type)
    local quest_data = quest:get_active_quest_data()

    if start_type == mod_enum.quest_start.PICK then
        local quest_order_param = this.get_quest_order_param(quest_data)
        local ctx = m.GUIFlowQuestCounterStart(
            quest_order_param,
            quest_data:isArenaQuest() and e.get("app.GUIFlowQuestCounter.MODE").ARENA
                or e.get("app.GUIFlowQuestCounter.MODE").NORMAL,
            0
        )
        ---@type app.GUI060102.OPEN_FROM
        local open_from

        if quest_order_param.QuestType == e.get("app.GUI050000.QUEST_TYPE").DECLARATION_QUEST then
            open_from = e.get("app.GUI060102.OPEN_FROM").SUMMARY_QUEST_DETAIL
        else
            open_from = e.get("app.GUI060102.OPEN_FROM").QUEST_COUNTER
        end

        s.get("app.GUIManager")._QuestCounterFlowHandle = ctx
        s.get("app.GUIManager"):call(
            "requestOpenGUI060102(app.cGUIQuestViewData, app.GUI060102.OPEN_FROM, app.GUI060102.OPEN_ANIMATION)",
            quest_order_param.QuestViewData,
            open_from,
            e.get("app.GUI060102.OPEN_ANIMATION").ANIMATION
        )
    else
        local start_point = this.get_closest_starting_point(
            quest_data:getStage(),
            quest_data:getTargetEmSetAreaNo()
        )
        local quest_order_param = this.get_quest_order_param(quest_data, start_point)
        ---@type System.Guid
        local host_id
        local ctx_manager = s.get("app.NetworkManager"):get_ContextManager()

        if quest_order_param.QuestType == e.get("app.GUI050000.QUEST_TYPE").DECLARATION_QUEST then
            start_type = mod_enum.quest_start.START_AND_DEPART
            m.saveInstantQuest(quest_data:get_KeepQuestData())
        end

        if
            ctx_manager._ContextState
            == e.get("app.net_context_manager.cContextManager.CONTEXT_STATE").ACTIVE
        then
            host_id = ctx_manager:get_HunterId()
        else
            host_id = util_ref.value_type("System.Guid")
        end

        local quest_arg = util_ref.ctor("app.cQuestAcceptArg", true)
        local accepted_time = m.getUTCTime()
        quest_arg:call(
            ".ctor(app.cStartPointInfo, System.Guid, System.Int64)",
            start_point,
            host_id,
            accepted_time
        )
        quest_arg.StartType = e.get("app.cGUIQuestOrderParam.QUEST_START_TYPE").QUEST_COUNTER

        local user_save = s.get("app.SaveDataManager"):getCurrentUserSaveData()
        local recrute_setting = user_save:get_QuestRecruteSearchSetting()
        local quest_id = quest_data:get_MissionId()
        local max_join = m.calcQuestMaxJoinNum(quest_id)
        local quest_director = s.get("app.MissionManager"):get_QuestDirector()

        s.get("app.GUIManager"):clearPreparingData()
        quest_director:setQuestSyncParam(
            max_join,
            recrute_setting.RecruteMultiType,
            recrute_setting.RecruteHostPermission == 0,
            true
        )
        quest_director:acceptQuest(quest_data, quest_arg, false, false)
        s.get("app.GUIManager")
            :setQuestOrderParam(
                quest_order_param,
                start_type == mod_enum.quest_start.START_AND_DEPART
            )
    end
end

return this
