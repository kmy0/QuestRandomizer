local util_misc = require("QuestRandomizer.util.misc.init")

local this = {}

local COL_FRAME_BG = 0xFF3F3535
local COL_FRAME_BG_HOVERED = 0xFF4F4E4D
local COL_FRAME_BG_ACTIVE = 0xFF8D8C8C
local COL_CHECK = 0xFF8D8C8C
local COL_DASH = 0xFF8D8C8C
local COL_TEXT = 0xFFFFFFFF
local DISABLED_ALPHA = 0.6

local FRAME_PADDING_Y = 3.0
local ITEM_PADDING = 3.0
local ROUNDING = 7.0

---@enum CheckboxTri
this.state = {
    NONE = 1,
    MIXED = 2,
    ON = 3,
}

local CYCLE = {
    [this.state.NONE] = this.state.MIXED,
    [this.state.ON] = this.state.NONE,
    [this.state.MIXED] = this.state.ON,
}

---comment
---@param id string
---@param size Vector2f
---@return boolean
local function invisible_button(id, size)
    --[[
        imgui.inivisible_button
        imgui.same_line
        imgui.text
        for whatever reason imgui.text is not centered, it just starts at 0,0, cba figuring this shit out
    ]]
    imgui.push_style_color(21, 0x00000000)
    imgui.push_style_color(22, 0x00000000)
    imgui.push_style_color(23, 0x00000000)
    local ret = imgui.button("##" .. id, size)
    imgui.pop_style_color(3)
    return ret
end

---@param dl ImDrawList
---@param p Vector2f
---@param size number
---@param col integer
local function draw_checkmark(dl, p, size, col)
    local pad = math.max(1.0, math.floor(size / 6.0))
    local sz = size - pad * 2.0
    local thickness = math.max(sz / 5.0, 1.0)
    sz = sz - thickness * 0.5
    local ox = p.x + pad + thickness * 0.25
    local oy = p.y + pad + thickness * 0.25
    local third = sz / 3.0
    local bx = ox + third
    local by = oy + sz - third * 0.5
    dl:path_line_to(Vector2f.new(bx - third, by - third))
    dl:path_line_to(Vector2f.new(bx, by))
    dl:path_line_to(Vector2f.new(bx + third * 2.0, by - third * 2.0))
    dl:path_stroke(col, 0, thickness)
end

---@param dl ImDrawList
---@param p Vector2f
---@param size number
---@param col integer
local function draw_dash(dl, p, size, col)
    local pad = math.floor(size / 3.6)
    local mid = p.y + size * 0.5
    local thickness = math.max(math.floor(size / 3.6), 1.0)
    dl:path_line_to(Vector2f.new(p.x + pad, mid))
    dl:path_line_to(Vector2f.new(p.x + size - pad, mid))
    dl:path_stroke(col, 0, thickness)
end

---@param dl ImDrawList
---@param p Vector2f
---@param size number
---@param state CheckboxTri
---@return number next_x
local function draw_legend_item(dl, p, size, state)
    dl:add_rect_filled(p, Vector2f.new(p.x + size, p.y + size), COL_FRAME_BG, ROUNDING, 0)
    if state == this.state.ON then
        draw_checkmark(dl, p, size, COL_CHECK)
    elseif state == this.state.MIXED then
        draw_dash(dl, p, size, COL_DASH)
    end
    return p.x + size
end

---@param labels table<CheckboxTri, string>
---@param title string?
function this.draw_legend(labels, title)
    local y = imgui.calc_text_size("X").y
    local size = y + FRAME_PADDING_Y * 2
    local dl = imgui.get_window_draw_list()
    local p = imgui.get_cursor_screen_pos()
    local x = p.x

    if title then
        local title_size = imgui.calc_text_size(title)
        local ty = p.y + size * 0.5 - title_size.y * 0.5
        dl:add_text(Vector2f.new(x, ty), COL_TEXT, title)
        x = x + title_size.x + ITEM_PADDING * 2
    end

    for state, label in ipairs(labels) do
        local origin = Vector2f.new(x, p.y)
        x = draw_legend_item(dl, origin, size, state)

        if label and label ~= "" then
            local lbl_size = imgui.calc_text_size(label)
            local tx = x + ITEM_PADDING
            local ty = p.y + size * 0.5 - lbl_size.y * 0.5
            dl:add_text(Vector2f.new(tx, ty), COL_TEXT, label)
            x = x + ITEM_PADDING + lbl_size.x + ITEM_PADDING * 2
        else
            x = x + ITEM_PADDING * 2
        end
    end

    invisible_button(
        tostring(labels),
        Vector2f.new(x - p.x - ITEM_PADDING * 2, y + ITEM_PADDING * 2)
    )
end

---@param label string
---@param state CheckboxTri
---@param disabled boolean?
---@return boolean, CheckboxTri
function this.checkbox_tri(label, state, disabled)
    local changed = false
    local id
    label, id = table.unpack(util_misc.split_string(label, "##"))
    id = id or label

    local size = imgui.calc_text_size("X").y + FRAME_PADDING_Y * 2
    local label_size = imgui.calc_text_size(label)
    local size_x = size + (label ~= "" and label_size.x + ITEM_PADDING or 0)

    local dl = imgui.get_window_draw_list()
    local p = imgui.get_cursor_screen_pos()
    local clicked = invisible_button(id, Vector2f.new(size_x, size))
    local hovered = imgui.is_item_hovered() and not disabled
    local is_active = imgui.is_item_active() and not disabled

    if clicked and not disabled then
        state = CYCLE[state]
        changed = true
    end

    local col_fill = is_active and COL_FRAME_BG_ACTIVE
        or hovered and COL_FRAME_BG_HOVERED
        or COL_FRAME_BG
    local col_mark = COL_CHECK
    local col_dash = COL_DASH
    local col_text = COL_TEXT

    if disabled then
        col_fill = util_misc.mul_alpha(col_fill, DISABLED_ALPHA)
        col_mark = util_misc.mul_alpha(col_mark, DISABLED_ALPHA)
        col_dash = util_misc.mul_alpha(col_dash, DISABLED_ALPHA)
        col_text = util_misc.mul_alpha(col_text, DISABLED_ALPHA)
    end

    dl:add_rect_filled(p, Vector2f.new(p.x + size, p.y + size), col_fill, ROUNDING, 0)

    if state == this.state.ON then
        draw_checkmark(dl, p, size, col_mark)
    elseif state == this.state.MIXED then
        draw_dash(dl, p, size, col_dash)
    end

    if label ~= "" then
        local tx = p.x + size + ITEM_PADDING
        local ty = p.y + size * 0.5 - label_size.y * 0.5

        dl:add_text(Vector2f.new(tx, ty), col_text, label)
    end

    return changed, state
end

return this
