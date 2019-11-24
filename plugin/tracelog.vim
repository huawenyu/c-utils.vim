" ============================================================================
" File:        tracelog.vim
" Description: the wrapper of autoload
" ============================================================================


"Init {
if exists('g:loaded_tracelog')
    finish
endif

if &cp || v:version < 700
    echom 'Please use the new vim version > 700'
    finish
endif

if !executable('cscope') || !executable('ctags')
    echom 'Please install tools: cscope, ctags'
    finish
endif

if !exists('g:tracelog_default_dir')
    let g:tracelog_default_dir = $HOME . "/script/trace-wad/"
endif

let g:loaded_tracelog = 1
"}

"Misc {
command! -nargs=0 TraceOutline call tracelog#TraceOutline()
command! -nargs=0 TraceLogClear call tracelog#TraceLogClear()
"}
