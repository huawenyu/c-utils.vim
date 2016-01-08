function! utils#IsLeftMostWindow()
    let curNr = winnr()
    wincmd h
    if winnr() == curNr
        return 1
    endif
    wincmd p " Move back.
    return 0
endfunction

" Space: show columnline or open-declaration
function! utils#ColumnlineOrDeclaration()
  let l:col = col('.')
  let l:virtcol = virtcol('.')

  "echom "current: " . l:col . strtrans(getline(".")[col(".")-2])

  " Show colorcolumn
  if l:col == 1
     \ ||strtrans(getline(".")[col(".")-1]) == ' '
     \ || strtrans(getline(".")[col(".")-1]) == "^I"
     \ || strtrans(getline(".")[col(".")-2]) == ' '
     \ || strtrans(getline(".")[col(".")-2]) == "^I"
    if l:col == 1 || &colorcolumn == l:virtcol
      setlocal colorcolumn&
      unlet! g:colorcolumn_col
    else
      let &l:colorcolumn = l:virtcol
      let g:colorcolumn_col = l:col
    endif
  else
    execute ":ptjump " . expand("<cword>")
    execute "norm! \<c-w>pzt\<c-w>p"
    "norm! ^wpzt^wp
  endif
endfunction

function! utils#VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" preconditon: mark a, mark b
" then in <gdb> source log.crash
function! utils#Tracecrash()
  exec ":silent %normal \<ESC>0i#"
  exec ":'a,'b normal df["
  exec ":'a,'b normal f]d$"
  exec ":'a,'b normal Il *"
endfunction

function! utils#VoomInsert(vsel)
    let number = 1
    if v:count > 0
        let number = v:count
    endif

    if a:vsel
        let temp = @s
        norm! gv"sy
        let line_ins = "# " . @s . " {{{" . "" . number . "}}}"
        let @s = temp
    else
        let line_ins = "# " . expand('<cword>') . " {{{" . "" . number . "}}}"
    endif

    norm O
    execute "put =line_ins"
endfunction

function! utils#GotoFileWithLineNum()
  " filename under the cursor
  let file_name = expand('<cfile>')
  if !strlen(file_name)
    echo 'NO FILE UNDER CURSOR'
    return
  endif

  " look for a line number separated by a :
  if search('\%#\f*:\zs[0-9]\+')
    " change the 'iskeyword' option temporarily to pick up just numbers
    let temp = &iskeyword
    set iskeyword=48-57
    let line_number = expand('<cword>')
    exe 'set iskeyword=' . temp
  endif

  " edit the file
  exe 'e '.file_name

  " if there is a line number, go to it
  if exists('line_number')
    exe line_number
  endif
endfunction

