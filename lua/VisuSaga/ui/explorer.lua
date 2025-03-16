-- -------------------------------------------------------------------------- --
--                                                                            --
--                                                        :::      ::::::::   --
--   explorer.lua                                       :+:      :+:    :+:   --
--                                                    +:+ +:+         +:+     --
--   By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+        --
--                                                +#+#+#+#+#+   +#+           --
--   Created: 2025/03/16 17:50:41 by jeportie          #+#    #+#             --
--   Updated: 2025/03/16 17:50:44 by jeportie         ###   ########.fr       --
--                                                                            --
-- -------------------------------------------------------------------------- --

local api = vim.api
local volt = require("volt")

local Explorer = {}

local explorer_buf, explorer_win = nil, nil

-- Our mock content – one line per entry.
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

-- A helper to create blank lines for our buffer.
local function set_explorer_empty_lines(buf, height, width)
  local lines = {}
  for i = 1, height do
    table.insert(lines, string.rep(" ", width))
  end
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- Our layout function: instead of reading the raw buffer, we return our virt text.
local function explorer_layout(buf)
  local virt_lines = {}
  for _, line in ipairs(mock_lines) do
    table.insert(virt_lines, { { line, "Normal" } })
  end
  return virt_lines
end

local function create_explorer_window()
  -- Create the explorer buffer.
  explorer_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(explorer_buf, "buftype", "nofile")
  api.nvim_buf_set_option(explorer_buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(explorer_buf, "modifiable", false)
  api.nvim_buf_set_option(explorer_buf, "filetype", "TestExplorer")

  -- Create a namespace for Volt.
  local ns = api.nvim_create_namespace("VisuSagaExplorer")

  -- Define a minimal layout using our layout function.
  local layout = {
    {
      name = "explorer",
      lines = explorer_layout,
      row = 0,
      col_start = 0,  -- no extra horizontal padding here
    },
  }

  -- Initialize Volt's state for this buffer.
  volt.gen_data({
    { buf = explorer_buf, layout = layout, xpad = 0, ns = ns },
  })

  -- Open the explorer window as a floating window positioned on the right.
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
  -- Disable line numbers, relative numbers, etc.
  api.nvim_win_set_option(explorer_win, "number", false)
  api.nvim_win_set_option(explorer_win, "relativenumber", false)
  api.nvim_win_set_option(explorer_win, "cursorline", false)

  -- Fill the buffer with blank lines so that only Volt's virt_text shows.
  set_explorer_empty_lines(explorer_buf, explorer_height, explorer_width)

  -- Run Volt on our buffer.
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

