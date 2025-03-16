-- -------------------------------------------------------------------------- --
--                                                                            --
--                                                        :::      ::::::::   --
--   explorer.lua                                       :+:      :+:    :+:   --
--                                                    +:+ +:+         +:+     --
--   By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+        --
--                                                +#+#+#+#+#+   +#+           --
--   Created: 2025/03/16 17:53:58 by jeportie          #+#    #+#             --
--   Updated: 2025/03/16 17:54:02 by jeportie         ###   ########.fr       --
--                                                                            --
-- -------------------------------------------------------------------------- --

local api = vim.api
local volt = require("volt")

local Explorer = {}

local explorer_buf, explorer_win = nil, nil

-- Helper: fill the buffer with blank lines.
local function set_explorer_empty_lines(buf, height, width)
  api.nvim_buf_set_option(buf, "modifiable", true)
  local lines = {}
  for i = 1, height do
    table.insert(lines, string.rep(" ", width))
  end
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  api.nvim_buf_set_option(buf, "modifiable", false)
end

-- Our mock content for the explorer.
local mock_lines = {
  "  Test Explorer",          -- Title with a NerdFont devicon
  "────────────────────────────",
  "  Test Suite 1",
  "     Test 1.1",
  "     Test 1.2",
  "  Test Suite 2",
  "     Test 2.1",
  "     Test 2.2",
}

local explorer_height = #mock_lines
local explorer_width = 30

-- Layout function returns our virt text version of the mock content.
local function explorer_layout(buf)
  local virt_lines = {}
  for _, line in ipairs(mock_lines) do
    table.insert(virt_lines, { { line, "Normal" } })
  end
  return virt_lines
end

local function create_explorer_window()
  explorer_buf = api.nvim_create_buf(false, true)
  -- Set buffer options.
  api.nvim_buf_set_option(explorer_buf, "buftype", "nofile")
  api.nvim_buf_set_option(explorer_buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(explorer_buf, "modifiable", false)
  api.nvim_buf_set_option(explorer_buf, "filetype", "TestExplorer")

  -- Create a namespace for Volt.
  local ns = api.nvim_create_namespace("VisuSagaExplorer")

  -- Define a layout that uses our layout function.
  local layout = {
    {
      name = "explorer",
      lines = explorer_layout,
      row = 0,
      col_start = 0,
    },
  }

  -- Initialize Volt state.
  volt.gen_data({
    { buf = explorer_buf, layout = layout, xpad = 0, ns = ns },
  })

  -- Open a floating window positioned on the right side.
  local opts = {
    row = 0,
    col = vim.o.columns - explorer_width,
    width = explorer_width,
    height = explorer_height,
    relative = "editor",
    style = "minimal",
    border = "single",
    zindex = 100,
  }
  explorer_win = api.nvim_open_win(explorer_buf, true, opts)
  api.nvim_win_set_option(explorer_win, "number", false)
  api.nvim_win_set_option(explorer_win, "relativenumber", false)
  api.nvim_win_set_option(explorer_win, "cursorline", false)

  -- Fill the buffer with blank lines so that only Volt's virt_text is visible.
  set_explorer_empty_lines(explorer_buf, explorer_height, explorer_width)

  -- Render the explorer UI via Volt.
  local volt_opts = {
    h = explorer_height,
    w = explorer_width,
    custom_empty_lines = function(buf, h, w)
      set_explorer_empty_lines(buf, h, w)
    end,
  }
  volt.run(explorer_buf, volt_opts)
end

function Explorer.open()
  if explorer_win and api.nvim_win_is_valid(explorer_win) then
    return
  else
    create_explorer_window()
  end
end

function Explorer.close()
  if explorer_win and api.nvim_win_is_valid(explorer_win) then
    api.nvim_win_close(explorer_win, true)
    explorer_win = nil
    explorer_buf = nil
  end
end

function Explorer.toggle()
  if explorer_win and api.nvim_win_is_valid(explorer_win) then
    Explorer.close()
  else
    Explorer.open()
  end
end

return Explorer

