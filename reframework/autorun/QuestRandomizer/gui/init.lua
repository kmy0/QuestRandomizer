---@class Gui
---@field window GuiWindow

---@class (exact) GuiWindow
---@field flags integer
---@field condition integer

local checkbox_tri = require("QuestRandomizer.util.imgui.checkbox_tri")
local combo_chips = require("QuestRandomizer.util.imgui.combo_chips")
local config = require("QuestRandomizer.config.init")
local data = require("QuestRandomizer.data.init")
local menu_bar = require("QuestRandomizer.gui.menu_bar")
local randomizer = require("QuestRandomizer.quest_randomizer.randomizer")
local set = require("QuestRandomizer.util.imgui.config_set"):new(config)
local state = require("QuestRandomizer.gui.state")
local util_gui = require("QuestRandomizer.gui.util")
local util_imgui = require("QuestRandomizer.util.imgui.init")
local util_randomizer = require("QuestRandomizer.quest_randomizer.util")
local util_table = require("QuestRandomizer.util.misc.table")

local ace_map = data.ace.map
local mod_map = data.mod.map
local mod_enum = data.mod.enum

---@class Gui
local this = {
    window = {
        flags = 1024,
        condition = 2,
    },
}

---@param key "map" | "monster" | "type" | "monster_species" | "monster_state" | "monster_target" | "environ"  | "rank" | "monster_grade" | "quest_target" | "attempts"
---@param tooltip string?
---@return boolean
local function draw_chips(key, tooltip)
    local config_mod = config.current.mod
    local combo = state.combo[key] --[[@as Combo]]
    local map = config_mod[key] --[[@as table<string, integer>]]
    local combo_index_key = "mod.combo_ignore_" .. key --[[@as string]]

    local changed = set:checkbox("##box_ignore_" .. key, "mod.ignore_" .. key)
    if tooltip then
        util_imgui.tooltip(tooltip)
    end

    imgui.begin_disabled(not config:get("mod.ignore_" .. key))
    imgui.same_line()
    changed = set:combo_chips(
        "##combo_ignore_" .. key,
        combo_index_key,
        map,
        combo,
        util_gui.tr("mod.button_ignore", key),
        {
            {
                label = config.lang:tr("mod.button_clear"),
                action = combo_chips.clear_selection,
            },
            {
                label = config.lang:tr("mod.button_ignore_all"),
                is_draw = function(_, _, combo, _)
                    return not util_table.empty(combo.map)
                        and #combo.values + #combo.disabled > config.min_ignore_all
                end,
                action = combo_chips.select_all,
            },
        }
    ) or changed
    imgui.end_disabled()

    if not util_table.empty(map) then
        imgui.separator()
    end

    return changed
end

---@param id string
---@param min_val integer
---@param max_val integer
---@param display_text string?
---@return boolean
local function draw_ignore_slider(id, min_val, max_val, display_text)
    local config_mod = config.current.mod

    set:checkbox("##box_ignore_" .. id, "mod.ignore_" .. id)
    imgui.begin_disabled(not config_mod["ignore_" .. id])
    imgui.same_line()
    local changed =
        set:slider_int("##slider_" .. id, "mod.slider_" .. id, min_val, max_val, display_text)
    imgui.end_disabled()

    return changed
end

