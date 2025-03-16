-- -------------------------------------------------------------------------- --
--                                                                            --
--                                                        :::      ::::::::   --
--   VisuSaga.lua                                       :+:      :+:    :+:   --
--                                                    +:+ +:+         +:+     --
--   By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+        --
--                                                +#+#+#+#+#+   +#+           --
--   Created: 2025/03/16 15:35:19 by jeportie          #+#    #+#             --
--   Updated: 2025/03/16 16:07:15 by jeportie         ###   ########.fr       --
--                                                                            --
-- -------------------------------------------------------------------------- --

vim.api.nvim_create_user_command("ToggleVisuSagaExplorer", function()
  require("VisuSaga.ui.explorer").toggle()
end, {})
