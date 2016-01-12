function! blame#GitBlameCurrent()
    execute "!git --no-pager blame -L" . (line(".") - 5) . ",+10 HEAD -- " . expand("%p")
endfunction

function! blame#SvnBlameCurrent()
    execute("!svn blame " . expand("%p") . "|sed -n '" . (line(".") - 5) . "," . (line(".") + 5)  . "p'")
endfunction

function! blame#SvnBlame()
     let line = line(".")
     setlocal nowrap
     " create a new window at the left-hand side
     aboveleft 18vnew
     " blame, ignoring white space changes
     %!svn blame -x-w "#"
     setlocal nomodified readonly buftype=nofile nowrap winwidth=1
     setlocal nonumber
     if has('&relativenumber') | setlocal norelativenumber | endif
     " return to original line
     exec "normal " . line . "G"
     " synchronize scrolling, and return to original window
     setlocal scrollbind
     wincmd p
     setlocal scrollbind
     syncbind
endfunction
