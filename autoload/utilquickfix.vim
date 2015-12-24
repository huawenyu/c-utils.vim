function! utilquickfix#QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(values(buffer_numbers))
endfunction

function! utilquickfix#LocalEasyReplace()
  return "Qargs | argdo %s/\\<" . expand('<cword>') . "\\>/" . expand('<cword>') . "/gc | update"
endfunction

"" filter  :Qfilter pattern  <OR>  :Qfilter! pattern
"function! s:FilterQuickfixList(bang, pattern)
"  let cmp = a:bang ? '!~#' : '=~#'
"  call setqflist(filter(getqflist(), "bufname(v:val['bufnr']) " . cmp . " a:pattern"))
"endfunction
"command! -bang -nargs=1 -complete=file Qfilter call s:FilterQuickfixList(<bang>0, <q-args>)

function! utilquickfix#QuickFixFilter()
  execute ":copen"
  execute ":w! /tmp/vim.qfilter"
  let l:name = input('QFilter: ')
  execute ":silent !grep '" . l:name .  "' /tmp/vim.qfilter > /tmp/vim.qfilter_"
  execute ':redraw!'
  execute ':cgetfile /tmp/vim.qfilter_'
endfunction

function! utilquickfix#QuickFixFunction()
  execute "norm \<Enter>"
  execute ":copen"
  execute "norm gg\<Enter>"

  let list = getqflist()
  let new_list = filter(list, 'get(v:val, "bufnr", 0) > 0')
  "let new_list = []
  "for i in range(len(list))
  "  echom get(list[i], "bufnr", "")
  "  "echom list[i].filename
  "  if len(get(list[i], "bufnr", "")) > 2
  "    call add(new_list, list[i]
  "  endif
  "endfor
  "return

  for i in range(len(new_list))
    if has_key(new_list[i], 'bufnr')
      let new_list[i].filename = fnamemodify(bufname(new_list[i].bufnr), ':p:.')
      unlet new_list[i].bufnr
    endif

    let text = substitute(new_list[i].text, '^\s*\(.\{-}\)\s*$', '\1', '')
    let text = substitute(text, '^\t*\(.\{-}\)\t*$', '\1', '')

    execute "norm $"
    let func_name = statusline#GetFuncName()
    let funcName = func_name
    let funcName = matchstr(funcName, '\s*\(\w*\)\s*(')[:-2]

    if empty(funcName)
      let funcName = func_name
    else
      let funcName = substitute(funcName, '^\s*\(.\{-}\)\s*$', '\1', '')
      let funcName = substitute(funcName, '^\t*\(.\{-}\)\t*$', '\1', '')
    endif

    let new_list[i].text = "<<" . funcName . ">> " . text
    silent! execute "cn"
  endfor

  call setqflist(new_list)
  execute "norm `P"
endfunction

function! utilquickfix#SaveQuickFixList(fname)
  let list = getqflist()
  for i in range(len(list))
    if has_key(list[i], 'bufnr')
      let list[i].filename = fnamemodify(bufname(list[i].bufnr), ':p')
      unlet list[i].bufnr
    endif
  endfor
  let string = string(list)
  let lines = split(string, "\n")
  call writefile(lines, a:fname)
endfunction

function! utilquickfix#LoadQuickFixList(fname)
  if filereadable(a:fname)
    let lines = readfile(a:fname)
    let string = join(lines, "\n")
    call setqflist(eval(string))
  endif
endfunction