---@return boolean
local function draw_quest_attr()
    local config_mod = config.current.mod
    local changed = false

    util_imgui.separator_text(
        config.lang:tr("mod.category_ignore_attr"),
        nil,
        nil,
        mod_map.colors.blue
    )

    changed = set:checkbox(util_gui.tr("mod.box_ignore_posted"), "mod.ignore_posted") or changed
    imgui.same_line()
    if imgui.button(util_gui.tr("mod.button_reset_posted")) then
        mod_map.posted_quests:clear()
        changed = true
    end

    imgui.same_line()
    local size = mod_map.posted_quests:size()
    imgui.text(
        string.format(
            config.lang:tr("mod.text_posted_quests"),
            size,
            size == 1 and config.lang:tr("misc.text_quest")
                or config.lang:tr("misc.text_quest_plural")
        )
    )

    changed = set:checkbox(util_gui.tr("mod.box_ignore_custom_list"), "mod.ignore_custom_list")
        or changed
    imgui.same_line()
    if imgui.button(util_gui.tr("mod.button_reset_custom_list")) then
        mod_map.custom_quest_list:clear()
        changed = true
    end

    imgui.same_line()
    size = mod_map.custom_quest_list:size()
    imgui.text(
        string.format(
            config.lang:tr("mod.text_posted_quests"),
            size,
            size == 1 and config.lang:tr("misc.text_quest")
                or config.lang:tr("misc.text_quest_plural")
        )
    )

    changed = set:checkbox(util_gui.tr("mod.box_ignore_completed"), "mod.ignore_completed")
        or changed
    changed = set:checkbox(
        util_gui.tr("mod.box_ignore_non_acceptable"),
        "mod.ignore_non_acceptable"
    ) or changed

    changed = draw_ignore_slider(
        "time_limit",
        1,
        ace_map.max_time,
        string.format(
            config.lang:tr("mod.slider_text_time_limit"),
            config_mod.slider_time_limit,
            config_mod.slider_time_limit == 1 and config.lang:tr("misc.text_minute")
                or config.lang:tr("misc.text_minute_plural")
        )
    ) or changed

    changed = draw_chips("rank") or changed
    changed = draw_chips("type") or changed
    changed = draw_chips("quest_target") or changed
    changed = draw_chips("attempts", config.lang:tr("mod.tooltip_attempts")) or changed

    imgui.spacing()

    return changed
end

---@return boolean
local function draw_monster()
    local changed = false
    util_imgui.separator_text(
        config.lang:tr("mod.category_ignore_monster"),
        nil,
        nil,
        mod_map.colors.blue
    )

    changed = draw_chips("monster_grade") or changed
    changed = draw_chips("monster") or changed
    changed = draw_chips("monster_species") or changed
    changed = draw_chips("monster_state") or changed
    changed = draw_chips("monster_target") or changed

    imgui.spacing()

    return changed
end

---@return boolean
local function draw_map()
    local changed = false
    util_imgui.separator_text(
        config.lang:tr("mod.category_ignore_map"),
        nil,
        nil,
        mod_map.colors.blue
    )
    changed = draw_chips("map") or changed
    changed = draw_chips("environ") or changed

    imgui.spacing()

    return changed
end

---@return boolean
local function draw_misc()
    local config_mod = config.current.mod
    local changed = false

    util_imgui.separator_text(config.lang:tr("mod.category_misc"), nil, nil, mod_map.colors.blue)
    checkbox_tri.draw_legend({
        config.lang:tr("mod.text_legend_disabled"),
        config.lang:tr("mod.text_legend_prefer"),
        config.lang:tr("mod.text_legend_require"),
    }, config.lang:tr("mod.text_legend"))
    util_imgui.tooltip(config.lang:tr("mod.tooltip_legend"))
    util_imgui.tooltip(config.lang:tr("mod.tooltip_prefer"), true)
    imgui.separator()

    changed = set:checkbox_tri(
        util_gui.tr("mod.box_require_item_wishlist", "any"),
        "mod.require_item_wishlist_any"
    ) or changed
    util_imgui.tooltip(config.lang:tr("mod.tooltip_item_wishlist_any"), true)

    changed = set:checkbox_tri(
        util_gui.tr("mod.box_require_current_stage"),
        "mod.require_current_stage"
    ) or changed
    util_imgui.tooltip_text(config.lang:tr("mod.tooltip_investigations_only"))

    changed = set:checkbox_tri(util_gui.tr("mod.box_require_spoffer"), "mod.require_spoffer")
        or changed
    util_imgui.tooltip(config.lang:tr("mod.tooltip_require_spoffer"), true)

    changed = set:checkbox_tri(util_gui.tr("mod.box_require_boost"), "mod.require_boost") or changed
    changed = set:checkbox_tri(
        util_gui.tr("mod.box_require_item_wishlist"),
        "mod.require_item_wishlist"
    ) or changed
    util_imgui.tooltip(config.lang:tr("mod.tooltip_item_wishlist"), true)

    changed = set:checkbox_tri(util_gui.tr("mod.box_require_item_rare"), "mod.require_item_rare")
        or changed
    util_imgui.tooltip(config.lang:tr("mod.tooltip_item_rare"), true)

    changed = set:checkbox_tri("##require_judge_item", "mod.require_item_judge") or changed
    imgui.same_line()
    imgui.begin_disabled(not config_mod.require_item_judge)
    changed = set:combo("##combo_item_judge", "mod.combo_item_judge", state.combo.item.values)
        or changed
    imgui.end_disabled()

    util_imgui.tooltip_text(config.lang:tr("mod.tooltip_field"))
    changed = set:checkbox(util_gui.tr("mod.box_prefer_expiring_soon"), "mod.prefer_expiring_soon")
        or changed
    util_imgui.tooltip(config.lang:tr("mod.tooltip_prefer_expiring_soon"), true)

    imgui.spacing()

    return changed
