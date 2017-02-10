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

"command! -nargs=1 Function call utilquickfix#Function(<f-args>)
"function! utilquickfix#Function(name)
"  " Retrieve tags of the 'f' kind
"  let tags = taglist('^'.a:name)
"  let tags = filter(tags, 'v:val["kind"] == "f"')
"
"  " Prepare them for inserting in the quickfix window
"  let qf_taglist = []
"  for entry in tags
"    call add(qf_taglist, {
"          \ 'pattern':  entry['cmd'],
"          \ 'filename': entry['filename'],
"          \ })
"  endfor
"
"  " Place the tags in the quickfix window, if possible
"  if len(qf_taglist) > 0
"    call setqflist(qf_taglist)
"    copen
"  else
"    echo "No tags found for ".a:name
"  endif
"endfunction

function! utilquickfix#QuickFixFilter()
  execute ":copen"
  execute ":w! /tmp/vim.qfilter"
  let l:name = input('QFilter: ')
  execute ":silent !grep '" . l:name .  "' /tmp/vim.qfilter > /tmp/vim.qfilter_"
  execute ':redraw!'
  execute ':cgetfile /tmp/vim.qfilter_'
endfunction

function! utilquickfix#QuickFixFunction()
  let list = getqflist()
  if empty(list)
    return
  endif

  silent! copen
  silent! cfirst

  let new_list = filter(list, 'get(v:val, "bufnr", 0) > 0')
  for i in range(len(new_list))
    exec "cc ". (i+1)

    if has_key(new_list[i], 'type') && new_list[i].type == 'F'
      continue
    endif

    if has_key(new_list[i], 'filename') && empty(new_list[i].filename) || new_list[i].lnum == 0
      continue
    endif

    if has_key(new_list[i], 'lnum') && new_list[i].lnum == 0
      continue
    endif

    if has_key(new_list[i], 'bufnr')
      let new_list[i].filename = fnamemodify(bufname(new_list[i].bufnr), ':p:.')
      unlet new_list[i].bufnr
    else
      let new_list[i].filename = fnamemodify(new_list[i].filename, ':p:.')
    endif

    let text = substitute(new_list[i].text, '^\s*\(.\{-}\)\s*$', '\1', '')
    let text = substitute(text, '^\t*\(.\{-}\)\t*$', '\1', '')

    execute "norm $"
    let func_name = statusline#GetFuncName()
    let funcName = func_name
    let funcName = matchstr(funcName, '\s*\(\w*\)\s*(')[:-2]

    if empty(funcName)
      let funcName = func_name
    endif

    let funcName = substitute(funcName, '^\s*\(.\{-}\)\s*$', '\1', '')
    let funcName = substitute(funcName, '^\t*\(.\{-}\)\t*$', '\1', '')

    let new_list[i].text = "<<" . funcName . ">> " . text
    let new_list[i].type = "F"
  endfor

  "let w:quickfix_title = len(new_list)
  call setqflist(new_list, 'r')
  execute "norm `P"
endfunction

function! utilquickfix#Complete(A, L, P)
  if filereadable(g:utilquickfix_file)
    let lines = readfile(g:utilquickfix_file)
    let string = join(lines, "\n")
    let key_value = eval(string)
    return join(sort(keys(key_value)), "\n")
  else
    return ""
  endif
endfunction

function! utilquickfix#SaveQuickFixList(fname)
  if filereadable(g:utilquickfix_file)
    let lines = readfile(g:utilquickfix_file)
    let string = join(lines, "\n")
    let key_value = eval(string)
  else
    let key_value = {}
  endif

  let list = getqflist()
  for i in range(len(list))
    if has_key(list[i], 'bufnr')
      let list[i].filename = fnamemodify(bufname(list[i].bufnr), ':p')
      unlet list[i].bufnr
    endif
    let list[i].valid = 3
  endfor

  let key_value[a:fname] = list
  let string = string(key_value)
  let lines = split(string, "\n")
  call writefile(lines, g:utilquickfix_file)

endfunction

function! utilquickfix#LoadQuickFixList(fname)
  if filereadable(g:utilquickfix_file)
    let lines = readfile(g:utilquickfix_file)
    let string = join(lines, "\n")
    let key_value = eval(string)
    if has_key(key_value, a:fname)
      let list = key_value[a:fname]

      for i in range(len(list))
        if has_key(list[i], 'filename')
          let list[i].filename = fnamemodify(list[i].filename, ':p:.')
        endif
      endfor

      call setqflist(list, 'r')
      let w_qf = genutils#GetQuickfixWinnr()
      if w_qf == 0
        call genutils#MarkActiveWindow()
        copen
        call genutils#RestoreActiveWindow()
      endif

      let w_qf = genutils#GetQuickfixWinnr()
      if w_qf > 0
        call genutils#MarkActiveWindow()
        call genutils#MoveCursorToWindow(w_qf)
        let w:quickfix_title = a:fname
        call genutils#RestoreActiveWindow()
      endif

    endif
  endif
endfunction

function! utilquickfix#RelativePath()
    let list = getqflist()
    for i in range(len(list))
        if has_key(list[i], 'bufnr')
            let list[i].filename = fnamemodify(bufname(list[i].bufnr), ':p:.')
            unlet list[i].bufnr
        else
            let list[i].filename = fnamemodify(list[i].filename, ':p:.')
        endif
    endfor
    call setqflist(list)
endfunction

function! s:CompareQuickfixEntries(i1, i2)
    if bufname(a:i1.bufnr) == bufname(a:i2.bufnr)
        return a:i1.lnum == a:i2.lnum ? 0 : (a:i1.lnum < a:i2.lnum ? -1 : 1)
    else
        return bufname(a:i1.bufnr) < bufname(a:i2.bufnr) ? -1 : 1
    endif
endfunction

function! utilquickfix#SortUniqQFList()
    let sortedList = sort(getqflist(), 's:CompareQuickfixEntries')
    let uniqedList = []
    let last = ''
    for item in sortedList
        let this = bufname(item.bufnr) . "\t" . item.lnum
        if this !=# last
            call add(uniqedList, item)
            let last = this
        endif
    endfor
    call setqflist(uniqedList)
endfunction


