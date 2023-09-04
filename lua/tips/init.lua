local M = {}

local cnf = require("tips.config")
-- local nui_text = require("nui.text")

local api = vim.api

local buf, win, border_win
local position = 0

-- highlight group and defines
local CheatSheet = api.nvim_create_namespace("CheatSheet")

vim.api.nvim_set_hl(0, "CheatSheetHeading0", { fg = "#c099ff" })
vim.api.nvim_set_hl(0, "CheatSheetHeading1", { fg = "#ff007c" })
vim.api.nvim_set_hl(0, "CheatSheetSubHeading", { fg = "#1e2030", bg = "#3e68d7" })
vim.api.nvim_set_hl(0, "CheatSheetSection", { fg = "#c8d3f5", bg = "#1e2030" })

local hlgroups = {
    heading0 = "CheatSheetHeading0",
    heading1 = "CheatSheetHeading1",
    mapping = "CheatSheetSection",
    padding = "CheatSheetSection",
    subheading = "CheatSheetSubHeading",
    cursorline = "CheatSheetCursorLine",
    empty = "none",
}

local function center(str)
    local center_point = api.nvim_win_get_width(win) / 2
    local padding_size = center_point - (vim.fn.strwidth(str) / 2)
    local right_padding = string.rep(" ", padding_size)
    return string.rep(" ", padding_size) .. str .. right_padding
end

local end_line_of_title = 0
local function open_window()
    -- create new empty buffer
    buf = api.nvim_create_buf(false, true)
    local border_buf = api.nvim_create_buf(false, true)

    -- options: delete window when buffer be hidden
    api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    -- get dimensions
    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")
    local center_point = width / 2

    -- calculate floating window size and start position
    local win_width = math.ceil(width * 0.8)
    local win_height = math.ceil(height * 0.9 - 4)
    local start_row = math.ceil((height - win_height) / 2 - 1)
    local start_col = math.ceil((width - win_width) / 2)

    -- set some border window options
    local border_opts = {
        style = "minimal",
        relative = "editor",
        width = win_width + 2,
        height = win_height + 2,
        row = start_row - 1,
        col = start_col - 1,
    }

    -- set some window options
    local opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = start_row,
        col = start_col,
    }

    -- add border buffer under the main buffer
    -- local border_lines = { "╔" .. string.rep("═", win_width) .. "╗" }
    -- local middle_line = "║" .. string.rep(" ", win_width) .. "║"
    -- for i = 1, win_height do
    --     table.insert(border_lines, middle_line)
    -- end
    -- table.insert(border_lines, "╚" .. string.rep("═", win_width) .. "╝")
    -- api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)
    -- api.nvim_buf_set_lines(buf, 0, -1, false, border_lines)

    border_win = api.nvim_open_win(border_buf, true, border_opts)
    api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

    -- create float window with buffer attached
    win = api.nvim_open_win(buf, true, opts)

    -- highlight line with the cursor on it
    api.nvim_win_set_option(win, "cursorline", true)

    -- add title already here, because first line will never change
    api.nvim_buf_set_lines(buf, 1, -1, false, {
        center(
            "█▀▀ █░█ █▀▀ ▄▀█ ▀█▀ █▀ █░█ █▀▀ █▀▀ ▀█▀"
        ),
        center(
            "█▄▄ █▀█ ██▄ █▀█ ░█░ ▄█ █▀█ ██▄ ██▄ ░█░"
        ),
        center("                                      "),
    })
    api.nvim_buf_add_highlight(buf, CheatSheet, hlgroups["heading0"], 0, 0, -1)
    api.nvim_buf_add_highlight(buf, CheatSheet, hlgroups["heading1"], 1, 0, -1)
    end_line_of_title = 3
end

function M.update_view(direction)
    vim.opt_local.modifiable = true

    local cards = {}

    cards["Ufo"] = {
        { "n", "zR", "Extract warp" },
    }
    cards["Telescope"] = {
        { "n", "gd", "Goto Defination" },
        { "n", "gr", "Goto Reference" },
    }
    cards["Bufferline"] = {
        { "n", "<Tab>", "Switch to next buffer" },
        { "n", "<Alt-Num>", "Switch to peek buffer with <Num> ID" },
    }

    local result = {}
    local lineDesc = {}

    for title, items in pairs(cards) do
        -- result[#result + 1] = center(title)
        lineDesc[#lineDesc + 1] = "subheading"

        result[#result + 1] = center(title)
        for i = 1, #items do
            local item = items[i]
            result[#result + 1] = item[1] .. " " .. item[2]
        end
    end

    -- we will use vim systemlist function which run shell
    -- command and return resutl as list
    -- local result = vim.fn.systemlist('git diff-tree --no-commit-id --name-only -r HEAD~' .. position)

    -- add an empty line to prevent layout if result is empty
    -- if #result == 0 then
    --   table.insert(result, '')
    -- end

    -- with small indentation results will look better
    -- for k, v in pairs(result) do
    --   result[k] = '  ' .. result[k]
    -- end

    -- put header into buffer
    -- api.nvim_buf_set_lines(buf, 1, 2, false, {
    --   center('HEAD~' .. position),
    --   ''
    -- })

    -- put result into buffer
    api.nvim_buf_set_lines(buf, end_line_of_title + 1, -1, false, result)

    -- set hightlight to header text
    for i, v in ipairs(lineDesc) do
        api.nvim_buf_add_highlight(buf, CheatSheet, hlgroups[v], end_line_of_title + i, 1, -2)
    end
    --hlgroups[v]
    -- disable float window edit method
    vim.opt_local.buflisted = false
    vim.opt_local.modifiable = false
    vim.opt_local.buftype = "nofile"
    vim.opt_local.filetype = "tips"
    vim.opt_local.number = false
    vim.opt_local.list = false
    vim.opt_local.wrap = false
    vim.opt_local.relativenumber = false
    vim.opt_local.cul = false
end

function M.close_window()
    api.nvim_win_close(border_win, true)
    api.nvim_win_close(win, true)
end

-- our file list start at line 4, so we can prevent reaching above it
-- from bottom the end of the buffer will limit movement
function M.move_cursor(direction)
    local new_pos = math.max(end_line_of_title + 2, api.nvim_win_get_cursor(win)[1] + direction)
    api.nvim_win_set_cursor(win, { new_pos, 0 })
end

-- open file under cursor
function M.open_file()
    local str = api.nvim_get_current_line()
    close_window()
    api.nvim_command("edit " .. str)
end

local function set_mappings()
    local mappings = {
        ["["] = "update_view(-1)",
        ["]"] = "update_view(1)",
        ["<CR>"] = "open_file()",
        h = "update_view(-1)",
        l = "update_view(1)",
        q = "close_window()",
        k = "move_cursor(-1)",
        j = "move_cursor(1)",
    }

    for k, v in pairs(mappings) do
        api.nvim_buf_set_keymap(buf, "n", k, ':lua require("tips").' .. v .. "<CR>", {
            nowait = true,
            noremap = true,
            silent = true,
        })
    end
end

function M.setup(custom_opts)
    vim.api.nvim_set_keymap("n", "<leader>ot", "<Cmd> TipsToggle <CR>", { noremap = true })

    local command = vim.api.nvim_create_user_command

    command("TipsToggle", function()
        open_window()
        set_mappings()
        M.update_view(0)

        -- set cursor on first list entry
        api.nvim_win_set_cursor(win, { end_line_of_title + 2, 0 })
    end, { desc = "Toggle Tips" })

    cnf:set_options(custom_opts)
end

return M
