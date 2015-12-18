function! utilexecute#execute_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]

  let i = 0
  let l_len = len(lines) - 1
  call VimuxOpenRunner()
  if (l_len == 0)
    call VimuxRunCommand(lines[i])
  else
    for cmd in lines
      if i == l_len
        call VimuxSendText(cmd)
      else
        call VimuxRunCommand(cmd)
      endif

      let i += 1
    endfor
  endif
endfunction

function! utilexecute#copy_selection()
  if !exists("g:VimuxRunnerIndex")
    call VimuxOpenRunner()
    return
  endif

  if !exists("g:VimuxRunnerIndex")
    echom "No VimxOpenRunner."
    return
  endif

  VimuxScrollUpInspect
  call VimuxSendKeys("G")
  call VimuxSendKeys(v:count)
  call VimuxSendKeys("k")
  call VimuxSendKeys("0")
  call VimuxSendKeys("Space")
  call VimuxSendKeys(v:count)
  call VimuxSendKeys("j")
  call VimuxSendKeys("$")
  call VimuxSendKeys("Enter")
endfunction
