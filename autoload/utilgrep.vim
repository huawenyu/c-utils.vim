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
function! utilgrep#Grep(add,sel)
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

  let search_str = ""
  if a:sel == 1
    " when the selection is limited to within one line
    let l:sel_len = virtcol("'>") - virtcol("'<") + 1
    if l:sel_len >= 2
      let search_str = utilgrep#_GetVisualSelection()
    endif
  else
    let search_str = expand('<cword>')
  endif

  if !empty(search_str)
    let search_str = input("Search? ", search_str)
    return l:cmd . l:param . search_str . "' ."
  endif
endfunction

function! utilgrep#Ag(sel)
  execute "norm mP"
  if a:sel == 1
    " when the selection is limited to within one line
    let l:sel_len = virtcol("'>") - virtcol("'<") + 1
    if l:sel_len >= 2
      return "Grep -- '" . utilgrep#_GetVisualSelection() . "'"
    endif
  else
    return "Grep -- '" . expand('<cword>') . "'"
  endif
endfunction

function! utilgrep#FormatForProgram(program)
  if match(a:program, '^a(g|ck)') != -1
    let b:grepformat="%f:%l:%c:%m"
  else
    let b:grepformat="%f:%l:%m"
  endif
endfunction

function! utilgrep#Grep(cmd, args)
  call utilgrep#FormatForProgram(g:grepprg)

  call utilgrep#SearchWithDispatch(a:cmd, a:args)
  "if exists(":Dispatch")
  "  if match(a:cmd, "^l.*") != -1
  "    call utilgrep#SearchWithGrep(a:cmd, a:args)
  "  else
  "    call utilgrep#SearchWithDispatch(a:cmd, a:args)
  "  endif
  "else
  "  call utilgrep#SearchWithGrep(a:cmd, a:args)
  "endif
endfunction

function! utilgrep#SearchWithGrep(cmd, args)
  let grepprg_bak=&grepprg
  let grepformat_bak=&grepformat

  try
    let &grepprg=g:grepprg
    let &grepformat=b:grepformat
    execute a:cmd . " " . a:args
  finally
    let &grepprg=grepprg_bak
    let &grepformat=grepformat_bak
  endtry
endfunction

function! utilgrep#SearchWithDispatch(cmd, args)
  let l:makeprg_bak = &l:makeprg
  let l:errorformat_bak = &l:errorformat

  try
    let &l:makeprg = g:grepprg . ' ' . a:args
    let &l:errorformat = b:grepformat

    Make
  finally
    let &l:makeprg = l:makeprg_bak
    let &l:errorformat = l:errorformat_bak
  endtry
endfunction

