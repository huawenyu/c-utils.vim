" store all global UPPCASE variable

if !exists('g:BOOKMARKS')
  let g:BOOKMARKS = {}
endif

" Completion function for choosing bookmarks group
function! bookmark#BookmarkGroups(A, L, P)
  return join(sort(keys(g:BOOKMARKS)), "\n")
endfunction

function! bookmark#LoadGroup(bookmarks_groupname)
  let g:bookmarks_groupname = 'Default'
  if !empty(a:bookmarks_groupname)
    let g:bookmarks_groupname = a:bookmarks_groupname
  endif

  if !has_key(g:BOOKMARKS, a:bookmarks_groupname)
    if (a:bookmarks_groupname != 'Default')
      echom "Create bookmark group " . a:bookmarks_groupname . " succ!"
    endif
    let g:bookmarks_group = {}
    let g:BOOKMARKS[a:bookmarks_groupname] = g:bookmarks_group
  else
    if (a:bookmarks_groupname != 'Default')
      echom "Loaded bookmark group " . a:bookmarks_groupname
    endif
    let g:bookmarks_group = g:BOOKMARKS[a:bookmarks_groupname]
  endif

  call workspace#PromptExistedWorkspaceName()
endfunction

" Add the current [filename, cursor position] in g:bookmarks_group under the given
" name
function! bookmark#BookmarkSet(name)
  let file   = expand('%:p')
  let cursor = getpos('.')

  if !exists("g:bookmarks_groupname")
    echom "Please opened bookmark group first: <leader>mo"
    return
  endif

  if file != ''
    let g:bookmarks_group[a:name] = [file, cursor]
    let g:BOOKMARKS[g:bookmarks_groupname] = g:bookmarks_group
  else
    echom "No file"
  endif

  "wviminfo
  Savews
endfunction

" Delete the user-chosen bookmark
function! bookmark#DelBookmark(name)
  if !exists("g:bookmarks_groupname")
    echom "Please opened bookmark group first: <leader>mo"
    return
  endif

  if !has_key(g:bookmarks_group, a:name)
    return
  endif

  call remove(g:bookmarks_group, a:name)

  let g:BOOKMARKS[g:bookmarks_groupname] = g:bookmarks_group

  "wviminfo
  Savews
endfunction

" Go to the user-chosen bookmark
function! bookmark#GotoBookmark(name)
  if !has_key(g:bookmarks_group, a:name)
    return
  endif

  let [filename, cursor] = g:bookmarks_group[a:name]

  exe 'edit '.filename
  call setpos('.', cursor)
endfunction

function! bookmark#LongestCommonSubstring(foo, bar)
  let longest = ''
  for n in range(strlen(a:foo))
    let common = matchlist(strpart(a:foo, n) . '|' . a:bar, '\v(.+).*\|.*\1')[1]
    if strlen(common) > strlen(longest)
      let longest = common
    endif
  endfor
  return longest
endfun

" Open all bookmarks in the quickfix window
function! bookmark#ShowAll()
  if !exists("g:bookmarks_groupname")
    echom "Please opened bookmark group first: <leader>mo"
    return
  endif

  let choices = []
  let curr_dir = expand('%:p:h')
  let curr_dir0 = fnamemodify(curr_dir, ":p:~")

  for [name, place] in items(g:bookmarks_group)
    let [filename, cursor] = place
    let file0 = fnamemodify(filename, ":t")

    if filereadable(file0)
      let filename2 = file0
    else
      let file_dir0 = fnamemodify(filename, ":p:h:~") . '/'
      let common_str = bookmark#LongestCommonSubstring(curr_dir0, file_dir0)
      let common_len = strlen(common_str)
      if common_len > 2 && common_str[-1:] == '/'
        let file_start = strridx(filename, common_str)
        let curr_start = strridx(curr_dir0, common_str)
        let filename2 = curr_dir0[:(curr_start + common_len)] . filename[(file_start + common_len):]
      endif
    endif

    let filename = fnamemodify(filename2, ":p:.")
    call add(choices, {
          \ 'text':     name,
          \ 'filename': filename,
          \ 'lnum':     cursor[1],
          \ 'col':      cursor[2]
          \ })
  endfor

  call setqflist(choices)
  copen
endfunction

" Completion function for choosing bookmarks
function! bookmark#BookmarkNames(A, L, P)
  if !exists("g:bookmarks_groupname")
    echom "Please opened bookmark group first: <leader>mo"
    return
  endif

  return join(sort(keys(g:bookmarks_group)), "\n")
endfunction

