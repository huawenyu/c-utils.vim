" ============================================================================
" File:        tracelog.vim
" Description: vim plugin to create outline by VOom.fmr1/2
" Maintainer:  Wilson Huawen Yu <wilson.yuu@gmail.com>
" Notes:       Should have a dir to hold the file name's list of the processing
" ============================================================================

"Implementation {

fun! s:PrepareFile(file)
    exec ":silent e " . a:file
    exec ":silent g/^\_s$/normal dd"
endfun

fun! s:TraceOutline()
    exec ":silent g/] Received request from client: /norm A {{{1}}}"
    exec ":silent g/ Forward response from cache:/norm A {{{2}}}"
endfun

fun! s:LogClearLines()
    let l:file = g:tracelog_default_dir . "logclear"

    if filereadable(l:file)
        let l:bufname = expand('%:p')
        "echom l:bufname

        call s:PrepareFile(l:file)
        for line in range(line("1"),line("$"))
            if !empty(getline(line))
                let l:stringcmd = ":silent g/" . getline(line) . "/normal dd"

                exec ":silent b " . l:bufname
                "echom l:stringcmd
                exec l:stringcmd
                exec ":silent b " . l:file
            endif
        endfor
    endif

    exec ":silent b " . l:bufname
    exec ':silent! %s/\(\n\n\)\n\+/\1/'

endfun

"}

"Misc {

"}


"Export {

fun! tracelog#TraceOutline()
    call s:TraceOutline()
endfun

fun! tracelog#TraceLogClear()
    call s:LogClearLines()
endfun

"}

