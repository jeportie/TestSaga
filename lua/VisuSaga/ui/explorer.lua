-- -------------------------------------------------------------------------- --
--                                                                            --
--                                                        :::      ::::::::   --
--   explorer.lua                                       :+:      :+:    :+:   --
--                                                    +:+ +:+         +:+     --
--   By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+        --
--                                                +#+#+#+#+#+   +#+           --
--   Created: 2025/03/16 16:16:31 by jeportie          #+#    #+#             --
--   Updated: 2025/03/16 16:16:42 by jeportie         ###   ########.fr       --
--                                                                            --
-- -------------------------------------------------------------------------- --

local api = vim.api
local volt = require("volt")

local Explorer = {}

local explorer_buf = nil
local explorer_win = nil

-- Helper: convert plain text lines to virt text cells as expected by Volt.
local function convert_lines_to_virt(lines)
	local virt_lines = {}
	for _, line in ipairs(lines) do
		table.insert(virt_lines, { { line, "Normal" } })
	end
	return virt_lines
end

local function create_explorer_window()
	explorer_buf = api.nvim_create_buf(false, true)

	-- Set our mock content in the explorer buffer.
	local lines = {
		"  Test Explorer", -- Title with a NerdFont devicon.
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

	-- Define a minimal layout that uses our buffer content.
	local layout = {
		{
			name = "explorer",
			lines = function(buf)
				local plain_lines = api.nvim_buf_get_lines(buf, 0, -1, false)
				return convert_lines_to_virt(plain_lines)
			end,
			row = 0,
			col_start = 2,
		},
	}

	-- Initialize Volt's state for our explorer buffer.
	volt.gen_data({
		{ buf = explorer_buf, xpad = 2, layout = layout, ns = ns },
	})

	-- Open a right-side vertical split.
	vim.cmd("rightbelow vsplit")
	explorer_win = api.nvim_get_current_win()

	-- Set the explorer window width.
	vim.cmd("vertical resize 30")

	-- Set our explorer buffer into the current window.
	api.nvim_win_set_buf(explorer_win, explorer_buf)

	local explorer_opts = {
		h = #lines, -- height equals the number of lines in our mock content
		w = 30, -- width of the window
		xpad = 2, -- horizontal padding
		-- Prevent Volt from clearing our mock content.
		custom_empty_lines = function() end,
	}

	-- Render the explorer UI via Volt.
	volt.run(explorer_buf, explorer_opts)
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
		-- If explorer_win is the only window, open a new vertical split to avoid closing the last window.
		if #api.nvim_list_wins() == 1 then
			vim.cmd("rightbelow vsplit")
		end
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
