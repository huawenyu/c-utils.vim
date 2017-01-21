# tracelog.vim
use vim adding trace log to the source code

# QuickStart
Assume we now locate our source top dir.

## prepare config files
We should have a dir to hold all these files, here it's `$HOME/script/trace-wad/`:
  - files         file path list, oneline one file which are the list of all need trace file
  - func-add      function name list, oneline one function, some special function should trace but maybe dinfinition in header file
  - func-comment  function name list, oneline one function, some special function should not trace because too many called
  - logclear      remove some log line, the post process of our output log, some repeated and too verbose log we donnot need at all
  - macro-def     the trace macro
  - macro-imp     the trace macro implement

## tell tracelog.vim the path
Add the follow line to your vimrc:  
`let g:tracelog_default_dir = $HOME . "/script/trace-wad/"`

## start auto insert trace
  1. back to your source top dir, then enter vim environment: $ vi .
  2. :TraceAdd
    - insert TRACE to all function according to `files`
  3. $ cscope -Rkbq . ; ctags -R .
    - gen tags to process func-add, func-comment
  4. :TraceAdjust
    - add trace to special function according to `func-add`
    - comment trace to special function according to `func-comment`
  5. $ ./test > log.output
    - generate trace log
  6. $ vi log.output
    - :TraceLogClear
    - clear some too verbose log according to `logclear`

# Appendix
## ref
http://learnvimscriptthehardway.stevelosh.com/  
http://stevelosh.com/blog/2011/09/writing-vim-plugins/  
http://andrewscala.com/vimscript/  
http://note.axiaoxin.com/contents/vimscript-note.html  

## line wrap
As in many other languages, statements can be wrapped using a \ character. Unlike in those languages, in Vim Script it must appear at the beginning of the succeeding line:
```vimscript
if some_exceedingly_long_expression ||
   \ a_second_expression
  echo 'Success'
endif
```
## function

###function command

```vimscript
function! s:DoSomething()
  " stuff
endfunction
 
command DoSomething :call <SID>DoSomething()
nmap k :DoSomething
```
Explain:
  - A trailing ! on function enables redefinition.
  - The s: in the function definition and the <SID> in the command declaration are a thin but tenable form of namespace management.
  They’ll expand to a unique name at read time so that similarly named functions in other files are not clobbered.
  - function could be replaced equivalently with fu, fun, func, etc. This follows for all Vim commands.
  As long as a token can uniquely complete into a keyword, it is valid.

### function define
Vimscript functions must start with a capital letter if they are unscoped!

Even if you do add a scope to a function you may as well capitalize the first letter of function names anyway. Most Vimscript coders seem to do it, so don't break the convention.

Okay, let's define a function for real this time. Run the following commands:
```
:function Meow()
:  echom "Meow!"
:endfunction
```
This time Vim will happily define the function. Let's try running it:

`:call Meow()`

Vim will display Meow! as expected.

Let's try returning a value. Run the following commands:
```
:function GetMeow()
:  return "Meow String!"
:endfunction
```
Now try it out by running this command:

`:call GetMeow()`
The return value is thrown away when you use call, so this is only useful when the function has side effects.

`:echom GetMeow()`
Vim will call the function in expressions and give the result to echom, which will display Meow String!.
As we saw before, this calls GetMeow and passes the return value to echom.

`:echom Meow()`
This will display two lines: Meow! and 0. The first obviously comes from the echom inside of Meow. The second shows us that if a Vimscript function doesn't return a value, it implicitly returns 0. 

### arguments
```vimscript
:function DisplayName(name)
:  echom "Hello!  My name is:"
:  echom a:name
:endfunction
```
Run the function:

`:call DisplayName("Your Name")`

Vim will display two lines: Hello! My name is: and Your Name.
This 'a:' represents a variable scope. When you write a Vimscript function that takes arguments you always need to prefix those arguments with a: when you use them to tell Vim that they're in the argument scope.

### variable-length argument
```vimscript
:function Varg(...)
:  echom a:0
:  echom a:1
:  echo a:000
:endfunction
```
`:call Varg("a", "b")`

The ... in the function definition tells Vim that this function can take any number of arguments.
The first line of the function echoes the message a:0 and displays 2. When you define a function that takes a variable number of arguments in Vim, a:0 will be set to the number of extra arguments you were given. In this case we passed two arguments to Varg so Vim displayed 2.

The second line echoes a:1 which displays a. You can use a:1, a:2, etc to refer to each extra argument your function receives. If we had used a:2 Vim would have displayed "b".

The third line is a bit trickier. When a function has varargs, a:000 will be set to a list containing all the extra arguments that were passed. We haven't looked at lists quite yet, so don't worry about this too much. You can't use echom with a list, which is why we used echo instead for that line.

You can use varargs together with regular arguments too. Run the following commands:

```
:function Varg2(foo, ...)
:  echom a:foo
:  echom a:0
:  echom a:1
:  echo a:000
:endfunction
```
`:call Varg2("a", "b", "c")`

We can see that Vim puts "a" into the named argument a:foo, and the rest are put into the list of varargs.

### Argument's Assignment

Try running the following commands:
```vimscript
:function Assign(foo)
:  let a:foo = "Nope"
:  echom a:foo
:endfunction
```
`:call Assign("test")`
Vim will throw an error, because you can't reassign argument variables. Now run these commands:
```vimscript
:function AssignGood(foo)
:  let foo_tmp = a:foo
:  let foo_tmp = "Yep"
:  echom foo_tmp
:endfunction
```
`:call AssignGood("test")`
This time the function works, and Vim displays Yep.

