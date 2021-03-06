function workspace#InitCheck()
  exec 'let s:AutochdirValue=&autochdir'
  if s:AutochdirValue == 1 
    echohl WarningMsg 
    echom 'workspace: Your Vimrc have set autochdir on, it would cause unexpected results when using workspace plugin.' 
    echom 'workspace: You would better to turn it off if you want workspace plugin works well.' 
    echohl Normal

    return 0
  endif

  return 0
endfunction


function! workspace#SaveWorkspaceCore(sf, vf)
  " echo "SaveWorkspaceLogic: args count:" . a:0
  " a:0 only works in function(...) mode
  " can't work in fixed arguments mode
  " So if a:0 != 2 NOT work in s:SaveWorkspaceCore(sf, vf)
  " because a:0 always equal 0
  " if a:0 != 2
  "
  " And please have '' for var in exists()

  if exists('a:sf') == 0 || exists('a:vf') == 0
    echohl ErrorMsg
    echom 'workspace: Please provide two arguments.' 
    echohl Normal
    return 0
  endif

  " Only existed (sf or vf), and wsOverwrite is 1
  " then we print a hint.
  if g:wsOverwrite == 1
    if !g:wsSilence && (glob(a:sf) != "" || glob(a:vf) != "")
      echo "workspace: wsOverwrite option is 1."
      echo "workspace: Will overwrite existed files." 
      if glob(a:sf) != ""
        echo "workspace: [" . fnamemodify(a:sf, ":p") . "] will be overwritten."
      endif
      if glob(a:vf) != ""
        echo "workspace: [" . fnamemodify(a:vf, ":p") . "] will be overwritten."
      endif
    endif

    if g:wsStoreSession
      execute "mksession! " . a:sf
    endif
    if g:wsStoreViminfo
      execute "wviminfo! "  . a:vf
    endif
    let g:wsLastWorkspaceName=fnamemodify(a:sf, ":p:r") . ".ws"

    if !g:wsSilence
      echo "workspace: Save [" . fnamemodify(a:sf, ":p") . "] sucessfully."
      echo "workspace: Save [" . fnamemodify(a:vf, ":p") . "] sucessfully."
      echo "Workspace Name:[" . g:wsLastWorkspaceName . "]"
      call input("")
    endif

    return 1
  else
    if glob(a:sf)!="" || glob(a:vf)!=""
      if !g:wsSilence
        echohl WarningMsg 

        if glob(a:sf)!=""
          echom "workspace: [" . fnamemodify(a:sf, ":p") . "] exists."
        endif
        if glob(a:vf)!=""
          echom "workspace: [" . fnamemodify(a:vf, ":p") . "] exists."
        endif

        echom "workspace: Either session or viminfo files exists, and "
        echom "workspace: wsOverwrite option is 0, you can do either one "
        echom "workspace: in following methods:"
        echom "workspace:   * Remove existed files: "
        echom "             [" . fnamemodify(a:sf, ":p") . "]"
        echom "             [" . fnamemodify(a:vf, ":p") . "]"
        echom "workspace:   * If you're in vim, specify another name for Savews command" 
        echom "workspace:   * If you're in vim, Run Loadws to source existed session and viminfo files"
        echohl Normal
        call input("")
      endif

      return 0
    else
      if g:wsStoreSession
        execute "mksession " . a:sf
      endif
      if g:wsStoreViminfo
        execute "wviminfo "  . a:vf
      endif
      let g:wsLastWorkspaceName=fnamemodify(a:sf, ":p:r") . ".ws"

      if !g:wsSilence
        echo "workspace: Save [" . fnamemodify(a:sf, ":p") . "] sucessfully."
        echo "workspace: Save [" . fnamemodify(a:vf, ":p") . "] sucessfully."
        echo "Workspace Name:[" . g:wsLastWorkspaceName . "]"
        call input("")
      endif

      return 1
    endif
  endif
