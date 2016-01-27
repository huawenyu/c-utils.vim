" ============================================================================
" File:        utilquickfix.vim
" Description: the wrapper of autoload
" ============================================================================

"Init {
if exists('g:loaded_c_utils_utilquickfix')
    finish
endif

if &cp || v:version < 700
    echom 'Please use the new vim version > 700'
    finish
endif

let g:loaded_c_utils_utilquickfix = 1
"}

"autocmd
command! -nargs=0 -bar Qargs execute 'args ' . utilquickfix#QuickfixFilenames()
command! -nargs=1 Function call utilquickfix#_Function(<f-args>)

" autofit
autocmd FileType qf call AdjustWindowHeight(2, 4)
function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

" auto command
augroup quickfix
  autocmd!
  " forbit focus on quickfix, but confuse my layout
  "autocmd Syntax qf wincmd p

  autocmd QuickFixCmdPost grep,make,grepadd,vimgrep,vimgrepadd,cscope,cfile,cgetfile,caddfile,helpgrep cwindow
  autocmd QuickFixCmdPost lgrep,lmake,lgrepadd,lvimgrep,lvimgrepadd,lfile,lgetfile,laddfile lwindow
augroup END

nmap <silent> <leader>;1 :call utilquickfix#SaveQuickFixList('/tmp/vim.qfile1') \| echom "SaveQuickFixList to /tmp/vim.qfile#" <CR>
nmap <silent> <leader>;2 :call utilquickfix#SaveQuickFixList('/tmp/vim.qfile2') \| echom "SaveQuickFixList to /tmp/vim.qfile#" <CR>
nmap <silent> <leader>;3 :call utilquickfix#SaveQuickFixList('/tmp/vim.qfile3') \| echom "SaveQuickFixList to /tmp/vim.qfile#" <CR>
nmap <silent> <leader>;4 :call utilquickfix#SaveQuickFixList('/tmp/vim.qfile4') \| echom "SaveQuickFixList to /tmp/vim.qfile#" <CR>
nmap <silent> <leader>;5 :call utilquickfix#SaveQuickFixList('/tmp/vim.qfile5') \| echom "SaveQuickFixList to /tmp/vim.qfile#" <CR>
nmap <silent> <leader>j1 :call utilquickfix#LoadQuickFixList('/tmp/vim.qfile1') \| echom "LoadQuickFixList from /tmp/vim.qfile#" <CR>
nmap <silent> <leader>j2 :call utilquickfix#LoadQuickFixList('/tmp/vim.qfile2') \| echom "LoadQuickFixList from /tmp/vim.qfile#" <CR>
nmap <silent> <leader>j3 :call utilquickfix#LoadQuickFixList('/tmp/vim.qfile3') \| echom "LoadQuickFixList from /tmp/vim.qfile#" <CR>
nmap <silent> <leader>j4 :call utilquickfix#LoadQuickFixList('/tmp/vim.qfile4') \| echom "LoadQuickFixList from /tmp/vim.qfile#" <CR>
nmap <silent> <leader>j5 :call utilquickfix#LoadQuickFixList('/tmp/vim.qfile5') \| echom "LoadQuickFixList from /tmp/vim.qfile#" <CR>

"quickfix keymap import by ag.vim
"e    to open file and close the quickfix window
"o    to open (same as enter)
"go   to preview file (open but maintain focus on ag.vim results)
"t    to open in new tab
"T    to open in new tab silently
"h    to open in horizontal split
"H    to open in horizontal split silently
"v    to open in vertical split
"gv   to open in vertical split silently
"q    to close the quickfix window

