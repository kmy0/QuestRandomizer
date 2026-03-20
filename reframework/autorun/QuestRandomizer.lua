local bind = require("QuestRandomizer.bind.init")
local config = require("QuestRandomizer.config.init")
local config_menu = require("QuestRandomizer.gui.init")
local data = require("QuestRandomizer.data.init")
local hook = require("QuestRandomizer.quest_randomizer.hook")
local util = require("QuestRandomizer.util.init")
local util_randomizer = require("QuestRandomizer.quest_randomizer.util")
local logger = util.misc.logger.g
---@class MethodUtil
local m = require("QuestRandomizer.util.ref.methods")

local init = util.misc.init_chain:new(
    "MAIN",
    config.init,
    data.init,
    config_menu.init,
    bind.init,
    data.mod.init,
    function()
        util_randomizer.request_quest_reload(data.mod.enum.quest_reload.FULL)
        return true
    end
)
local mod = data.mod

m.createQuestTitleMessage = m.wrap(m.get("app.MessageUtil.createMessage(ace.cGUIMessageInfo)")) --[[@as fun(msg: ace.cGUIMessageInfo): System.String]]
m.getItemData = m.wrap(m.get("app.ItemDef.Data(app.ItemDef.ID)")) --[[@as fun(item_id: app.ItemDef.ID): app.user_data.ItemData.cData]]
m.isValidItem = m.wrap(m.get("app.ItemDef.isValidItem(app.ItemDef.ID)")) --[[@as fun(item_id: app.ItemDef.ID): System.Boolean]]
m.isBossID = m.wrap(m.get("app.EnemyDef.isBossID(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Boolean]]
m.isEmValid = m.wrap(m.get("app.EnemyDef.isValid(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Boolean]]
m.getEnemyNameGuid = m.wrap(m.get("app.EnemyDef.EnemyName(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Guid]]
m.isJudgeItem = m.wrap(m.get("app.ItemUtil.isJudgeItem(app.ItemDef.ID)")) --[[@as fun(item_id: app.ItemDef.ID): System.Boolean]]
m.getStageNameGuid =
    m.wrap(m.get("app.GUIUtilApp.MapUtil.getStageFullName(app.FieldDef.STAGE, System.Guid)")) --[[@as fun(stage: app.FieldDef.STAGE, guid_ptr: integer): System.Boolean]]
m.isMainStage = m.wrap(m.get("app.FieldUtil.isMainStage(app.FieldDef.STAGE)")) --[[@as fun(stage: app.FieldDef.STAGE): System.Boolean]]
m.isArenaStage = m.wrap(m.get("app.FieldUtil.isArenaStage(app.FieldDef.STAGE)")) --[[@as fun(stage: app.FieldDef.STAGE): System.Boolean]]
m.getItemNameGuid = m.wrap(m.get("app.ItemDef.RawName(app.ItemDef.ID)")) --[[@as fun(item_id: app.ItemDef.ID): System.Guid]]
m.getStageBaseCampGmID = m.wrap(m.get("app.GUI050001.getStageBaseCampID(app.FieldDef.STAGE)")) --[[@as fun(stage: app.FieldDef.STAGE): System.Int32]]
m.getGmIDFromSimpleCampID =
    m.wrap(m.get("app.GimmickUtil.getGmIDFromSimpleCampID(System.Int32, app.FieldDef.STAGE)")) --[[@as fun(camp_id: System.Int32, stage:  app.FieldDef.STAGE): app.GimmickDef.ID]]
m.getEmSpecies = m.wrap(m.get("app.EnemyDef.Species(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): app.EnemyDef.SPECIES_Fixed]]
m.getSpeciesData = m.wrap(m.get("app.EnemyDef.Data(app.EnemyDef.SPECIES)")) --[[@as fun(species: app.EnemyDef.SPECIES): app.user_data.EnemySpeciesData.cData]]
m.canOpenStartMenu =
    m.wrap(m.get("app.cGUISystemModuleSystemInputOpenController.canOpenStartMenu(System.Boolean)")) --[[@as fun(check_open_item_slider_flag: System.Boolean): System.Boolean]]
m.isItemWishlisted = m.wrap(m.get("app.WishlistUtil.isItemRequiredForWishlist(app.ItemDef.ID)")) --[[@as fun(item_id: app.ItemDef.ID): System.Boolean]]
m.isQuestRequiredForWishlist = m.wrap(
    m.get("app.WishlistUtil.isQuestRequiredForWishlist(app.MissionIDList.ID, app.QuestDef.RANK)")
) --[[@as fun(quest_id: app.MissionIDList.ID, quest_rank: app.QuestDef.RANK): System.Boolean)]]
m.isEnemyRequiredForWishlist =
    m.wrap(m.get("app.WishlistUtil.isEnemyRequiredForWishlist(app.EnemyDef.ID, app.QuestDef.RANK)")) --[[@as fun(em_id: app.EnemyDef.ID, quest_rank: app.QuestDef.RANK): System.Boolean]]
m.isExQuestRequiredForWishlist = m.wrap(
    m.get(
        "app.WishlistUtil.isExQuestRequiredForWishlist(System.Collections.Generic.IEnumerable`1<app.savedata.cItemWork>, app.EnemyDef.ID, app.EnemyDef.ROLE_ID, app.EnemyDef.LEGENDARY_ID, app.QuestDef.RANK, app.QuestDef.EM_REWARD_RANK, System.Boolean)"
    )
) --[[@as fun(rewards: System.Array<app.savedata.cItemWork>, em_id: app.EnemyDef.ID, em_role: app.EnemyDef.ROLE_ID, em_legendary: app.EnemyDef.LEGENDARY_ID, quest_rank: app.QuestDef.RANK, reward_rank: app.QuestDef.EM_REWARD_RANK, check_normal_rewards: System.Boolean): System.Boolean]]
m.convertSaveData2KeepQuest =
    m.wrap(m.get("app.QuestUtil.convertSaveData2KeepQuest(app.savedata.cQuestParam)")) --[[@as fun(keep_quest: app.savedata.cQuestParam): app.cKeepQuestData]]
m.getUTCTime = m.wrap(m.get("app.QuestUtil.getUTCTime()")) --[[@as fun(): System.UInt64]]
m.isEnableNetwork = m.wrap(m.get("app.GUIUtilApp.QuestUtil.isEnableNetwork()")) --[[@as fun() : System.Boolean]]
m.calcQuestMaxJoinNum = m.wrap(m.get("app.QuestUtil.calcQuestMaxJoinNum(app.MissionIDList.ID)")) --[[@as fun(quest_id: app.MissionIDList.ID) : System.Int32]]
m.checkAcceptable =
    m.wrap(m.get("app.QuestUtil.checkAcceptable(System.Int32, app.cActiveQuestData)")) --[[@as fun(out: System.Int32, quest: app.cActiveQuestData): System.Boolean]]
m.checkQuestClear = m.wrap(m.get("app.QuestUtil.checkQuestClear(app.MissionIDList.ID)")) --[[@as fun(quest_id: app.MissionIDList.ID): System.Boolean]]
m.getKeepQuestRemain = m.wrap(m.get("app.QuestUtil.getKeepQuestRemain(System.Int32)")) --[[@as fun(index: System.Int32): System.Int32]]
m.GUIFlowQuestCounterStart = m.wrap(
    m.get(
        "app.GUIFlowQuestCounter.start(app.cGUIQuestOrderParam, app.GUIFlowQuestCounter.MODE, ace.IGUIFlowHandle)"
    )
) --[[@as fun(order_param: app.cGUIQuestOrderParam, flow_mode: app.GUIFlowQuestCounter.MODE, flow_handle: ace.IGUIFlowHandle | 0): ace.IGUIFlowHandle]]
m.createActiveQuestData_InstantPopEnemy = m.wrap(
    m.get(
        "app.QuestUtil.createActiveQuestData_Instant(app.cExFieldEvent_PopEnemy, app.FieldDef.STAGE)"
    )
) --[[@as fun(em: app.cExFieldEvent_PopEnemy, stage: app.FieldDef.STAGE): app.cActiveQuestData]]
m.createActiveQuestData_InstantSpOffer =
    m.wrap(m.get("app.QuestUtil.createActiveQuestData_Instant(app.cExSpOfferInfo_forView)")) --[[@as fun(spoffer: app.cExSpOfferInfo_forView): app.cActiveQuestData]]
m.saveInstantQuest = m.wrap(m.get("app.QuestUtil.saveInstantQuest(app.cKeepQuestData)")) --[[@as fun(quest_data: app.cKeepQuestData)]]
m.getExEmRemainSec =
    m.wrap(m.get("app.ExFieldUtil.getExEmRemainSec(app.cExFieldEvent_PopEnemy, System.Boolean)")) --[[@as fun(pop_em: app.cExFieldEvent_PopEnemy, real_time: System.Boolean): System.Single]]

m.hook("app.GUIManager.resetTitleApp()", nil, hook.clear_quest_data)
m.hook("app.GUI050000.closeQuestDetailWindow()", nil, hook.reload_quest_data)
m.hook("app.GUIManager.lateUpdateApp()", nil, hook.update)
m.hook("app.cExFieldDirector.init()", nil, hook.reload_quest_data)
m.hook(
    "app.QuestUtil.saveKeepQuest(app.MissionIDList.ID, System.UInt32, app.EnemyDef.ID, app.EnemyDef.ROLE_ID, app.EnemyDef.LEGENDARY_ID, System.Int32, app.cExFieldScheduleExportData, app.FieldDef.STAGE)",
    nil,
    hook.reload_keep_quest_data
)
m.hook(
    "app.cQuestDirector.acceptQuest(app.cActiveQuestData, app.cQuestAcceptArg, System.Boolean, System.Boolean)",
    hook.accept_quest_pre
)

re.on_draw_ui(function()
    if imgui.button(string.format("%s %s", config.name, config.commit)) and init.ok then
        local gui_main = config.gui.current.gui.main
        gui_main.is_opened = not gui_main.is_opened
    end

    if not init.failed then
        local errors = logger:format_errors()
        if errors then
            imgui.same_line()
            imgui.text_colored("Error!", mod.map.colors.bad)
            util.imgui.tooltip_exclamation(errors)
        elseif not init.ok then
            imgui.same_line()
            imgui.text_colored("Initializing...", mod.map.colors.info)
        end
    else
        imgui.same_line()
        imgui.text_colored("Init failed!", mod.map.colors.bad)
    end
end)

re.on_application_entry("BeginRendering", function()
    init:init()
end)

re.on_frame(function()
    if not init.ok then
        return
    end

    bind.monitor:monitor()

    local config_gui = config.gui.current.gui

    if not reframework:is_drawing_ui() then
        config_gui.main.is_opened = false
    end

    if config_gui.main.is_opened then
        config_menu.draw()
    end

    config.run_save()
end)

re.on_config_save(function()
    if mod.initialized then
        config.save_no_timer_global()
    end
end)
