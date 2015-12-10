function! utilcscope#LoadCscope()
    "" Searches from the directory of the current file upwards until root '/'
    "let db = findfile("cscope.out", ".;")
    "if (!empty(db))
    "  let path = strpart(db, 0, match(db, "/cscope.out$"))
    "  set nocscopeverbose " suppress 'duplicate connection' error
    "  exe "cs add " . db . " " . path
    "  set cscopeverbose
    "endif

    set nocscopeverbose
    exe "cs add cscope.out"
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
