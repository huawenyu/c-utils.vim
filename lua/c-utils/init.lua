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

end

return M
