" @orig: https://stackoverflow.com/questions/13634826/show-function-name-in-status-line
fun! statusline#GetFuncName()
    let lft = &ft
    if lft ==? "log" | return | endif

    let lnum = line(".")
    let col = col(".")
    let l:cmd = getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))
    call search("\\%" . lnum . "l" . "\\%" . col . "c")
    return substitute(l:cmd, "(.*", "()", "")
endfun

fun! statusline#GetFuncName2()
    let lft = &ft
    if lft ==? "log" | return | endif

    let res = getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bWn'))
    echohl None
    return substitute(res, "(.*", "()", "")
endfun

"Status Line
" cf the default statusline: %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
" format markers:
"   %< truncation point
"   %= split point for left and right justification
"   %m modified flag [+] (modified), [-] (unmodifiable) or nothing
"
"   %n buffer number
"   %f relative path to file
"   %r readonly flag [RO]
"   %y filetype [ruby]
"   %-35. width specification
"   %l current line number
"   %L number of lines in buffer
"   %c current column number
"   %V current virtual column number (-n), if different from %c
"   %P percentage through buffer
"   %) end of width specification
fun! statusline#simple_info()
    set laststatus=2                             " always show statusbar

    let &statusline  = '[%n] '
    let &statusline .= '%{statusline#GetFuncName2()} '
    let &statusline .= '  %f'
    let &statusline .= '%<'
    let &statusline .= '%='
    let &statusline .= '%m'

    "setlocal statusline+=%-18(%02.2c[%02.2B]L%l/%L%)\ "space
    let &statusline .= 'L%L/%l %P %02.2c[%02.2B]%y '

    "setlocal statusline+=%h%m%r%w                     " status flags
    "setlocal statusline+=\[%{strlen(&ft)?&ft:'none'}] " file type
endfun

