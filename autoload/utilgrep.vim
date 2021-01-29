" autocmd QuickfixCmdPost make,grep,vimgrep copen
" @param append     0 a new search,
"                   1 append-mode,
" @param sel        0 current word mode
"                   1 selected word mode
" @param dir        '' current dir
"                   "<dir>
" @param quickfix   0 output to quickfix
"                   1 output to local
function! utilgrep#Grep(append, sel, dir, quickfix, ...)
    let l:cmd = "GrepperRg"
    let l:param = ""

    " https://github.com/BurntSushi/ripgrep/issues/639
    " Q: $ rg -F "->"
    "    error: Found argument '->' which wasn't expected, or isn't valid in this context
    " A: `-F` is a flag that does not accept any arguments, as documented.
    "    The invocation rg -F "->" -- therefore doesn't really make sense. rg -F -- -> or rg -F -e -> should both work.
    "
    let l:boundry = " -F -- "

    let g:grepper.quickfix = a:quickfix
    let g:grepper.append = a:append

    let search_str = ""
    if a:sel == 1
        " when the selection is limited to within one line
        let l:sel_len = virtcol("'>") - virtcol("'<") + 1
        if l:sel_len >= 2
            let search_str = utils#GetSelected('v')
        endif
    else
        let search_str = expand('<cword>')
        let l:boundry = " -w "
    endif

    if !empty(search_str)
        "let search_str = input("Search? ", search_str)
        if exists("a:000") && !empty(a:dir)
            return l:cmd .' '. l:param . l:boundry . shellescape(search_str,1)." ".join(a:000, " "). a:dir
        else
            return l:cmd .' '. l:param . l:boundry . shellescape(search_str,1)." "
        endif
    endif
endfunction

function! utilgrep#FormatForProgram(program)
    if match(a:program, '^a(g|ck)') != -1
        let b:grepformat="%f:%l:%c:%m"
    else
        let b:grepformat="%f:%l:%m"
    endif
endfunction

function! utilgrep#_Grep(cmd, args)
    call utilgrep#FormatForProgram(g:grepprg)

    if exists(":Dispatch")
        if match(a:cmd, "^l.*") != -1
            call utilgrep#SearchWithGrep(a:cmd, a:args)
        else
            call utilgrep#SearchWithDispatch(a:cmd, a:args)
        endif
    else
        call utilgrep#SearchWithGrep(a:cmd, a:args)
    endif
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

function! utilgrep#ReplaceAll(org_str, to_str)
    if a:org_str ==# a:to_str
        echo "Same string, NOP!"
        return
    endif

    let cmd_str = ":silent !replace-str.sh ".a:org_str." ".a:to_str
    Decho cmd_str
    execute cmd_str
    "execute ':redraw!'
endfunction

