" ============================================================================
" File:        bookmark.vim
" Description: the wrapper of autoload
" ============================================================================

"Init {
if exists('g:loaded_c_utils_bookmark')
    finish
endif

if &cp || v:version < 700
    echom 'Please use the new vim version > 700'
    finish
endif

let g:loaded_c_utils_bookmark = 1
"}

"Misc
command! -nargs=1 -complete=custom,bookmark#BookmarkGroups BookmarkLoad call bookmark#LoadGroup(<f-args>)
command! BookmarkShowAll call bookmark#ShowAll()
command! -nargs=1 BookmarkSet call bookmark#BookmarkSet(<f-args>)
command! -nargs=1 -complete=custom,bookmark#BookmarkNames  BookmarkGoto call bookmark#GotoBookmark(<f-args>)
command! -nargs=1 -complete=custom,bookmark#BookmarkNames  BookmarkDel  call bookmark#DelBookmark(<f-args>)
