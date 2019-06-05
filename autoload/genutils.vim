" https://github.com/vim-scripts/genutils

"" --- START save/restore position. {{{1

function! genutils#SaveSoftPosition(id)
  let b:sp_startline_{a:id} = getline(".")
  call genutils#SaveHardPosition(a:id)
endfunction

function! genutils#RestoreSoftPosition(id)
  0
  call genutils#RestoreHardPosition(a:id)
  let stLine = b:sp_startline_{a:id}
  if getline('.') !=# stLine
    if ! search('\V\^'.escape(stLine, "\\").'\$', 'W') 
      call search('\V\^'.escape(stLine, "\\").'\$', 'bW')
    endif
  endif
  call genutils#MoveCurLineToWinLine(b:sp_winline_{a:id})
endfunction

function! genutils#ResetSoftPosition(id)
  unlet b:sp_startline_{a:id}
endfunction

" A synonym for genutils#SaveSoftPosition.
function! genutils#SaveHardPositionWithContext(id)
  call genutils#SaveSoftPosition(a:id)
endfunction

" A synonym for genutils#RestoreSoftPosition.
function! genutils#RestoreHardPositionWithContext(id)
  call genutils#RestoreSoftPosition(a:id)
endfunction

" A synonym for genutils#ResetSoftPosition.
function! genutils#ResetHardPositionWithContext(id)
  call genutils#ResetSoftPosition(a:id)
endfunction

function! genutils#SaveHardPosition(id)
  let b:sp_col_{a:id} = virtcol(".")
  let b:sp_lin_{a:id} = line(".")
  " Avoid accounting for wrapped lines.
  let _wrap = &l:wrap
  try
    setl nowrap
    let b:sp_winline_{a:id} = winline()
  finally
    let &l:wrap = _wrap
  endtry
endfunction

function! genutils#RestoreHardPosition(id)
  " This doesn't take virtual column.
  "call cursor(b:sp_lin_{a:id}, b:sp_col_{a:id})
  " Vim7 generates E16 if line number is invalid.
  " TODO: Why is this leaving cursor on the last-but-one line when the
  " condition meets?
  execute ((line('$') < b:sp_lin_{a:id}) ? line('$') :
        \ b:sp_lin_{a:id})
  "execute b:sp_lin_{a:id}
  execute ((line('$') < b:sp_lin_{a:id}) ? line('$') :
        \ b:sp_lin_{a:id})
  "execute b:sp_lin_{a:id}
  execute "normal!" b:sp_col_{a:id} . "|"
  call genutils#MoveCurLineToWinLine(b:sp_winline_{a:id})
endfunction

function! genutils#ResetHardPosition(id)
  unlet b:sp_col_{a:id}
  unlet b:sp_lin_{a:id}
  unlet b:sp_winline_{a:id}
endfunction

function! genutils#GetLinePosition(id)
  return b:sp_lin_{a:id}
endfunction

function! genutils#GetColPosition(id)
  return b:sp_col_{a:id}
endfunction

function! genutils#IsPositionSet(id)
  return exists('b:sp_col_' . a:id)
endfunction

"" --- END save/restore position. }}}

function! genutils#UserFileComplete(ArgLead, CmdLine, CursorPos, smartSlash,
      \ searchPath)
  return genutils#UserFileComplete2(a:ArgLead, a:CmdLine, a:CursorPos,
        \ {'resultsAsList': 0, 'relativePaths': 1, 'smartSlash': a:smartSlash,
        \  'searchPath': a:searchPath})
endfunction

function! genutils#UserDirComplete2(ArgLead, CmdLine, CursorPos, ...)
  let params = a:0 ? a:1 : {}
  return genutils#UserFileComplete2(a:ArgLead, a:CmdLine, a:CursorPos,
        \ extend(params, {'completionTypes': ['dir']}))
endfunction

