function! tmp#LocalGrepYankToNewTab()
  execute "R !grep -Inr --include='*.[ch]' -- '" . @" . "' ."
endfunction

function! tmp#CurrentReplace()
    return "%s/\\<" . expand("<cword>") . "\\>/" . expand("<cword>") . "/gi"
endfunction

function! tmp#AppendNoteOnSource()
  call inputsave()
  let msg = input('log.marks msg: ')
  call inputrestore()
  if(empty(msg))
    return
  endif

  redir => msg2 | call ShowFuncName() | redir END

  let msg2 = substitute(msg2, '^\n', '', '')
  let msg2 = substitute(msg2, '^\s*\(.\{-}\)\s*$', '\1', '')
  let msg2 = substitute(msg2, '\n$', '', '')
  let line = line(".")

  redir >> log.marks
  echo strftime("%Y-%m-%d %H:%M") . " '" . msg . "' in " . msg2
  "echo expand('%') . ' ' . (line-1) . '  ' . getline(line-1)
  echo expand('%') . ':' .  line    . ': ' . getline(line)
  "echo expand('%') . ' ' . (line+1) . ': ' . getline(line+1)
  redir END

  "silent cfile log.marks
  "silent clast
endfunction

function! tmp#GotoJump()
  jumps
  let j = input("Please select your jump: ")
  if j != ''
    let pattern = '\v\c^\+'
    if j =~ pattern
      let j = substitute(j, pattern, '', 'g')
      execute "normal " . j . "\<c-i>"
    else
      execute "normal " . j . "\<c-o>"
    endif
  endif
endfunction

" disassembly current function
function! Asm()
  execute("new|r !gdb -batch sysinit/init -ex 'disas /m " . expand("<cword>") . "'")
endfunction

function! tmp#ShowFuncName()
  let lnum = line(".")
  let col = col(".")
  echohl ModeMsg
  echo getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))
  echohl None
  call search("\\%" . lnum . "l" . "\\%" . col . "c")
endfunction

function! tmp#PreviewWindowOpened()
    for nr in range(1, winnr('$'))
        if getwinvar(nr, "&pvw") == 1
            " found a preview
            return 1
        endif
    endfor

    return 0
endfunction

function! tmp#OpenFileInPreviewWindow()
  return "pedit " . matchstr(getline("."), '\h\S*')
endfunction


"map <leader>g  :call LocalGrepYankToNewTab() <CR>
"nmap <Leader>j :call GotoJump()<CR>
