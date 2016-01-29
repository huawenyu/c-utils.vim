function! layout#DefaultLayout()
    pclose
    cclose
    pedit %
    wincmd H
    copen
    wincmd J
    wincmd p
endfunction
