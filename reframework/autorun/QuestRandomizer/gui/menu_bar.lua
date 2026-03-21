local bind_manager = require("QuestRandomizer.bind.init")
local config = require("QuestRandomizer.config.init")
local data = require("QuestRandomizer.data.init")
local quest_reference = require("QuestRandomizer.quest_randomizer.quest_reference")
local set = require("QuestRandomizer.util.imgui.config_set"):new(config)
local state = require("QuestRandomizer.gui.state")
local util_bind = require("QuestRandomizer.util.game.bind.init")
local util_gui = require("QuestRandomizer.gui.util")
local util_imgui = require("QuestRandomizer.util.imgui.init")
local util_randomizer = require("QuestRandomizer.quest_randomizer.util")
local util_table = require("QuestRandomizer.util.misc.table")

local mod_map = data.mod.map
local mod_enum = data.mod.enum

local this = {
    quest_ref = {
        table = {
            name = "quest_ref",
            flags = 1 << 8 | 1 << 7 | 1 << 10 | 1 << 25 | 3 << 13 | 1 << 0,
        },
    },
}

---@param label string
---@param draw_func fun()
---@param enabled_obj boolean?
---@param text_color integer?
---@param size number[]?
---@return boolean
local function draw_menu(label, draw_func, enabled_obj, text_color, size)
    enabled_obj = enabled_obj == nil and true or enabled_obj

    if text_color then
        imgui.push_style_color(0, text_color)
    end

    if size then
        imgui.set_next_window_size(size)
    end

    local menu = imgui.begin_menu(label, enabled_obj)

    if text_color then
        imgui.pop_style_color(1)
    end

    if menu then
        draw_func()
        imgui.end_menu()
    end

    return menu
end

local function draw_mod_menu()
    imgui.push_style_var(14, Vector2f.new(0, 2))

    if set:menu_item(util_gui.tr("menu.config.enabled"), "mod.enabled") then
        if config.current.mod.enabled then
            util_randomizer.request_quest_reload(mod_enum.quest_reload.FULL)
        else
            util_randomizer.clear_all()
        end
    end

    if
        set:menu_item(
            util_gui.tr("menu.config.filter_quest_reference"),
            "mod.filter_quest_reference"
        )
    then
        quest_reference.mark_dirty()
    end

    set:menu_item(util_gui.tr("menu.config.auto_post"), "mod.auto_post")
    util_imgui.tooltip(config.lang:tr("menu.config.tooltip_auto_post"))
    set:menu_item(util_gui.tr("menu.config.auto_randomize"), "mod.auto_randomize")
    util_imgui.tooltip(config.lang:tr("menu.config.tooltip_auto_randomize"))

    if set:menu_item(util_gui.tr("menu.config.use_custom_list"), "mod.use_custom_list") then
        util_randomizer.request_mod_action(mod_enum.mod_action.FILTER)
    end
    util_imgui.tooltip(config.lang:tr("menu.config.tooltip_use_custom_list"))

    imgui.separator()

    imgui.begin_disabled(not util_randomizer.reload_ok())
    if
        util_imgui.menu_item(util_gui.tr("menu.config.reload_quest_data"), nil, nil, true)
        and config.current.mod.enabled
    then
        util_randomizer.request_quest_reload(mod_enum.quest_reload.FULL)
    end
    imgui.end_disabled()

    if util_imgui.menu_item(util_gui.tr("menu.config.reset"), nil, nil, true) then
        state.clear_disabled_items()
        config:restore()
        util_randomizer.request_mod_action(mod_enum.mod_action.FILTER)
    end

    imgui.pop_style_var(1)
end

local function draw_lang_menu()
    local config_lang = config.current.mod.lang
    imgui.push_style_var(14, Vector2f.new(0, 2))

    for i = 1, #config.lang.sorted do
        local menu_item = config.lang.sorted[i]
        if util_imgui.menu_item(menu_item, config_lang.file == menu_item) then
            config_lang.file = menu_item
            config.lang:change()
            config:save()
            state.translate_combo()
        end
    end

    imgui.separator()

    set:menu_item(util_gui.tr("menu.language.fallback"), "mod.lang.fallback")
    util_imgui.tooltip(config.lang:tr("menu.language.fallback_tooltip"))

    imgui.pop_style_var(1)
end

