function! layout#DefaultLayout()
    exec "normal mP"

    exec ':silent! grep -n -w ' . expand('<cword>') . ' *.' . expand('%:e')
    exec ':redraw!'
    "exec ":silent vimgrep! /\\<" . expand('<cword>') . "\\>/\\Cgj " . expand('%:p')

    exec ":silent pclose"
    exec ":silent cclose"
    exec ":silent psearch " . expand('<cword>')
    exec "normal \<C-W>H"
    exec ":silent copen"
    exec "normal \<C-W>J"
    exec "normal \<C-W>k"

    exec "normal `P"
endfunction
