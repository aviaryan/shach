# Shach
 

## Overview

Building our own new language SHACH (pronounced s-aa-ch). SHACH is a simple
programming language that compiles to Bash and Windows Batch. The user can write the script
only once and can compile it in any platform. Both Bash and Batch are messy to read and tricky
to write. You have to spend a lot of time learning either of them and write platform-dependent
code for each operating system. If the user happens to be a maintainer of a cross-platform tool
which relies on Bash on Linux/Mac and Batch on Windows as "glue code", and found it painful
to simultaneously code for them, SHACH can help them in this case. SHACH is quite easy to
write, no complex syntaxes, different inbuilt functions provided for making the tasks easier and
above all you don’t have to worry about writing different codes for different platforms.
Cross-compiling is supported so that you can create bash & batch scripts from any platform,
whether it be OSX, Linux or Windows.


## Features
1. Simple syntax, inspired from C, Python, Bash and Batch.
2. Write once, use everywhere.
3. Users can also write the native bash or native batch statements by using the functions provided.
4. Different loops (like loop by directory, loop by file line) provided for handling common tasks.
5. Defining custom functions is supported.
6. Inbuilt functions provided for making frequent tasks more easier.
7. Command-line arguments supported.
8. Different variable types like string, number, bool and arrays supported.

##Compile Instructions

For Windows - 

$$ flex <file>.l
$$ bison -dy <file>.y
$$ gcc lex.yy.c y.tab.c -o <file>.exe
$$ <file>.exe

For Linux - 

$$ lex <file>.l
$$ yacc <file>.y
$$ gcc lex.yy.c y.tab.c -ll
$$ ./a.out
