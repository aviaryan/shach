# Shach Final Report

![Builds Passing](https://img.shields.io/badge/builds-passing-brightgreen.svg)
![Open Source](https://img.shields.io/badge/open-source-blue.svg)

Shach is a simple programming language that can compile to both Bash and Windows Batch.
The user will write the shach script (`.shach`) only once and compile it in any platform to generate
a `.sh` or a `.bat` file or both.


## Table of Contents

* [Motivation](#mvn)
* [Project Development](#dev)
	* [Lex Phase](#lexph)
	* [Shach Semantics Phase](#intsem)
	* [Final Phase](#finalph)
* [Manual](#manual)
	* [Variables](#vars)
	* [Expressions](#exps)
	* [Conditions](#conds)
	* [Loops](#loops)
	* [Functions](#func)
	* [Blocks](#blocks)
	* [Native commands](#native)
	* [Inbuilt functions](#inbuilt)
* [Sample Code](#ex)
* [Building](#build)
* [Problems Faced](#problems)
* [Future Scope](#future)
* [Team](#team)


<a name="mvn"></a>
## Motivation

Both bash and batch are tedious to write. You have to spend a lot of time to 
learn either of them and writing a platform-dependent code for the respective 
Operating System. If the user happens to be a maintainer of a cross-platform 
tool which relies on Bash on Linux/Mac and Batch on Windows as "glue code", 
simultaneously writing code for both of them can be really painful.

Shach comes to your rescue here. Shach is quite easy to write, no complex syntaxes,
different inbuilt functions provided for making the tasks easier and above all you
don’t have to worry about writing different codes for different platforms. 
Cross-compiling is supported so that you can create bash & batch scripts from any
platform, whether it be OSX, Linux or Windows.


<a name="dev"></a>
## Project Development

In the Lex Phase, the team agreed upon what keywords we were going to use for Shach 
and also developed a parser for the statements of the language and formulated the 
grammar. we also formulated test cases in this phase.

In the Intermediate Semantics Phase we developed the symantics of shach and tested 
them rigourously against unit test cases.

In the Final phase, we tested against the the complete Shach programs we had generated
in the lex phase. Also, we incorporated the code to generate .sh and .bat files upon 
compilation.


<a name="lexph"></a>
### Lex Phase

Shach is a case sensitive language. Its keywords are:

```
#BEGIN, #END, UX, WN, RAWUX, RAWWN, return, call, rawbash, rawbatch, bash, batch, 
loadenv, break, continue, if, else, elif, func, in, for, xxx, while 		
```

The tokens of the Shach grammar are:

```
NUMBER, ID, FUNC_NAME, COMMAND, RETURN, CALL, SCAN, PRINT, ISFILE, ISDIR, EXISTS, RAWBASH, 		
RAWBATCH, BASH, BATCH, NL, TEXT, BREAK, CONTINUE, BEGIN_UX, END_UX, BEGIN_WN, END_WN, IF, 
ELSE, ELIF, FUNC, IN, FOR, WHILE, READFILE, DIR, ARRLEN, STRLEN, LOADENV, NEGATIVE_NUM, 
STR, POWER, EOFL, CONCAT, GTEQ, LTEQ, NOTEQ, EQCOND, LOGAND, LOGOR, INVALID, RAW_UX, RAW_WN
```

The grammar of Shach is:

```yacc
program : nlLoop statements EOFL 

statements : functionDeclaration nlLoopPlus statements
        | statement nlLoopPlus statements 
        | null

mainStatements : statement nlLoopPlus mainStatements 
        | null
        
statement : variableAssignment  
        | conditionalStatement  
        | functionCall  
        | loopStatement  
        | uxBlockStatement  
        | winBlockStatement  
        | commandStatement  
        | commentStatement  
        | rawStatementBlock  
        
variableAssignment : allVar '=' allExpr 

conditionalStatement : IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  
        | IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}' ELSE '{' nlLoopPlus mainStatements '}'  
        | IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  elif_st  ELSE '{' nlLoopPlus mainStatement '}'        
commandStatement : COMMAND 

elif_st : ELIF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  

conditionalFuncStatement : IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' 
        | IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' ELSE '{' nlLoopPlus funcStatements '}' 
        | IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}'  elif_func_st  ELSE '{' nlLoopPlus funcStatements '}' 

elif_func_st : ELIF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' 

conditionalLoopStatement : IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' 
        | IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' ELSE '{' nlLoopPlus loopStatements '}' 
        | IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}'  elif_loop_st  ELSE '{' nlLoopPlus loopStatements '}' 

elif_loop_st : ELIF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' 

loopStatement : forLoop  
        | whileLoop  
        | forLine  
        | forDir  

nlLoopPlus : NL nlLoop

nlLoop : NL nlLoop
        | null

loopStatements : statement nlLoopPlus loopStatements 
        | conditionalLoopStatement nlLoopPlus loopStatements 
        | BREAK nlLoopPlus 
        | CONTINUE nlLoopPlus 
        | null

whileLoop : WHILE '(' conditionList ')' '{' nlLoopPlus loopStatements '}'  

forLoop : FOR var IN '(' NUMBER ',' NUMBER ',' NUMBER  ')' '{' nlLoopPlus loopStatements '}'  

forLine : FOR var IN READFILE '(' strVal ')' '{' nlLoopPlus loopStatements '}'  

forDir : FOR var IN DIR '(' strVal ')' '{' nlLoopPlus loopStatements '}'  

commentStatement : "#" TEXT

funcStatements : statement nlLoopPlus funcStatements 
        | conditionalFuncStatement nlLoopPlus funcStatements 
        | retStatement nlLoopPlus 
        | null
        
functionDeclaration : FUNC FUNC_NAME '(' universalIdList ')' '{' nlLoopPlus funcStatements '}' 

retStatement : RETURN '(' allVals ')' 
        | RETURN  
        
functionCall : inbuiltFunc '(' paramList ')'
        | PRINT '(' paramList ')' 
        | SCAN '(' paramList ')' 
        | RAWBASH '(' paramList ')' 
        | RAWBATCH '(' paramList ')' 
        | BASH '(' paramList ')'
        | BATCH '(' paramList ')' 
        | FUNC_NAME '(' paramList ')'
        | FUNC_NAME '(' ')'

inbuiltFunc : CALL 
        | ISFILE 
        | ISDIR 
        | EXISTS 
        | LOADENV 
        | STRLEN 
        | ARRLEN 
        
uxBlockStatement : BEGIN_UX nlLoopPlus statements END_UX 

winBlockStatement : BEGIN_WN nlLoopPlus statements END_WN 

rawStatementBlock : RAW_UX 
        | RAW_WN 

expr : id1 '+' expr  
        | id1 '-' expr  
        | id1  

id1 : id2 '*' id1  
        | id2  

id2 : id2 '/' id3  
        | id3  

id3 : '(' expr ')'  
        | numVal  
    

stringExpr : strVal 
        | strVal CONCAT stringExpr

arrayExpr : '{' varList '}' 
        | '[' ']'
        
conditionList : condition LOGAND conditionList 
        | condition LOGOR conditionList 
        | condition  
        
condition : expr '<' expr
        | expr '>' expr 
        | expr LTEQ expr 
        | expr GTEQ expr 
        | expr NOTEQ expr 
        | expr EQCOND expr 
        | stringExpr EQCOND stringExpr 
        | stringExpr NOTEQ stringExpr 
        | functionCall

paramList : allExpr ',' paramList  
        | allExpr  
        
idList : var ',' idList
        | var  

universalIdList: idList  
        | null

varList : allVals ',' varList 
        | allVals
        
var :    ID 

allVar : var  
        | var '[' positiveNum ']'
        
string : STR { $$ = $1; dataType=1; }
        
num :  positiveNum  { $$ = $1; dataType=0; }
        | negativeNum { $$ = $1; dataType=0; }
        
positiveNum : NUMBER  
        
negativeNum : NEGATIVE_NUM   
        
numVal : allVar  
        | num  
        
strVal : allVar  
        | string  
        
vals : num  
        | string  
        | functionCall  

allVals : vals  
        | allVar  

allExpr : expr  
        | stringExpr  
        | arrayExpr  
        | functionCall  
```


<a name="intsem"></a>
### Intermediate Semantics Phase

Different Semantic Rules were written in the yacc file in this phase. These were some intermediate semantics that were written to test that the our semantic is accessing all the grammer variables properly or not. Example of the written semantics is :

```
program : nlLoop statements EOFL { 
            printf("\nVALID_CODE");
            printf("<< %s >>", $2);
            return 0; 
        }
        ;
statements : functionDeclaration nlLoopPlus statements { sprintf($$, "%s\n%s", $1, $3); }
        | statement nlLoopPlus statements { sprintf($$, "%s\n%s", $1, $3); }
        | { $$ = ""; }
        ;
```

By using this, different grammer non-terminals were assigned the values and it was tested by printing the output values to the console. Every grammer variable was checked for its value and then we moved on to the Final Phase.

#### Test Cases

We used TravisCI to continuously test if our grammar was correctly recognizing the tokens or not. 
For that we used 2 types of tests, `test` and `anti-test`. As the name suggest, all `test` files should be 
correctly recognized by our grammar whereas `anti-test` should be discarded by our grammar.


<a name="finalph"></a>
### Final Phase

In this phase after testing the intermediate sematic rules, we moved on to the actual semantics that was written to convert the shach code into corresponding bash and batch codes. First the user is asked to provide a input that he wants a batch or a bash file based on the OS he is working on. After this, if the user wants the code to be in a bash file, then a variable called compileBash is set to true otherwise false. And then accordingly the semantics are performed for bash and batch and a string buffer is passed for genrating the output file. Example of the final semantic rules is :

```
conditionalStatement : IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  { 
            char * s = malloc(lstr2($3, $7));
            if (compileBash){
                sprintf(s, "if (( %s ))\nthen\n%sfi", $3, $7); $$ = s;
            } else {
                sprintf(s, "if %s (\n%s)", $3, $7); $$ = s;
            }
        }
```

Finally an output file is generated accordingly, based on the user's input for bash or batch.

<a name="manual"></a>
## Manual

Shach syntax is pretty much inspired from bash's expect that it is more human friendly and intuitive. 
This section will cover concepts about how to write code in Shach. 
The file extension for Shach files is `.shach`. All `.shach` files must end with `xxx` (it is the temporary EOF we are using as Shach is highly experimental 
and this helps debugging.)

<a name="vars"></a>
### Variables

Variables in Shach are preceeded by a dollar `$`, everywhere.

```sh
$intVar = 2
$stringVar = "abcd"
$anotherVar = $stringVar
```

<a name="exps"></a>
### Expressions

Expressions in Shach have been inspired from C and are very intuitive.

```sh
$intVar = 2 + (2 * 5)
$string = "abcd" ++ "another string"
$int = 4 - 2
$intVar = $intVar * (6 - $int)
$string = "abcd" ++ $string
```

**Note** - For string concat, we have `++` operator.

**Bool** - Like bash and batch, there is no bool type in Shach. If you are looking for a bool like behavior, feel free to use the `int` or `string` type.



<a name="conds"></a>
### Conditions

Shach supports if, else and elif condition expressions. The syntax is inspired from C/JavaScript.
Example -

```
$in = 4
if ($in > 2){
	$s = "${in} is more than 2"
} elif ($in < 2) {
	$s = "${in} is less than 2"
} else {
	$s = "same as 2"
}
```


<a name="loops"></a>
### Loops

Shach supports four types of loops.

1. for range loop
2. while loop
3. for file in directory loop
4. for line in file loop


#### for range loop

It takes 3 parameters which are (START, END, INCREMENT).

```sh
for $v in (1,10,3){
  print("current loop count is ${v}")
}
```

#### while loop

While loop is same as C's while loop.

```sh
$v = 0
while ($v < 10){
	$v = $v + 1
	print("loop running")
}
```

#### for file in directory loop

This loop reads the list of files in a directory. The text inside `dir(..)` below corresponds to directory path.

```sh
for $a in dir("path/to/directory"){
    print("Found file/folder ${a}")
}
```

#### for line in file loop

This loops reads a file, line by line. The text inside `file(...)` corresponds to file to read.

```sh
for $p in file("path/to/filename") {
	print("Found file ${p}")
}
```

<a name="func"></a>
### Functions

Shach supports functions like bash and batch and follows a similar style.
Functions can have any number of parameters and they need not to be defined in the function declaration.
Return data of function is passed to a global variable which can be used anywhere in the code.

Here is an example of function declaration.

```sh
func add($retVar){
	$sum = $1 + $2
	return($sum)
}
```

Here `$1`, `$2` are the parameters passed when calling the function. The `$retVal` seen above is actually the variable which will contain the final answer 
after the function executes.

To call this function, we do -

```sh
add($myVar, 2, 4)
print("the sum of 2 and 4 is ${myVar}")
```

All functions in Shach must define a return variable and a return statement. This has been done to promote good coding habits that is every routine should 
atleast return its success/failure status.


<a name="blocks"></a>
### Blocks

Shach has the concept of blocks to output code only in bash or batch file. This can be used if you are writing platform-dependent codes. 

We have two class of blocks. Raw and non-raw. 

Raw blocks are written in bash or batch depending on the target platform. Example of it is as following

```sh
#BEGIN RAWUX
s=2
t="This is unix"
#END RAWUX

#BEGIN RAWWN
set s=2
set s=this is windows
#END RAWWN
```

Non-Raw blocks are written in Shach's language but they compile into Unix or Windows only, depending on the header.

```sh
#BEGIN WN
$v = 2
print("win ${v}")
#END WN

#BEGIN UX
$v = 3
print("unix ${v}")
#END UX

$a = "this is present in both places"
```

<a name="native"></a>
### Native commands

Shach can also run native commands in bash and batch. Example of a native command is `gcc prog.c`.

```sh
~ gcc prog.c
```

It can also support Shach-like variables. Example -

```sh
~ go run $var
```


<a name="inbuilt"></a>
### Inbuilt functions

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.


<a name="ex"></a>
## Sample Code

Different sample codes that can be written in our language Shach are : 

1. Code for Squaring the numbers.
```
for $v in (1,3,10){
  $var=$v*$v
  print("Sqaure of ${v} is ${var}")
}

xxx
```

2. Code for generating Fibonacci Series.

```
$t1 = 0
$t2 = 1
$nextTerm = 0
print("Enter the number of terms: ")
scan($var)
print("Fibonacci Series: ")
for $v in (1,1,10){
  if($v==1){
    print("${t1}")
    continue 
  }
  if($v==2){
    print("${t2}")
    continue 
  }
  $nextTerm = $t1+$t2
  $t1=$t2
  $t2=$nextTerm
  print("${nextTerm}")
}
xxx
```

<a name="build"></a>
## Building/Compiling

On a Unix computer, run the following commands to build this project.

```sh
flex project.lex
yacc -d project.yacc
gcc lex.yy.c y.tab.c -ll -ly
```

One can also use the shortcut command which is 

```sh
make build
```

Once build is done, `a.out` file will be generated. Run it as follows -

```sh
./a.out < input_file.shach
# OR ./a.out bash < input_file.shach
```

The above command will take `input_file.shach` as the input source code and will create the output bash file called `output.sh` in the same directory. 
To run the bash code, do - 

```sh
bash output.sh
```

To generate batch code, run the following.

```sh
./a.out batch < input_file.shach
```

The above command will generate batch code in `output.bat` file.

When `a.out` is run, it prints the list of found tokens in the terminal. This was added for debugging purposes and will be removed later with a stable release.


<a name="problems"></a>
## Problems Faced

Since it was our first experience designing a compiler, we encountered many challenges. Intially, our code failed to parse the language, debugging that much big code proved to be a herculean task. Many a times it was hard to determine why the desired regex was not getting matched by the sample code. Later we manifested it by integration tests that passes for the pieces of code. We also had a bad time bridging the gap between bash and batch. There we have some functionalties which were only one way round supported by either bash or batch but not both.Here, we came up with the idea of UX and WN commands where the particular commands in the blocks will be executed only for the respective OS. It took us a long time to figure out the way to handle such cases and implement the cumbersome syntax for the output scripts. During semantics we ran into segmentation fault, bus errors and function declartion problems.


<a name="future"></a>
## Future Scope

The development of this language surely prompts many new areas of improvements. 
This project does not covers all functionalities related to bash and batch scripts. 
It would have great to implement that provided we’d enough time. 
Though it suceesfully meets the main objective which was to make a platform independent and easy to write progamming language.

For further improvements we would like to implement all the remaining functionalites. 

Also the current error handling only tell the user about error,does not suggest the user what needs to be done. 
We would like to implement auto suggesting feature in case of errors.

Further we would like to make a web service for this, which would let the user to compile and genrate the bash and the batch scripts online. 


<a name="team"></a>
## Team

[![Avi Aryan](https://avatars0.githubusercontent.com/u/4047597?v=3&s=130)](http://aviaryan.in) | [![Saurabh Jain](https://avatars3.githubusercontent.com/u/9781788?v=3&s=130)](https://github.com/saurabhjn76) | [![Charu Chhimpa](https://avatars3.githubusercontent.com/u/17537890?v=3&s=130)](https://github.com/CharuChhimpa) | [![Sagrika Rastogi](https://avatars3.githubusercontent.com/u/17158526?v=3&s=130)](https://github.com/Sagrika-Rastogi) | [![Harshit Purohit](https://avatars2.githubusercontent.com/u/10785498?v=3&s=130)](https://github.com/hrshtpurohit)
---|---|---|---|---
[Avi Aryan](http://aviaryan.in) | [Saurabh Jain](https://github.com/saurabhjn76) | [Charu Chhimpa](https://github.com/CharuChhimpa) | [Sagrika Rastogi](https://github.com/Sagrika-Rastogi) | [Harshit Purohit](https://github.com/hrshtpurohit)
