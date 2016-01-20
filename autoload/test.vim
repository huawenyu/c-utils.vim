function test#Varg2(foo, ...)
  echom a:foo

  echom "a:0 exists=" . exists("a:0")
  echom a:0

  echom "a:1 exists=" . exists("a:1")
  echom a:1

  echom "a:000 exists=" . exists("a:000")
  echo a:000
endfunction
