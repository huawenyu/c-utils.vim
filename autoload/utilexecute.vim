function! utilexecute#execute_selection(sel)
  if a:sel
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
  else
    " run current line
    call VimuxRunCommand(line('.'))
  endif
endfunction

function! utilexecute#start_insert()
  set paste | startinsert!
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

  if v:count > 0
    if v:count > 20
      call _VimuxTmux("capture-pane -t ".g:VimuxRunnerIndex." -S -" . v:count)
    else
      call _VimuxTmux("capture-pane -t ".g:VimuxRunnerIndex." -S - -E " . (v:count - 1))
    endif
  else
    call _VimuxTmux("capture-pane -t ".g:VimuxRunnerIndex)
  endif

  call _VimuxTmux("save-buffer /tmp/vim.yank")
  call utilexecute#start_insert()
  call _VimuxTmux("paste-buffer -t ".g:VimuxVimIndex)
  call _VimuxTmux("delete-buffer")

  redraw!
endfunction
