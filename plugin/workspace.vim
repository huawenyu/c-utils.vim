" File:        plugin/workspace.vim
" Version:     1.0
" Modified:    2014-08-17
" Description: This plugin provides commands to save and load vim session and 
"              viminfo files automatically. 
" Maintainer:  Brant Chen <brantchen2008@gmail.com and xkdcc@163.com>
" Manual:      Read ":help workspaceIntro".
" ============================================================================

" Initialization: {{{

if exists("g:loaded_workspace") || &cp
  " User doesn't want this plugin or compatible is set, let's get out!
  finish
endif
let g:loaded_workspace= 1
let save_cpo = &cpo
set cpo&vim

if v:version < 700
  echoerr "workspace: This plugin requires vim >= 7!"
  finish
endif

let s:SavewsCoreFuncref = function('workspace#SaveWorkspaceCore')
let s:LoadwsCoreFuncref = function('workspace#LoadWorkspaceCore')
command! -nargs=? -bar Savews :call workspace#WorkspaceOperator(s:SavewsCoreFuncref, <f-args>)
command! -nargs=? -bar Loadws :call workspace#WorkspaceOperator(s:LoadwsCoreFuncref, <f-args>)

let g:wsOverwrite = 1
let g:wsSilence = 1
let g:wsStoreSession = 1
let g:wsStoreViminfo = 1

"call workspace#PromptExistedWorkspaceName()
"augroup workspace
"  au!
"  autocmd VimLeavePre * 
"        \ if g:wsLastWorkspaceName!="" |
"        \   call workspace#WorkspaceOperator(s:SavewsCoreFuncref, g:wsLastWorkspaceName) |
"        \ endif
"augroup END

let &cpo = save_cpo
" vim:foldmethod=marker:foldcolumn=4:ts=2:sw=2
