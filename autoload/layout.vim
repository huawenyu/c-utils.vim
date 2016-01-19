function! layout#DefaultLayout()
    "exec "normal mP"

    exec ':silent! grep -n -w ' . expand('<cword>') . ' *.' . expand('%:e')
    redraw!
    "exec ":silent vimgrep! /\\<" . expand('<cword>') . "\\>/\\Cgj " . expand('%:p')

    pclose
    cclose
    exec ":silent psearch " . expand('<cword>')
    wincmd H
    copen
    wincmd J
    wincmd p

    "exec "normal `P"
endfunction