endfunction

function! workspace#WorkspaceOperator(...)
  if a:0 == 1 
    " Note: Please don't use call(a:1, ['xxx', 'xxx'])!!! That's fault!
    call a:1(s:DefaultWorkspaceSessionName, s:DefaultWorkspaceViminfoName) 
    return 1 
  elseif a:0 == 2 
    " Detect arg whether it's a path
    let slash_index = match(a:2, '[\|/]')
    " We put . and .. to else branch.
    if slash_index == -1 && a:2 != '.' && a:2 != '..' " Specified workspace name
      " We process name without path in this branch.
      " For example:
      " test.ws
      " Please note: without .ws as suffix should be illegal.

      if (match(a:2,".ws") > 0) && (match(a:2, ".ws") == (strlen(a:2) - strlen(".ws")))
        " Above first condition: must find .ws in a:2, exclude ".ws"
        " Above second condition: must have a name for .ws, but not something like my.wsxxx.
        " So legal input should be something like:
        "   te.ws
        let s:WorkspaceName=strpart(a:2, 0, strlen(a:2) - strlen(".ws"))

        " s:WorkspaceName should not a existed folder or file
        if ! isdirectory(s:WorkspaceName) && glob(s:WorkspaceName) == "" 
          call a:1(s:WorkspaceName . ".session", s:WorkspaceName . ".viminfo")
          return 1
        else
          echohl ErrorMsg
          echom 'workspace: [' . a:2 . '] exists as a folder or file under current path.'
          echom 'workspace: Please use another workspace name.' 
          echohl Normal
          return 0
        endif
      else
        " For example, .ws or .wsaxxasds or xcvouia
        echohl ErrorMsg
        echom 'workspace: Seems you did not give legal name.'
        echom 'workspace: Your input: ' . a:2
        echom 'workspace: Here comes an example, you need give a name with .ws as suffix: ~/my.ws or test.ws' 
        echom 'workspace: But not:     ~/.ws or test'
        echohl Normal
        return 0
      endif
    else " This would be a path
      try
        " Note:
        " I found fnamemodify parse '\' as '/root'! no matter '\' in
        " which position.

        " I don't want to support \
        if match(a:2, '\') != -1
          echohl ErrorMsg
          echom 'workspace: Please remove \ from [' . a:2 . '].'
          echohl Normal
          return 0
        endif

        if isdirectory(a:2)
          " Just specify a folder.  
          " We need pass workspace files with default name but under
          " the specified folder to funcref.

          " To remove redundant '/'
          if match(a:2, '/', strlen(a:2)-1) != (strlen(a:2) -1)
            call a:1(a:2 . "/" . s:DefaultWorkspaceSessionName, a:2 . "/" . s:DefaultWorkspaceViminfoName)
          else
            call a:1(a:2 . s:DefaultWorkspaceSessionName, a:2 . s:DefaultWorkspaceViminfoName)
          endif
          return 1
        else 
          " Specify a folder with your workspace name.
          " Folder must be existed already, workspace name should
          " have .ws as suffix.

          " Condition:
          " 1. fnamemodify(a:2, ":p:h") must be an existed folder
          " 2. must have .ws as suffix
          " 3. Must have a name for .ws.
          " For example, you must type: <folder_path>/name.ws
          " but not like: <folder_path>/.ws

          if ! isdirectory(fnamemodify(a:2, ":p:h"))
            echohl ErrorMsg
            echom 'workspace: Folder [' . fnamemodify(a:2, ":p:h") . '] not exist.'
            echom 'workspace: Please create it beforehand.'
            echohl Normal
            return 0
          endif

          " Please note -1 in following line.
          " Because fnamemodify didn't get last /.
          " For example: fnamemodify('/tmp/my.ws', ":p:h") will
          " return /tmp but not /tmp/
          if ! (match(a:2,".ws") == (strlen(a:2) - 1 - 2))
            echohl ErrorMsg
            echom 'workspace: Seems you do not have .ws as suffix.'
            echom 'workspace: Your input: ' . a:2
            echohl Normal
            return 0
          endif

          " if it's relative path, for example, you're in /abc, you
          " type ../test.ws
          " then :p:h will return /abc
          " :p will return /abc/test.ws
          let s:head_path_len=strlen(fnamemodify(a:2,":p:h"))
          let s:full_path_len=strlen(fnamemodify(a:2, ":p"))
          let s:len_wsname_without_suffix = s:full_path_len - s:head_path_len - 1 - strlen('.ws')

          if s:len_wsname_without_suffix <= 0
            echohl ErrorMsg
            echom 'workspace: Seems you did not give a name to .ws'
            echom 'workspace: Your input: ' . a:2
            echom 'workspace: Here comes an example: Savews ~/my.ws' 
            echom 'workspace: But not:     Savews ~/.ws'
            echohl Normal
            return 0
          endif

          " Replace suffix:
          " change .ws to .session
          " change .ws to .viminfo (This is a must, because
          " wviminfo must create file with viminfo or .viminfo
          " as suffix from vim script.)
          let s:wk_name=strpart(fnamemodify(a:2, ":p"), 0, s:head_path_len + 1 + s:len_wsname_without_suffix) . '.session'
          let s:viminfo_name=strpart(fnamemodify(a:2, ":p"), 0, s:head_path_len + 1 + s:len_wsname_without_suffix) . '.viminfo'

          call a:1(s:wk_name, s:viminfo_name)

          return 1 
        endif
      catch
        echohl ErrorMsg
        echom 'workspace: Invalid args found [' . a:2 . '].'
        echohl Normal
        return 0
      endtry
    endif
  else
    echohl ErrorMsg
    echom 'workspace: Only accept 0 or 1 arg.'
    echohl Normal
    return 0
  endif
