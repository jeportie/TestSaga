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

local explorer_buf = nil
local explorer_win = nil

-- Helper: convert plain text lines to virt text format.
local function convert_lines_to_virt(lines)
	local virt_lines = {}
	for _, line in ipairs(lines) do
		-- Wrap each line in a cell table; using "Normal" as the highlight group.
		table.insert(virt_lines, { { line, "Normal" } })
	end
	return virt_lines
end

local function create_explorer_window()
	explorer_buf = api.nvim_create_buf(false, true)

	local lines = {
		"  Test Explorer", -- Title with a devicon.
		"────────────────────────────",
		"  Test Suite 1",
		"     Test 1.1",
		"     Test 1.2",
		"  Test Suite 2",
		"     Test 2.1",
		"     Test 2.2",
	}
	api.nvim_buf_set_lines(explorer_buf, 0, -1, false, lines)

	local ns = api.nvim_create_namespace("VisuSagaExplorer")

	-- Define a minimal layout; note that we convert buffer lines to virt text.
	local layout = {
		{
			name = "explorer",
			lines = function(buf)
				local plain_lines = api.nvim_buf_get_lines(buf, 0, -1, false)
				return convert_lines_to_virt(plain_lines)
			end,
			row = 0, -- starting row for the section
			col_start = 2, -- horizontal padding
		},
	}

	-- Initialize Volt state for our buffer.
	volt.gen_data({
		{ buf = explorer_buf, xpad = 2, layout = layout, ns = ns },
	})

	local explorer_opts = {
		h = #lines, -- height equals number of lines
		w = 30, -- fixed width; adjust as needed
		xpad = 2, -- horizontal padding
		-- Additional Volt options (border, position, etc.) can be added here.
	}

	-- Create the floating window using Volt.
	volt.run(explorer_buf, explorer_opts)
	explorer_win = api.nvim_get_current_win()
end

function Explorer.open()
	if not (explorer_win and api.nvim_win_is_valid(explorer_win)) then
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
