---@meta

---@class app.AppBehavior : via.Behavior
---@class app.savedata.cQuestParam : ace.cSaveDataParam
---@class app.Net_UserInfo : via.clr.ManagedObject
---@class app.CharacterBase : app.AppBehavior
---@class app.user_data.QuestData : via.UserData
---@class app.cExFieldEvent_Battlefield : app.cExFieldEventBase
---@class app.cExFieldEvent_SpecialOfferBase : app.cExFieldEventBase
---@class app.cGUIPartsBaseApp : ace.cGUIPartsBase

---@class app.savedata.cItemWork : ace.cSaveDataParam
---@field get_ItemId fun(self: app.savedata.cItemWork): app.ItemDef.ID

---@class app.user_data.ItemData.cData : ace.user_data.ExcelUserData.cData
---@field get_RawName fun(self: app.user_data.ItemData.cData): System.Guid
---@field get_Special fun(self: app.user_data.ItemData.cData): System.Boolean

---@class app.user_data.EnemySpeciesData.cData : ace.user_data.ExcelUserData.cData
---@field get_EmSpeciesName fun(self: app.user_data.EnemySpeciesData.cData): System.Guid

---@class app.MissionManager : ace.GAElement
---@field get_QuestDirector fun(self: app.MissionManager): app.cQuestDirector
---@field getQuestDataFromMissionId fun(self: app.MissionManager, quest_id: app.MissionIDList.ID): app.cActiveQuestData
---@field get_IsQuestEndShowing fun(self: app.MissionManager): System.Boolean
---@field get_IsActiveQuest fun(self: app.MissionManager): System.Boolean
---@field getQuestData fun(self: app.MissionManager, quest_id: app.MissionIDList.ID): app.user_data.QuestData
---@field getStreamQuestDataFromID fun(self: app.MissionManager, quest_id: app.MissionIDList.ID): app.cStreamQuestData
---@field get_MissionSetting fun(self: app.MissionManager): app.user_data.MissionManagerSetting
---@field reflectStreamQuestListCache fun(self: app.MissionManager)

---@class app.user_data.MissionManagerSetting : via.UserData
---@field get_QuestSetting fun(self: app.user_data.MissionManagerSetting): app.user_data.QuestSetting

---@class app.user_data.QuestSetting : via.UserData
---@field get_KeepQuestAcceptableMax fun(self: app.user_data.QuestSetting): System.Byte

---@class app.cQuestDirector : via.clr.ManagedObject
---@field acceptQuest fun(self: app.cQuestDirector, quest_data: app.cActiveQuestData, quest_arg: app.cQuestAcceptArg, unknown_bool1: System.Boolean, unknown_bool2: System.Boolean)
--- alwys_true, check connection? if no connection multiplay_setting = NPC_ONLY
---@field setQuestSyncParam fun(self: app.cQuestDirector, num_player: System.UInt32, multiplay_setting: app.net_quest_session.cCreateQuestSessionInfo.MULTIPLAY_SETTING, is_auto_accept: System.Boolean, always_true: System.Boolean)
---@field isPlayingQuest fun(self: app.cQuestDirector): System.Boolean
---@field get_QuestData fun(self: app.cQuestDirector): app.cActiveQuestData
---@field notifyQuestRetry fun(self: app.cQuestDirector)

---@class app.GimmickManager : ace.GAElement
---@field get_CampManager fun(self: app.GimmickManager): app.cCampManager

---@class app.cCampManager.TentQuestStartPointInfo : via.clr.ManagedObject
---@field get_CampID fun(self: app.cCampManager.TentQuestStartPointInfo): System.Int32

---@class app.cQuestAcceptArg : via.clr.ManagedObject
---@field StartType app.cGUIQuestOrderParam.QUEST_START_TYPE
---@field IsJoinRescue System.Boolean

---@class app.cGUIQuestOrderParam : via.clr.ManagedObject
---@field QuestType app.GUI050000.QUEST_TYPE
---@field ActiveQuestData app.cActiveQuestData
---@field QuestViewData app.cGUIQuestViewData
---@field IsOnline System.Boolean
---@field IsJoinRescue System.Boolean
---@field SelectStartPointInfo app.cStartPointInfo
---@field IsHost System.Boolean

---@class app.cStartPointInfo : via.clr.ManagedObject
---@field CampID System.Int32