endfunction

function! workspace#LoadWorkspaceCore(sf, vf)
  try
    if glob(a:sf) == ""
      echohl ErrorMsg
      echom 'workspace: [' fnamemodify(a:sf, ":p") . '] not exist.'
      echom 'workspace: Do nothing.'
      echohl Normal
      return 0
    endif
    if glob(a:vf) == ""
      echohl ErrorMsg
      echom 'workspace: [' fnamemodify(a:vf, ":p") . '] not exist.'
      echom 'workspace: Do nothing.'
      echohl Normal
      return 0
    endif

    let s:cur_dir=getcwd()

    if g:wsStoreSession
      execute "silent source " . a:sf
    endif
    if g:wsStoreViminfo
      execute "rviminfo " . a:vf
    endif
    let g:wsLastWorkspaceName=fnamemodify(a:sf, ":p:r") . ".ws"

    if !g:wsSilence
      echo "workspace: Load [" . fnamemodify(a:sf, ":p") . "] sucessfully."
      echo "workspace: Load [" . fnamemodify(a:vf, ":p") . "] sucessfully."
      echo "Workspace Name:[" . g:wsLastWorkspaceName . "]"
    endif

    execute "cd " . s:cur_dir
    return 1
  catch
    echohl ErrorMsg
    echom 'workspace: Call workspace#LoadWorkspaceCore failed:'
    echom "workspace: a:sf: " . a:sf
    echom "workspace: a:vf: " . a:vf
    echohl Normal
    return 0
  endtry
endfunction

