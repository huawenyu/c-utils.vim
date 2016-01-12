" ============================================================================
" File:        utilgrep.vim
" Description: the wrapper of autoload
" ============================================================================

"Init {
if exists('g:loaded_c_utils_utilgrep')
    finish
endif

if &cp || v:version < 700
    echom 'Please use the new vim version > 700'
    finish
endif

let g:loaded_c_utils_utilgrep = 1
"}

" Grep utility
if !exists("g:grepprg")
  let output = system("git rev-parse --is-inside-work-tree")
  let is_git_repo = v:shell_error == 0

  if is_git_repo
    let g:grepprg="git --no-pager grep -n"
  else
    if executable("ag")
      let g:grepprg="ag --nogroup --column --hidden"
    else
      let g:grepprg="grep -rnH"
    endif
  endif
endif

"Misc
command! -bang -nargs=* -complete=file Grep call utilgrep#_Grep('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=file GrepAdd call utilgrep#_Grep('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file LGrep call utilgrep#_Grep('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LGrepAdd call utilgrep#_Grep('lgrepadd<bang>', <q-args>)

