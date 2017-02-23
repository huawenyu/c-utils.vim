function! utils#IsLeftMostWindow()
    let curNr = winnr()
    wincmd h
    if winnr() == curNr
        return 1
    endif
    wincmd p " Move back.
    return 0
endfunction

" Refresh files
function! utils#RefreshWindows()
    call genutils#MarkActiveWindow()
    let act_tabnr = tabpagenr()
    let counts = 0

    for tab_nr in range(1, tabpagenr('$'))
        silent! exec tab_nr . "tabnext"

        let act_nr = winnr()
        for nr in range(1, winnr('$'))
            silent! exec nr . "wincmd w"
            if getwinvar(1, "&modifiable") == 1
                silent! e!
                let counts += 1
            endif
        endfor
        silent! exec act_nr . "wincmd w"
    endfor

    silent! exec act_tabnr . "tabnext"
    call genutils#RestoreActiveWindow()
    echom "Reload " . counts . " times!"
endfunction


function! utils#Columnline()
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
    endif
endfunction


function! utils#Declaration()
    call genutils#MarkActiveWindow()

    let l:act_nr = winnr()
    let l:have_preview = 0
    let t:x=[]
    windo call add(t:x, winnr())
    for i in t:x
        if getwinvar(i, '&previewwindow')
            let l:have_preview = 1
            break
        endif
    endfor

    if !l:have_preview
        call genutils#RestoreActiveWindow()

        wincmd l " Move right side.
        let l:preview_nr = winnr()
        if l:preview_nr != l:act_nr
            let &l:previewwindow = 1
        endif
    endif

    let oline = 0
    let winnr = genutils#GetPreviewWinnr()
    if winnr > 0
        call genutils#MoveCursorToWindow(winnr)
        let oline = line('.')
    endif

    call genutils#RestoreActiveWindow()
    execute ":ptag " . expand("<cword>")

    let winnr = genutils#GetPreviewWinnr()
    if winnr > 0
        call genutils#MoveCursorToWindow(winnr)
        let cline = line('.')
        if cline != oline
            norm zt
        endif
    endif

    call genutils#RestoreActiveWindow()
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

    let perc = line('.') * 1000 / line('$')
    if a:vsel
        let temp = @s
        norm! gv"sy
        let line_ins = "#" . perc ."% ". @s . " {{{" . "" . number . "}}}"
        let @s = temp
    else
        let line_ins = "#" . perc ."% ". expand('<cword>') . " {{{" . "" . number . "}}}"
    endif

    norm O
    let len = len(line_ins)
    execute "put =line_ins"
    call cursor(line('.'), len - 3)
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

function! utils#GetSelected(fname)
    " Why is this not a built-in Vim script function?!
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]

    let ret_str = join(lines, "\n")
    if empty(a:fname)
        return ret_str
    else
        new
        setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted
        put=ret_str
        exec 'w! '.a:fname
        q
    endif
endfunction

function! utils#AppendToFile(file, lines)
    call writefile(a:lines, a:file, "a")
endfunction
