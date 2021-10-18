if exists('g:loaded_c_utils_utilgrep') || &compatible
    finish
endif
let g:loaded_c_utils_utilgrep = 1
if g:loaded_c_utils_utilgrep == 1
    let g:loaded_c_utils_utilgrep = 2
    if !exists(":Shortcut")
        command! -nargs=+ Shortcut <Nop>
    endif
endif

" Grep utility
if !exists("g:grepprg")
  let output = system("git rev-parse --is-inside-work-tree")
  let is_git_repo = v:shell_error == 0

  if is_git_repo
    let g:grepprg="git --no-pager grep -n"
  else
    if executable("ag")
      "let g:grepprg="ag --nogroup --column --hidden"
      let g:grepprg="ag --nogroup"
    else
      let g:grepprg="grep -rnH"
    endif
  endif
endif


let g:c_utils_map = get(g:, 'c_utils_map', 0)
if g:c_utils_map
    let g:c_utils_prefer_dir = get(g:, 'c_utils_prefer_dir', '')

    nnoremap         ;bb    :Rg <c-r>=utils#GetSelected('n')<cr>
    nnoremap  <leader>bb    :Rg <c-r>=utils#GetSelected('n')<cr>
    " vnoremap         ;bb    :<c-u>Rg <c-r>=utils#GetSelected('v')<cr>
    " vnoremap  <leader>bb    :<c-u>Rg <c-r>=utils#GetSelected('v')<cr>

    nnoremap  <leader>gg    :<C-\>e utilgrep#Grep(0, 0, g:c_utils_prefer_dir, 1)<cr>
    nnoremap         ;gg    :<C-\>e utilgrep#Grep(0, 0, "",           1)<cr>
    vnoremap  <leader>gg    :<C-\>e utilgrep#Grep(0, 1, g:c_utils_prefer_dir, 1)<cr>
    vnoremap         ;gg    :<C-\>e utilgrep#Grep(0, 1, "",           1)<cr>

    nnoremap  <leader>vv    :<C-\>e utilgrep#Grep(0, 0, "",           1)<cr>
    nnoremap         ;vv    :<C-\>e utilgrep#Grep(0, 0, "",           1)<cr>
    vnoremap  <leader>vv    :<C-\>e utilgrep#Grep(0, 1, "",           1)<cr>
    vnoremap         ;vv    :<C-\>e utilgrep#Grep(0, 1, "",           1)<cr>

    Shortcut!  ;gg    Search wad
    Shortcut!  ;vv    Search all

    " Giveback the 'g' to git
    " nnoremap ;gg :<C-\>e utilgrep#Grep(0, 0, "daemon/wad", 0)<cr>
    " vnoremap ;gg :<C-\>e utilgrep#Grep(0, 1, "daemon/wad", 0)<cr>
    " nnoremap ;vv :<C-\>e utilgrep#Grep(0, 0, "", 0)<cr>
    " vnoremap ;vv :<C-\>e utilgrep#Grep(0, 1, "", 0)<cr>

    nnoremap gf :<c-u>call utils#GotoFileWithLineNum(0)<CR>
    nnoremap <silent> <leader>gf :<c-u>call utils#GotoFileWithPreview()<CR>
    Shortcut! <space>gf    File Goto preview

endif