end

local function draw_top_menu()
    local config_mod = config.current.mod
    set:radio_group(
        "quest_start_type_radio",
        "mod.quest_start_type",
        util_table.map_table(mod_enum.quest_start, function(o)
            return mod_enum.quest_start[o]
        end, function(o)
            local key = util_table.reverse_lookup(mod_enum.quest_start, o)
            return config.lang:tr("mod.radio_start_quest." .. key)
        end),
        nil,
        false,
        true
    )
    util_imgui.tooltip(config.lang:tr("mod.tooltip_radio_start_quest"), true)
    imgui.separator()

    set:input_text(util_gui.tr("mod.input_quest_id"), "mod.quest_id")
    local quest_name = config.lang:tr("misc.text_none")
    local quest = ace_map.quests[config_mod.quest_id]

    if quest then
        quest_name = string.format(
            "%s | %s | %s",
            quest.title,
            quest.stage_name,
            quest.level .. config.lang:tr("misc.text_star")
        )
    end
    util_imgui.tooltip(quest_name)

    imgui.begin_disabled(not util_randomizer.post_ok())
    if imgui.button(util_gui.tr("mod.button_post")) then
        util_randomizer.request_mod_action(mod_enum.mod_action.POST)
    end
    imgui.end_disabled()
    imgui.same_line()

    imgui.begin_disabled(not util_randomizer.rand_ok())
    if imgui.button(util_gui.tr("mod.button_randomize")) then
        util_randomizer.request_mod_action(mod_enum.mod_action.ROLL)
    end
    imgui.end_disabled()

    imgui.same_line()
    imgui.text(
        string.format(
            "%s/%s %s",
            util_table.size(randomizer.filtered),
            config_mod.use_custom_list and mod_map.custom_quest_list:size()
                or util_table.size(ace_map.quests),
            config.lang:tr("misc.text_quest_plural")
        )
    )
end

function this.draw()
    local gui_main = config.gui.current.gui.main
    local config_mod = config.current.mod

    imgui.set_next_window_pos(Vector2f.new(gui_main.pos_x, gui_main.pos_y), this.window.condition)
    imgui.set_next_window_size(
        Vector2f.new(gui_main.size_x, gui_main.size_y),
        this.window.condition
    )

    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    gui_main.is_opened = imgui.begin_window(
        string.format("%s %s", config.name, config.commit),
        gui_main.is_opened,
        this.window.flags
    )

    util_imgui.set_win_state(gui_main)

    if not gui_main.is_opened then
        if config.lang.font then
            imgui.pop_font()
        end

        config.save_global()
        imgui.end_window()
        return
    end

    if imgui.begin_menu_bar() then
        menu_bar.draw()
        imgui.end_menu_bar()
    end

    imgui.spacing()
    imgui.indent(3)

    imgui.begin_disabled(not config_mod.enabled)

    local changed = false
    draw_top_menu()
    changed = draw_quest_attr() or changed
    changed = draw_monster() or changed
    changed = draw_map() or changed
    changed = draw_misc() or changed

    if changed then
        util_randomizer.request_mod_action(mod_enum.mod_action.FILTER)
    end

    imgui.end_disabled()

    if config.lang.font then
        imgui.pop_font()
    end

    imgui.unindent(3)
    imgui.spacing()
    imgui.end_window()
end

---@return boolean
function this.init()
    state.init()
    return true
end

return this
