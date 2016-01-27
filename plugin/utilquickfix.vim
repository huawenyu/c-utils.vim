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
command! -nargs=1 -complete=custom,utilquickfix#Complete QSave call utilquickfix#SaveQuickFixList(<f-args>)
command! -nargs=1 -complete=custom,utilquickfix#Complete QLoad call utilquickfix#LoadQuickFixList(<f-args>)

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

if !exists("g:utilquickfix_file")
  let g:utilquickfix_file = "/tmp/vim.quickfix"
endif

autocmd Filetype qf setlocal stl=%t\ (%l\ of\ %L)%{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%-15(%l,%c%V%)\ %P
