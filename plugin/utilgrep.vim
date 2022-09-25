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

    nnoremap         ;bb    :"Search-rg all         "<c-U>Rg <c-r>=utils#GetSelected('n')<cr>
    nnoremap  <leader>bb    :"Search-rg all         "<c-U>Rg <c-r>=utils#GetSelected('n')<cr>

    nnoremap  <leader>gg    :"Search 'g:c_utils_prefer_dir' from '.vimrc.before'  "<c-U><C-\>e utilgrep#Grep(0, 0, g:c_utils_prefer_dir, 1)<cr>
    nnoremap         ;gg    :"Search 'g:c_utils_prefer_dir' from '.vimrc.before'  "<c-U><C-\>e utilgrep#Grep(0, 0, "",           1)<cr>
    vnoremap  <leader>gg    :<C-\>e utilgrep#Grep(0, 1, g:c_utils_prefer_dir, 1)<cr>
    vnoremap         ;gg    :<C-\>e utilgrep#Grep(0, 1, "",           1)<cr>

    nnoremap  <leader>vv    :"Search all            "<c-U><C-\>e utilgrep#Grep(0, 0, "",           1)<cr>
    nnoremap         ;vv    :"Search all            "<c-U><C-\>e utilgrep#Grep(0, 0, "",           1)<cr>
    vnoremap  <leader>vv    :<C-\>e utilgrep#Grep(0, 1, "",           1)<cr>
    vnoremap         ;vv    :<C-\>e utilgrep#Grep(0, 1, "",           1)<cr>

    nnoremap gf :"open File:number          "<c-U>call utils#GotoFileWithLineNum(0)<CR>
    nnoremap <silent> <leader>gf :"open File in preview window   "<c-U>call utils#GotoFileWithPreview()<CR>
endif

