-- c-utils: Grep utilities and C coding helpers
local M = {}

function M.setup()
  local g = vim.g
  local home = os.getenv("HOME")

  g.tlTokenList = { "FIXME @wilson", "TODO @wilson", "XXX @wilson" }
  g.ctrlsf_mapping = { next = "n", prev = "N" }
  g.utilquickfix_file = home .. "/.vim/vim.quickfix"
  g.c_utils_map = g.c_utils_map or 1
  g.c_utils_prefer_dir = g.c_utils_prefer_dir or ""

  local function get_prefer_dir()
    return (g.c_utils_prefer_dir ~= "") and g.c_utils_prefer_dir or "daemon/wad"
  end

  vim.keymap.set('n', '<leader><leader>', function()
    vim.fn["VimMotionPreview"]()
  end, { silent = true, desc = "[tag] Preview Tag *" })

  vim.keymap.set('v', '<leader><leader>', function()
    vim.fn["VimMotionPreview"]()
  end, { silent = true, desc = "[tag] Preview Tag *" })

  local function prepare_grep(is_visual, dir, to_qf)
    vim.cmd("let g:grepper = {}")
    if is_visual == 1 then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>gv<Esc>", true, false, true), "nx", false)
    end
    local target_dir = ""
    if dir == "prefer" then
      target_dir = get_prefer_dir()
    end
    local cmd = vim.fn["utilgrep#Grep"](0, is_visual, target_dir, to_qf)
    local prefix = is_visual == 1 and ":<C-u>" or ":"
    local keys = vim.api.nvim_replace_termcodes(prefix .. cmd, true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
  end

  vim.keymap.set('n', '<leader>gg', function() prepare_grep(0, "prefer", 1) end, { desc = "[find] Search in *" })
  vim.keymap.set('v', '<leader>gg', function() prepare_grep(1, "prefer", 1) end, { desc = "[find] Search selection in *" })
  vim.keymap.set('n', ';gg',        function() prepare_grep(0, "", 1) end, { desc = "[find] Search all *" })
  vim.keymap.set('v', ';gg',        function() prepare_grep(1, "", 1) end, { desc = "[find] Search all *" })
end

return M