---@class app.SaveDataManager : ace.SaveDataManagerBase
---@field getCurrentUserSaveData fun(self: app.SaveDataManager): app.savedata.cUserSaveParam

---@class app.savedata.cUserSaveParam : ace.cSaveDataParam
---@field get_Quest fun(self: app.savedata.cUserSaveParam): System.Array<app.savedata.cQuestParam>
---@field get_Equip fun(self: app.savedata.cUserSaveParam): app.savedata.cEquipParam
---@field get_QuestRecruteSearchSetting fun(self: app.savedata.cUserSaveParam): app.savedata.cQuestRecruteSearchSetting

---@class app.savedata.cEquipParam : ace.cSaveDataParam
---@field get_Wishlist fun(self: app.savedata.cEquipParam): app.savedata.cWishlistParam

---@class app.savedata.cWishlistParam : ace.cSaveDataParam
---@field getEntryCount fun(self: app.savedata.cWishlistParam): System.Int32

---@class app.cActiveQuestData : via.clr.ManagedObject
---@field getStage fun(self: app.cActiveQuestData): app.FieldDef.STAGE
---@field getTargetEmSetAreaNo fun(self: app.cActiveQuestData): System.Array<System.Int32>
---@field get_TitleText fun(self: app.cActiveQuestData): ace.cGUIMessageInfo
---@field getQuestLv fun(self: app.cActiveQuestData): System.Int32
---@field get_MissionId fun(self: app.cActiveQuestData): app.MissionIDList.ID
---@field get_MissionType fun(self: app.cActiveQuestData): app.MissionTypeList.TYPE
---@field getTargetEmId fun(self: app.cActiveQuestData): System.Array<app.EnemyDef.ID>
---@field getTargetEmRoleId fun(self: app.cActiveQuestData): System.Array<app.EnemyDef.ROLE_ID>
---@field getTargetEmLegendaryId fun(self: app.cActiveQuestData): System.Array<app.EnemyDef.LEGENDARY_ID>
---@field getTargetEmDifficulityGrade fun(self: app.cActiveQuestData): System.Array<System.Int32>
---@field getQuestTarget fun(self: app.cActiveQuestData): app.QuestDef.QUEST_TARGET
---@field getEnvironmentType fun(self: app.cActiveQuestData): app.EnvironmentType.ENVIRONMENT
---@field getTimeLimit fun(self: app.cActiveQuestData): System.UInt32
---@field get_KeepQuestData fun(self: app.cActiveQuestData): app.cKeepQuestData
---@field getQuestRank fun(self: app.cActiveQuestData, out: app.QuestDef.RANK): System.Boolean
---@field isTargetZako fun(self: app.cActiveQuestData): System.Boolean
---@field isTargetBoss fun(self: app.cActiveQuestData): System.Boolean
---@field isArenaQuest fun(self: app.cActiveQuestData): System.Boolean

---@class app.cKeepQuestData : via.clr.ManagedObject
---@field get_IsSpOffer fun(self: app.cKeepQuestData): System.Boolean
---@field getSpOfferRewardList fun(self: app.cKeepQuestData): System.Array<app.savedata.cItemWork>
---@field getExEmRewardList fun(self: app.cKeepQuestData): System.Array<app.savedata.cItemWork>
---@field get_IsVillageBoost fun(self: app.cKeepQuestData): System.Boolean
---@field get_Index fun(self: app.cKeepQuestData): System.Int32
---@field get_TatgetExUniqueIdxArray fun(self: app.cKeepQuestData): System.Array<System.Int32>
---@field get_BfExUniqueIndex fun(self: app.cKeepQuestData): System.Int32
---@field get_ExSpawnUniqueIndex fun(self: app.cKeepQuestData): System.Int32
---@field get_BfBelongingStage fun(self: app.cKeepQuestData): app.FieldDef.STAGE
---@field getSpOfferInfo fun(self: app.cKeepQuestData): app.cExFieldEvent_SpecialOfferBase
---@field get_CreatedDate fun(self: app.cKeepQuestData): System.Int64

---@class app.NetworkManager : ace.GAElement
---@field get_ContextManager fun(self: app.NetworkManager): app.net_context_manager.cContextManager
---@field get_SessionService fun(self: app.NetworkManager): app.Net_SessionService

