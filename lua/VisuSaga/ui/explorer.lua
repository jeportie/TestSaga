-- -------------------------------------------------------------------------- --
--                                                                            --
--                                                        :::      ::::::::   --
--   explorer.lua                                       :+:      :+:    :+:   --
--                                                    +:+ +:+         +:+     --
--   By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+        --
--                                                +#+#+#+#+#+   +#+           --
--   Created: 2025/03/16 18:09:17 by jeportie          #+#    #+#             --
--   Updated: 2025/03/16 18:09:21 by jeportie         ###   ########.fr       --
--                                                                            --
-- -------------------------------------------------------------------------- --

local api = vim.api
local volt = require("volt")

local Explorer = {}

local explorer_buf, explorer_win = nil, nil
local explorer_ns = api.nvim_create_namespace("TestExplorer")

-- Our mock data for the explorer (feel free to update icons or text)
local mock_lines = {
  "  Test Explorer",         -- Title with a NerdFont devicon
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

-- Layout function: converts each mock line into a virt_text line
local function explorer_layout()
  local virt_lines = {}
  for _, line in ipairs(mock_lines) do
    table.insert(virt_lines, { { line, "Normal" } })
  end
  return virt_lines
end

local function create_explorer_window()
  -- Create a scratch buffer for the explorer.
  explorer_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(explorer_buf, "buftype", "nofile")
  api.nvim_buf_set_option(explorer_buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(explorer_buf, "filetype", "TestExplorer")

  -- Define a simple layout using our explorer_layout function.
  local layout = {
    {
      name = "explorer",
      lines = explorer_layout,
      row = 0,
      col_start = 0,
    },
  }

  -- Register the layout with Volt (like Typr does).
  volt.gen_data({ { buf = explorer_buf, layout = layout, xpad = 0, ns = explorer_ns } })

  -- Create a floating window on the right side.
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

  -- Run Volt to render our layout.
  volt.run(explorer_buf, { h = explorer_height, w = explorer_width })
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