function! workspace#PromptExistedWorkspaceName()
  " If workspace.session and workspace.viminfo existed, load them directly
  " But not return.
  if glob(s:DefaultWorkspaceSessionName) != "" && glob(s:DefaultWorkspaceViminfoName) != ""

    if !g:wsSilence
      echohl WarningMsg
      echom "workspace: You have default workspace files:"
      echom 'workspace:   ' . fnamemodify(s:DefaultWorkspaceSessionName, ":p")
      echom 'workspace:   ' . fnamemodify(s:DefaultWorkspaceViminfoName, ":p")
      echom 'workspace: We will load them by default.'
      echohl Normal
    endif

    call workspace#LoadWorkspaceCore(s:DefaultWorkspaceSessionName, s:DefaultWorkspaceViminfoName)
    " call input("workspace: Press any key to continue...")
    return 1
  endif

  " Note: 
  " Following line: if there are 2342.session, xcvoui.session
  " it will return 2342 and xcvoui
  let s:SessionList=sort(map(split(globpath(".", "*.session"), "\n"), 'fnamemodify(v:val, ":r")'))
  let s:ViminfoList=sort(map(split(globpath(".", "*.viminfo"), "\n"), 'fnamemodify(v:val, ":r")'))
  let s:MatchedWorkspace=[]
  let s:WorkspaceItem=""
  let s:i=0
  let s:j=0
  if len(s:SessionList) > 0 && len(s:ViminfoList) > 0
    for s:i in range(len(s:SessionList))
      if fnamemodify(s:SessionList[s:i], ":p") != fnamemodify(s:DefaultWorkspaceSessionName, ":p")
        for s:j in range(len(s:ViminfoList))
          if s:SessionList[s:i] == s:ViminfoList[s:j]
            call add(s:MatchedWorkspace, fnamemodify(s:SessionList[s:i], ":r"))
            break
          endif
        endfor
      endif
    endfor
  endif

  if len(s:MatchedWorkspace) > 0 
    if len(s:MatchedWorkspace) == 1
      " Just load it
      call workspace#LoadWorkspaceCore(s:MatchedWorkspace[0] . ".session", s:MatchedWorkspace[0] . ".viminfo")
      return 1
    else 
      let s:loopflag=0
      while (s:loopflag != 1 )
        echom "workspace: Please input the expected workspace index you want to load:"

        " Print all existed items
        let s:i=0
        for s:i in range(len(s:MatchedWorkspace))
          echom "     [" . s:i . "] " . fnamemodify(s:MatchedWorkspace[s:i], ":p")
        endfor

        " Get user's choice
        let s:UserChoice = input("Your input(q to exit this fucntion of workspace plugin): ")

        " If this is a number
        if s:UserChoice =~# '^\d\+$' 
          echo "User choice: " . s:UserChoice
          if s:UserChoice >= 0 && s:UserChoice < len(s:MatchedWorkspace) 
            call workspace#LoadWorkspaceCore(s:MatchedWorkspace[str2nr(s:UserChoice)] . ".session", s:MatchedWorkspace[str2nr(s:UserChoice)] . ".viminfo")
            return 1
          else
            echohl WarningMsg 
            echom "workspace: Illegal input. Please try again."
            echom "workspace: Your input: " . s:UserChoice
            echohl Normal 

            continue
          endif
        else 
          if s:UserChoice == "q" || s:UserChoice == "Q"
            echom "workspace: You choose not to load vim session and viminfo files."
            return 1
          else
            echohl WarningMsg 
            echom "workspace: Illegal input. Please try again."
            echom ""
            echohl Normal 

            continue
          endif
        endif
      endwhile
    endif
  endif
  return 1
endfunction
"}}}

" Initialization: {{{
let s:DefaultWorkspaceSessionName="vim.session"
let s:DefaultWorkspaceViminfoName="vim.viminfo"

" Once execute SaveWorkspaceCore, we save the session and viminfo files name.
" in order to save them when VimLeave
let g:wsLastWorkspaceName=""

" We get all *.session and *.viminfo from current folder while VimEnter,
" Then give chance to user to select to use which one and load them.
" If only session and viminfo files with default name found or only one
" session and viminfo files found, we just load them without notification.
let s:CurPathWorkspaceNameList=[]

call workspace#InitCheck()
"}}}

" vim:foldmethod=marker:foldcolumn=4:ts=2:sw=2