---@class app.Net_SessionService : via.clr.ManagedObject
---@field isOnline fun(self: app.Net_SessionService, sess_type: app.net_session_manager.SESSION_TYPE): System.Boolean

---@class app.net_context_manager.cContextManager : via.clr.ManagedObject
---@field get_HunterId fun(self: app.net_context_manager.cContextManager): System.Guid
---@field _ContextState app.net_context_manager.cContextManager.CONTEXT_STATE

---@class app.GUIManager : ace.GUIManagerBase
---@field get_LastInputDeviceIgnoreMouseMove fun(self: app.GUIManager): ace.GUIDef.INPUT_DEVICE
---@field clearPreparingData fun(self: app.GUIManager)
---@field setQuestOrderParam fun(self: app.GUIManager, order_param: app.cGUIQuestOrderParam, start_quest: System.Boolean)
---@field _QuestCounterFlowHandle ace.IGUIFlowHandle

---@class app.savedata.cQuestParam : ace.cSaveDataParam
---@field RemainingNum System.Int32
---@field CreatedDate System.Int64

---@class app.HunterCharacter : app.CharacterBase
---@field get_IsInBaseCamp fun(self: app.HunterCharacter): System.Boolean

---@class app.PlayerManager : ace.GAElement
---@field getMasterPlayer fun(self: app.PlayerManager): app.cPlayerManageInfo

---@class app.cPlayerManageInfo : via.clr.ManagedObject
---@field get_Character fun(self: app.cPlayerManageInfo): app.HunterCharacter

---@class app.cCampManager : via.clr.ManagedObject
---@field getQuestStartPointBitInfo fun(self: app.cCampManager, stage: app.FieldDef.STAGE): System.Int16

---@class app.savedata.cQuestRecruteSearchSetting : ace.cSaveDataParam
---@field RecruteMultiType System.Int32
---@field RecruteHostPermission System.Byte

---@class app.cGUIQuestViewData : via.clr.ManagedObject
---@field set_QuestCategory fun(self: app.cGUIQuestViewData, type: app.GUI050000.QUEST_TYPE)

---@class app.VariousDataManager : ace.GAElement
---@field get_Setting fun(self: app.VariousDataManager) : app.user_data.VariousDataManagerSetting

---@class app.user_data.VariousDataManagerSetting : via.UserData
---@field get_ExQuestRewardSetting fun(self: app.user_data.VariousDataManagerSetting): app.user_data.ExQuestRewardSetting

---@class app.user_data.ExQuestRewardSetting : via.UserData
---@field _ArtianRewardTbl System.Array<app.user_data.ExQuestRewardSetting.cExRewardDataParam>
---@field _AmuletRewardTbl System.Array<app.user_data.ExQuestRewardSetting.cExRewardDataParam>
---@field _SkillGemRewardTbl System.Array<app.user_data.ExQuestRewardSetting.cExRewardDataParam>
---@field _ExjudgeEmRewardArray System.Array<app.user_data.ExQuestRewardSetting.cExJudgeEmReward>

---@class app.user_data.ExQuestRewardSetting.cExRewardDataParam : via.clr.ManagedObject
---@field get_RewardItem fun(self: app.user_data.ExQuestRewardSetting.cExRewardDataParam): app.ItemDef.ID

---@class app.user_data.ExQuestRewardSetting.cExJudgeEmReward : via.clr.ManagedObject
---@field get_ItemID fun(self: app.user_data.ExQuestRewardSetting.cExJudgeEmReward): app.ItemDef.ID

---@class app.cStreamQuestData : via.clr.ManagedObject
---@field isEnable fun(self: app.cStreamQuestData): System.Boolean

---@class app.cExSpOfferInfo_forView : via.clr.ManagedObject
---@field get_SpOfferUniqueIdx fun(self: app.cExSpOfferInfo_forView): System.Int32

---@class app.EnvironmentManager : ace.GAElement
---@field getSpOfferInfoList fun(self: app.EnvironmentManager, stage: app.FieldDef.STAGE): System.Array<app.cExSpOfferInfo_forView>
---@field getBattlefieldInfoList fun(self: app.EnvironmentManager, stage: app.FieldDef.STAGE): System.Array<app.cExBattlefieldInfo_forView>
---@field get_ExCurrentStage fun(self: app.EnvironmentManager): app.FieldDef.STAGE
---@field get_IsExploringMyExField fun(self: app.EnvironmentManager): System.Boolean
---@field findExecutedPopEmsInMyExField fun(self: app.EnvironmentManager, stage: app.FieldDef.STAGE, quest_only: System.Boolean): System.Array<app.cExFieldEvent_PopEnemy>
---@field findExecutedPopEms fun(self: app.EnvironmentManager, quest_target_only: System.Boolean, unknown_bool: System.Boolean): System.Array<app.cExFieldEvent_PopEnemy>
---@field _ExFieldDirector app.cExFieldDirector

