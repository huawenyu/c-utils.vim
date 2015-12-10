function! verticalmove#VerticalMoveDown(down)
    let l:total_lines = line('$')
    if a:down
      let l:cursor_row = line('.') + 1
    else
      let l:cursor_row = line('.') - 1
    endif

    if exists("g:colorcolumn_col") && g:colorcolumn_col > 1
      let l:cursor_col = g:colorcolumn_col
    else
      let l:cursor_col = col('.')
    endif

    if l:cursor_col <= 1
      return
    endif

    let l:count = 0
    while l:cursor_row > 0 && l:count < 1000
      "echom "current: " . l:cursor_row . ":". l:cursor_col . " " . getline(l:cursor_row)[l:cursor_col - 1]
      ":echo strtrans(getline('.')[col('.')-1])

      let l:count += 1

      if  ( (strtrans(getline(l:cursor_row)[l:cursor_col - 2]) == ' '
        \    && strtrans(getline(l:cursor_row)[l:cursor_col - 3]) == ' ')
        \  || strtrans(getline(l:cursor_row)[l:cursor_col - 2]) == "^I")
        \ && (strtrans(getline(l:cursor_row)[l:cursor_col - 1]) != ' '
        \     && strtrans(getline(l:cursor_row)[l:cursor_col - 1]) != "^I")
        call cursor(l:cursor_row, l:cursor_col)
        return
      else
        if a:down
          let l:cursor_row += 1
        else
          let l:cursor_row -= 1
        endif
      endif
    endwhile
endfunction