local function draw_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod

    if
        set:slider_int(
            util_gui.tr("menu.bind.slider_buffer"),
            "mod.bind.buffer",
            1,
            11,
            config_mod.bind.buffer - 1 == 0 and config.lang:tr("misc.text_disabled")
                or config_mod.bind.buffer - 1 == 1 and string.format(
                    "%s %s",
                    config_mod.bind.buffer - 1,
                    config.lang:tr("misc.text_frame")
                )
                or string.format(
                    "%s %s",
                    config_mod.bind.buffer - 1,
                    config.lang:tr("misc.text_frame_plural")
                )
        )
    then
        bind_manager.monitor:set_max_buffer_frame(config_mod.bind.buffer)
    end
    util_imgui.tooltip(config.lang:tr("menu.bind.tooltip_buffer"))

    imgui.separator()
    imgui.begin_disabled(state.listener ~= nil)

    local manager = bind_manager.action
    local config_key = "mod.bind.action"
    set:combo("##bind_action_combo", "mod.bind.combo_action", state.combo.action.values)

    imgui.same_line()

    if imgui.button(util_gui.tr("menu.bind.button_add")) then
        state.listener = {
            opt = state.combo.action:get_key(config_mod.bind.combo_action),
            listener = util_bind.listener:new(),
            opt_name = state.combo.action:get_value(config_mod.bind.combo_action),
        }
    end

    imgui.end_disabled()

    if state.listener then
        bind_manager.monitor:pause()

        imgui.separator()

        local bind = state.listener.listener:listen() --[[@as ModBind]]
        ---@type string[]
        local bind_name

        if bind.name_display ~= "" then
            bind_name = { bind.name_display, "..." }
        else
            bind_name = { config.lang:tr("menu.bind.text_default") }
        end

        imgui.begin_table("keybind_listener", 1, 1 << 9)
        imgui.table_next_row()

        util_imgui.adjust_pos(0, 3)

        imgui.table_set_column_index(0)

        if manager:is_valid(bind) then
            bind.bound_value = state.listener.opt

            local is_col, col = manager:is_collision(bind)
            if is_col and col then
                state.listener.collision = string.format(
                    "%s %s",
                    config.lang:tr("menu.bind.tooltip_bound"),
                    config.lang:tr(mod_map.actions[col.bound_value])
                )
            else
                state.listener.collision = nil
            end
        else
            state.listener.collision = nil
        end

        imgui.begin_disabled(state.listener.collision ~= nil or bind.name == "")

        local save_button = imgui.button(util_gui.tr("menu.bind.button_save"))

        if save_button then
            manager:register(bind)
            config:set(config_key, manager:get_base_binds())

            config:save()
            state.listener = nil
            bind_manager.monitor:unpause()
        end

        imgui.end_disabled()
        imgui.same_line()

        if imgui.button(util_gui.tr("menu.bind.button_clear")) then
            state.listener.listener:clear()
        end

        imgui.same_line()

        if imgui.button(util_gui.tr("menu.bind.button_cancel")) then
            state.listener = nil
            bind_manager.monitor:unpause()
        end

        imgui.end_table()
        imgui.separator()

        if state.listener and state.listener.collision then
            imgui.text_colored(state.listener.collision, mod_map.colors.bad)
            imgui.separator()
        end

        imgui.text(table.concat(bind_name, " + "))
        imgui.separator()
    end

    if
        not util_table.empty(config:get(config_key))
        and imgui.begin_table("keybind_state", 3, 1 << 9)
    then
        imgui.separator()

        ---@type ModBind[]
        local remove = {}
        local binds = config:get(config_key) --[=[@as ModBind[]]=]
        for i = 1, #binds do
            local bind = binds[i]
            imgui.table_next_row()
            imgui.table_set_column_index(0)

            if
                imgui.button(util_gui.tr("menu.bind.button_remove", bind.name, bind.bound_value))
            then
                table.insert(remove, bind)
            end

            imgui.table_set_column_index(1)
            imgui.text(config.lang:tr(mod_map.actions[bind.bound_value]))
            imgui.table_set_column_index(2)
            imgui.text(bind.name_display)
        end

        if not util_table.empty(remove) then
            for _, bind in pairs(remove) do
                manager:unregister(bind)
            end

            config:set(config_key, manager:get_base_binds())
        end

        imgui.end_table()
    end

    imgui.unindent(2)
    imgui.spacing()
end

local function draw_quest_ref_menu()
    imgui.spacing()
    imgui.indent(2)

    imgui.set_next_item_width(-1)
    if set:input_text("##quest_ref_filter", "mod.quest_ref_query") then
        quest_reference.mark_dirty()
    end

    util_imgui.tooltip(config.lang:tr("menu.quest_ref.tooltip_input_filter"))

    quest_reference.filter()

    if
        imgui.begin_table(
            this.quest_ref.table.name,
            5,
            this.quest_ref.table.flags --[[@as ImGuiTableFlags]],
            Vector2f.new(0, 10 * 28)
        )
    then
        imgui.table_setup_column(util_gui.tr("menu.quest_ref.header_name"))
        imgui.table_setup_column(util_gui.tr("menu.quest_ref.header_map"))
        imgui.table_setup_column(util_gui.tr("menu.quest_ref.header_level"))
        imgui.table_setup_column(util_gui.tr("menu.quest_ref.header_custom_list"))
        imgui.table_setup_column(util_gui.tr("menu.quest_ref.header_id"))
        imgui.table_headers_row()

        for row = 1, #quest_reference.items do
            local quest = quest_reference.items[row]
            imgui.table_next_row()
            imgui.table_set_column_index(0)
            imgui.text(quest.title)
            imgui.table_set_column_index(1)
            imgui.text(quest.stage_name)
            imgui.table_set_column_index(2)
            imgui.text(quest.level .. config.lang:tr("misc.text_star"))
            imgui.table_set_column_index(3)

            imgui.begin_disabled(quest.type == quest.enum_type.INSTANT)
            if mod_map.custom_quest_list:get(quest.key) then
                if imgui.button(util_gui.tr("menu.quest_ref.button_remove", tostring(row))) then
                    mod_map.custom_quest_list:set(quest.key, nil)
                end
            else
                if imgui.button(util_gui.tr("menu.quest_ref.button_add", tostring(row))) then
                    mod_map.custom_quest_list:set(quest.key, true)
                end
            end
            imgui.end_disabled()

            imgui.table_set_column_index(4)
            if imgui.button(quest.key) then
                config.current.mod.quest_id = quest.key
            end
            util_imgui.tooltip(config.lang:tr("menu.quest_ref.tooltip_quest_no"))
        end

        imgui.end_table()
    end

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    draw_menu(util_gui.tr("menu.config.name"), draw_mod_menu)
    draw_menu(util_gui.tr("menu.language.name"), draw_lang_menu)
    draw_menu(util_gui.tr("menu.bind.name"), draw_bind_menu)
    draw_menu(util_gui.tr("menu.quest_ref.name"), draw_quest_ref_menu, nil, nil, { 500, 0 })
end

return this