---@class app.cExEvent : via.clr.ManagedObject
---@field get_UniqueIndex fun(self: app.cExEvent): System.Int32

---@class app.GameFlowManager : ace.GAElement
---@field get_IsPlayableScene fun(self: app.GameFlowManager): System.Boolean

---@class app.ChatManager : ace.GAElement
---@field addSystemLog fun(self: app.ChatManager, message: System.String)

---@class app.NetworkManager : ace.GAElement
---@field get_UserInfoManager fun(self: app.NetworkManager): app.Net_UserInfoManager

---@class app.Net_UserInfoManager : via.clr.ManagedObject
---@field getHostUserInfo fun(self: app.Net_UserInfoManager, type: app.net_session_manager.SESSION_TYPE): app.Net_UserInfo
---@field getSelfUserInfo fun(self: app.Net_UserInfoManager, type: app.net_session_manager.SESSION_TYPE, unknown_bool: System.Boolean): app.Net_UserInfo

---@class app.cExFieldDirector : via.clr.ManagedObject
---@field _IsCreatedEmInFrame System.Boolean
---@field _LoadedStage System.Boolean
---@field _ScheduleTimeline app.cScheduleTimelime

---@class app.cScheduleTimelime : via.clr.ManagedObject
---@field get_KeyList fun(self: app.cScheduleTimelime): System.Array<app.cExFieldEventBase>

---@class app.cExFieldEventBase : app.cExEvent
---@field get_Executed fun(self: app.cExFieldEventBase): System.Boolean
---@field get_IsActive fun(self: app.cExFieldEventBase): System.Boolean

---@class app.cExBattlefieldInfo_forView : via.clr.ManagedObject
---@field get_BattlefieldEvent fun(self: app.cExBattlefieldInfo_forView): app.cExFieldEvent_Battlefield
---@field get_KeepQuestData fun(self: app.cExBattlefieldInfo_forView): app.cKeepQuestData

---@class app.cExFieldEvent_PopEnemy : app.cExFieldEventBase
---@field get_EnableInstantQuestTarget fun(self: app.cExFieldEvent_PopEnemy): System.Boolean
---@field get_IsBattlefieldEm fun(self: app.cExFieldEvent_PopEnemy): System.Boolean

---@class app.DemoMediator : ace.DemoMediatorBase
---@field get_IsBusy fun(self: app.DemoMediator): System.Boolean

---@class app.GameFlowManager : ace.GameFlowManagerBase
---@field get_GameJumper fun(self: app.GameFlowManager): app.cGameJumper

---@class app.cGameJumper : via.clr.ManagedObject
---@field _GameSceneTransition app.cGameSceneTransition

---@class app.cGameSceneTransition : via.clr.ManagedObject
---@field _Phase app.cGameSceneTransition.PHASE

---@class app.FadeManager : ace.FadeManagerBase
---@field get_IsFadingAny fun(self: app.FadeManager): System.Boolean

---@class app.GUI050001_AcceptList : app.cGUIPartsBaseApp
---@field _MenuItem_AcceptAndPreparing via.gui.SelectItem
---@field _MenuItem_AcceptAndStart via.gui.SelectItem
---@field _InputCtrl ace.cGUIInputCtrl_FluentItemsControlLink
---@field getItemIndex fun(self: app.GUI050001_AcceptList, sel: via.gui.SelectItem): System.Int32
---@field callbackDecide fun(self: app.GUI050001_AcceptList, ctrl: via.gui.Control, sel: via.gui.SelectItem, index: System.Int32)

---@class ace.cGUIInputCtrl_FluentItemsControlLink : ace.cGUIInputCtrl
---@field _FicLink via.gui.FluentItemsControlLink

---@class via.gui.FluentItemsControlLink : via.gui.Control
---@field set_SelectedItemIndex fun(self: via.gui.FluentItemsControlLink, index: System.Int32)
