-- c-utils: Grep utilities and C coding helpers
local M = {}

function M.toggle_header_source()
  local function extract_include_path()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    -- find "..." region
    local s1, e1 = line:find('"[^"]-"')
    if s1 and col >= s1 and col <= e1 then
      return line:sub(s1 + 1, e1 - 1)
    end

    -- find <...> region
    local s2, e2 = line:find("<[^>]->")
    if s2 and col >= s2 and col <= e2 then
      return line:sub(s2 + 1, e2 - 1)
    end

    return nil
  end

  local function is_include_like()
    local path = extract_include_path()
    return path ~= nil, path
  end

  local function has_exe(cmd)
    return vim.fn.executable(cmd) == 1
  end


  local function fd_search(name)
    if vim.fn.executable("fd") == 1 then
      return vim.fn.systemlist({
        "fd",
        "--type", "file",
        "--hidden",
        "--follow",
        "--exclude", ".cache",
        "--exclude", ".git",
        "--exclude", "build",
        "--exclude", "node_modules",
        "--extension", "c",
        "--extension", "cpp",
        "--extension", "h",
        name,
      })
    end

    -- fallback: find (more strict filtering manually)
    return vim.fn.systemlist(
      "find . -type f \\( -name '*.c' -o -name '*.cpp' -o -name '*.h' \\) -not -path '*/.cache/*' -name "
      .. vim.fn.shellescape("*" .. name .. "*")
    )
  end

  local function search_file_and_open(name)
    local results = fd_search(name)

    if vim.v.shell_error ~= 0 or #results == 0 then
      return false
    end

    if #results == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(results[1]))
      return true
    end

    -- multiple results → quickfix
    local qf = {}
    for _, f in ipairs(results) do
      table.insert(qf, f .. ":1:1")
    end

    vim.fn.setqflist({}, " ", {
      title = "file search: " .. name,
      lines = qf,
    })

    vim.cmd("copen")
    return true
  end


  local bufname = vim.api.nvim_buf_get_name(0)

  -- 1. FILE MODE (cursor is filename)
  local is_include, target = is_include_like()
  if is_include then
    target = vim.fn.expand("<cfile>")

    -- try direct open first
    if vim.fn.filereadable(target) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(target))
      return
    end

    -- fallback search
    if search_file_and_open(vim.fn.fnamemodify(target, ":t")) then
      return
    end

    vim.notify("No match for file: " .. target, vim.log.levels.WARN)
    return
  end

  -- 2. SOURCE/HEADER TOGGLE MODE
  local new_path

  if bufname:match("%.c$") or bufname:match("%.cpp$") then
    new_path = bufname:gsub("%.[^.]+$", ".h")
  elseif bufname:match("%.h$") then
    new_path = bufname:gsub("%.[^.]+$", ".c")
  end

  -- try open counterpart
  if new_path and vim.fn.filereadable(new_path) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(new_path))
    return
  end

  -- fallback search using filename
  local name = vim.fn.fnamemodify(new_path or bufname, ":t")

  if not search_file_and_open(name) then
    vim.notify("No toggle/search match: " .. name, vim.log.levels.WARN)
  end
end

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

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function(ev)
      vim.keymap.set("n", "<leader>fa", M.toggle_header_source, {
        buffer = ev.buf,
        silent = true,
        desc = "[misc] Toggle source/header",
      })
    end,
  })

end

return M
