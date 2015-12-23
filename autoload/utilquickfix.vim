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
  for i in range(len(list))
    if has_key(list[i], 'bufnr')
      let list[i].filename = fnamemodify(bufname(list[i].bufnr), ':p:.')
      unlet list[i].bufnr
    endif
    let funcName = statusline#GetFuncName()
    let text = substitute(list[i].text, '^\s*\(.\{-}\)\s*$', '\1', '')
    let text = substitute(text, '^\t*\(.\{-}\)\t*$', '\1', '')
    let list[i].text = substitute(funcName, '\s*\(\w*\)\s*(.*', '<<\1>>', '') . " " . text
    silent! execute "cn"
  endfor

  call setqflist(list)
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
