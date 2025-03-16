-- -------------------------------------------------------------------------- --
--                                                                            --
--                                                        :::      ::::::::   --
--   explorer.lua                                       :+:      :+:    :+:   --
--                                                    +:+ +:+         +:+     --
--   By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+        --
--                                                +#+#+#+#+#+   +#+           --
--   Created: 2025/03/16 15:32:21 by jeportie          #+#    #+#             --
--   Updated: 2025/03/16 15:36:18 by jeportie         ###   ########.fr       --
--                                                                            --
-- -------------------------------------------------------------------------- --

local api = vim.api
local volt = require("volt")

local Explorer = {}

-- Internal state to track the buffer and window IDs.
local explorer_buf = nil
local explorer_win = nil

-- Create and open the explorer window.
local function create_explorer_window()
  explorer_buf = api.nvim_create_buf(false, true)
  -- Populate the buffer with some mock explorer content.
  local lines = {
    "  Test Explorer",           -- Top title (use your preferred devicon)
    "────────────────────────────",
    "  Test Suite 1",
    "     Test 1.1",
    "     Test 1.2",
    "  Test Suite 2",
    "     Test 2.1",
    "     Test 2.2",
  }
  api.nvim_buf_set_lines(explorer_buf, 0, -1, false, lines)

  -- Set up Volt options.
  local explorer_opts = {
    h = #lines,   -- height equals the number of lines
    w = 30,       -- fixed width (adjust as needed)
    xpad = 2,     -- optional horizontal padding
    -- You can add more options (e.g. border, position) from Volt's API here.
  }
  -- Use Volt to create the floating window.
  volt.run(explorer_buf, explorer_opts)
  -- Retrieve the current window id (assuming Volt makes it the current window).
  explorer_win = api.nvim_get_current_win()
end

-- Open the explorer window if it is not already open.
function Explorer.open()
  if not (explorer_win and api.nvim_win_is_valid(explorer_win)) then
    create_explorer_window()
  end
end

-- Close the explorer window if it is open.
function Explorer.close()
  if explorer_win and api.nvim_win_is_valid(explorer_win) then
    api.nvim_win_close(explorer_win, true)
    explorer_win = nil
    explorer_buf = nil
  end
end

-- Toggle the explorer window.
function Explorer.toggle()
  if explorer_win and api.nvim_win_is_valid(explorer_win) then
    Explorer.close()
  else
    Explorer.open()
  end
end

return Explorer

