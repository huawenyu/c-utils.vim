function! utilgrep#_GetVisualSelection()
  " Why is this not a built-in Vim script function?!
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

" autocmd QuickfixCmdPost make,grep,vimgrep copen
function! utilgrep#LocalEasyGrep(add,sel)
  execute "norm mP"
  if a:add == 0
    let l:cmd = "grepadd"
    let l:param = "! -Inr --include='*.[ch]' -- '"
  elseif a:add == 1
    let l:cmd = "grep"
    let l:param = "! -Inr --include='*.[ch]' -- '"
  elseif a:add == 2
    let l:cmd = "grep"
    let l:param = "! -Inr
                  \ --exclude='patch.*'
                  \ --exclude='cscope.*'
                  \ --exclude='tags'
                  \ --exclude='TAGS'
                  \ --exclude='\*.svn\*'
                  \ --exclude='.svn'
                  \ --exclude='.git'
                  \ -w '"
  endif

  if a:sel == 1
    " when the selection is limited to within one line
    let l:sel_len = virtcol("'>") - virtcol("'<") + 1
    if l:sel_len >= 2
      return l:cmd . l:param . utilgrep#_GetVisualSelection() . "' ."
    endif
  endif

  return l:cmd . l:param . expand('<cword>') . "' ."
endfunction

function! utilgrep#Ag(sel)
  execute "norm mP"
  if a:sel == 1
    " when the selection is limited to within one line
    let l:sel_len = virtcol("'>") - virtcol("'<") + 1
    if l:sel_len >= 2
      return "Ag -- '" . utilgrep#_GetVisualSelection() . "'"
    endif
  else
    return "Ag -- '" . expand('<cword>') . "'"
  endif
endfunction

