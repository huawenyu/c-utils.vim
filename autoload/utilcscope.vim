function! utilcscope#LoadCscope()
    if exists('g:loaded_c_utils_utilcscope_have_db')
        return
    endif

    " Searches from the directory of the current file upwards until root '/'
    let db = findfile("cscope.out", ".;")
    set nocscopeverbose " suppress 'duplicate connection' error
    if filereadable("cscope.out")
      exe "cs add cscope.out"
      let g:loaded_c_utils_utilcscope_have_db = 1
    elseif (!empty(db))
      let path = strpart(db, 0, match(db, "/cscope.out$"))
      exe "cs add " . db . " " . path
      let g:loaded_c_utils_utilcscope_have_db = 1
    endif
    set cscopeverbose
endfunction

" Find symbol and add to quickfix
function! utilcscope#CscopeSymbol()
  let l:old_cscopeflag = &cscopequickfix
  "let save_cursor = getpos(".")
  exec "normal mP"

  set cscopequickfix=s-,c0,d0,i0,t-,e-
  exec ':cs find s ' . expand("<cword>")
  "exec ':silent !copen'
  "exec "normal \<C-W>k"

  "call setpos('.', save_cursor)
  exec "normal `P"
  let &cscopequickfix = l:old_cscopeflag
endfunction

function! utilcscope#Function(type, sel)
  if a:sel
    return "Function ".a:type." ".utils#GetSelected("")." "
  else
    return "Function ".a:type." ".expand('<cword>')." "
  endif
endfunction

function! utilcscope#_Function(type, sname, ...)
  Decho "utilcscope#_Function a:0=" . a:0

  if a:0 > 0
    let cmd_str = ":silent !taglist.awk ".a:type." ".a:sname." ".a:1
  else
    let cmd_str = ":silent !taglist.awk ".a:type." ".a:sname
  endif

  Decho cmd_str
  execute cmd_str

  execute ':redraw!'
  if filereadable('/tmp/vim.taglist')
    let lines = readfile('/tmp/vim.taglist')
    if !empty(lines)
      execute ':cgetfile /tmp/vim.taglist'
    endif
  endif
endfunction

