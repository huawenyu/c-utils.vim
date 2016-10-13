" ============================================================================
" File:        utilcscope.vim
" Description: the wrapper of autoload
" ============================================================================

"Init {
if exists('g:loaded_c_utils_utilcscope')
    finish
endif

if &cp || v:version < 700
    echom 'Please use the new vim version > 700'
    finish
endif

let g:loaded_c_utils_utilcscope = 1
"}


"nvim should load cscope db by script
"set tags=tags;/
set tags=./tags,tags;$HOME

autocmd BufEnter * call utilcscope#LoadCscope()
"autocmd BufNewFile,BufRead * call utilcscope#LoadCscope()

" The following maps all invoke one of the following cscope search types:
"   's'   symbol: find all references to the token under cursor
"   'g'   global: find global definition(s) of the token under cursor
"   'c'   calls:  find all calls to the function name under cursor
"   'd'   called: find functions that function under cursor calls
"   't'   text:   find all instances of the text under cursor
"   'e'   egrep:  egrep search for the word under cursor
"   'f'   file:   open the filename under cursor
"   'i'   includes: find files that include the filename under cursor
" +ctags
"         :tags   see where you currently are in the tag stack
"         :tag sys_<TAB>  auto-complete
" http://www.fsl.cs.sunysb.edu/~rick/rick_vimrc

":help cscope-options

"set cscopetag
"set cscopequickfix=s0,c0,d0,i0,t-,e-

nmap <leader>ff :cs find f <C-R>=expand("<cfile>")<CR>
nmap <leader>fw :cs find f <C-R>=expand("<cword>")<CR>
nmap <leader>fs :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <leader>fg :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <leader>fc :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <leader>fd :cs find d <C-R>=expand("<cword>")<CR><CR>
"nmap <leader>ft :cs find t <C-R>=expand("<cword>")<CR>
"nmap <leader>fe :cs find e <C-R>=expand("<cword>")<CR>
"nmap <leader>fi :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <leader>fe :call utilcscope#CscopeSymbol() <CR>
nmap <leader>fi :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <leader>ft :<C-\>e utilcscope#FindFunc(0) <CR>
vmap <leader>ft :<C-\>e utilcscope#FindFunc(1) <CR>
"nmap <leader>fe :<C-\>e utilcscope#FindVar(0) <CR>
"vmap <leader>fe :<C-\>e utilcscope#FindVar(1) <CR>

nmap <leader>] :cs find g <C-R>=expand("<cword>")<CR><CR>
command! -nargs=* FindFunc call utilcscope#_Function("function", <f-args>)
command! -nargs=* FindVar call utilcscope#_Function("variable", <f-args>)


if has('cscope')
    set cscopetagorder=0
    set cscopetag
    set cscopeverbose
    "set cscopequickfix=s-,c-,d-,i-,t-,e-
    set cscopequickfix=s0,c0,d0,i0,t-,e-
    set cscopepathcomp=3

    function! LoadCscope()
        let db = findfile("cscope.out", ".;")
        if (!empty(db))
            let path = strpart(db, 0, match(db, "/cscope.out$"))
            set nocscopeverbose " suppress 'duplicate connection' error
            exe "cs reset"
            exe "cs add " . db . " " . path
            set cscopeverbose
        endif
    endfunction
    au BufEnter /* call utilcscope#LoadCscope2()

    "nnoremap T :cs find c <C-R>=expand("<cword>")<CR><CR>
    "nnoremap t <C-]>
    "nnoremap gt <C-W><C-]>
    "nnoremap gT <C-W><C-]><C-W>T

    "nnoremap <silent> <leader>z :Dispatch echo "Generating tags and cscope database..." &&
    "    \ find -L . -iname '*.c' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.hpp' > cscope.files &&
    "    \ sort cscope.files > cscope.files.sorted && mv cscope.files.sorted cscope.files &&
    "    \ cscope -kbq -i cscope.files -f cscope.out &&
    "    \ ctags -R --fields=+aimSl --c-kinds=+lpx --c++-kinds=+lpx --exclude='.svn' 
    "    \ --exclude='.git' --exclude='*.a' --exclude='*.js' --exclude='*.pxd' --exclude='*.pyx' --exclude='*.so' &&
    "    \ echo "Done." <cr><cr>

    nnoremap <silent> <leader>z :Dispatch echo "Generating tags and cscope database..." &&
        \ gencs.sh -a all &&
        \ echo "Done." <cr><cr>

    "cnoreabbrev csa cs add
    "cnoreabbrev csf cs find
    "cnoreabbrev csk cs kill
    "cnoreabbrev csr cs reset
    "cnoreabbrev css cs show
    "cnoreabbrev csh cs help
    "cnoreabbrev csc Cscope
    command! Cscope :call utilcscope#LoadCscope2()
endif


"nmap <F11> :!find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.hpp' > cscope.files<CR>
"    \:!cscope -b -i cscope.files -f cscope.out<CR>
"    \:cs reset<CR>