function! genutils#UserFileComplete2(ArgLead, CmdLine, CursorPos, ...)
  let params = a:0 ? a:1 : {}
  let smartSlash = get(params, 'smartSlash', 1)
  let searchPath = get(params, 'searchPath', '')
  let relativePaths = get(params, 'relativePaths', 0)
  let completionTypes = get(params, 'completionTypes', ['file', 'dir'])
  let anchorAtStart = get(params, 'anchorAtStart', 1)
  let resultsAsList = get(params, 'resultsAsList', 1)
  let includeOriginal = get(params, 'includeOriginal', 1)
  let dedupe = get(params, 'dedupe', 0)
  let opathsep = "\\"
  let npathsep = '/'
  if exists('+shellslash') && ! &shellslash && smartSlash &&
        \ stridx(a:ArgLead, '/') == -1
    let opathsep = '/'
    let npathsep = "\\"
  endif
  let matchMap = {}
  let allMatches = []
  let includeDirs = index(completionTypes, 'dir') != -1
  let includeFiles = index(completionTypes, 'file') != -1
  let _shellslash = &shellslash
  let ArgHead = fnamemodify(a:ArgLead, ':h')
  " Also remove any trailing slashes, for consistency.
  let ArgHead = ArgHead == '.' ? '' :
        \ (genutils#PathIsAbsolute(ArgHead) || ArgHead =~ '^\~' ?
        \  substitute(genutils#CleanupFileName(ArgHead), '\(.\)[\\/]$', '\1', '') :
        \  ArgHead)
  let ArgTail = fnamemodify(a:ArgLead, ':t')
  let pat = (ArgHead == '' && ArgTail == '') ? '*' :
        \    (ArgTail == '' ? ArgHead.'/' :
        \     (ArgHead == '' ? '' : ArgHead.'/').(anchorAtStart ? '' : '*')
        \     .ArgTail).'*'
  for nextPath in split(searchPath, genutils#CrUnProtectedCharsPattern(','), 1)
    " Ignore paths if the ArgHead happens to be an absolute path.
    let nextPath = genutils#PathIsAbsolute(ArgHead) ? '' : 
          \ genutils#CleanupFileName(nextPath).npathsep
    let matches = split(glob(nextPath.pat), "\n")
    if len(matches) != 0
      call map(matches, 'substitute(v:val, opathsep, npathsep, "g").(isdirectory(v:val) ? npathsep : "")')
      call filter(matches, 'v:val[-1:] == npathsep ? includeDirs : includeFiles')
      if relativePaths
        let pathRE = '\V'.escape(substitute(nextPath, opathsep, npathsep, 'g'), "\\")
        call map(matches, 'substitute(v:val, pathRE, "", "g")')
      endif
      if dedupe
        call filter(matches, '!has_key(matchMap, v:val)')
        for match in matches
          let matchMap[match] = 1
        endfor
      endif
      let allMatches += matches
    endif
  endfor
  if includeOriginal
    let allMatches += [a:ArgLead]
  endif
  return resultsAsList ? allMatches : join(allMatches, "\n")
endfunction

command! -complete=file -nargs=* GUDebugEcho :echo <q-args>
function! genutils#UserFileExpand(fileArgs)
  return substitute(genutils#GetVimCmdOutput(
        \ 'GUDebugEcho ' . a:fileArgs), '^\_s\+\|\_s\+$', '', 'g')
endfunction

function! genutils#GetVimCmdOutput(cmd)
  let v:errmsg = ''
  let output = ''
  let _shortmess = &shortmess
  try
    set shortmess=
    redir => output
    silent exec a:cmd
  catch /.*/
    let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
  finally
    redir END
    let &shortmess = _shortmess
    if v:errmsg != ''
      let output = ''
    endif
  endtry
  return output
endfunction

function! genutils#OptClearBuffer()
  " Go as far as possible in the undo history to conserve Vim resources.
  let _modifiable = &l:modifiable
  let _undolevels = &undolevels
  try
    setl modifiable
    set undolevels=-1
    silent! keepjumps 0,$delete _
  finally
    let &undolevels = _undolevels
    let &l:modifiable = _modifiable
  endtry
endfunction

" Window related functions {{{1

function! genutils#NumberOfWindows()
  let i = 1
  while winbufnr(i) != -1
    let i = i+1
  endwhile
  return i - 1
endfunction

" Find the window number for the buffer passed.
" The fileName argument is treated literally, unlike the bufnr() which treats
"   the argument as a regex pattern.
function! genutils#FindWindowForBuffer(bufferName, checkUnlisted)
  return bufwinnr(genutils#FindBufferForName(a:bufferName))
endfunction

function! genutils#FindBufferForName(fileName)
  " The name could be having extra backslashes to protect certain chars (such
  "   as '#' and '%'), so first expand them.
  return s:FindBufferForName(genutils#UnEscape(a:fileName, '#%'))
endfunction

function! s:FindBufferForName(fileName)
  let fileName = genutils#Escape(a:fileName, '[?,{')
  let _isf = &isfname
  try
    set isfname-=\
    set isfname-=[
    let i = bufnr('^' . fileName . '$')
  finally
    let &isfname = _isf
  endtry
  return i
endfunction

function! genutils#GetBufNameForAu(bufName)
  let bufName = a:bufName
  " Autocommands always require forward-slashes.
  let bufName = substitute(bufName, "\\\\", '/', 'g')
  let bufName = escape(bufName, '*?,{}[ ')
  return bufName
endfunction

function! genutils#MoveCursorToWindow(winno)
  if genutils#NumberOfWindows() != 1
    execute a:winno . " wincmd w"
  endif
endfunction

function! genutils#MoveCurLineToWinLine(n)
  normal! zt
  if a:n == 1
    return
  endif
  let _wrap = &l:wrap
  setl nowrap
  let n = a:n
  if n >= winheight(0)
    let n = winheight(0)
  endif
  let n = n - 1
  execute "normal! " . n . "\<C-Y>"
  let &l:wrap = _wrap
endfunction

function! genutils#CloseWindow(win, force)
  let _eventignore = &eventignore
  try
    set eventignore=all
    call genutils#MarkActiveWindow()

    let &eventignore = _eventignore
    exec a:win 'wincmd w'
    exec 'close'.(a:force ? '!' : '')
    set eventignore=all

    if a:win < t:curWinnr
      let t:curWinnr = t:curWinnr - 1
    endif
    if a:win < t:prevWinnr
      let t:prevWinnr = t:prevWinnr - 1
    endif
  finally
    call genutils#RestoreActiveWindow()
    let &eventignore = _eventignore
  endtry
endfunction

function! genutils#MarkActiveWindow()
  let t:curWinnr = winnr()
  " We need to restore the previous-window also at the end.
  silent! wincmd p
  let t:prevWinnr = winnr()
  silent! wincmd p
endfunction

function! genutils#RestoreActiveWindow()
  if !exists('t:curWinnr')
    return
  endif

  " Restore the original window.
  if winnr() != t:curWinnr
    exec t:curWinnr'wincmd w'
  endif
  if t:curWinnr != t:prevWinnr
    exec t:prevWinnr'wincmd w'
    wincmd p
  endif
endfunction

function! genutils#IsOnlyVerticalWindow()
  let onlyVertWin = 1
  let _eventignore = &eventignore

  try
    "set eventignore+=WinEnter,WinLeave
    set eventignore=all
    call genutils#MarkActiveWindow()

    wincmd j
    if winnr() != t:curWinnr
      let onlyVertWin = 0
    else
      wincmd k
      if winnr() != t:curWinnr
	let onlyVertWin = 0
      endif
    endif
  finally
    call genutils#RestoreActiveWindow()
    let &eventignore = _eventignore
  endtry
  return onlyVertWin
endfunction

function! genutils#IsOnlyHorizontalWindow()
  let onlyHorizWin = 1
  let _eventignore = &eventignore
  try
    set eventignore=all
    call genutils#MarkActiveWindow()
    wincmd l
    if winnr() != t:curWinnr
      let onlyHorizWin = 0
    else
      wincmd h
      if winnr() != t:curWinnr
	let onlyHorizWin = 0
      endif
    endif
  finally
    call genutils#RestoreActiveWindow()
    let &eventignore = _eventignore
  endtry
  return onlyHorizWin
endfunction

function! genutils#MoveCursorToNextInWinStack(dir)
  let newwin = genutils#GetNextWinnrInStack(a:dir)
  if newwin != 0
    exec newwin 'wincmd w'
  endif
endfunction

function! genutils#GetNextWinnrInStack(dir)
  let newwin = winnr()
  let _eventignore = &eventignore
  try
    set eventignore=all
    call genutils#MarkActiveWindow()
    let newwin = s:GetNextWinnrInStack(a:dir)
  finally
    call genutils#RestoreActiveWindow()
    let &eventignore = _eventignore
  endtry
  return newwin
endfunction

function! genutils#MoveCursorToLastInWinStack(dir)
  let newwin = genutils#GetLastWinnrInStack(a:dir)
  if newwin != 0
    exec newwin 'wincmd w'
  endif
endfunction

function! genutils#GetLastWinnrInStack(dir)
  let newwin = winnr()
  let _eventignore = &eventignore
  try
    set eventignore=all
    call genutils#MarkActiveWindow()
    while 1
      let wn = s:GetNextWinnrInStack(a:dir)
      if wn != 0
        let newwin = wn
        exec newwin 'wincmd w'
      else
        break
      endif
    endwhile
  finally
    call genutils#RestoreActiveWindow()
    let &eventignore = _eventignore
  endtry
  return newwin
endfunction

" Based on the WinStackMv() function posted by Charles E. Campbell, Jr. on vim
"   mailing list on Jul 14, 2004.
function! s:GetNextWinnrInStack(dir)
  "call Decho("genutils#MoveCursorToNextInWinStack(dir<".a:dir.">)")

  let isHorizontalMov = (a:dir ==# 'h' || a:dir ==# 'l') ? 1 : 0

  let orgwin = winnr()
  let orgdim = s:GetWinDim(a:dir, orgwin)

  let _winwidth = &winwidth
  let _winheight = &winheight
  try
    set winwidth=1
    set winheight=1
    exec 'wincmd' a:dir
    let newwin = winnr()
    if orgwin == newwin
      " No more windows in this direction.
      "call Decho("newwin=".newwin." stopped".winheight(newwin)."x".winwidth(newwin))
      return 0
    endif
    if s:GetWinDim(a:dir, newwin) != orgdim
      " Window dimension has changed, indicates a move across window stacks.
      "call Decho("newwin=".newwin." height changed".winheight(newwin)."x".winwidth(newwin))
      return 0
    endif
    " Determine if changing original window height affects current window
    "   height.
    exec orgwin 'wincmd w'
    try
      if orgdim == 1
        exec 'wincmd' (isHorizontalMov ? '_' : '|')
      else
        exec 'wincmd' (isHorizontalMov ? '-' : '<')
      endif
      if s:GetWinDim(a:dir, newwin) != s:GetWinDim(a:dir, orgwin)
        "call Decho("newwin=".newwin." different row".winheight(newwin)."x".winwidth(newwin))
        return 0
      endif
      "call Decho("newwin=".newwin." same row".winheight(newwin)."x".winwidth(newwin))
    finally
      exec (isHorizontalMov ? '' : 'vert') 'resize' orgdim
    endtry

    "call Decho("genutils#MoveCursorToNextInWinStack")

    return newwin
  finally
    let &winwidth = _winwidth
    let &winheight = _winheight
  endtry
endfunction

function! s:GetWinDim(dir, win)
  return (a:dir ==# 'h' || a:dir ==# 'l') ? winheight(a:win) : winwidth(a:win)
endfunction

function! genutils#OpenWinNoEa(winOpenCmd)
  call s:ExecWinCmdNoEa(a:winOpenCmd)
endfunction

function! genutils#CloseWinNoEa(winnr, force)
  call s:ExecWinCmdNoEa(a:winnr.'wincmd w | close'.(a:force?'!':''))
endfunction

function! s:ExecWinCmdNoEa(winCmd)
  let _eventignore = &eventignore
  try
    set eventignore=all
    call genutils#MarkActiveWindow()
    windo let w:_winfixheight = &winfixheight
    windo set winfixheight
    call genutils#RestoreActiveWindow()

    let &eventignore = _eventignore
    exec a:winCmd
    set eventignore=all

    call genutils#MarkActiveWindow()
    silent! windo let &winfixheight = w:_winfixheight
    silent! windo unlet w:_winfixheight
    call genutils#RestoreActiveWindow()
  finally
    let &eventignore = _eventignore
  endtry
endfunction

function! genutils#GetQuickfixWinnr()
  for nr in range(1, winnr('$'))
    if getwinvar(nr, "&buftype") == "quickfix"
      " found a preview
      return nr
    endif
  endfor

  return 0
endfunction

function! genutils#GetPreviewWinnr()
  for nr in range(1, winnr('$'))
    if getwinvar(nr, "&pvw") == 1
      " found a preview
      return nr
    endif
  endfor

  return 0
endfunction


" Window related functions }}}
