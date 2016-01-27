function test#Arg(foo, ...)
  echo "first arg=" . a:foo

  if exists("a:0")
    echo "a:0 as args-count exists and eq " . a:0
  else
    echo "a:0 as args-count not exists"
  endif

  if exists("a:1")
    echo "a:1 exists and eq " . a:1
  else
    echo "a:1 not exists"
  endif

  if exists("a:000")
    echo "a:000 exists and eq " . string(a:000)
  else
    echo "a:000 not exists"
  endif
endfunction
